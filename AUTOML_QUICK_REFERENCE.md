# AutoML Quick Reference

Quick command reference for common AutoML operations.

## Service Management

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart AutoML service
docker-compose restart ml-automl

# View logs
docker-compose logs -f ml-automl
docker-compose logs -f prefect-server

# Check service status
docker-compose ps
```

## Access Points

```bash
# Prefect UI
open http://localhost:4200

# MinIO Console
open http://localhost:9001

# ML Inference API
open http://localhost:8000/docs
```

## Flow Operations

```bash
# List deployments
docker-compose exec ml-automl prefect deployment ls

# Trigger daily collection
docker-compose exec ml-automl prefect deployment run 'daily_data_collection/daily-collection'

# Trigger monthly creation
docker-compose exec ml-automl prefect deployment run 'monthly_dataset_creation/monthly-creation'

# Run flow directly (for testing)
docker-compose exec ml-automl python flows/dataset_management.py daily
docker-compose exec ml-automl python flows/dataset_management.py monthly

# View flow runs
docker-compose exec ml-automl prefect flow-run ls
```

## Database Queries

```bash
# Count today's predictions
docker-compose exec postgres psql -U ${DB_USER} -d ${DB_NAME} -c \
  "SELECT COUNT(*) FROM user_styles WHERE created_at >= CURRENT_DATE;"

# Count verified predictions
docker-compose exec postgres psql -U ${DB_USER} -d ${DB_NAME} -c \
  "SELECT COUNT(*) FROM user_styles WHERE is_verified = true;"

# Check class distribution
docker-compose exec postgres psql -U ${DB_USER} -d ${DB_NAME} -c \
  "SELECT style_id, COUNT(*) FROM user_styles GROUP BY style_id ORDER BY COUNT(*) DESC;"

# Recent predictions
docker-compose exec postgres psql -U ${DB_USER} -d ${DB_NAME} -c \
  "SELECT id, user_id, style_id, is_verified, created_at FROM user_styles ORDER BY created_at DESC LIMIT 10;"
```

## MinIO Operations

```bash
# List datasets
docker-compose exec minio-init mc ls myminio/ml-artifacts/datasets/ --insecure

# List candidate collections
docker-compose exec minio-init mc ls myminio/ml-artifacts/datasets/candidates/ --insecure

# View manifest
docker-compose exec minio-init mc cat myminio/ml-artifacts/datasets/verified/2024-11/manifest.json --insecure

# Count images in a dataset
docker-compose exec minio-init mc ls --recursive myminio/ml-artifacts/datasets/verified/2024-11/ --insecure | wc -l

# Check bucket size
docker-compose exec minio-init mc du myminio/ml-artifacts --insecure
```

## Monitoring

```bash
# Check Prefect server health
curl http://localhost:4200/api/health

# Check ML inference health
curl http://localhost:8000/health

# Check MinIO health
curl http://localhost:9000/minio/health/live

# View work pools
docker-compose exec ml-automl prefect work-pool ls

# View recent flow runs
docker-compose exec ml-automl prefect flow-run ls --limit 10
```

## Troubleshooting

```bash
# Test database connection
docker-compose exec ml-automl python -c "
from config import settings
import psycopg2
conn = psycopg2.connect(settings.db.connection_string)
print('✓ Database OK')
conn.close()
"

# Test MinIO connection
docker-compose exec ml-automl python -c "
from minio import Minio
from config import settings
client = Minio(settings.minio.endpoint, 
               access_key=settings.minio.access_key,
               secret_key=settings.minio.secret_key,
               secure=False)
print('✓ MinIO OK')
print('Buckets:', [b.name for b in client.list_buckets()])
"

# Check environment variables
docker-compose exec ml-automl env | grep -E 'DB_|MINIO_|PREFECT_'

# Restart everything
docker-compose restart prefect-postgres prefect-server ml-automl
```

## Deployment

```bash
# Deploy flows (if needed)
docker-compose exec ml-automl python deploy_flows.py

# Create work pool manually
docker-compose exec ml-automl prefect work-pool create default-pool --type process
```

## Data Upload

```bash
# Upload gold dataset (example using mc)
docker-compose exec minio-init mc cp --recursive /local/path/to/gold/ \
  myminio/ml-artifacts/datasets/gold/ --insecure

# Or using MinIO console at http://localhost:9001
# Navigate to ml-artifacts bucket > datasets > gold
```

## Development

```bash
# Enter automl container
docker-compose exec ml-automl bash

# Install additional packages (temporary)
docker-compose exec ml-automl pip install package-name

# View Python files
docker-compose exec ml-automl ls -la flows/ tasks/ config/

# Check Python version and packages
docker-compose exec ml-automl python --version
docker-compose exec ml-automl pip list
```

## Common Issues & Solutions

### Flow Not Running
```bash
# Check if worker is active
docker-compose exec ml-automl prefect work-pool preview default-pool

# Restart worker
docker-compose restart ml-automl
```

### Database Connection Error
```bash
# Verify database is running
docker-compose ps postgres

# Test connection
docker-compose exec ml-automl nc -zv postgres 5432
```

### MinIO Access Error
```bash
# Verify MinIO is running
docker-compose ps minio

# Check buckets exist
docker-compose exec minio-init mc ls myminio/ --insecure
```

### Prefect Server Down
```bash
# Check Prefect logs
docker-compose logs prefect-server

# Restart Prefect stack
docker-compose restart prefect-postgres prefect-server ml-automl
```

## Useful Prefect Commands

```bash
# Inside ml-automl container
docker-compose exec ml-automl bash

# List all flows
prefect flow ls

# List all deployments
prefect deployment ls

# View specific deployment
prefect deployment inspect daily_data_collection/daily-collection

# Cancel a flow run
prefect flow-run cancel <flow-run-id>

# Delete a deployment (careful!)
prefect deployment delete daily_data_collection/daily-collection
```

## Environment Variables

Key variables in `.env`:

```bash
# Database
DB_HOST=postgres
DB_PORT=5432
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=suitesme

# MinIO
MINIO_ROOT_USER=your_minio_user
MINIO_ROOT_PASSWORD=your_minio_password
STYLE_PHOTO_BUCKET=style-photos
ML_ARTIFACTS_BUCKET=ml-artifacts

# Auto-configured in docker-compose
PREFECT_API_URL=http://prefect-server:4200/api
PREFECT_WORK_POOL=default-pool
MINIO_ENDPOINT=minio:9000
```

## Dataset Paths

```
ML_ARTIFACTS_BUCKET/
├── datasets/
│   ├── gold/                           # Base training dataset
│   ├── candidates/YYYY-MM-DD/          # Daily collections
│   ├── verified/YYYY-MM/               # Monthly verified datasets
│   └── full/YYYY-MM/                   # Monthly full datasets
├── models/checkpoints/                 # Model weights
└── metadata/                           # Additional metadata
```

## Face Classes

```
Aristocratic, Business, Fire, Fragile, Heroin,
Inferno, Melting, Queen, Renaissance, Serious,
Soft, Strong, Sunny, Vintage, Warm
```

## Cron Schedules

- **Daily Collection**: `0 0 * * *` (every day at 00:00 UTC)
- **Monthly Creation**: `0 1 1 * *` (1st of month at 01:00 UTC)

---

For detailed documentation, see:
- `ml/automl/README.md` - Full AutoML documentation
- `AUTOML_SETUP.md` - Setup guide
- `IMPLEMENTATION_SUMMARY.md` - Implementation details

