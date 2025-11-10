"""Flows module for AutoML dataset management and model training"""

from flows.dataset_management import (
    daily_data_collection_flow,
    monthly_dataset_creation_flow
)
from flows.dataset_validation import validate_dataset_structure_flow
from flows.model_training import model_training_flow
from flows.model_comparison import compare_and_deploy_best_model_flow
from flows.model_update_orchestrator import update_model_flow

__all__ = [
    'daily_data_collection_flow',
    'monthly_dataset_creation_flow',
    'validate_dataset_structure_flow',
    'model_training_flow',
    'compare_and_deploy_best_model_flow',
    'update_model_flow'
]

