#!/usr/bin/env python3
"""
Full Pipeline Test Script
Tests the complete model update orchestrator with:
- Dataset validation
- Training on verified and full datasets (1 epoch each)
- Model comparison (verified, full, production)
- Deployment of best model
- Artifact generation

Usage:
    python test_full_pipeline.py           # Full test with real training (1 epoch)
    python test_full_pipeline.py --quick   # Quick test with fake data (~10 seconds)
"""

import os
import sys

# Add paths
sys.path.append('/app')

from flows.model_update_orchestrator import update_model_flow
from config.training_config import training_config

def main():
    # Check for quick test flag
    quick_test = '--quick' in sys.argv or '-q' in sys.argv
    
    print("=" * 80)
    if quick_test:
        print("TESTING MODEL UPDATE ORCHESTRATOR (QUICK MODE)")
    else:
        print("TESTING MODEL UPDATE ORCHESTRATOR (FULL MODE)")
    print("=" * 80)
    print()
    
    if quick_test:
        print("⚡ Quick Test Mode:")
        print("  - Skips actual model training")
        print("  - Uses fake data for testing")
        print("  - Completes in ~10 seconds")
        print("  - Perfect for testing UI/artifacts")
    else:
        # Override config for testing (1 epoch only)
        training_config.num_epochs = 1
        training_config.batch_size = 16
        training_config.early_stopping_patience = 1
        
        print("Configuration:")
        print(f"  - Epochs: {training_config.num_epochs}")
        print(f"  - Batch Size: {training_config.batch_size}")
        print(f"  - Dataset: 2025-11")
    
    print()
    
    # Run the orchestrator
    result = update_model_flow(
        year=2025,
        month=11,
        training_mode='local',
        validate_datasets=True,
        train_verified=True,
        train_full=True,
        quick_test=quick_test
    )
    
    # Print results
    print()
    print("=" * 80)
    print("PIPELINE COMPLETE")
    print("=" * 80)
    print()
    print(f"Status: {result.get('status')}")
    print(f"Duration: {result.get('pipeline_duration', 0):.2f}s ({result.get('pipeline_duration', 0)/60:.1f} minutes)")
    
    if result.get('status') == 'success':
        print()
        print("Deployment:")
        print(f"  - Model: {result.get('deployed_model')}")
        print(f"  - Version: {result.get('deployment_version')}")
        print(f"  - Accuracy: {result.get('deployment_accuracy', 0):.2f}%")
        print()
        print("✓ Model deployed successfully")
        print("✓ ModelManager will auto-reload within 5 minutes")
        print("✓ Artifact created for visualization in Prefect UI")
    else:
        print()
        print(f"✗ Pipeline failed: {result.get('message')}")
        if result.get('partial_results'):
            print()
            print("Partial results available - check logs for details")
    
    print()
    print("=" * 80)

if __name__ == "__main__":
    main()


