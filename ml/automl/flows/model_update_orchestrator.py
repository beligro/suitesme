"""
Model Update Orchestrator Flow.
Main orchestrator that coordinates the entire model update lifecycle:
- Dataset validation
- Model training (verified and full datasets)
- Model comparison
- Deployment
- Reporting
"""

from datetime import datetime
from typing import Optional, Dict, Any

from prefect import flow, get_run_logger

from flows.dataset_validation import validate_dataset_structure_flow
from flows.model_training import model_training_flow
from flows.model_comparison import compare_and_deploy_best_model_flow
from tasks.artifact_generation import create_pipeline_artifact


@flow(name="update_model_orchestrator")
def update_model_flow(
    year: Optional[int] = None,
    month: Optional[int] = None,
    training_mode: str = 'local',
    validate_datasets: bool = True,
    train_verified: bool = True,
    train_full: bool = True,
    quick_test: bool = False
) -> Dict[str, Any]:
    """
    Orchestrate complete model update pipeline.
    
    This is the main entry point for the automated model update process.
    It coordinates dataset validation, training on multiple datasets,
    comparison of results, and deployment of the best model.
    
    Args:
        year: Dataset year (default: current year)
        month: Dataset month (default: current month)
        training_mode: 'local' or 'yandex_cloud'
        validate_datasets: Whether to validate datasets before training
        train_verified: Whether to train on verified dataset
        train_full: Whether to train on full dataset
        quick_test: If True, skip actual training and use fake data for testing UI
    
    Returns:
        Complete pipeline results with deployment info and artifact references
    """
    logger = get_run_logger()
    
    # Track pipeline timing
    pipeline_start = datetime.now()
    
    # Use current date if not specified
    if year is None or month is None:
        now = datetime.now()
        year = year or now.year
        month = month or now.month
    
    logger.info("=" * 80)
    logger.info("MODEL UPDATE ORCHESTRATOR")
    logger.info(f"Dataset: {year}-{month:02d}")
    logger.info(f"Training Mode: {training_mode}")
    logger.info("=" * 80)
    
    # Initialize result tracking
    verified_val = None
    full_val = None
    verified_result = None
    full_result = None
    deployment_result = None
    
    try:
        # ========================================
        # PHASE 1: DATASET VALIDATION
        # ========================================
        if validate_datasets:
            logger.info("\n" + "=" * 80)
            logger.info("PHASE 1: DATASET VALIDATION")
            logger.info("=" * 80 + "\n")
            
            # Validate verified dataset
            if train_verified:
                logger.info("Validating VERIFIED dataset...")
                verified_val = validate_dataset_structure_flow('verified', year, month)
                logger.info(f"✓ Verified validation: {verified_val.status}")
                
                if verified_val.status != 'pass':
                    logger.error(f"Verified dataset validation failed: {verified_val.issues}")
                    return create_failure_result(
                        "Dataset validation failed (verified)",
                        pipeline_start,
                        verified_val=verified_val
                    )
            
            # Validate full dataset
            if train_full:
                logger.info("Validating FULL dataset...")
                full_val = validate_dataset_structure_flow('full', year, month)
                logger.info(f"✓ Full validation: {full_val.status}")
                
                if full_val.status != 'pass':
                    logger.error(f"Full dataset validation failed: {full_val.issues}")
                    return create_failure_result(
                        "Dataset validation failed (full)",
                        pipeline_start,
                        verified_val=verified_val,
                        full_val=full_val
                    )
            
            logger.info("\n✓ All datasets validated successfully\n")
        
        # ========================================
        # PHASE 2: MODEL TRAINING
        # ========================================
        logger.info("=" * 80)
        logger.info("PHASE 2: MODEL TRAINING")
        logger.info("=" * 80 + "\n")
        
        # Quick test mode - use fake data
        if quick_test:
            logger.info("⚡ QUICK TEST MODE - Using fake data")
            import time
            time.sleep(2)  # Simulate training time
            
            timestamp = datetime.now().strftime("%Y%m%dT%H%M%S")
            
            if train_verified:
                verified_result = {
                    'status': 'success',
                    'message': 'Fake training data for testing',
                    'dataset_type': 'verified',
                    'checkpoint_version': f'{year}-{month:02d}-verified-{timestamp}',
                    'checkpoint_path': f'models/checkpoints/{year}-{month:02d}-verified-{timestamp}',
                    'metrics': {
                        'status': 'success',
                        'test_accuracy': 47.83,
                        'per_class_accuracy': {
                            'Aristocratic': 50.0, 'Business': 75.0, 'Fire': 40.0,
                            'Fragile': 60.0, 'Heroin': 85.0, 'Inferno': 45.0,
                            'Melting': 55.0, 'Queen': 80.0, 'Renaissance': 35.0,
                            'Serious': 30.0, 'Soft': 25.0, 'Strong': 40.0,
                            'Sunny': 50.0, 'Vintage': 45.0, 'Warm': 70.0
                        }
                    },
                    'training_duration': 850.5,
                    'final_epoch': 1,
                    'best_val_accuracy': 47.83
                }
                logger.info(f"✓ Fake verified training: 47.83%")
            
            if train_full:
                time.sleep(1)
                full_result = {
                    'status': 'success',
                    'message': 'Fake training data for testing',
                    'dataset_type': 'full',
                    'checkpoint_version': f'{year}-{month:02d}-full-{timestamp}',
                    'checkpoint_path': f'models/checkpoints/{year}-{month:02d}-full-{timestamp}',
                    'metrics': {
                        'status': 'success',
                        'test_accuracy': 52.17,
                        'per_class_accuracy': {
                            'Aristocratic': 50.0, 'Business': 100.0, 'Fire': 0.0,
                            'Fragile': 100.0, 'Heroin': 100.0, 'Inferno': 100.0,
                            'Melting': 0.0, 'Queen': 0.0, 'Renaissance': 100.0,
                            'Serious': 0.0, 'Soft': 0.0, 'Strong': 0.0,
                            'Sunny': 50.0, 'Vintage': 50.0, 'Warm': 100.0
                        }
                    },
                    'training_duration': 958.2,
                    'final_epoch': 1,
                    'best_val_accuracy': 52.17
                }
                logger.info(f"✓ Fake full training: 52.17%")
        else:
            # Real training
            # Train on verified dataset
            if train_verified:
                logger.info("Training on VERIFIED dataset...")
                verified_result = model_training_flow('verified', year, month, training_mode)
                
                if verified_result.get('status') == 'success':
                    logger.info(f"✓ Verified training complete: {verified_result.get('metrics', {}).get('test_accuracy', 0):.2f}%")
                else:
                    logger.warning(f"⚠️  Verified training failed: {verified_result.get('message')}")
            
            # Train on full dataset
            if train_full:
                logger.info("Training on FULL dataset...")
                full_result = model_training_flow('full', year, month, training_mode)
                
                if full_result.get('status') == 'success':
                    logger.info(f"✓ Full training complete: {full_result.get('metrics', {}).get('test_accuracy', 0):.2f}%")
                else:
                    logger.warning(f"⚠️  Full training failed: {full_result.get('message')}")
        
        # Check if at least one training succeeded
        has_successful_training = (
            (verified_result and verified_result.get('status') == 'success') or
            (full_result and full_result.get('status') == 'success')
        )
        
        if not has_successful_training:
            logger.error("All training runs failed!")
            return create_failure_result(
                "All training runs failed",
                pipeline_start,
                verified_val=verified_val,
                full_val=full_val,
                verified_training=verified_result,
                full_training=full_result
            )
        
        logger.info("\n✓ Training phase complete\n")
        
        # ========================================
        # PHASE 3: MODEL COMPARISON & DEPLOYMENT
        # ========================================
        logger.info("=" * 80)
        logger.info("PHASE 3: MODEL COMPARISON & DEPLOYMENT")
        logger.info("=" * 80 + "\n")
        
        if quick_test:
            # Skip actual deployment in quick test mode
            logger.info("⚡ QUICK TEST MODE - Creating fake deployment result")
            import time
            time.sleep(1)
            
            # Determine winner from fake results
            v_acc = verified_result.get('metrics', {}).get('test_accuracy', 0) if verified_result else 0
            f_acc = full_result.get('metrics', {}).get('test_accuracy', 0) if full_result else 0
            
            if f_acc > v_acc:
                winner = full_result
                winner_name = "Full Dataset Model"
            else:
                winner = verified_result
                winner_name = "Verified Dataset Model"
            
            deployment_result = {
                'status': 'success',
                'deployed_model': winner_name,
                'dataset_type': winner.get('dataset_type'),
                'version': winner.get('checkpoint_version'),
                'checkpoint_path': winner.get('checkpoint_path'),
                'winner_accuracy': winner.get('metrics', {}).get('test_accuracy', 0),
                'winner_metrics': winner.get('metrics', {}),
                'production_accuracy': 0,  # No production model in test
                'reason': 'Best performing model (quick test)',
                'deployed_at': datetime.now().isoformat(),
                'previous_version': None,
                'comparison_summary': [
                    {'name': 'Verified Dataset Model', 'accuracy': v_acc, 'is_winner': v_acc >= f_acc},
                    {'name': 'Full Dataset Model', 'accuracy': f_acc, 'is_winner': f_acc > v_acc}
                ],
                'num_candidates': 2
            }
            logger.info(f"✓ Fake deployment: {winner_name}")
        else:
            # Real deployment
            deployment_result = compare_and_deploy_best_model_flow(
                verified_result=verified_result if train_verified else None,
                full_result=full_result if train_full else None,
                year=year,
                month=month
            )
        
        if deployment_result.get('status') != 'success':
            logger.error(f"Deployment failed: {deployment_result.get('message')}")
            return create_failure_result(
                f"Deployment failed: {deployment_result.get('message')}",
                pipeline_start,
                verified_val=verified_val,
                full_val=full_val,
                verified_training=verified_result,
                full_training=full_result,
                deployment=deployment_result
            )
        
        logger.info(f"\n✓ Deployed: {deployment_result.get('deployed_model')}\n")
        
        # ========================================
        # PHASE 4: CREATE PIPELINE REPORT ARTIFACT
        # ========================================
        logger.info("=" * 80)
        logger.info("PHASE 4: CREATING PIPELINE REPORT")
        logger.info("=" * 80 + "\n")
        
        pipeline_duration = (datetime.now() - pipeline_start).total_seconds()
        
        artifact_id = create_pipeline_artifact(
            verified_validation=verified_val if validate_datasets else None,
            full_validation=full_val if validate_datasets else None,
            verified_training=verified_result if train_verified else None,
            full_training=full_result if train_full else None,
            deployment=deployment_result,
            pipeline_duration=pipeline_duration
        )
        
        logger.info(f"✓ Pipeline report artifact created\n")
        
        # ========================================
        # PIPELINE COMPLETE
        # ========================================
        logger.info("=" * 80)
        logger.info("PIPELINE COMPLETE - SUCCESS")
        logger.info("=" * 80)
        logger.info(f"Duration: {pipeline_duration:.2f}s ({pipeline_duration/60:.1f} minutes)")
        logger.info(f"Deployed Model: {deployment_result.get('deployed_model')}")
        logger.info(f"Version: {deployment_result.get('version')}")
        logger.info(f"Accuracy: {deployment_result.get('winner_accuracy', 0):.2f}%")
        logger.info("=" * 80)
        
        return {
            'status': 'success',
            'message': 'Model update pipeline completed successfully',
            'pipeline_duration': pipeline_duration,
            'deployed_model': deployment_result.get('deployed_model'),
            'deployment_version': deployment_result.get('version'),
            'deployment_accuracy': deployment_result.get('winner_accuracy'),
            'artifact_id': artifact_id,
            'year': year,
            'month': month,
            'training_mode': training_mode
        }
    
    except Exception as e:
        logger.error(f"Pipeline failed with exception: {e}")
        import traceback
        logger.error(traceback.format_exc())
        
        return create_failure_result(
            f"Pipeline exception: {str(e)}",
            pipeline_start,
            verified_val=verified_val,
            full_val=full_val,
            verified_training=verified_result,
            full_training=full_result,
            deployment=deployment_result
        )


def create_failure_result(
    error_message: str,
    pipeline_start: datetime,
    verified_val=None,
    full_val=None,
    verified_training=None,
    full_training=None,
    deployment=None
) -> Dict[str, Any]:
    """
    Create a standardized failure result with partial results.
    
    Args:
        error_message: Error message describing the failure
        pipeline_start: Pipeline start time
        verified_val: Verified validation results (if available)
        full_val: Full validation results (if available)
        verified_training: Verified training results (if available)
        full_training: Full training results (if available)
        deployment: Deployment results (if available)
    
    Returns:
        Failure result dictionary
    """
    pipeline_duration = (datetime.now() - pipeline_start).total_seconds()
    
    return {
        'status': 'failed',
        'message': error_message,
        'pipeline_duration': pipeline_duration,
        'partial_results': {
            'verified_validation': verified_val,
            'full_validation': full_val,
            'verified_training': verified_training,
            'full_training': full_training,
            'deployment': deployment
        },
        'deployed_model': None,
        'deployment_version': None
    }


if __name__ == "__main__":
    """For local testing"""
    import sys
    
    if len(sys.argv) >= 3:
        year = int(sys.argv[1]) if len(sys.argv) > 1 else None
        month = int(sys.argv[2]) if len(sys.argv) > 2 else None
        training_mode = sys.argv[3] if len(sys.argv) > 3 else 'local'
        
        result = update_model_flow(
            year=year,
            month=month,
            training_mode=training_mode,
            validate_datasets=True,
            train_verified=True,
            train_full=True
        )
        
        print("\n=== PIPELINE RESULT ===")
        print(f"Status: {result.get('status')}")
        print(f"Message: {result.get('message')}")
        print(f"Duration: {result.get('pipeline_duration', 0):.2f}s")
        if result.get('deployed_model'):
            print(f"Deployed: {result.get('deployed_model')}")
            print(f"Version: {result.get('deployment_version')}")
    else:
        print("Usage: python model_update_orchestrator.py <year> <month> [training_mode]")
        print("Example: python model_update_orchestrator.py 2025 11 local")

