"""Tasks module for AutoML dataset management"""

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
    'create_monthly_dataset'
]

