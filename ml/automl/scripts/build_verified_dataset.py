#!/usr/bin/env python3
"""
Build a verified dataset directly from the database.
Fetches all verified predictions, downloads images from MinIO,
and organizes them into train/val/test splits by class.

Structure:
  datasets/verified-from-db/{version}/
    train/{class_name}/...
    val/{class_name}/...
    test/{class_name}/...
    manifest.json
"""

import json
import sys
import math
from datetime import datetime
from io import BytesIO
from collections import defaultdict

import psycopg2
from psycopg2.extras import RealDictCursor
from minio import Minio
from minio.error import S3Error

sys.path.insert(0, '/app/automl')
from config import settings


TRAIN_RATIO = 0.8
VAL_RATIO   = 0.1
TEST_RATIO  = 0.1

VERSION = datetime.now().strftime("%Y-%m")
DATASET_PATH = f"datasets/verified-from-db/{VERSION}"
BUCKET = settings.minio.ml_artifacts_bucket


def connect_db():
    return psycopg2.connect(
        host=settings.db.host,
        port=settings.db.port,
        user=settings.db.user,
        password=settings.db.password,
        database=settings.db.database
    )


def connect_minio():
    return Minio(
        settings.minio.endpoint,
        access_key=settings.minio.access_key,
        secret_key=settings.minio.secret_key,
        secure=settings.minio.secure
    )


def fetch_verified_predictions(conn):
    """Fetch all verified predictions grouped by class."""
    query = """
        SELECT
            id, user_id, photo_url, photo_urls,
            style_id, initial_prediction, confidence,
            verified_at, created_at
        FROM db_user_styles
        WHERE is_verified = true
          AND style_id IS NOT NULL
          AND style_id != ''
        ORDER BY style_id, created_at
    """
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(query)
        rows = cur.fetchall()
    return [dict(r) for r in rows]


def get_photo_urls(prediction):
    """Extract list of photo URLs from a prediction record."""
    urls = []
    if prediction.get('photo_urls'):
        try:
            raw = prediction['photo_urls']
            data = json.loads(raw) if isinstance(raw, str) else raw
            if isinstance(data, list):
                urls.extend(data)
            elif isinstance(data, dict):
                urls.extend(data.get('urls', []))
        except Exception:
            pass
    if not urls and prediction.get('photo_url'):
        urls.append(prediction['photo_url'])
    return [u for u in urls if u]


def extract_object_path(url):
    """Extract MinIO object path from URL."""
    parts = url.split('/')
    bucket = settings.minio.style_photo_bucket
    if bucket in parts:
        idx = parts.index(bucket)
        return '/'.join(parts[idx + 1:])
    if len(parts) >= 5:
        return '/'.join(parts[4:])
    return None


def download_image(minio_client, url):
    """Download image bytes from MinIO."""
    obj_path = extract_object_path(url)
    if not obj_path:
        return None
    try:
        resp = minio_client.get_object(settings.minio.style_photo_bucket, obj_path)
        data = resp.read()
        resp.close()
        resp.release_conn()
        return data
    except S3Error:
        return None
    except Exception:
        return None


def upload_image(minio_client, data, dest_path):
    """Upload image bytes to MinIO."""
    minio_client.put_object(
        BUCKET,
        dest_path,
        BytesIO(data),
        length=len(data),
        content_type='image/jpeg'
    )


def split_indices(n):
    """Return (train_end, val_end) indices for n items."""
    train_end = max(1, math.floor(n * TRAIN_RATIO))
    val_end   = train_end + max(1, math.floor(n * VAL_RATIO))
    if val_end >= n:
        val_end = n - 1
    return train_end, val_end


def build_dataset():
    print("=" * 70)
    print(f"Building verified dataset from DB -> {DATASET_PATH}")
    print("=" * 70)

    conn = connect_db()
    minio_client = connect_minio()
    print("✓ Connected to DB and MinIO")

    predictions = fetch_verified_predictions(conn)
    conn.close()
    print(f"✓ Fetched {len(predictions)} verified predictions")

    # Group by class
    by_class = defaultdict(list)
    for p in predictions:
        by_class[p['style_id']].append(p)

    print(f"\nClass distribution:")
    for cls in sorted(by_class):
        print(f"  {cls:15s}: {len(by_class[cls])}")

    # Track stats
    split_counts = {'train': 0, 'val': 0, 'test': 0}
    class_split_counts = {}
    failed = 0
    total_uploaded = 0

    print(f"\nDownloading and uploading images...")

    for class_name, preds in sorted(by_class.items()):
        train_end, val_end = split_indices(len(preds))
        class_split_counts[class_name] = {'train': 0, 'val': 0, 'test': 0}

        for i, pred in enumerate(preds):
            if i < train_end:
                split = 'train'
            elif i < val_end:
                split = 'val'
            else:
                split = 'test'

            urls = get_photo_urls(pred)
            if not urls:
                failed += 1
                continue

            pred_id = str(pred['id'])
            for img_idx, url in enumerate(urls):
                data = download_image(minio_client, url)
                if data is None:
                    failed += 1
                    continue

                filename = f"pred_{pred_id}_img_{img_idx}.jpg"
                dest = f"{DATASET_PATH}/{split}/{class_name}/{filename}"

                try:
                    upload_image(minio_client, data, dest)
                    split_counts[split] += 1
                    class_split_counts[class_name][split] += 1
                    total_uploaded += 1
                except Exception as e:
                    print(f"  ✗ Upload failed {dest}: {e}")
                    failed += 1

        print(f"  ✓ {class_name}: "
              f"train={class_split_counts[class_name]['train']} "
              f"val={class_split_counts[class_name]['val']} "
              f"test={class_split_counts[class_name]['test']}")

    # Create manifest
    manifest = {
        'dataset_type': 'verified-from-db',
        'version': f"{VERSION}-v1",
        'created_at': datetime.now().isoformat(),
        'total_images': total_uploaded,
        'failed_images': failed,
        'splits': split_counts,
        'class_distribution': {
            cls: sum(v.values()) for cls, v in class_split_counts.items()
        },
        'class_split_distribution': class_split_counts,
        'train_ratio': TRAIN_RATIO,
        'val_ratio': VAL_RATIO,
        'test_ratio': TEST_RATIO
    }

    manifest_json = json.dumps(manifest, indent=2)
    minio_client.put_object(
        BUCKET,
        f"{DATASET_PATH}/manifest.json",
        BytesIO(manifest_json.encode()),
        length=len(manifest_json),
        content_type='application/json'
    )

    print(f"\n{'=' * 70}")
    print(f"DONE")
    print(f"  Uploaded : {total_uploaded}")
    print(f"  Failed   : {failed}")
    print(f"  Train    : {split_counts['train']}")
    print(f"  Val      : {split_counts['val']}")
    print(f"  Test     : {split_counts['test']}")
    print(f"  Path     : {DATASET_PATH}/")
    print(f"  Manifest : {DATASET_PATH}/manifest.json")
    print(f"{'=' * 70}")


if __name__ == "__main__":
    build_dataset()
