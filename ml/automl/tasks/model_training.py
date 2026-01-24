"""
Model training tasks.
Includes dataset download, training, validation, comparison, and upload.
"""

import json
import os
import tempfile
import shutil
from datetime import datetime
from typing import Dict, Any, Optional, Tuple
from pathlib import Path
from io import BytesIO

from minio import Minio
from minio.commonconfig import CopySource
from minio.error import S3Error
from prefect import task, get_run_logger
from prefect.events import emit_event

from config import settings
from config.training_config import training_config


@task(name="download_dataset_from_minio")
def download_dataset_from_minio(
    minio_client: Minio,
    dataset_type: str,
    year: int,
    month: int,
    local_dir: str
) -> str:
    """
    Download training dataset from MinIO to local directory.
    
    Args:
        minio_client: MinIO client
        dataset_type: 'verified' or 'full'
        year: Dataset year
        month: Dataset month
        local_dir: Local directory to download to
    
    Returns:
        Path to downloaded dataset directory
    """
    logger = get_run_logger()
    bucket = settings.minio.ml_artifacts_bucket
    dataset_path = f"datasets/{dataset_type}/{year}-{month:02d}"
    
    logger.info(f"Downloading dataset from {dataset_path}")
    
    # Create local dataset directory
    local_dataset_path = os.path.join(local_dir, f"{dataset_type}_{year}_{month:02d}")
    os.makedirs(local_dataset_path, exist_ok=True)
    
    try:
        # List all objects in dataset
        objects = minio_client.list_objects(bucket, prefix=dataset_path, recursive=True)
        
        downloaded = 0
        for obj in objects:
            if obj.is_dir:
                continue
            
            # Get relative path
            rel_path = obj.object_name[len(dataset_path):].lstrip('/')
            
            # Handle long filenames by truncating and adding hash
            path_parts = rel_path.split('/')
            if path_parts:
                filename = path_parts[-1]
                # If filename is too long, truncate and add hash
                if len(filename) > 100:
                    import hashlib
                    name_part, ext_part = os.path.splitext(filename)
                    hash_suffix = hashlib.md5(filename.encode()).hexdigest()[:8]
                    filename = f"{name_part[:80]}_{hash_suffix}{ext_part}"
                    path_parts[-1] = filename
                    rel_path = '/'.join(path_parts)
            
            local_file_path = os.path.join(local_dataset_path, rel_path)
            
            # Create parent directories
            os.makedirs(os.path.dirname(local_file_path), exist_ok=True)
            
            # Download file
            minio_client.fget_object(bucket, obj.object_name, local_file_path)
            downloaded += 1
        
        logger.info(f"✓ Downloaded {downloaded} files to {local_dataset_path}")
        return local_dataset_path
    
    except Exception as e:
        logger.error(f"Error downloading dataset: {e}")
        raise


@task(name="train_model")
def train_model(
    dataset_path: str,
    training_mode: str = "local"
) -> Dict[str, Any]:
    """
    Train model on dataset.
    
    Args:
        dataset_path: Path to training dataset
        training_mode: 'local' or 'yandex_cloud'
    
    Returns:
        Training results including paths to model files
    """
    logger = get_run_logger()
    
    logger.info(f"=" * 80)
    logger.info(f"TRAINING MODEL - Mode: {training_mode}")
    logger.info(f"Dataset: {dataset_path}")
    logger.info(f"=" * 80)
    
    if training_mode == "yandex_cloud":
        logger.error("Yandex Cloud training not yet implemented")
        return {
            "status": "error",
            "message": "Yandex Cloud training not yet implemented",
            "model_path": None,
            "centroids_path": None,
            "training_duration": 0,
            "final_epoch": 0
        }
    
    # Local training
    logger.info("Training mode: Local")
    logger.info(f"Training configuration:")
    logger.info(f"  - Model type: {training_config.model_type}")
    logger.info(f"  - Hidden dim: {training_config.hidden_dim}")
    logger.info(f"  - Batch size: {training_config.batch_size}")
    logger.info(f"  - Learning rate: {training_config.learning_rate}")
    logger.info(f"  - Epochs: {training_config.num_epochs}")
    
    import sys
    import time
    sys.path.append('/app/ml/inference/src')
    
    try:
        from small_classifier.train import TrainPipeline
        
        # Initialize training pipeline
        # Point it to the train directory of downloaded dataset
        train_dir = os.path.join(dataset_path, 'train')
        
        if not os.path.exists(train_dir):
            raise FileNotFoundError(f"Train directory not found: {train_dir}")
        
        logger.info(f"Loading dataset from: {train_dir}")
        
        # Normalize class names to match hierarchical model expectations
        # The hierarchical model expects: Queen, Business, Fire, Inferno, Fragile, Warm, Vintage, 
        # Strong, Aristocratic, Renaissance, Soft, Sunny, Serious, Heroin, Melting
        class_name_mapping = {
            'aristocratic_lady': 'Aristocratic',
            'business_woman': 'Business',
            'fire_lady': 'Fire',
            'fragile_girl': 'Fragile',
            'heroin_girl': 'Heroin',
            'inferno_lady': 'Inferno',
            'melting_lady': 'Melting',
            'queen': 'Queen',
            'renaissance_queen': 'Renaissance',
            'serious_girl': 'Serious',
            'soft_diva': 'Soft',
            'strong_diva': 'Strong',
            'sunny_girl': 'Sunny',
            'vintage_girl': 'Vintage',
            'warm_woman': 'Warm',
            # Handle capitalized duplicates by mapping to same target
            'Business': 'Business',
            'Queen': 'Queen',
            'Vintage': 'Vintage'
        }
        
        # Create normalized dataset directory
        normalized_train_dir = os.path.join(dataset_path, '_normalized_train')
        os.makedirs(normalized_train_dir, exist_ok=True)
        
        logger.info("Normalizing class names for hierarchical model...")
        for original_class in os.listdir(train_dir):
            original_class_path = os.path.join(train_dir, original_class)
            if not os.path.isdir(original_class_path):
                continue
            
            # Get normalized name
            normalized_class = class_name_mapping.get(original_class, original_class)
            normalized_class_path = os.path.join(normalized_train_dir, normalized_class)
            os.makedirs(normalized_class_path, exist_ok=True)
            
            # Symlink images to normalized directory
            for img_file in os.listdir(original_class_path):
                if img_file.lower().endswith(('.jpg', '.jpeg', '.png', '.webp')):
                    src = os.path.join(original_class_path, img_file)
                    dst = os.path.join(normalized_class_path, f"{original_class}_{img_file}")
                    if not os.path.exists(dst):
                        os.symlink(src, dst)
        
        logger.info(f"✓ Normalized {len(class_name_mapping)} class names")
        logger.info(f"Using normalized dataset: {normalized_train_dir}")
        
        # Initialize pipeline - we'll override the directories
        trainer = TrainPipeline(faces_dir=normalized_train_dir, faces_v0_dir=normalized_train_dir)
        
        # Output paths
        output_dir = os.path.join(dataset_path, '_training_output')
        os.makedirs(output_dir, exist_ok=True)
        
        model_path = os.path.join(output_dir, 'best_model.pth')
        
        # Check if we should load existing production model for fine-tuning
        from minio import Minio
        from config import settings
        production_weights_path = None
        
        try:
            # Try to download current production model for fine-tuning
            logger.info("Checking for existing production model to fine-tune...")
            
            minio_client = Minio(
                settings.minio.endpoint,
                access_key=settings.minio.access_key,
                secret_key=settings.minio.secret_key,
                secure=False
            )
            
            # Try to download latest production model
            latest_model_path = "models/checkpoints/latest/best_model.pth"
            production_weights_path = os.path.join(output_dir, 'production_weights.pth')
            
            minio_client.fget_object(
                settings.minio.ml_artifacts_bucket,
                latest_model_path,
                production_weights_path
            )
            logger.info("✓ Downloaded production model for fine-tuning")
            
        except Exception as e:
            logger.info(f"No production model found or error downloading: {e}")
            logger.info("Training from scratch (no fine-tuning)")
            production_weights_path = None
        
        # Train the model (with optional fine-tuning)
        start_time = time.time()
        
        logger.info("Starting training...")
        
        # Pass production weights for fine-tuning if available
        model, train_losses, val_accuracies = trainer.train(
            num_epochs=training_config.num_epochs,
            batch_size=training_config.batch_size,
            learning_rate=training_config.learning_rate,
            validation_split=0.2,
            save_path=model_path,
            patience=training_config.early_stopping_patience,
            pretrained_model_path=production_weights_path  # Load production weights for fine-tuning
        )
        
        training_duration = time.time() - start_time
        
        # Get class mappings from trainer
        class_to_idx = trainer.class_to_idx
        idx_to_class = trainer.idx_to_class
        
        logger.info(f"✓ Training completed in {training_duration:.2f}s")
        logger.info(f"Final validation accuracy: {val_accuracies[-1]:.2f}%")
        logger.info(f"Best validation accuracy: {max(val_accuracies):.2f}%")
        
        # Generate centroids (we'll use the trained model's embeddings)
        # For now, we'll copy the existing centroids or generate placeholder
        centroids_path = os.path.join(output_dir, 'face_centroids.pkl')
        
        # Copy existing centroids as placeholder
        import shutil
        bundled_centroids = '/app/ml/inference/assets/face_centroids.pkl'
        if os.path.exists(bundled_centroids):
            shutil.copy(bundled_centroids, centroids_path)
            logger.info(f"✓ Copied centroids to {centroids_path}")
        
        return {
            "status": "success",
            "message": "Training completed successfully",
            "model_path": model_path,
            "centroids_path": centroids_path,
            "training_duration": training_duration,
            "final_epoch": len(train_losses),
            "train_losses": train_losses,
            "val_accuracies": val_accuracies,
            "best_val_accuracy": max(val_accuracies),
            "final_val_accuracy": val_accuracies[-1]
        }
    
    except Exception as e:
        logger.error(f"Training failed: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return {
            "status": "error",
            "message": f"Training failed: {str(e)}",
            "model_path": None,
            "centroids_path": None,
            "training_duration": 0,
            "final_epoch": 0
        }


@task(name="validate_trained_model")
def validate_trained_model(
    model_path: str,
    centroids_path: str,
    test_dataset_path: str
) -> Dict[str, Any]:
    """
    Validate trained model on test set.
    
    Args:
        model_path: Path to trained model weights
        centroids_path: Path to centroids file
        test_dataset_path: Path to test dataset
    
    Returns:
        Validation metrics
    """
    logger = get_run_logger()
    
    logger.info("Validating trained model on test set...")
    logger.info(f"Model: {model_path}")
    logger.info(f"Test dataset: {test_dataset_path}")
    
    import sys
    import torch
    from torch.utils.data import DataLoader
    sys.path.append('/app/ml/inference/src')
    
    try:
        from small_classifier.train import TrainPipeline, FaceDataset, HierarchicalClassifier
        from facenet_pytorch import MTCNN, InceptionResnetV1
        
        # Load model checkpoint
        logger.info("Loading model checkpoint...")
        checkpoint = torch.load(model_path, map_location='cpu')
        
        class_to_idx = checkpoint['class_to_idx']
        idx_to_class = checkpoint['idx_to_class']
        num_classes = checkpoint['num_classes']
        
        # Initialize model
        model = HierarchicalClassifier(
            input_dim=512,
            num_classes=num_classes,
            hidden_dim=256,
            dropout_prob=0.3,
            class_to_idx=class_to_idx,
            idx_to_class=idx_to_class
        )
        model.load_state_dict(checkpoint['model_state_dict'])
        model.eval()
        
        logger.info(f"✓ Model loaded with {num_classes} classes")
        
        # Initialize MTCNN and InceptionResnetV1 for test set
        mtcnn = MTCNN(keep_all=True, device='cpu')
        resnet = InceptionResnetV1(pretrained='vggface2').eval()
        for param in resnet.parameters():
            param.requires_grad = False
        
        # Load test dataset
        logger.info(f"Loading test dataset from {test_dataset_path}")
        
        # Use same class name mapping as training
        class_name_mapping = {
            'aristocratic_lady': 'Aristocratic',
            'business_woman': 'Business',
            'fire_lady': 'Fire',
            'fragile_girl': 'Fragile',
            'heroin_girl': 'Heroin',
            'inferno_lady': 'Inferno',
            'melting_lady': 'Melting',
            'queen': 'Queen',
            'renaissance_queen': 'Renaissance',
            'serious_girl': 'Serious',
            'soft_diva': 'Soft',
            'strong_diva': 'Strong',
            'sunny_girl': 'Sunny',
            'vintage_girl': 'Vintage',
            'warm_woman': 'Warm',
            'Business': 'Business',
            'Queen': 'Queen',
            'Vintage': 'Vintage'
        }
        
        test_image_paths = []
        test_labels = []
        
        for class_name in os.listdir(test_dataset_path):
            class_path = os.path.join(test_dataset_path, class_name)
            if not os.path.isdir(class_path):
                continue
            
            # Map to normalized class name
            normalized_class = class_name_mapping.get(class_name, class_name)
            
            if normalized_class not in class_to_idx:
                logger.warning(f"Class {class_name} (normalized: {normalized_class}) not in training set, skipping")
                continue
            
            class_idx = class_to_idx[normalized_class]
            
            for img_file in os.listdir(class_path):
                if img_file.lower().endswith(('.jpg', '.jpeg', '.png', '.webp')):
                    test_image_paths.append(os.path.join(class_path, img_file))
                    test_labels.append(class_idx)
        
        logger.info(f"Found {len(test_image_paths)} test images")
        
        if len(test_image_paths) == 0:
            return {
                "status": "error",
                "message": "No test images found",
                "test_accuracy": 0.0,
                "test_loss": 0.0,
                "per_class_accuracy": {},
                "confusion_matrix": None
            }
        
        # Create test dataset
        test_dataset = FaceDataset(test_image_paths, test_labels, mtcnn, resnet, is_training=False)
        test_loader = DataLoader(test_dataset, batch_size=16, shuffle=False)
        
        # Run validation
        correct = 0
        total = 0
        per_class_correct = {i: 0 for i in range(num_classes)}
        per_class_total = {i: 0 for i in range(num_classes)}
        
        all_preds = []
        all_labels = []
        
        with torch.no_grad():
            for embeddings, labels in test_loader:
                outputs = model(embeddings)
                _, predicted = torch.max(outputs, 1)
                
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
                
                # Per-class accuracy
                for label, pred in zip(labels, predicted):
                    label_item = label.item()
                    per_class_total[label_item] += 1
                    if pred == label:
                        per_class_correct[label_item] += 1
                
                all_preds.extend(predicted.tolist())
                all_labels.extend(labels.tolist())
        
        test_accuracy = 100.0 * correct / total if total > 0 else 0.0
        
        # Per-class accuracy
        per_class_accuracy = {}
        for class_idx in range(num_classes):
            # idx_to_class has integer keys, not string keys
            class_name = idx_to_class[class_idx]
            if per_class_total[class_idx] > 0:
                acc = 100.0 * per_class_correct[class_idx] / per_class_total[class_idx]
                per_class_accuracy[class_name] = acc
            else:
                per_class_accuracy[class_name] = 0.0
        
        logger.info(f"✓ Test accuracy: {test_accuracy:.2f}%")
        logger.info(f"Per-class accuracy:")
        for class_name, acc in sorted(per_class_accuracy.items()):
            logger.info(f"  {class_name}: {acc:.2f}%")
        
        return {
            "status": "success",
            "test_accuracy": test_accuracy,
            "test_loss": 0.0,  # We don't compute loss during inference
            "per_class_accuracy": per_class_accuracy,
            "total_test_samples": total,
            "correct_predictions": correct,
            "confusion_matrix": None  # Can add if needed
        }
    
    except Exception as e:
        logger.error(f"Validation failed: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return {
            "status": "error",
            "message": f"Validation failed: {str(e)}",
            "test_accuracy": 0.0,
            "test_loss": 0.0,
            "per_class_accuracy": {},
            "confusion_matrix": None
        }


@task(name="compare_with_current_model")
def compare_with_current_model(
    new_model_metrics: Dict[str, Any],
    minio_client: Minio
) -> Tuple[bool, str]:
    """
    Compare new model with current production model.
    
    Args:
        new_model_metrics: Metrics from new model
        minio_client: MinIO client
    
    Returns:
        Tuple of (should_deploy, reason)
    """
    logger = get_run_logger()
    
    logger.info("Comparing new model with current production model...")
    
    bucket = settings.minio.ml_artifacts_bucket
    current_metadata_path = "models/checkpoints/latest/metadata.json"
    
    try:
        # Try to load current model metadata
        response = minio_client.get_object(bucket, current_metadata_path)
        metadata_str = response.read().decode('utf-8')
        response.close()
        response.release_conn()
        
        current_metadata = json.loads(metadata_str)
        current_accuracy = current_metadata.get('metrics', {}).get('test_accuracy', 0.0)
        
        logger.info(f"Current model accuracy: {current_accuracy:.4f}")
        logger.info(f"New model accuracy: {new_model_metrics.get('test_accuracy', 0.0):.4f}")
        
    except S3Error as e:
        if e.code == 'NoSuchKey':
            logger.info("No current production model found, will deploy new model")
            return True, "No existing model in production"
        else:
            logger.error(f"Error loading current model metadata: {e}")
            return False, f"Error comparing models: {e}"
    except Exception as e:
        logger.error(f"Error comparing models: {e}")
        return False, f"Error: {e}"
    
    # STUB: Compare metrics
    new_accuracy = new_model_metrics.get('test_accuracy', 0.0)
    
    if new_accuracy > current_accuracy + training_config.min_accuracy_improvement:
        improvement = (new_accuracy - current_accuracy) * 100
        reason = f"New model improves accuracy by {improvement:.2f}% ({current_accuracy:.4f} -> {new_accuracy:.4f})"
        logger.info(f"✓ {reason}")
        return True, reason
    else:
        diff = (new_accuracy - current_accuracy) * 100
        reason = f"New model does not meet improvement threshold ({diff:.2f}% vs required {training_config.min_accuracy_improvement*100:.2f}%)"
        logger.info(f"✗ {reason}")
        return False, reason


@task(name="upload_model_to_minio")
def upload_model_to_minio(
    minio_client: Minio,
    model_path: str,
    centroids_path: str,
    metadata: Dict[str, Any],
    year: int,
    month: int
) -> Tuple[bool, Optional[str], Optional[str]]:
    """
    Upload trained model to MinIO.
    
    Args:
        minio_client: MinIO client
        model_path: Path to model weights file
        centroids_path: Path to centroids file
        metadata: Model metadata (version, metrics, etc.)
        year: Training dataset year
        month: Training dataset month
    
    Returns:
        Tuple of (success, version, checkpoint_path)
    """
    logger = get_run_logger()
    
    bucket = settings.minio.ml_artifacts_bucket
    
    try:
        # Create unique version identifier with timestamp and dataset type
        timestamp = datetime.now().strftime("%Y%m%dT%H%M%S")
        dataset_suffix = metadata.get('dataset_type', 'unknown')
        version = f"{year}-{month:02d}-{dataset_suffix}-{timestamp}"
        metadata['version'] = version
        metadata['uploaded_at'] = datetime.now().isoformat()
        
        # Upload to versioned path (backup/archive)
        versioned_prefix = f"models/checkpoints/{version}"
        
        logger.info(f"Uploading model to {versioned_prefix}")
        
        # Upload model weights
        minio_client.fput_object(
            bucket,
            f"{versioned_prefix}/best_model.pth",
            model_path
        )
        logger.info("✓ Uploaded model weights")
        
        # Upload centroids
        minio_client.fput_object(
            bucket,
            f"{versioned_prefix}/face_centroids.pkl",
            centroids_path
        )
        logger.info("✓ Uploaded centroids")
        
        # Upload metadata
        metadata_json = json.dumps(metadata, indent=2)
        metadata_bytes = metadata_json.encode('utf-8')
        minio_client.put_object(
            bucket,
            f"{versioned_prefix}/metadata.json",
            data=BytesIO(metadata_bytes),
            length=len(metadata_bytes),
            content_type='application/json'
        )
        logger.info("✓ Uploaded metadata")
        
        # NOTE: NOT updating 'latest' here - that will be done by deployment flow
        # after comparing all candidate models
        
        logger.info("✓ Model checkpoint uploaded successfully to MinIO")
        logger.info(f"  Checkpoint path: {versioned_prefix}")
        logger.info(f"  Version: {version}")
        
        return True, version, versioned_prefix
    
    except Exception as e:
        logger.error(f"Failed to upload model: {e}")
        return False, None, None


@task(name="emit_model_ready_event")
def emit_model_ready_event(
    year: int,
    month: int,
    version: str,
    metrics: Dict[str, Any]
):
    """
    Emit Prefect event that model is ready for deployment.
    
    Args:
        year: Model year
        month: Model month
        version: Model version
        metrics: Model metrics
    """
    logger = get_run_logger()
    
    try:
        emit_event(
            event="model.trained.ready",
            resource={
                "prefect.resource.id": f"model.{year}-{month:02d}",
                "prefect.resource.name": f"Model {version}"
            },
            payload={
                "version": version,
                "year": year,
                "month": month,
                "metrics": metrics,
                "training_completed_at": datetime.now().isoformat()
            }
        )
        logger.info(f"✓ Emitted event: model.trained.ready for {version}")
    except Exception as e:
        logger.warning(f"Failed to emit model ready event: {e}")

