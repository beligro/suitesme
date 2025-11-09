"""
Prefect flows for dataset management orchestration.
Includes daily data collection and monthly dataset creation flows.
"""

from datetime import datetime, timedelta
from typing import Optional

from prefect import flow, get_run_logger

from tasks.data_collection import (
    connect_to_database,
    connect_to_minio,
    fetch_new_predictions,
    process_prediction_images,
    upload_candidates_to_minio,
    create_collection_manifest
)

from tasks.dataset_creation import create_monthly_dataset
from config import settings


@flow(name="daily_data_collection", log_prints=True)
def daily_data_collection_flow(
    collection_date: Optional[str] = None,
    since_date: Optional[str] = None
):
    """
    Daily flow to collect new predictions and store as training candidates.
    
    Args:
        collection_date: Collection date (YYYY-MM-DD), defaults to today
        since_date: Fetch predictions since this date, defaults to yesterday
    """
    logger = get_run_logger()
    
    # Determine collection date
    if collection_date is None:
        collection_date = datetime.now().strftime('%Y-%m-%d')
    
    logger.info("=" * 80)
    logger.info(f"DAILY DATA COLLECTION FLOW - {collection_date}")
    logger.info("=" * 80)
    
    # Parse since_date if provided
    since_datetime = None
    if since_date:
        try:
            since_datetime = datetime.fromisoformat(since_date)
        except ValueError:
            logger.warning(f"Invalid since_date format: {since_date}, using default")
    
    # Step 1: Connect to database
    logger.info("Step 1: Connecting to database")
    db_conn = connect_to_database()
    
    # Step 2: Connect to MinIO
    logger.info("Step 2: Connecting to MinIO")
    minio_client = connect_to_minio()
    
    # Step 3: Fetch new predictions
    logger.info("Step 3: Fetching new predictions")
    predictions = fetch_new_predictions(db_conn, since_datetime)
    
    if not predictions:
        logger.info("No new predictions found. Flow complete.")
        db_conn.close()
        return {
            'status': 'success',
            'collection_date': collection_date,
            'predictions_processed': 0,
            'images_collected': 0
        }
    
    # Step 4: Process all predictions
    logger.info(f"Step 4: Processing {len(predictions)} predictions")
    all_processed_images = []
    
    for i, prediction in enumerate(predictions):
        logger.info(f"Processing prediction {i+1}/{len(predictions)}: {prediction['id']}")
        processed_images = process_prediction_images(minio_client, prediction)
        all_processed_images.extend(processed_images)
    
    logger.info(f"✓ Processed {len(all_processed_images)} images total")
    
    # Step 5: Upload to MinIO
    if all_processed_images:
        logger.info("Step 5: Uploading candidates to MinIO")
        upload_stats = upload_candidates_to_minio(
            minio_client,
            collection_date,
            all_processed_images
        )
        
        # Step 6: Create manifest
        logger.info("Step 6: Creating collection manifest")
        create_collection_manifest(
            minio_client,
            collection_date,
            all_processed_images,
            upload_stats
        )
    else:
        logger.warning("No images to upload")
        upload_stats = {'uploaded': 0, 'failed': 0}
    
    # Cleanup
    db_conn.close()
    
    # Summary
    result = {
        'status': 'success',
        'collection_date': collection_date,
        'predictions_processed': len(predictions),
        'images_collected': len(all_processed_images),
        'images_uploaded': upload_stats.get('uploaded', 0),
        'images_failed': upload_stats.get('failed', 0)
    }
    
    logger.info("=" * 80)
    logger.info("FLOW COMPLETE")
    logger.info(f"Results: {result}")
    logger.info("=" * 80)
    
    return result


@flow(name="monthly_dataset_creation", log_prints=True)
def monthly_dataset_creation_flow(
    year: Optional[int] = None,
    month: Optional[int] = None
):
    """
    Monthly flow to create verified and full training datasets.
    
    Args:
        year: Year (YYYY), defaults to previous month
        month: Month (1-12), defaults to previous month
    """
    logger = get_run_logger()
    
    # Determine year and month (default to previous month)
    if year is None or month is None:
        now = datetime.now()
        # Get first day of current month, then subtract one day to get last month
        first_of_month = now.replace(day=1)
        prev_month = first_of_month - timedelta(days=1)
        year = prev_month.year
        month = prev_month.month
    
    logger.info("=" * 80)
    logger.info(f"MONTHLY DATASET CREATION FLOW - {year}-{month:02d}")
    logger.info("=" * 80)
    
    # Connect to MinIO
    logger.info("Connecting to MinIO")
    minio_client = connect_to_minio()
    
    # Create verified dataset
    logger.info("=" * 80)
    logger.info("Creating VERIFIED dataset")
    logger.info("=" * 80)
    verified_stats = create_monthly_dataset(
        minio_client,
        year,
        month,
        'verified'
    )
    
    logger.info(f"✓ Verified dataset created: {verified_stats}")
    
    # Create full dataset
    logger.info("=" * 80)
    logger.info("Creating FULL dataset")
    logger.info("=" * 80)
    full_stats = create_monthly_dataset(
        minio_client,
        year,
        month,
        'full'
    )
    
    logger.info(f"✓ Full dataset created: {full_stats}")
    
    # Summary
    result = {
        'status': 'success',
        'year': year,
        'month': month,
        'verified_dataset': verified_stats,
        'full_dataset': full_stats
    }
    
    logger.info("=" * 80)
    logger.info("FLOW COMPLETE")
    logger.info(f"Results: {result}")
    logger.info("=" * 80)
    
    return result


if __name__ == "__main__":
    """For local testing"""
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "daily":
        # Run daily collection
        daily_data_collection_flow()
    elif len(sys.argv) > 1 and sys.argv[1] == "monthly":
        # Run monthly creation
        monthly_dataset_creation_flow()
    else:
        print("Usage:")
        print("  python dataset_management.py daily   - Run daily collection")
        print("  python dataset_management.py monthly - Run monthly creation")

