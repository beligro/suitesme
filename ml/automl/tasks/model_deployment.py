"""
Model deployment tasks.
Handles production pointer management, latest checkpoint updates, and deployment events.
"""

import json
from datetime import datetime
from typing import Dict, Any
from io import BytesIO

from minio import Minio
from minio.commonconfig import CopySource
from minio.error import S3Error
from prefect import task, get_run_logger
from prefect.events import emit_event

from config import settings


@task(name="update_production_pointer")
def update_production_pointer(
    minio_client: Minio,
    winning_version: str,
    checkpoint_path: str,
    metadata: Dict[str, Any]
) -> bool:
    """
    Update production_model.json pointer to winning model.
    
    Args:
        minio_client: MinIO client
        winning_version: Version string of winning model
        checkpoint_path: Path to checkpoint in MinIO
        metadata: Model metadata including metrics
    
    Returns:
        True if successful, False otherwise
    """
    logger = get_run_logger()
    
    bucket = settings.minio.ml_artifacts_bucket
    production_pointer_path = "models/production_model.json"
    
    try:
        # Create production pointer document
        production_info = {
            "version": winning_version,
            "checkpoint_path": checkpoint_path,
            "deployed_at": datetime.now().isoformat(),
            "metrics": metadata.get('metrics', {}),
            "dataset_type": metadata.get('dataset_type', 'unknown'),
            "deployment_reason": metadata.get('deployment_reason', 'Best performing model'),
            "training_date": metadata.get('training_date', ''),
            "training_duration": metadata.get('training_duration', 0)
        }
        
        logger.info(f"Updating production pointer to: {winning_version}")
        
        # Upload production pointer
        pointer_json = json.dumps(production_info, indent=2)
        pointer_bytes = pointer_json.encode('utf-8')
        
        minio_client.put_object(
            bucket,
            production_pointer_path,
            data=BytesIO(pointer_bytes),
            length=len(pointer_bytes),
            content_type='application/json'
        )
        
        logger.info(f"✓ Production pointer updated: {production_pointer_path}")
        return True
    
    except Exception as e:
        logger.error(f"Failed to update production pointer: {e}")
        return False


@task(name="update_latest_checkpoint")
def update_latest_checkpoint(
    minio_client: Minio,
    winning_version: str
) -> bool:
    """
    Update latest/ directory to point to winning model.
    This triggers ModelManager auto-reload in inference service.
    
    Args:
        minio_client: MinIO client
        winning_version: Version string of winning model
    
    Returns:
        True if successful, False otherwise
    """
    logger = get_run_logger()
    
    bucket = settings.minio.ml_artifacts_bucket
    source_prefix = f"models/checkpoints/{winning_version}"
    latest_prefix = "models/checkpoints/latest"
    
    try:
        logger.info(f"Updating latest/ to point to: {winning_version}")
        
        # Copy model weights
        minio_client.copy_object(
            bucket,
            f"{latest_prefix}/best_model.pth",
            CopySource(bucket, f"{source_prefix}/best_model.pth")
        )
        logger.info("  ✓ Copied model weights")
        
        # Copy centroids
        minio_client.copy_object(
            bucket,
            f"{latest_prefix}/face_centroids.pkl",
            CopySource(bucket, f"{source_prefix}/face_centroids.pkl")
        )
        logger.info("  ✓ Copied centroids")
        
        # Copy metadata (this triggers ModelManager version detection)
        minio_client.copy_object(
            bucket,
            f"{latest_prefix}/metadata.json",
            CopySource(bucket, f"{source_prefix}/metadata.json")
        )
        logger.info("  ✓ Copied metadata")
        
        logger.info(f"✓ Latest checkpoint updated successfully")
        logger.info(f"  ModelManager will auto-reload within ~5 minutes")
        
        return True
    
    except Exception as e:
        logger.error(f"Failed to update latest checkpoint: {e}")
        return False


@task(name="emit_deployment_event")
def emit_deployment_event(
    version: str,
    metrics: Dict[str, Any],
    reason: str,
    dataset_type: str
) -> bool:
    """
    Emit Prefect event for model deployment.
    
    Args:
        version: Deployed model version
        metrics: Model metrics
        reason: Deployment reason
        dataset_type: Dataset type (verified/full)
    
    Returns:
        True if successful, False otherwise
    """
    logger = get_run_logger()
    
    try:
        emit_event(
            event="model.deployed",
            resource={
                "prefect.resource.id": f"model.{version}",
                "prefect.resource.name": f"Production Model {version}"
            },
            payload={
                "version": version,
                "dataset_type": dataset_type,
                "test_accuracy": metrics.get('test_accuracy', 0),
                "reason": reason,
                "deployed_at": datetime.now().isoformat()
            }
        )
        logger.info(f"✓ Emitted deployment event: model.deployed")
        return True
    
    except Exception as e:
        logger.warning(f"Failed to emit deployment event: {e}")
        return False


@task(name="get_production_model_info")
def get_production_model_info(minio_client: Minio) -> Dict[str, Any]:
    """
    Get current production model information.
    
    Args:
        minio_client: MinIO client
    
    Returns:
        Production model info dict, or empty dict if none exists
    """
    logger = get_run_logger()
    
    bucket = settings.minio.ml_artifacts_bucket
    production_pointer_path = "models/production_model.json"
    
    try:
        response = minio_client.get_object(bucket, production_pointer_path)
        pointer_str = response.read().decode('utf-8')
        response.close()
        response.release_conn()
        
        production_info = json.loads(pointer_str)
        logger.info(f"Current production model: {production_info.get('version', 'unknown')}")
        
        return production_info
    
    except S3Error as e:
        if e.code == 'NoSuchKey':
            logger.info("No production model exists yet")
            return {}
        else:
            logger.error(f"Error loading production model info: {e}")
            return {}
    
    except Exception as e:
        logger.error(f"Error loading production model info: {e}")
        return {}

