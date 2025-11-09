# AutoML Dataset Management

Automated dataset management system using Prefect for orchestrating data collection and dataset creation workflows.

## Overview

This system provides automated workflows for:

1. **Daily Data Collection**: Collects new predictions from the database and stores them as training candidates in MinIO
2. **Monthly Dataset Creation**: Creates two versions of training datasets:
   - **Verified Dataset**: Gold dataset + verified predictions only
   - **Full Dataset**: Gold dataset + all predictions (verified and unverified)

## Architecture

```
ml/automl/
├── config/          # Configuration settings
├── tasks/           # Prefect tasks
│   ├── data_collection.py      # Daily collection tasks
│   └── dataset_creation.py     # Monthly creation tasks
├── flows/           # Prefect flows
│   └── dataset_management.py   # Flow orchestration
├── deploy_flows.py  # Deployment script
├── Dockerfile       # Container image
└── requirements.txt # Python dependencies
```

## Flows

### 1. Daily Data Collection Flow

**Schedule**: Every day at 00:00 UTC  
**Purpose**: Collect new predictions and prepare training candidates

**Process**:
1. Connect to PostgreSQL database
2. Fetch new predictions from `user_styles` table
3. Download up to 4 images per prediction from MinIO
4. Organize by class and upload to `datasets/candidates/{YYYY-MM-DD}/`
5. Create manifest with metadata

**Storage Structure**:
```
ML_ARTIFACTS_BUCKET/
└── datasets/
    └── candidates/
        └── 2024-11-06/
            ├── manifest.json
            ├── Aristocratic/
            │   ├── user_{id}_pred_{pred_id}_img_0.jpg
            │   └── ...
            ├── Business/
            └── ...
```

### 2. Monthly Dataset Creation Flow

**Schedule**: 1st day of month at 01:00 UTC  
**Purpose**: Create verified and full training datasets

**Process**:
1. List all candidate collections from the previous month
2. Copy gold dataset as base
3. Add candidates (filtered by verification status)
4. Generate manifest.json, dataset_info.md, and version.txt

**Storage Structure**:
```
ML_ARTIFACTS_BUCKET/
└── datasets/
    ├── gold/                    # Base training dataset
    │   ├── Aristocratic/
    │   ├── Business/
    │   └── ...
    ├── verified/
    │   └── 2024-11/             # Verified dataset for Nov 2024
    │       ├── manifest.json
    │       ├── dataset_info.md
    │       ├── version.txt
    │       ├── Aristocratic/
    │       └── ...
    └── full/
        └── 2024-11/             # Full dataset for Nov 2024
            ├── manifest.json
            ├── dataset_info.md
            ├── version.txt
            ├── Aristocratic/
            └── ...
```

## Deployment

### Using Docker Compose

The system is automatically deployed with docker-compose:

```bash
# Start all services (includes Prefect server and worker)
docker-compose up -d

# View Prefect logs
docker-compose logs -f ml-automl

# View Prefect UI
open http://localhost:4200
```

### Manual Deployment

If you need to manually deploy flows:

```bash
# Inside the automl container or with Prefect CLI configured
cd ml/automl
python deploy_flows.py
```

## Configuration

All configuration is loaded from environment variables:

### Database Configuration
- `DB_HOST` - PostgreSQL host (default: postgres)
- `DB_PORT` - PostgreSQL port (default: 5432)
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password
- `DB_NAME` - Database name

### MinIO Configuration
- `MINIO_ENDPOINT` - MinIO endpoint (default: minio:9000)
- `MINIO_ROOT_USER` - MinIO access key
- `MINIO_ROOT_PASSWORD` - MinIO secret key
- `STYLE_PHOTO_BUCKET` - Bucket for user photos
- `ML_ARTIFACTS_BUCKET` - Bucket for ML artifacts

### Prefect Configuration
- `PREFECT_API_URL` - Prefect server API URL
- `PREFECT_WORK_POOL` - Work pool name (default: default-pool)

## Manual Flow Execution

### Run Daily Collection

```bash
# Using Prefect CLI
prefect deployment run 'daily_data_collection/daily-collection'

# Or directly (for testing)
docker-compose exec ml-automl python -m flows.dataset_management daily
```

### Run Monthly Creation

```bash
# Using Prefect CLI
prefect deployment run 'monthly_dataset_creation/monthly-creation'

# Or directly (for testing)
docker-compose exec ml-automl python -m flows.dataset_management monthly

# For specific year/month
prefect deployment run 'monthly_dataset_creation/monthly-creation' \
  --param year=2024 --param month=11
```

## Monitoring

### Prefect UI

Access the Prefect UI at http://localhost:4200 to:
- View flow runs and their status
- Monitor task execution
- Check logs and errors
- Trigger manual runs
- View schedules

### Logs

```bash
# View automl service logs
docker-compose logs -f ml-automl

# View Prefect server logs
docker-compose logs -f prefect-server
```

## Data Schema

### user_styles Table

The system reads from the `user_styles` PostgreSQL table:

```sql
CREATE TABLE user_styles (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    photo_url VARCHAR(128),
    photo_urls JSONB,              -- Array of up to 4 image URLs
    style_id VARCHAR(64) NOT NULL,  -- Current/verified class
    initial_prediction VARCHAR(64), -- Original ML prediction
    confidence FLOAT8,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by INT,
    verified_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
```

### Manifest Format

Each dataset includes a `manifest.json`:

```json
{
  "dataset_type": "verified",
  "version": "2024-11-v1",
  "created_at": "2024-12-01T01:00:00",
  "year": 2024,
  "month": 11,
  "total_images": 1250,
  "gold_images": 1000,
  "new_images": 250,
  "collection_dates": ["2024-11-01", "2024-11-02", ...],
  "class_distribution": {
    "Aristocratic": 85,
    "Business": 92,
    ...
  }
}
```

## Troubleshooting

### Flow Not Running

1. Check if Prefect server is running:
   ```bash
   curl http://localhost:4200/api/health
   ```

2. Check if worker is running:
   ```bash
   docker-compose ps ml-automl
   ```

3. Check deployments:
   ```bash
   docker-compose exec ml-automl prefect deployment ls
   ```

### Database Connection Issues

- Verify database credentials in `.env`
- Check if PostgreSQL is accessible:
  ```bash
  docker-compose exec ml-automl nc -zv postgres 5432
  ```

### MinIO Connection Issues

- Verify MinIO is running and accessible:
  ```bash
  docker-compose ps minio
  curl http://localhost:9000/minio/health/live
  ```

- Check bucket exists:
  ```bash
  docker-compose exec minio-init mc ls myminio/${ML_ARTIFACTS_BUCKET}
  ```

## Development

### Run Tests Locally

```bash
cd ml/automl

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export DB_HOST=localhost
export DB_PORT=5433
export MINIO_ENDPOINT=localhost:9000
# ... other env vars

# Run a flow
python flows/dataset_management.py daily
```

### Add New Tasks

1. Create task in `tasks/` directory
2. Add `@task` decorator
3. Import and use in flows
4. Update deployment if schedule changes

## Class Names

The system supports 15 face classification classes:

- Aristocratic
- Business
- Fire
- Fragile
- Heroin
- Inferno
- Melting
- Queen
- Renaissance
- Serious
- Soft
- Strong
- Sunny
- Vintage
- Warm

## Version History

- **v1.0.0** - Initial release with daily collection and monthly creation flows

