"""
Data collection task for gathering new predictions daily.
Collects images from user_styles table and stores them in MinIO.
"""

import json
import logging
import os
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
from io import BytesIO

import psycopg2
from psycopg2.extras import RealDictCursor
from minio import Minio
from minio.error import S3Error
from PIL import Image
from prefect import task, get_run_logger

from config import settings


@task(name="connect_to_database", retries=3, retry_delay_seconds=10)
def connect_to_database() -> psycopg2.extensions.connection:
    """
    Connect to PostgreSQL database.
    
    Returns:
        Database connection object
    """
    logger = get_run_logger()
    logger.info(f"Connecting to database: {settings.db.host}:{settings.db.port}/{settings.db.database}")
    
    try:
        conn = psycopg2.connect(
            host=settings.db.host,
            port=settings.db.port,
            user=settings.db.user,
            password=settings.db.password,
            database=settings.db.database
        )
        logger.info("✓ Database connection established")
        return conn
    except Exception as e:
        logger.error(f"Failed to connect to database: {e}")
        raise


@task(name="connect_to_minio", retries=3, retry_delay_seconds=10)
def connect_to_minio() -> Minio:
    """
    Connect to MinIO storage.
    
    Returns:
        MinIO client object
    """
    logger = get_run_logger()
    logger.info(f"Connecting to MinIO: {settings.minio.endpoint}")
    
    try:
        client = Minio(
            settings.minio.endpoint,
            access_key=settings.minio.access_key,
            secret_key=settings.minio.secret_key,
            secure=settings.minio.secure
        )
        logger.info("✓ MinIO connection established")
        return client
    except Exception as e:
        logger.error(f"Failed to connect to MinIO: {e}")
        raise


@task(name="fetch_new_predictions")
def fetch_new_predictions(
    conn: psycopg2.extensions.connection,
    since_date: Optional[datetime] = None
) -> List[Dict[str, Any]]:
    """
    Fetch new predictions from user_styles table since last collection.
    
    Args:
        conn: Database connection
        since_date: Fetch predictions after this date (defaults to yesterday)
    
    Returns:
        List of prediction records
    """
    logger = get_run_logger()
    
    if since_date is None:
        # Default to yesterday 00:00:00
        since_date = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(days=1)
    
    logger.info(f"Fetching predictions since: {since_date}")
    
    query = """
        SELECT 
            id, user_id, photo_url, photo_urls, style_id, 
            initial_prediction, confidence, is_verified, 
            verified_by, verified_at, created_at, updated_at
        FROM db_user_styles
        WHERE created_at >= %s
        ORDER BY created_at DESC
    """
    
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(query, (since_date,))
            results = cursor.fetchall()
            
        # Convert to list of dicts
        predictions = [dict(row) for row in results]
        
        logger.info(f"✓ Fetched {len(predictions)} predictions")
        return predictions
        
    except Exception as e:
        logger.error(f"Failed to fetch predictions: {e}")
        raise


@task(name="download_image_from_minio")
def download_image_from_minio(
    minio_client: Minio,
    bucket_name: str,
    object_name: str
) -> Optional[bytes]:
    """
    Download an image from MinIO.
    
    Args:
        minio_client: MinIO client
        bucket_name: Bucket name
        object_name: Object path in bucket
    
    Returns:
        Image bytes or None if failed
    """
    logger = get_run_logger()
    
    try:
        response = minio_client.get_object(bucket_name, object_name)
        image_data = response.read()
        response.close()
        response.release_conn()
        
        logger.debug(f"Downloaded {object_name} ({len(image_data)} bytes)")
        return image_data
        
    except S3Error as e:
        logger.warning(f"Failed to download {object_name}: {e}")
        return None
    except Exception as e:
        logger.error(f"Error downloading {object_name}: {e}")
        return None


@task(name="extract_minio_path_from_url")
def extract_minio_path_from_url(url: str) -> Optional[str]:
    """
    Extract MinIO object path from URL.
    
    Args:
        url: Full URL (e.g., http://minio:9000/bucket/path/to/file.jpg)
    
    Returns:
        Object path (e.g., path/to/file.jpg) or None
    """
    logger = get_run_logger()
    
    try:
        # Parse URL to extract path after bucket name
        # Expected format: http://host:port/bucket/path/to/file.jpg
        parts = url.split('/')
        
        # Find bucket name and extract everything after it
        if settings.minio.style_photo_bucket in parts:
            bucket_idx = parts.index(settings.minio.style_photo_bucket)
            object_path = '/'.join(parts[bucket_idx + 1:])
            return object_path
        else:
            # Try direct path extraction (everything after domain)
            # Skip protocol and domain parts
            if len(parts) >= 4:
                # parts[0] = http:, parts[1] = '', parts[2] = domain:port, parts[3] = bucket, parts[4+] = path
                object_path = '/'.join(parts[4:])
                return object_path
            
        logger.warning(f"Could not extract path from URL: {url}")
        return None
        
    except Exception as e:
        logger.error(f"Error extracting path from URL {url}: {e}")
        return None


@task(name="process_prediction_images")
def process_prediction_images(
    minio_client: Minio,
    prediction: Dict[str, Any]
) -> List[Dict[str, Any]]:
    """
    Process all images for a single prediction.
    
    Args:
        minio_client: MinIO client
        prediction: Prediction record from database
    
    Returns:
        List of processed image info dicts
    """
    logger = get_run_logger()
    prediction_id = str(prediction['id'])
    
    # Extract photo URLs
    photo_urls = []
    
    # Check photo_urls JSONB field first
    if prediction.get('photo_urls'):
        try:
            if isinstance(prediction['photo_urls'], str):
                urls_data = json.loads(prediction['photo_urls'])
            else:
                urls_data = prediction['photo_urls']
            
            if isinstance(urls_data, list):
                photo_urls.extend(urls_data)
            elif isinstance(urls_data, dict):
                # Sometimes stored as {"urls": [...]}
                photo_urls.extend(urls_data.get('urls', []))
        except Exception as e:
            logger.warning(f"Failed to parse photo_urls for {prediction_id}: {e}")
    
    # Fallback to single photo_url field
    if not photo_urls and prediction.get('photo_url'):
        photo_urls.append(prediction['photo_url'])
    
    if not photo_urls:
        logger.warning(f"No photo URLs found for prediction {prediction_id}")
        return []
    
    logger.info(f"Processing {len(photo_urls)} images for prediction {prediction_id}")
    
    # Download and process each image
    processed_images = []
    
    for idx, url in enumerate(photo_urls):
        if not url:
            continue
        
        # Extract MinIO path from URL
        object_path = extract_minio_path_from_url(url)
        if not object_path:
            logger.warning(f"Could not extract path from URL: {url}")
            continue
        
        # Download image
        image_data = download_image_from_minio(
            minio_client,
            settings.minio.style_photo_bucket,
            object_path
        )
        
        if image_data:
            processed_images.append({
                'prediction_id': prediction_id,
                'user_id': str(prediction['user_id']),
                'image_index': idx,
                'original_url': url,
                'image_data': image_data,
                'style_id': prediction['style_id'],
                'initial_prediction': prediction.get('initial_prediction'),
                'is_verified': prediction['is_verified'],
                'confidence': prediction.get('confidence', 0.0),
                'created_at': prediction['created_at'].isoformat() if prediction.get('created_at') else None
            })
    
    logger.info(f"✓ Processed {len(processed_images)} images for prediction {prediction_id}")
    return processed_images


@task(name="upload_candidates_to_minio")
def upload_candidates_to_minio(
    minio_client: Minio,
    collection_date: str,
    processed_images: List[Dict[str, Any]]
) -> Dict[str, Any]:
    """
    Upload processed images to MinIO as training candidates.
    
    Args:
        minio_client: MinIO client
        collection_date: Date string (YYYY-MM-DD)
        processed_images: List of processed image dicts
    
    Returns:
        Upload statistics
    """
    logger = get_run_logger()
    logger.info(f"Uploading {len(processed_images)} images to candidates/{collection_date}")
    
    bucket = settings.minio.ml_artifacts_bucket
    base_path = f"datasets/candidates/{collection_date}"
    
    uploaded_count = 0
    failed_count = 0
    
    for img_info in processed_images:
        # Organize by class: datasets/candidates/YYYY-MM-DD/{class_name}/user_{id}_img_{n}.jpg
        class_name = img_info['style_id']
        file_name = f"user_{img_info['user_id']}_pred_{img_info['prediction_id']}_img_{img_info['image_index']}.jpg"
        object_path = f"{base_path}/{class_name}/{file_name}"
        
        try:
            # Upload image
            image_stream = BytesIO(img_info['image_data'])
            minio_client.put_object(
                bucket,
                object_path,
                image_stream,
                length=len(img_info['image_data']),
                content_type='image/jpeg'
            )
            uploaded_count += 1
            logger.debug(f"Uploaded: {object_path}")
            
        except Exception as e:
            logger.error(f"Failed to upload {object_path}: {e}")
            failed_count += 1
    
    stats = {
        'collection_date': collection_date,
        'total_images': len(processed_images),
        'uploaded': uploaded_count,
        'failed': failed_count
    }
    
    logger.info(f"✓ Upload complete: {uploaded_count} uploaded, {failed_count} failed")
    return stats


@task(name="create_collection_manifest")
def create_collection_manifest(
    minio_client: Minio,
    collection_date: str,
    processed_images: List[Dict[str, Any]],
    upload_stats: Dict[str, Any]
) -> None:
    """
    Create and upload a manifest file for the collection.
    
    Args:
        minio_client: MinIO client
        collection_date: Date string (YYYY-MM-DD)
        processed_images: List of processed image dicts
        upload_stats: Upload statistics
    """
    logger = get_run_logger()
    logger.info("Creating collection manifest")
    
    # Gather statistics
    class_distribution = {}
    verified_count = 0
    unverified_count = 0
    
    for img_info in processed_images:
        class_name = img_info['style_id']
        class_distribution[class_name] = class_distribution.get(class_name, 0) + 1
        
        if img_info['is_verified']:
            verified_count += 1
        else:
            unverified_count += 1
    
    manifest = {
        'collection_date': collection_date,
        'created_at': datetime.now().isoformat(),
        'total_images': len(processed_images),
        'verified_images': verified_count,
        'unverified_images': unverified_count,
        'class_distribution': class_distribution,
        'upload_stats': upload_stats,
        'images': [
            {
                'prediction_id': img['prediction_id'],
                'user_id': img['user_id'],
                'image_index': img['image_index'],
                'class': img['style_id'],
                'initial_prediction': img['initial_prediction'],
                'is_verified': img['is_verified'],
                'confidence': img['confidence'],
                'created_at': img['created_at']
            }
            for img in processed_images
        ]
    }
    
    # Upload manifest
    bucket = settings.minio.ml_artifacts_bucket
    manifest_path = f"datasets/candidates/{collection_date}/manifest.json"
    
    try:
        manifest_json = json.dumps(manifest, indent=2)
        manifest_stream = BytesIO(manifest_json.encode('utf-8'))
        
        minio_client.put_object(
            bucket,
            manifest_path,
            manifest_stream,
            length=len(manifest_json),
            content_type='application/json'
        )
        
        logger.info(f"✓ Manifest uploaded to {manifest_path}")
        
    except Exception as e:
        logger.error(f"Failed to upload manifest: {e}")
        raise

