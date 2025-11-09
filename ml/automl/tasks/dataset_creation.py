"""
Dataset creation task for assembling monthly training datasets.
Creates verified and full datasets from gold + candidates.
"""

import json
import logging
from datetime import datetime
from typing import List, Dict, Any, Optional, Tuple
from io import BytesIO
from collections import defaultdict

from minio import Minio
from minio.error import S3Error
from prefect import task, get_run_logger

from config import settings


@task(name="list_candidate_collections")
def list_candidate_collections(
    minio_client: Minio,
    year: int,
    month: int
) -> List[str]:
    """
    List all candidate collection dates for a given month.
    
    Args:
        minio_client: MinIO client
        year: Year (YYYY)
        month: Month (1-12)
    
    Returns:
        List of collection date strings (YYYY-MM-DD)
    """
    logger = get_run_logger()
    logger.info(f"Listing candidate collections for {year}-{month:02d}")
    
    bucket = settings.minio.ml_artifacts_bucket
    prefix = f"datasets/candidates/{year}-{month:02d}"
    
    collection_dates = set()
    
    try:
        objects = minio_client.list_objects(bucket, prefix=prefix, recursive=False)
        
        for obj in objects:
            # Extract date from path: datasets/candidates/YYYY-MM-DD/...
            parts = obj.object_name.split('/')
            if len(parts) >= 3:
                date_str = parts[2]
                if date_str.startswith(f"{year}-{month:02d}"):
                    collection_dates.add(date_str)
        
        collection_list = sorted(list(collection_dates))
        logger.info(f"✓ Found {len(collection_list)} collection dates: {collection_list}")
        return collection_list
        
    except Exception as e:
        logger.error(f"Failed to list candidate collections: {e}")
        raise


@task(name="load_collection_manifest")
def load_collection_manifest(
    minio_client: Minio,
    collection_date: str
) -> Optional[Dict[str, Any]]:
    """
    Load manifest for a specific collection date.
    
    Args:
        minio_client: MinIO client
        collection_date: Date string (YYYY-MM-DD)
    
    Returns:
        Manifest dict or None if not found
    """
    logger = get_run_logger()
    
    bucket = settings.minio.ml_artifacts_bucket
    manifest_path = f"datasets/candidates/{collection_date}/manifest.json"
    
    try:
        response = minio_client.get_object(bucket, manifest_path)
        manifest_data = response.read()
        response.close()
        response.release_conn()
        
        manifest = json.loads(manifest_data)
        logger.debug(f"Loaded manifest for {collection_date}")
        return manifest
        
    except S3Error as e:
        logger.warning(f"Manifest not found for {collection_date}: {e}")
        return None
    except Exception as e:
        logger.error(f"Error loading manifest for {collection_date}: {e}")
        return None


@task(name="copy_gold_dataset")
def copy_gold_dataset(
    minio_client: Minio,
    destination_path: str
) -> Dict[str, int]:
    """
    Copy gold dataset to destination path.
    
    Args:
        minio_client: MinIO client
        destination_path: Destination path prefix (e.g., datasets/verified/2024-11)
    
    Returns:
        Statistics dict with counts per class
    """
    logger = get_run_logger()
    logger.info(f"Copying gold dataset to {destination_path}")
    
    bucket = settings.minio.ml_artifacts_bucket
    gold_prefix = "datasets/gold/"
    
    class_counts = defaultdict(int)
    total_copied = 0
    
    try:
        # List all objects in gold dataset
        objects = minio_client.list_objects(bucket, prefix=gold_prefix, recursive=True)
        
        for obj in objects:
            # Skip directories and manifest files
            if obj.is_dir or obj.object_name.endswith('.json') or obj.object_name.endswith('.md'):
                continue
            
            # Extract class name from path: datasets/gold/{class_name}/image.jpg
            parts = obj.object_name.split('/')
            if len(parts) < 3:
                continue
            
            class_name = parts[2]
            file_name = parts[-1]
            
            # New destination path
            dest_path = f"{destination_path}/{class_name}/{file_name}"
            
            # Copy object
            try:
                minio_client.copy_object(
                    bucket,
                    dest_path,
                    f"{bucket}/{obj.object_name}"
                )
                class_counts[class_name] += 1
                total_copied += 1
                
            except Exception as e:
                logger.error(f"Failed to copy {obj.object_name}: {e}")
        
        logger.info(f"✓ Copied {total_copied} images from gold dataset")
        logger.info(f"  Class distribution: {dict(class_counts)}")
        
        return dict(class_counts)
        
    except Exception as e:
        logger.error(f"Failed to copy gold dataset: {e}")
        raise


@task(name="copy_candidate_images")
def copy_candidate_images(
    minio_client: Minio,
    collection_dates: List[str],
    destination_path: str,
    verified_only: bool = False
) -> Dict[str, int]:
    """
    Copy candidate images to destination dataset.
    
    Args:
        minio_client: MinIO client
        collection_dates: List of collection date strings
        destination_path: Destination path prefix
        verified_only: If True, only copy verified images
    
    Returns:
        Statistics dict with counts per class
    """
    logger = get_run_logger()
    logger.info(f"Copying candidates from {len(collection_dates)} collections (verified_only={verified_only})")
    
    bucket = settings.minio.ml_artifacts_bucket
    class_counts = defaultdict(int)
    total_copied = 0
    total_skipped = 0
    
    for collection_date in collection_dates:
        # Load manifest to check verification status
        manifest = load_collection_manifest(minio_client, collection_date)
        
        # Create lookup for verified images
        verified_images = set()
        if manifest and verified_only:
            for img in manifest.get('images', []):
                if img.get('is_verified'):
                    # Create identifier: user_{id}_pred_{pred_id}_img_{idx}.jpg
                    img_id = f"user_{img['user_id']}_pred_{img['prediction_id']}_img_{img['image_index']}.jpg"
                    verified_images.add(img_id)
        
        # List and copy images
        candidate_prefix = f"datasets/candidates/{collection_date}/"
        
        try:
            objects = minio_client.list_objects(bucket, prefix=candidate_prefix, recursive=True)
            
            for obj in objects:
                # Skip directories and manifest files
                if obj.is_dir or obj.object_name.endswith('.json'):
                    continue
                
                # Extract class name and file name
                # Path: datasets/candidates/YYYY-MM-DD/{class_name}/user_{id}_pred_{pred_id}_img_{idx}.jpg
                parts = obj.object_name.split('/')
                if len(parts) < 4:
                    continue
                
                class_name = parts[3]
                file_name = parts[-1]
                
                # Check if verified (if required)
                if verified_only and file_name not in verified_images:
                    total_skipped += 1
                    continue
                
                # New destination path
                dest_path = f"{destination_path}/{class_name}/{file_name}"
                
                # Copy object
                try:
                    minio_client.copy_object(
                        bucket,
                        dest_path,
                        f"{bucket}/{obj.object_name}"
                    )
                    class_counts[class_name] += 1
                    total_copied += 1
                    
                except Exception as e:
                    logger.error(f"Failed to copy {obj.object_name}: {e}")
            
        except Exception as e:
            logger.error(f"Failed to list candidates for {collection_date}: {e}")
    
    logger.info(f"✓ Copied {total_copied} candidate images, skipped {total_skipped}")
    logger.info(f"  Class distribution: {dict(class_counts)}")
    
    return dict(class_counts)


@task(name="create_dataset_manifest")
def create_dataset_manifest(
    minio_client: Minio,
    dataset_path: str,
    dataset_type: str,
    year: int,
    month: int,
    gold_stats: Dict[str, int],
    candidate_stats: Dict[str, int],
    collection_dates: List[str]
) -> None:
    """
    Create and upload dataset manifest and documentation.
    
    Args:
        minio_client: MinIO client
        dataset_path: Dataset path prefix
        dataset_type: 'verified' or 'full'
        year: Year
        month: Month
        gold_stats: Gold dataset statistics
        candidate_stats: Candidate images statistics
        collection_dates: List of included collection dates
    """
    logger = get_run_logger()
    logger.info(f"Creating manifest for {dataset_type} dataset")
    
    bucket = settings.minio.ml_artifacts_bucket
    
    # Combine statistics
    total_class_counts = defaultdict(int)
    for class_name, count in gold_stats.items():
        total_class_counts[class_name] += count
    for class_name, count in candidate_stats.items():
        total_class_counts[class_name] += count
    
    total_images = sum(total_class_counts.values())
    gold_images = sum(gold_stats.values())
    candidate_images = sum(candidate_stats.values())
    
    # Create manifest.json
    manifest = {
        'dataset_type': dataset_type,
        'version': f"{year}-{month:02d}-v1",
        'created_at': datetime.now().isoformat(),
        'year': year,
        'month': month,
        'total_images': total_images,
        'gold_images': gold_images,
        'new_images': candidate_images,
        'collection_dates': collection_dates,
        'class_distribution': dict(total_class_counts),
        'gold_distribution': gold_stats,
        'candidate_distribution': candidate_stats
    }
    
    manifest_path = f"{dataset_path}/manifest.json"
    
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
    
    # Create dataset_info.md
    info_md = f"""# {dataset_type.capitalize()} Dataset - {year}-{month:02d}

## Overview

- **Dataset Type**: {dataset_type}
- **Version**: {year}-{month:02d}-v1
- **Created**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}
- **Total Images**: {total_images:,}
- **Gold Dataset Images**: {gold_images:,}
- **New Images**: {candidate_images:,}

## Collection Details

- **Year**: {year}
- **Month**: {month}
- **Collection Dates**: {len(collection_dates)} days
  - From: {collection_dates[0] if collection_dates else 'N/A'}
  - To: {collection_dates[-1] if collection_dates else 'N/A'}

## Class Distribution

| Class Name | Count | Percentage |
|------------|-------|------------|
"""
    
    for class_name in sorted(total_class_counts.keys()):
        count = total_class_counts[class_name]
        percentage = (count / total_images * 100) if total_images > 0 else 0
        info_md += f"| {class_name} | {count} | {percentage:.1f}% |\n"
    
    info_md += f"""
## Source Breakdown

### Gold Dataset
Total: {gold_images:,} images

"""
    
    for class_name in sorted(gold_stats.keys()):
        info_md += f"- {class_name}: {gold_stats[class_name]}\n"
    
    info_md += f"""
### New Candidates
Total: {candidate_images:,} images

"""
    
    for class_name in sorted(candidate_stats.keys()):
        info_md += f"- {class_name}: {candidate_stats[class_name]}\n"
    
    info_md += """
## Usage

This dataset can be used for training face classification models. Images are organized by class:

```
datasets/{type}/{year}-{month:02d}/
├── Aristocratic/
│   ├── image1.jpg
│   ├── image2.jpg
│   └── ...
├── Business/
│   └── ...
└── ...
```

## Notes

- Images are in JPEG format
- All images have been preprocessed and validated
- Verified datasets contain only admin-verified predictions
- Full datasets include both verified and unverified predictions
"""
    
    info_path = f"{dataset_path}/dataset_info.md"
    
    try:
        info_stream = BytesIO(info_md.encode('utf-8'))
        
        minio_client.put_object(
            bucket,
            info_path,
            info_stream,
            length=len(info_md),
            content_type='text/markdown'
        )
        
        logger.info(f"✓ Dataset info uploaded to {info_path}")
        
    except Exception as e:
        logger.error(f"Failed to upload dataset info: {e}")
        raise
    
    # Create version.txt
    version_txt = f"{year}-{month:02d}-v1"
    version_path = f"{dataset_path}/version.txt"
    
    try:
        version_stream = BytesIO(version_txt.encode('utf-8'))
        
        minio_client.put_object(
            bucket,
            version_path,
            version_stream,
            length=len(version_txt),
            content_type='text/plain'
        )
        
        logger.info(f"✓ Version file uploaded to {version_path}")
        
    except Exception as e:
        logger.error(f"Failed to upload version file: {e}")
        raise


@task(name="create_monthly_dataset")
def create_monthly_dataset(
    minio_client: Minio,
    year: int,
    month: int,
    dataset_type: str
) -> Dict[str, Any]:
    """
    Create a monthly dataset (verified or full).
    
    Args:
        minio_client: MinIO client
        year: Year (YYYY)
        month: Month (1-12)
        dataset_type: 'verified' or 'full'
    
    Returns:
        Dataset creation statistics
    """
    logger = get_run_logger()
    logger.info(f"Creating {dataset_type} dataset for {year}-{month:02d}")
    
    # Determine destination path
    destination_path = f"datasets/{dataset_type}/{year}-{month:02d}"
    
    # Get list of candidate collections for the month
    collection_dates = list_candidate_collections(minio_client, year, month)
    
    if not collection_dates:
        logger.warning(f"No candidate collections found for {year}-{month:02d}")
    
    # Copy gold dataset
    logger.info("Step 1: Copying gold dataset")
    gold_stats = copy_gold_dataset(minio_client, destination_path)
    
    # Copy candidate images
    logger.info(f"Step 2: Copying candidate images (verified_only={dataset_type == 'verified'})")
    candidate_stats = copy_candidate_images(
        minio_client,
        collection_dates,
        destination_path,
        verified_only=(dataset_type == 'verified')
    )
    
    # Create manifest and documentation
    logger.info("Step 3: Creating manifest and documentation")
    create_dataset_manifest(
        minio_client,
        destination_path,
        dataset_type,
        year,
        month,
        gold_stats,
        candidate_stats,
        collection_dates
    )
    
    # Return statistics
    stats = {
        'dataset_type': dataset_type,
        'year': year,
        'month': month,
        'destination_path': destination_path,
        'gold_images': sum(gold_stats.values()),
        'candidate_images': sum(candidate_stats.values()),
        'total_images': sum(gold_stats.values()) + sum(candidate_stats.values()),
        'collection_dates': len(collection_dates)
    }
    
    logger.info(f"✓ Dataset creation complete: {stats}")
    return stats

