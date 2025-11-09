# AutoML Dataset Management Setup Guide

This guide will help you set up and start using the automated dataset management system.

## Overview

The system has been enhanced with automated dataset management using Prefect:

- **Daily Data Collection**: Automatically collects new predictions at 00:00 UTC
- **Monthly Dataset Creation**: Creates training datasets on the 1st of each month at 01:00 UTC
- **Version Control**: Tracks dataset versions with manifests and documentation
- **MinIO Storage**: All datasets stored in ML_ARTIFACTS_BUCKET

## Architecture Changes

### ML Service Split

The ML service has been split into two services:

1. **ml-inference**: FastAPI service for real-time predictions (port 8000)
2. **ml-automl**: Prefect worker for dataset management workflows

### New Services Added

1. **prefect-server**: Prefect orchestration server (UI at port 4200)
2. **prefect-postgres**: Separate PostgreSQL for Prefect metadata

## Quick Start

### 1. Start All Services

```bash
# From project root
docker-compose up -d

# Wait for all services to be healthy
docker-compose ps
```

### 2. Access Prefect UI

Open http://localhost:4200 in your browser to access the Prefect dashboard.

### 3. Verify Deployments

The flows should be automatically deployed. Verify in the Prefect UI or via CLI:

```bash
docker-compose exec ml-automl prefect deployment ls
```

You should see:
- `daily_data_collection/daily-collection`
- `monthly_dataset_creation/monthly-creation`

### 4. Check MinIO Bucket Structure

Access MinIO Console at http://localhost:9001 and verify the ML_ARTIFACTS_BUCKET contains:

```
ml-artifacts/
├── datasets/
│   ├── gold/          # Place your gold training dataset here
│   ├── candidates/    # Daily collections will appear here
│   ├── verified/      # Monthly verified datasets
│   └── full/          # Monthly full datasets
├── models/
│   └── checkpoints/   # For storing model weights
└── metadata/          # Additional metadata
```

## Initial Setup

### 1. Upload Gold Training Dataset

Your gold training dataset should be uploaded to MinIO at:

```
ml-artifacts/datasets/gold/
├── Aristocratic/
│   ├── image1.jpg
│   ├── image2.jpg
│   └── ...
├── Business/
│   └── ...
└── ... (all 15 classes)
```

You can upload via:
- MinIO Console UI (http://localhost:9001)
- MinIO CLI (`mc` command)
- Python script with minio library

### 2. Verify Database Connection

Test that the automl service can connect to the database:

```bash
docker-compose exec ml-automl python -c "
from config import settings
import psycopg2
conn = psycopg2.connect(settings.db.connection_string)
print('✓ Database connection successful')
conn.close()
"
```

### 3. Test Data Collection Flow

Manually trigger the daily collection flow to test:

```bash
# Via Prefect CLI
docker-compose exec ml-automl prefect deployment run 'daily_data_collection/daily-collection'

# Or run directly
docker-compose exec ml-automl python flows/dataset_management.py daily
```

Check the Prefect UI to see the flow execution.

## Environment Variables

Ensure your `.env` file contains all required variables:

```bash
# Database
DB_HOST=postgres
DB_PORT=5432
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=suitesme

# MinIO
MINIO_ROOT_USER=your_minio_user
MINIO_ROOT_PASSWORD=your_minio_password
MINIO_ENDPOINT=minio:9000
STYLE_PHOTO_BUCKET=style-photos
ML_ARTIFACTS_BUCKET=ml-artifacts

# Prefect (auto-configured in docker-compose)
PREFECT_API_URL=http://prefect-server:4200/api
PREFECT_WORK_POOL=default-pool
```

## How It Works

### Daily Data Collection (00:00 UTC)

1. Connects to PostgreSQL and queries `user_styles` table for new records
2. For each prediction:
   - Extracts up to 4 photo URLs from `photo_urls` JSONB field
   - Downloads images from STYLE_PHOTO_BUCKET
   - Organizes by class (style_id)
3. Uploads to `ml-artifacts/datasets/candidates/YYYY-MM-DD/`
4. Creates manifest with metadata (verification status, confidence, etc.)

### Monthly Dataset Creation (1st of month, 01:00 UTC)

1. Lists all candidate collections from the previous month
2. Creates **Verified Dataset**:
   - Copies gold dataset as base
   - Adds only verified predictions (is_verified = true)
   - Uploads to `datasets/verified/YYYY-MM/`
3. Creates **Full Dataset**:
   - Copies gold dataset as base
   - Adds all predictions (verified + unverified)
   - Uploads to `datasets/full/YYYY-MM/`
4. Generates documentation:
   - `manifest.json`: Complete metadata
   - `dataset_info.md`: Human-readable summary
   - `version.txt`: Version identifier

## Manual Operations

### Trigger Daily Collection Manually

```bash
# Run for today
docker-compose exec ml-automl python flows/dataset_management.py daily

# Or via Prefect CLI
docker-compose exec ml-automl prefect deployment run 'daily_data_collection/daily-collection'
```

### Trigger Monthly Creation Manually

```bash
# Run for previous month
docker-compose exec ml-automl python flows/dataset_management.py monthly

# Or for specific year/month via Prefect CLI
docker-compose exec ml-automl prefect deployment run 'monthly_dataset_creation/monthly-creation' \
  --param year=2024 --param month=11
```

### View Logs

```bash
# AutoML service logs
docker-compose logs -f ml-automl

# Prefect server logs
docker-compose logs -f prefect-server

# All Prefect-related logs
docker-compose logs -f ml-automl prefect-server prefect-postgres
```

### Check Dataset Statistics

After monthly creation, check the manifest:

```bash
# Using MinIO CLI
docker-compose exec minio-init mc cat myminio/ml-artifacts/datasets/verified/2024-11/manifest.json

# Or download and view in browser
curl http://localhost:9000/ml-artifacts/datasets/verified/2024-11/manifest.json
```

## Monitoring

### Prefect UI (http://localhost:4200)

The Prefect UI provides:
- Flow run history and status
- Detailed logs for each task
- Scheduled runs calendar
- Manual flow triggering
- Work pool status

### Key Metrics to Monitor

1. **Daily Collection Success Rate**: Check if daily flows complete successfully
2. **Images Collected**: Number of images collected each day
3. **Monthly Dataset Sizes**: Total images in verified vs full datasets
4. **Class Distribution**: Balance of classes in datasets

### Alerts

Consider setting up alerts for:
- Failed flow runs
- Zero images collected (possible data pipeline issue)
- Database connection failures
- MinIO storage issues

## Troubleshooting

### Flow Not Running

**Check deployment:**
```bash
docker-compose exec ml-automl prefect deployment ls
```

**Check work pool:**
```bash
docker-compose exec ml-automl prefect work-pool ls
```

**Restart worker:**
```bash
docker-compose restart ml-automl
```

### No Images Collected

**Check database has new predictions:**
```bash
docker-compose exec postgres psql -U ${DB_USER} -d ${DB_NAME} -c \
  "SELECT COUNT(*) FROM user_styles WHERE created_at >= CURRENT_DATE - INTERVAL '1 day';"
```

**Check MinIO connectivity:**
```bash
docker-compose exec ml-automl python -c "
from minio import Minio
from config import settings
client = Minio(settings.minio.endpoint, 
               access_key=settings.minio.access_key,
               secret_key=settings.minio.secret_key,
               secure=False)
print('✓ MinIO connection successful')
print('Buckets:', [b.name for b in client.list_buckets()])
"
```

### Database Connection Error

**Test connection:**
```bash
docker-compose exec ml-automl nc -zv postgres 5432
```

**Check credentials:**
```bash
docker-compose exec ml-automl env | grep DB_
```

### Prefect Server Not Starting

**Check Prefect postgres:**
```bash
docker-compose ps prefect-postgres
docker-compose logs prefect-postgres
```

**Restart Prefect services:**
```bash
docker-compose restart prefect-postgres prefect-server ml-automl
```

## Next Steps

### 1. Model Training Integration

Future enhancements:
- Add training flow that uses created datasets
- Automated model evaluation
- Model versioning and rollback
- A/B testing of model versions

### 2. Data Quality Checks

Add tasks for:
- Image validation (corrupt files, wrong format)
- Class distribution monitoring
- Duplicate detection
- Quality metrics tracking

### 3. Advanced Features

- Real-time monitoring dashboard
- Email/Slack notifications for flow status
- Automatic data augmentation
- Transfer learning from gold dataset

## Support

For issues or questions:
1. Check logs: `docker-compose logs -f ml-automl`
2. Review Prefect UI: http://localhost:4200
3. Check MinIO Console: http://localhost:9001
4. Review documentation: `ml/automl/README.md`

## File Locations

- **Flow definitions**: `ml/automl/flows/dataset_management.py`
- **Task implementations**: `ml/automl/tasks/`
- **Configuration**: `ml/automl/config/settings.py`
- **Docker config**: `docker-compose.yml`
- **MinIO init**: `minio-init.sh`

---

**Last Updated**: November 2024  
**Version**: 1.0.0

