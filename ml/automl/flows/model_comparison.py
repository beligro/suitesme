"""
Model comparison and deployment flow.
Compares verified, full, and production models, deploys the best one.
"""

from datetime import datetime
from typing import Optional, Dict, Any, Tuple

from prefect import flow, get_run_logger

from tasks.data_collection import connect_to_minio
from tasks.model_deployment import (
    get_production_model_info,
    update_production_pointer,
    update_latest_checkpoint,
    emit_deployment_event
)


@flow(name="compare_and_deploy_best_model")
def compare_and_deploy_best_model_flow(
    verified_result: Optional[Dict[str, Any]],
    full_result: Optional[Dict[str, Any]],
    year: int,
    month: int
) -> Dict[str, Any]:
    """
    Compare verified, full, and production models. Deploy the best one.
    
    Args:
        verified_result: Training result from verified dataset (or None)
        full_result: Training result from full dataset (or None)
        year: Dataset year
        month: Dataset month
    
    Returns:
        Deployment results dictionary
    """
    logger = get_run_logger()
    
    logger.info("=" * 80)
    logger.info("MODEL COMPARISON & DEPLOYMENT FLOW")
    logger.info("=" * 80)
    
    # Step 1: Connect to MinIO
    logger.info("Step 1: Connecting to MinIO")
    minio_client = connect_to_minio()
    
    # Step 2: Get production model info
    logger.info("Step 2: Loading current production model info")
    production_info = get_production_model_info(minio_client)
    
    # Step 3: Build candidates list
    logger.info("Step 3: Comparing candidate models")
    candidates = []
    
    # Add verified model as candidate
    if verified_result and verified_result.get('status') == 'success':
        candidates.append({
            'name': 'Verified Dataset Model',
            'dataset_type': 'verified',
            'version': verified_result.get('checkpoint_version'),
            'checkpoint_path': verified_result.get('checkpoint_path'),
            'accuracy': verified_result.get('metrics', {}).get('test_accuracy', 0),
            'metrics': verified_result.get('metrics', {}),
            'training_duration': verified_result.get('training_duration', 0),
            'result': verified_result
        })
        logger.info(f"  Candidate 1: Verified - {candidates[-1]['accuracy']:.2f}%")
    
    # Add full model as candidate
    if full_result and full_result.get('status') == 'success':
        candidates.append({
            'name': 'Full Dataset Model',
            'dataset_type': 'full',
            'version': full_result.get('checkpoint_version'),
            'checkpoint_path': full_result.get('checkpoint_path'),
            'accuracy': full_result.get('metrics', {}).get('test_accuracy', 0),
            'metrics': full_result.get('metrics', {}),
            'training_duration': full_result.get('training_duration', 0),
            'result': full_result
        })
        logger.info(f"  Candidate {len(candidates)}: Full - {candidates[-1]['accuracy']:.2f}%")
    
    # Add production model as candidate (if exists)
    production_accuracy = 0
    if production_info:
        production_accuracy = production_info.get('metrics', {}).get('test_accuracy', 0)
        candidates.append({
            'name': 'Current Production Model',
            'dataset_type': production_info.get('dataset_type', 'production'),
            'version': production_info.get('version'),
            'checkpoint_path': production_info.get('checkpoint_path'),
            'accuracy': production_accuracy,
            'metrics': production_info.get('metrics', {}),
            'training_duration': 0,  # Already trained
            'result': production_info
        })
        logger.info(f"  Candidate {len(candidates)}: Production - {production_accuracy:.2f}%")
    else:
        logger.info("  No production model exists - will deploy new model")
    
    # Check if we have any candidates
    if not candidates:
        logger.error("No candidate models available for deployment!")
        return {
            'status': 'error',
            'message': 'No candidate models available',
            'deployed_model': None
        }
    
    # Step 4: Select winner (highest accuracy)
    logger.info("Step 4: Selecting best model")
    winner = max(candidates, key=lambda x: x['accuracy'])
    
    logger.info(f"\n{'=' * 80}")
    logger.info("WINNER SELECTED")
    logger.info(f"  Model: {winner['name']}")
    logger.info(f"  Dataset: {winner['dataset_type']}")
    logger.info(f"  Accuracy: {winner['accuracy']:.2f}%")
    logger.info(f"  Version: {winner['version']}")
    logger.info(f"{'=' * 80}\n")
    
    # Build comparison summary
    comparison_summary = []
    for candidate in candidates:
        is_winner = (candidate['version'] == winner['version'])
        comparison_summary.append({
            'name': candidate['name'],
            'accuracy': candidate['accuracy'],
            'is_winner': is_winner
        })
    
    # Build deployment reason
    other_accuracies = [c['accuracy'] for c in candidates if c['version'] != winner['version']]
    if other_accuracies:
        avg_other = sum(other_accuracies) / len(other_accuracies)
        improvement = winner['accuracy'] - avg_other
        reason = f"Best performing model (+{improvement:.2f}% over alternatives)"
    else:
        reason = "Only available model"
    
    # Step 5: Deploy winner
    logger.info("Step 5: Deploying winning model")
    
    # Prepare deployment metadata
    deployment_metadata = {
        'dataset_type': winner['dataset_type'],
        'metrics': winner['metrics'],
        'deployment_reason': reason,
        'training_date': datetime.now().isoformat(),
        'training_duration': winner['training_duration'],
        'compared_models': len(candidates),
        'alternatives': [{'name': c['name'], 'accuracy': c['accuracy']} 
                        for c in candidates if c['version'] != winner['version']]
    }
    
    # Update production pointer
    pointer_updated = update_production_pointer(
        minio_client,
        winner['version'],
        winner['checkpoint_path'],
        deployment_metadata
    )
    
    if not pointer_updated:
        logger.error("Failed to update production pointer")
        return {
            'status': 'error',
            'message': 'Failed to update production pointer',
            'deployed_model': winner['name']
        }
    
    # Update latest checkpoint (this triggers ModelManager)
    latest_updated = update_latest_checkpoint(
        minio_client,
        winner['version']
    )
    
    if not latest_updated:
        logger.error("Failed to update latest checkpoint")
        return {
            'status': 'error',
            'message': 'Failed to update latest checkpoint',
            'deployed_model': winner['name']
        }
    
    # Emit deployment event
    emit_deployment_event(
        winner['version'],
        winner['metrics'],
        reason,
        winner['dataset_type']
    )
    
    # Step 6: Return deployment results
    logger.info("=" * 80)
    logger.info("DEPLOYMENT COMPLETE")
    logger.info(f"Production model: {winner['version']}")
    logger.info(f"ModelManager will auto-reload within ~5 minutes")
    logger.info("=" * 80)
    
    return {
        'status': 'success',
        'deployed_model': winner['name'],
        'dataset_type': winner['dataset_type'],
        'version': winner['version'],
        'checkpoint_path': winner['checkpoint_path'],
        'winner_accuracy': winner['accuracy'],
        'winner_metrics': winner['metrics'],
        'production_accuracy': production_accuracy,
        'reason': reason,
        'deployed_at': datetime.now().isoformat(),
        'previous_version': production_info.get('version') if production_info else None,
        'comparison_summary': comparison_summary,
        'num_candidates': len(candidates)
    }

