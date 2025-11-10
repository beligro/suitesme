"""
Model training flow.
Trains model on dataset, validates, compares with current, and uploads if better.
"""

import tempfile
import shutil
from datetime import datetime
from typing import Optional

from prefect import flow, get_run_logger

from tasks.data_collection import connect_to_minio
from tasks.model_training import (
    download_dataset_from_minio,
    train_model,
    validate_trained_model,
    upload_model_to_minio
)
from config.training_config import training_config


@flow(name="train_model", log_prints=True)
def model_training_flow(
    dataset_type: str = 'verified',
    year: Optional[int] = None,
    month: Optional[int] = None,
    training_mode: str = 'local'
) -> dict:
    """
    Train model on dataset.
    
    Args:
        dataset_type: 'verified' or 'full'
        year: Dataset year (default: current year)
        month: Dataset month (default: current month)
        training_mode: 'local' or 'yandex_cloud'
    
    Returns:
        Training results dictionary
    """
    logger = get_run_logger()
    
    # Use current date if not specified
    if year is None or month is None:
        now = datetime.now()
        year = year or now.year
        month = month or now.month
    
    logger.info("=" * 80)
    logger.info(f"MODEL TRAINING FLOW - {dataset_type.upper()} {year}-{month:02d}")
    logger.info(f"Training mode: {training_mode}")
    logger.info("=" * 80)
    
    # Create temporary directory for training
    temp_dir = tempfile.mkdtemp(prefix=f"training_{year}_{month:02d}_")
    logger.info(f"Temporary directory: {temp_dir}")
    
    try:
        # Step 1: Connect to MinIO
        logger.info("Step 1: Connecting to MinIO")
        minio_client = connect_to_minio()
        
        # Step 2: Download dataset
        logger.info("Step 2: Downloading dataset from MinIO")
        dataset_path = download_dataset_from_minio(
            minio_client,
            dataset_type,
            year,
            month,
            temp_dir
        )
        
        # Step 3: Train model
        logger.info("Step 3: Training model")
        training_results = train_model(dataset_path, training_mode)
        
        # Check if training was successful
        if training_results.get('status') == 'error':
            logger.error("Training failed, aborting flow")
            
            result = {
                'status': 'training_failed',
                'message': training_results.get('message', 'Training error'),
                'dataset_type': dataset_type,
                'year': year,
                'month': month,
                'training_mode': training_mode
            }
            
            logger.info("=" * 80)
            logger.info("FLOW ABORTED - TRAINING FAILED")
            logger.info(f"Results: {result}")
            logger.info("=" * 80)
            
            return result
        
        # Step 4: Validate trained model
        logger.info("Step 4: Validating trained model on test set")
        model_path = training_results.get('model_path')
        centroids_path = training_results.get('centroids_path')
        test_dataset_path = f"{dataset_path}/test"
        
        validation_metrics = validate_trained_model(
            model_path,
            centroids_path,
            test_dataset_path
        )
        
        logger.info(f"Validation metrics: {validation_metrics}")
        
        # Step 5: Upload model checkpoint to MinIO
        logger.info("Step 5: Uploading model checkpoint to MinIO")
        
        # Prepare metadata
        metadata = {
            'version': f"{year}-{month:02d}-v1",
            'dataset_type': dataset_type,
            'dataset_version': f"{year}-{month:02d}",
            'training_mode': training_mode,
            'training_date': datetime.now().isoformat(),
            'training_duration': training_results.get('training_duration', 0),
            'metrics': validation_metrics,
            'training_config': {
                'model_type': training_config.model_type,
                'hidden_dim': training_config.hidden_dim,
                'dropout_prob': training_config.dropout_prob,
                'batch_size': training_config.batch_size,
                'learning_rate': training_config.learning_rate,
                'num_epochs': training_config.num_epochs
            }
        }
        
        upload_success, checkpoint_version, checkpoint_path = upload_model_to_minio(
            minio_client,
            model_path,
            centroids_path,
            metadata,
            year,
            month
        )
        
        if not upload_success:
            logger.error("Failed to upload model checkpoint")
            
            result = {
                'status': 'upload_failed',
                'message': 'Failed to upload model checkpoint to MinIO',
                'dataset_type': dataset_type,
                'year': year,
                'month': month
            }
            
            return result
        
        # Success - checkpoint_version and checkpoint_path returned from upload task
        
        result = {
            'status': 'success',
            'message': 'Model trained, validated, and checkpoint uploaded',
            'dataset_type': dataset_type,
            'year': year,
            'month': month,
            'training_mode': training_mode,
            'checkpoint_version': checkpoint_version,
            'checkpoint_path': checkpoint_path,
            'metrics': validation_metrics,
            'training_duration': training_results.get('training_duration', 0),
            'final_epoch': training_results.get('final_epoch', 0),
            'best_val_accuracy': training_results.get('best_val_accuracy', 0)
        }
        
        logger.info("=" * 80)
        logger.info("FLOW COMPLETE - CHECKPOINT SAVED")
        logger.info(f"Checkpoint: {checkpoint_version}")
        logger.info(f"Test Accuracy: {validation_metrics.get('test_accuracy', 0):.2f}%")
        logger.info("=" * 80)
        
        return result
    
    finally:
        # Cleanup temporary directory
        logger.info(f"Cleaning up temporary directory: {temp_dir}")
        try:
            shutil.rmtree(temp_dir)
            logger.info("✓ Cleanup complete")
        except Exception as e:
            logger.warning(f"Failed to cleanup temp directory: {e}")


if __name__ == "__main__":
    """For local testing"""
    import sys
    
    if len(sys.argv) >= 3:
        dataset_type = sys.argv[1] if len(sys.argv) > 1 else 'verified'
        year = int(sys.argv[2]) if len(sys.argv) > 2 else None
        month = int(sys.argv[3]) if len(sys.argv) > 3 else None
        training_mode = sys.argv[4] if len(sys.argv) > 4 else 'local'
        
        result = model_training_flow(dataset_type, year, month, training_mode)
        print("\n=== TRAINING RESULT ===")
        print(f"Status: {result.get('status')}")
        print(f"Message: {result.get('message')}")
        print(f"Metrics: {result.get('metrics')}")
    else:
        print("Usage: python model_training.py <dataset_type> <year> <month> [training_mode]")
        print("Example: python model_training.py verified 2025 11 local")

