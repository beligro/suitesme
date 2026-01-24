#!/usr/bin/env python3
"""
Script to deploy Prefect flows with schedules.
Run this after the Prefect server is up and running.
"""

import sys
import time
import requests
from flows.dataset_management import (
    daily_data_collection_flow,
    monthly_dataset_creation_flow
)
from flows.model_update_orchestrator import update_model_flow
from prefect.deployments import Deployment
from prefect.server.schemas.schedules import CronSchedule
from config import settings


def wait_for_prefect_server(max_retries=30, retry_delay=2):
    """Wait for Prefect server to be ready"""
    print(f"Waiting for Prefect server at {settings.prefect.api_url}...")
    
    for i in range(max_retries):
        try:
            response = requests.get(
                f"{settings.prefect.api_url}/health",
                timeout=5
            )
            if response.status_code == 200:
                print("✓ Prefect server is ready!")
                return True
        except Exception as e:
            if i == 0:
                print(f"Waiting for server... ({e})")
        
        time.sleep(retry_delay)
    
    print("✗ Prefect server did not become ready in time")
    return False


def create_work_pool():
    """Create default work pool if it doesn't exist"""
    print(f"\nCreating work pool: {settings.prefect.work_pool_name}")
    
    try:
        import subprocess
        result = subprocess.run(
            [
                "prefect", "work-pool", "create",
                settings.prefect.work_pool_name,
                "--type", "process"
            ],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print(f"✓ Work pool '{settings.prefect.work_pool_name}' created")
        else:
            if "already exists" in result.stderr.lower():
                print(f"✓ Work pool '{settings.prefect.work_pool_name}' already exists")
            else:
                print(f"Warning: {result.stderr}")
    
    except Exception as e:
        print(f"Note: Could not create work pool: {e}")
        print("You may need to create it manually using:")
        print(f"  prefect work-pool create {settings.prefect.work_pool_name}")


def deploy_flows():
    """Deploy all flows with schedules"""
    print("\n" + "="*80)
    print("DEPLOYING PREFECT FLOWS")
    print("="*80)
    
    # Deploy daily collection flow
    print("\n1. Deploying daily data collection flow...")
    print("   Schedule: Every day at 00:00 UTC")
    
    try:
        daily_deployment = Deployment.build_from_flow(
            flow=daily_data_collection_flow,
            name="daily-collection",
            version="1.0.0",
            schedule=CronSchedule(
                cron="0 0 * * *",  # Every day at 00:00 UTC
                timezone="UTC"
            ),
            work_pool_name=settings.prefect.work_pool_name,
            tags=["dataset-management", "daily", "collection"],
            description="Daily collection of new predictions for ML training"
        )
        
        deployment_id = daily_deployment.apply()
        print(f"   ✓ Daily collection flow deployed (ID: {deployment_id})")
        
    except Exception as e:
        print(f"   ✗ Failed to deploy daily collection flow: {e}")
        return False
    
    # Deploy monthly creation flow
    print("\n2. Deploying monthly dataset creation flow...")
    print("   Schedule: 1st day of month at 01:00 UTC")
    
    try:
        monthly_deployment = Deployment.build_from_flow(
            flow=monthly_dataset_creation_flow,
            name="monthly-creation",
            version="1.0.0",
            schedule=CronSchedule(
                cron="0 1 1 * *",  # 1st day of month at 01:00 UTC
                timezone="UTC"
            ),
            work_pool_name=settings.prefect.work_pool_name,
            tags=["dataset-management", "monthly", "creation"],
            description="Monthly creation of verified and full training datasets"
        )
        
        deployment_id = monthly_deployment.apply()
        print(f"   ✓ Monthly creation flow deployed (ID: {deployment_id})")
        
    except Exception as e:
        print(f"   ✗ Failed to deploy monthly creation flow: {e}")
        return False
    
    # Deploy model update orchestrator flow
    print("\n3. Deploying model update orchestrator flow...")
    print("   Schedule: 2nd day of month at 02:00 UTC (after dataset creation)")
    
    try:
        model_update_deployment = Deployment.build_from_flow(
            flow=update_model_flow,
            name="monthly-model-update",
            version="1.0.0",
            schedule=CronSchedule(
                cron="0 2 2 * *",  # 2nd day of month at 02:00 UTC
                timezone="UTC"
            ),
            work_pool_name=settings.prefect.work_pool_name,
            tags=["model-training", "monthly", "orchestrator"],
            description="Monthly model training, comparison, and deployment orchestration"
        )
        
        deployment_id = model_update_deployment.apply()
        print(f"   ✓ Model update orchestrator deployed (ID: {deployment_id})")
        
    except Exception as e:
        print(f"   ✗ Failed to deploy model update orchestrator: {e}")
        return False
    
    return True


def main():
    """Main deployment function"""
    print("="*80)
    print("PREFECT FLOWS DEPLOYMENT SCRIPT")
    print("="*80)
    print(f"Prefect API URL: {settings.prefect.api_url}")
    print(f"Work Pool: {settings.prefect.work_pool_name}")
    print("="*80)
    
    # Wait for Prefect server
    if not wait_for_prefect_server():
        print("\n✗ Deployment failed: Prefect server not available")
        sys.exit(1)
    
    # Create work pool
    create_work_pool()
    
    # Deploy flows
    if deploy_flows():
        print("\n" + "="*80)
        print("✓ ALL FLOWS DEPLOYED SUCCESSFULLY")
        print("="*80)
        print("\nNext steps:")
        print("1. Check Prefect UI: http://localhost:4200")
        print("2. Verify deployments are scheduled")
        print("3. Start a worker to execute flows:")
        print(f"   prefect worker start --pool {settings.prefect.work_pool_name}")
        print("\nTo manually trigger a flow:")
        print("   prefect deployment run 'daily_data_collection/daily-collection'")
        print("   prefect deployment run 'monthly_dataset_creation/monthly-creation'")
        print("   prefect deployment run 'update_model_orchestrator/monthly-model-update'")
        print("="*80)
        sys.exit(0)
    else:
        print("\n✗ Deployment failed")
        sys.exit(1)


if __name__ == "__main__":
    main()

