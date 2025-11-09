# ML Services

Machine Learning services for face classification and automated dataset management.

## Structure

```
ml/
├── inference/          # ML Inference API
│   ├── api.py         # FastAPI service for predictions
│   ├── src/           # Model implementations
│   ├── assets/        # Model weights and centroids
│   └── Dockerfile
│
└── automl/            # AutoML Dataset Management
    ├── config/        # Configuration management
    ├── tasks/         # Prefect tasks
    ├── flows/         # Prefect flows
    ├── deploy_flows.py
    ├── Dockerfile
    └── README.md      # Detailed documentation
```

## Services

### 1. ML Inference (`ml-inference`)

FastAPI-based service for real-time face classification predictions.

- **Port**: 8000
- **API Docs**: http://localhost:8000/docs
- **Purpose**: Provides prediction API for user photos

**Key Endpoints**:
- `POST /predict` - Predict face class from base64 images
- `GET /classes` - Get available face classes
- `GET /health` - Health check

See `inference/README_API.md` for detailed API documentation.

### 2. AutoML Dataset Management (`ml-automl`)

Prefect-based orchestration for automated dataset management.

- **Prefect UI**: http://localhost:4200
- **Purpose**: Automated data collection and dataset versioning

**Workflows**:
- Daily collection of new predictions (00:00 UTC)
- Monthly creation of training datasets (1st of month, 01:00 UTC)

See `automl/README.md` for detailed documentation.

## Quick Start

### Start All Services

```bash
# From project root
docker-compose up -d

# Check services
docker-compose ps

# View logs
docker-compose logs -f ml-inference
docker-compose logs -f ml-automl
```

### Access Services

- **ML Inference API**: http://localhost:8000/docs
- **Prefect UI**: http://localhost:4200
- **MinIO Console**: http://localhost:9001

## Development

### Build Services Separately

```bash
# Build inference service
docker-compose build ml-inference

# Build automl service
docker-compose build ml-automl
```

### Run Tests

```bash
# Test inference API
docker-compose exec ml-inference python test_api.py

# Test automl flows (manual trigger)
docker-compose exec ml-automl python flows/dataset_management.py daily
```

## Architecture

### Data Flow

```
User Upload → Backend → MinIO (STYLE_PHOTO_BUCKET)
                ↓
        ML Inference API
                ↓
        user_styles table
                ↓
    Daily Collection Flow ←→ MinIO (ML_ARTIFACTS_BUCKET)
                ↓                   ├── datasets/candidates/
        Admin Verification          ├── datasets/verified/
                ↓                   ├── datasets/full/
    Monthly Creation Flow           └── models/checkpoints/
                ↓
        Training Datasets
```

### Storage Structure

**STYLE_PHOTO_BUCKET**: User uploaded photos
```
style-photos/
└── {user_id}/
    ├── photo_1.jpg
    ├── photo_2.jpg
    └── ...
```

**ML_ARTIFACTS_BUCKET**: ML artifacts and datasets
```
ml-artifacts/
├── datasets/
│   ├── gold/                 # Base training dataset
│   ├── candidates/           # Daily collections
│   │   └── YYYY-MM-DD/
│   ├── verified/             # Monthly verified datasets
│   │   └── YYYY-MM/
│   └── full/                 # Monthly full datasets
│       └── YYYY-MM/
├── models/
│   └── checkpoints/          # Model weights with timestamps
└── metadata/                 # Dataset manifests
```

## Face Classes

The system supports 15 face classification classes:

1. Aristocratic
2. Business
3. Fire
4. Fragile
5. Heroin
6. Inferno
7. Melting
8. Queen
9. Renaissance
10. Serious
11. Soft
12. Strong
13. Sunny
14. Vintage
15. Warm

## Environment Variables

Required environment variables (in `.env`):

```bash
# Database
DB_HOST=postgres
DB_PORT=5432
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=suitesme

# MinIO
MINIO_ENDPOINT=minio:9000
MINIO_ROOT_USER=your_access_key
MINIO_ROOT_PASSWORD=your_secret_key
STYLE_PHOTO_BUCKET=style-photos
ML_ARTIFACTS_BUCKET=ml-artifacts

# Prefect (auto-configured in docker-compose)
PREFECT_API_URL=http://prefect-server:4200/api
PREFECT_WORK_POOL=default-pool
```

## Monitoring

### Check Service Health

```bash
# ML Inference
curl http://localhost:8000/health

# Prefect Server
curl http://localhost:4200/api/health

# MinIO
curl http://localhost:9000/minio/health/live
```

### View Logs

```bash
# All ML services
docker-compose logs -f ml-inference ml-automl

# Prefect flows
docker-compose logs -f prefect-server

# MinIO operations
docker-compose logs -f minio
```

## Troubleshooting

### Inference API Issues

```bash
# Check if model files exist
docker-compose exec ml-inference ls -la /app/assets/checkpoints/

# Restart service
docker-compose restart ml-inference
```

### AutoML Flow Issues

```bash
# Check Prefect deployments
docker-compose exec ml-automl prefect deployment ls

# Check work pool
docker-compose exec ml-automl prefect work-pool ls

# Manually trigger daily collection
docker-compose exec ml-automl python flows/dataset_management.py daily
```

### Database Connection Issues

```bash
# Test database connection
docker-compose exec ml-automl nc -zv postgres 5432

# Check database logs
docker-compose logs postgres
```

## Production Deployment

For production, use `docker-compose.prod.yml`:

```bash
# Build and push images
docker build -t ghcr.io/yourorg/ml-inference:latest ./ml/inference
docker build -t ghcr.io/yourorg/ml-automl:latest ./ml/automl
docker push ghcr.io/yourorg/ml-inference:latest
docker push ghcr.io/yourorg/ml-automl:latest

# Deploy with production config
docker-compose -f docker-compose.prod.yml up -d
```

## Contributing

When adding new features:

1. **Inference changes**: Update `ml/inference/`
2. **AutoML changes**: Update `ml/automl/`
3. **New tasks**: Add to `ml/automl/tasks/`
4. **New flows**: Add to `ml/automl/flows/`
5. **Configuration**: Update `ml/automl/config/settings.py`

## License

Proprietary - SuitesMe Project

