"""Tasks module for AutoML dataset management, training, and deployment"""

from tasks.data_collection import (
    connect_to_database,
    connect_to_minio,
    fetch_new_predictions,
    process_prediction_images,
    upload_candidates_to_minio,
    create_collection_manifest
)

from tasks.dataset_creation import (
    list_candidate_collections,
    load_collection_manifest,
    copy_gold_dataset,
    copy_candidate_images,
    create_dataset_manifest,
    create_monthly_dataset
)

from tasks.model_training import (
    download_dataset_from_minio,
    train_model,
    validate_trained_model,
    upload_model_to_minio
)

from tasks.model_deployment import (
    get_production_model_info,
    update_production_pointer,
    update_latest_checkpoint,
    emit_deployment_event
)

from tasks.artifact_generation import (
    create_pipeline_artifact
)

__all__ = [
    # Data collection tasks
    'connect_to_database',
    'connect_to_minio',
    'fetch_new_predictions',
    'process_prediction_images',
    'upload_candidates_to_minio',
    'create_collection_manifest',
    # Dataset creation tasks
    'list_candidate_collections',
    'load_collection_manifest',
    'copy_gold_dataset',
    'copy_candidate_images',
    'create_dataset_manifest',
    'create_monthly_dataset',
    # Model training tasks
    'download_dataset_from_minio',
    'train_model',
    'validate_trained_model',
    'upload_model_to_minio',
    # Model deployment tasks
    'get_production_model_info',
    'update_production_pointer',
    'update_latest_checkpoint',
    'emit_deployment_event',
    # Artifact tasks
    'create_pipeline_artifact'
]

