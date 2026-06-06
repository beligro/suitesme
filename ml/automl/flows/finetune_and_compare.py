"""
Fine-tune current production model on the verified-from-db dataset,
then compare with the original production model and deploy if better.

Steps:
  1. Download verified-from-db dataset from MinIO to temp dir
  2. Fine-tune production model on train split
  3. Validate on test split
  4. Compare accuracy with current production model
  5. Deploy if accuracy improved, report results either way
"""

import os
import shutil
import tempfile
import json
from datetime import datetime
from typing import Dict, Any, Optional
from io import BytesIO

from prefect import flow, task, get_run_logger
from minio import Minio
from minio.error import S3Error

from tasks.data_collection import connect_to_minio
from tasks.model_training import train_model, validate_trained_model, upload_model_to_minio
from tasks.model_deployment import (
    get_production_model_info,
    update_production_pointer,
    update_latest_checkpoint,
    emit_deployment_event
)
from config import settings
from config.training_config import training_config


# ──────────────────────────────────────────────────────────────────────────────
# Helper task: download a dataset by its full MinIO prefix
# ──────────────────────────────────────────────────────────────────────────────

@task(name="download_dataset_by_path")
def download_dataset_by_path(
    minio_client: Minio,
    dataset_prefix: str,   # e.g. "datasets/verified-from-db/2026-03"
    local_dir: str
) -> str:
    """
    Download an arbitrary dataset from MinIO to a local directory.
    Preserves the split/class/file structure.

    Returns:
        Path to downloaded dataset root directory.
    """
    logger = get_run_logger()
    bucket = settings.minio.ml_artifacts_bucket

    local_dataset_path = os.path.join(local_dir, "dataset")
    os.makedirs(local_dataset_path, exist_ok=True)

    logger.info(f"Downloading dataset: {dataset_prefix}")

    objects = minio_client.list_objects(bucket, prefix=dataset_prefix, recursive=True)
    downloaded = 0
    for obj in objects:
        if obj.is_dir:
            continue
        rel = obj.object_name[len(dataset_prefix):].lstrip("/")
        if not rel:
            continue

        # Truncate overly long filenames
        parts = rel.split("/")
        fname = parts[-1]
        if len(fname) > 100:
            import hashlib
            name, ext = os.path.splitext(fname)
            h = hashlib.md5(fname.encode()).hexdigest()[:8]
            fname = f"{name[:80]}_{h}{ext}"
            parts[-1] = fname
            rel = "/".join(parts)

        local_path = os.path.join(local_dataset_path, rel)
        os.makedirs(os.path.dirname(local_path), exist_ok=True)
        minio_client.fget_object(bucket, obj.object_name, local_path)
        downloaded += 1

    logger.info(f"✓ Downloaded {downloaded} files to {local_dataset_path}")
    return local_dataset_path


# ──────────────────────────────────────────────────────────────────────────────
# Main flow
# ──────────────────────────────────────────────────────────────────────────────

@flow(name="finetune_and_compare", log_prints=True)
def finetune_and_compare_flow(
    dataset_version: str = "2026-03",
    training_mode: str = "local",
    num_epochs: int = 15,
    learning_rate: float = 0.0001,
    early_stopping_patience: int = 3,
    auto_deploy: bool = False   # Safety: never deploy automatically, require manual approval
) -> Dict[str, Any]:
    """
    Fine-tune the current production model on the verified-from-db dataset,
    then compare and optionally deploy the result.

    Args:
        dataset_version: Version suffix, e.g. '2026-03'
        training_mode:   'local' or 'yandex_cloud'
    """
    logger = get_run_logger()
    start_time = datetime.now()

    dataset_prefix = f"datasets/verified-from-db/{dataset_version}"

    logger.info("=" * 80)
    logger.info("FINETUNE & COMPARE FLOW")
    logger.info(f"Dataset : {dataset_prefix}")
    logger.info(f"Mode    : {training_mode}")
    logger.info("=" * 80)

    minio_client = connect_to_minio()

    # ── 1. Verify dataset exists ───────────────────────────────────────────────
    bucket = settings.minio.ml_artifacts_bucket
    manifest_path = f"{dataset_prefix}/manifest.json"
    try:
        resp = minio_client.get_object(bucket, manifest_path)
        manifest = json.loads(resp.read())
        resp.close(); resp.release_conn()
        logger.info(f"✓ Dataset manifest found: {manifest.get('total_images', '?')} images")
    except S3Error:
        logger.error(f"Dataset not found: {dataset_prefix}")
        return {"status": "error", "message": f"Dataset not found: {dataset_prefix}"}

    # ── 2. Get current production accuracy (baseline) ─────────────────────────
    logger.info("\n── Baseline: current production model ──")
    production_info = get_production_model_info(minio_client)
    production_accuracy = (
        production_info.get("metrics", {}).get("test_accuracy", 0.0)
        if production_info else 0.0
    )
    production_version = production_info.get("version", "none") if production_info else "none"
    logger.info(f"  Production model : {production_version}")
    logger.info(f"  Production acc   : {production_accuracy:.2f}%")

    # ── 3. Download dataset ────────────────────────────────────────────────────
    logger.info("\n── Step 1: Downloading dataset ──")
    temp_dir = tempfile.mkdtemp(prefix="finetune_")
    try:
        dataset_path = download_dataset_by_path(minio_client, dataset_prefix, temp_dir)

        # ── 4. Fine-tune ───────────────────────────────────────────────────────
        logger.info("\n── Step 2: Fine-tuning model ──")
        logger.info(f"  epochs={num_epochs}, lr={learning_rate}, patience={early_stopping_patience}")
        # Override training config for this run
        training_config.num_epochs = num_epochs
        training_config.learning_rate = learning_rate
        training_config.early_stopping_patience = early_stopping_patience
        training_results = train_model(dataset_path, training_mode)

        if training_results.get("status") == "error":
            logger.error(f"Training failed: {training_results.get('message')}")
            return {
                "status": "error",
                "message": training_results.get("message"),
                "production_accuracy": production_accuracy,
            }

        logger.info(f"✓ Training done. Best val accuracy: {training_results.get('best_val_accuracy', 0):.2f}%")

        # ── 5. Validate on test split ──────────────────────────────────────────
        logger.info("\n── Step 3: Validating on test split ──")
        test_dir = os.path.join(dataset_path, "test")
        if not os.path.exists(test_dir):
            logger.warning("No 'test' split found in dataset, skipping validation")
            val_metrics = {"status": "skipped", "test_accuracy": 0.0}
        else:
            val_metrics = validate_trained_model(
                training_results["model_path"],
                training_results["centroids_path"],
                test_dir
            )

        new_accuracy = val_metrics.get("test_accuracy", 0.0)
        logger.info(f"✓ Test accuracy: {new_accuracy:.2f}%")

        # ── 6. Compare ─────────────────────────────────────────────────────────
        logger.info("\n── Step 4: Comparing with production ──")
        improvement = new_accuracy - production_accuracy
        threshold = training_config.min_accuracy_improvement * 100  # convert to %
        should_deploy = improvement > threshold

        logger.info(f"  New model      : {new_accuracy:.2f}%")
        logger.info(f"  Production     : {production_accuracy:.2f}%")
        logger.info(f"  Improvement    : {improvement:+.2f}%")
        logger.info(f"  Threshold      : +{threshold:.2f}%")
        logger.info(f"  Deploy?        : {'YES ✓' if should_deploy else 'NO ✗'}")

        # ── 7. Upload checkpoint ───────────────────────────────────────────────
        logger.info("\n── Step 5: Uploading new checkpoint ──")
        year, month = int(dataset_version.split("-")[0]), int(dataset_version.split("-")[1])
        metadata = {
            "dataset_type": "verified-from-db",
            "dataset_version": dataset_version,
            "training_mode": training_mode,
            "training_date": datetime.now().isoformat(),
            "training_duration": training_results.get("training_duration", 0),
            "metrics": val_metrics,
            "finetuned_from": production_version,
            "training_config": {
                "model_type": training_config.model_type,
                "hidden_dim": training_config.hidden_dim,
                "dropout_prob": training_config.dropout_prob,
                "batch_size": training_config.batch_size,
                "learning_rate": training_config.learning_rate,
                "num_epochs": training_config.num_epochs,
            },
        }
        upload_ok, new_version, checkpoint_path = upload_model_to_minio(
            minio_client,
            training_results["model_path"],
            training_results["centroids_path"],
            metadata,
            year,
            month
        )
        if not upload_ok:
            logger.error("Failed to upload new checkpoint")
            return {"status": "error", "message": "Upload failed"}

        logger.info(f"✓ Checkpoint saved: {new_version}")

        # ── 8. Deploy decision ─────────────────────────────────────────────────
        deployed = False
        if not should_deploy:
            reason = (
                f"New model does NOT beat production "
                f"({improvement:+.2f}% vs threshold +{threshold:.2f}%)"
            )
            logger.info(f"\n── Step 6: Skipping deploy ──")
            logger.info(f"  {reason}")
        elif not auto_deploy:
            logger.info("\n── Step 6: DEPLOY SKIPPED — manual approval required ──")
            logger.info(f"  New model is better by {improvement:+.2f}% ({new_accuracy:.2f}% vs {production_accuracy:.2f}%)")
            logger.info(f"  Checkpoint saved: {new_version}")
            logger.info(f"  To deploy manually run:")
            logger.info(f"    python -m flows.finetune_and_compare deploy {new_version}")
            logger.info(f"  Or use deploy_approved_model_flow(version='{new_version}')")
            reason = f"Awaiting manual approval (auto_deploy=False)"
        else:
            logger.info("\n── Step 6: Deploying new model ──")
            reason = (
                f"Fine-tuned model improves accuracy by {improvement:+.2f}% "
                f"({production_accuracy:.2f}% → {new_accuracy:.2f}%)"
            )
            deployment_metadata = {
                "dataset_type": "verified-from-db",
                "metrics": val_metrics,
                "deployment_reason": reason,
                "training_date": datetime.now().isoformat(),
                "training_duration": training_results.get("training_duration", 0),
                "finetuned_from": production_version,
            }
            ptr_ok = update_production_pointer(
                minio_client, new_version, checkpoint_path, deployment_metadata
            )
            lat_ok = update_latest_checkpoint(minio_client, new_version)
            emit_deployment_event(new_version, val_metrics, reason, "verified-from-db")
            deployed = ptr_ok and lat_ok
            if deployed:
                logger.info(f"✓ New model deployed: {new_version}")
                logger.info("  ModelManager will reload within ~5 minutes")
            else:
                logger.error("Deployment steps failed (pointer/latest update)")

        # ── 9. Summary ─────────────────────────────────────────────────────────
        duration = (datetime.now() - start_time).total_seconds()
        logger.info("\n" + "=" * 80)
        logger.info("FLOW COMPLETE")
        logger.info(f"  Duration             : {duration:.1f}s ({duration/60:.1f} min)")
        logger.info(f"  New model version    : {new_version}")
        logger.info(f"  New model accuracy   : {new_accuracy:.2f}%")
        logger.info(f"  Production accuracy  : {production_accuracy:.2f}%")
        logger.info(f"  Improvement          : {improvement:+.2f}%")
        logger.info(f"  Beats production     : {should_deploy}")
        logger.info(f"  Deployed             : {deployed}")
        if should_deploy and not deployed and not auto_deploy:
            logger.info(f"  ⚠️  Awaiting manual approval before deploy")
            logger.info(f"  Run to deploy: python -m flows.finetune_and_compare deploy {new_version}")
        logger.info("=" * 80)

        return {
            "status": "success",
            "new_version": new_version,
            "new_accuracy": new_accuracy,
            "production_accuracy": production_accuracy,
            "improvement": improvement,
            "beats_production": should_deploy,
            "deployed": deployed,
            "awaiting_approval": should_deploy and not auto_deploy and not deployed,
            "per_class_accuracy": val_metrics.get("per_class_accuracy", {}),
            "duration": duration,
        }

    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)
        logger.info(f"✓ Cleaned up temp dir {temp_dir}")


# ──────────────────────────────────────────────────────────────────────────────
# Separate flow: deploy an approved checkpoint to production
# Run this after manual review of finetune_and_compare results
# ──────────────────────────────────────────────────────────────────────────────

@flow(name="deploy_approved_model", log_prints=True)
def deploy_approved_model_flow(version: str) -> Dict[str, Any]:
    """
    Deploy a previously trained checkpoint to production after manual approval.

    Args:
        version: Checkpoint version string shown in finetune_and_compare output as 'new_version'
                 e.g. '2026-03-verified-from-db-20260308T015000'
    """
    logger = get_run_logger()

    logger.info("=" * 80)
    logger.info("DEPLOY APPROVED MODEL")
    logger.info(f"  Version: {version}")
    logger.info("=" * 80)

    minio_client = connect_to_minio()
    bucket = settings.minio.ml_artifacts_bucket
    checkpoint_path = f"models/checkpoints/{version}"

    # Verify checkpoint exists
    try:
        resp = minio_client.get_object(bucket, f"{checkpoint_path}/metadata.json")
        metadata = json.loads(resp.read())
        resp.close(); resp.release_conn()
    except S3Error:
        logger.error(f"Checkpoint not found: {checkpoint_path}")
        return {"status": "error", "message": f"Checkpoint not found: {checkpoint_path}"}

    accuracy = metadata.get("metrics", {}).get("test_accuracy", 0)
    logger.info(f"  Checkpoint accuracy : {accuracy:.2f}%")
    logger.info(f"  Finetuned from      : {metadata.get('finetuned_from', '?')}")

    reason = f"Manually approved deployment of {version} ({accuracy:.2f}% test accuracy)"
    deployment_metadata = {
        "dataset_type": metadata.get("dataset_type", "verified-from-db"),
        "metrics": metadata.get("metrics", {}),
        "deployment_reason": reason,
        "training_date": metadata.get("training_date", ""),
        "training_duration": metadata.get("training_duration", 0),
        "finetuned_from": metadata.get("finetuned_from", ""),
        "manually_approved_at": datetime.now().isoformat(),
    }

    ptr_ok = update_production_pointer(minio_client, version, checkpoint_path, deployment_metadata)
    lat_ok = update_latest_checkpoint(minio_client, version)
    emit_deployment_event(version, metadata.get("metrics", {}), reason,
                          metadata.get("dataset_type", "verified-from-db"))

    if ptr_ok and lat_ok:
        logger.info(f"\n✓ Model {version} deployed to production")
        logger.info("  ModelManager will reload within ~5 minutes")
        return {"status": "success", "version": version, "accuracy": accuracy}
    else:
        logger.error("Deployment failed")
        return {"status": "error", "message": "Deployment steps failed"}


if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == "deploy":
        # Manual deploy after review:
        # python -m flows.finetune_and_compare deploy <version>
        version = sys.argv[2]
        result = deploy_approved_model_flow(version=version)
        print(json.dumps(result, indent=2))
    else:
        version   = sys.argv[1] if len(sys.argv) > 1 else "2026-03"
        mode      = sys.argv[2] if len(sys.argv) > 2 else "local"
        epochs    = int(sys.argv[3]) if len(sys.argv) > 3 else 15
        lr        = float(sys.argv[4]) if len(sys.argv) > 4 else 0.0001
        patience  = int(sys.argv[5]) if len(sys.argv) > 5 else 3
        result = finetune_and_compare_flow(dataset_version=version, training_mode=mode,
                                           num_epochs=epochs, learning_rate=lr,
                                           early_stopping_patience=patience,
                                           auto_deploy=False)
        print("\n=== RESULT ===")
        print(json.dumps({k: v for k, v in result.items() if k != "per_class_accuracy"}, indent=2))
        if result.get("per_class_accuracy"):
            print("\nPer-class accuracy:")
            for cls, acc in sorted(result["per_class_accuracy"].items()):
                print(f"  {cls:15s}: {acc:.1f}%")
        if result.get("awaiting_approval"):
            print(f"\n⚠️  Model beats production but NOT deployed. To deploy after review run:")
            print(f"  docker compose exec ml-automl python -m flows.finetune_and_compare deploy {result['new_version']}")
