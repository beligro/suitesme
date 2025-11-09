# Debug Startup Issues

## Quick Debug Commands

### 1. Check if Prefect Server is Actually Healthy

```bash
# Check docker health status
docker-compose ps

# Should show prefect-server as "healthy", not just "running"
```

### 2. Test Prefect Server Health Endpoint Manually

```bash
# From your host machine
curl http://localhost:4200/api/health

# Should return: {"status": "ok"} or similar

# From inside ml-automl container
docker-compose exec ml-automl curl http://prefect-server:4200/api/health
```

### 3. Check ml-automl Logs

```bash
# See what the startup script is doing
docker-compose logs ml-automl

# Look for:
# - "Waiting for Prefect server..."
# - "✓ Prefect server is ready!"
# - Or error messages
```

### 4. Bypass Health Check (Temporary Test)

If you need to test without health checks, temporarily modify docker-compose.yml:

```yaml
  ml-automl:
    build:
      context: ./ml/automl
    depends_on:
      - postgres
      - minio
      - prefect-server
    # Remove the health check conditions temporarily
```

## Common Issues

### Issue 1: Health Check Never Passes

**Symptom**: `docker-compose ps` shows prefect-server as "starting" forever

**Check**:
```bash
docker-compose logs prefect-server | tail -50
```

**Solution**: Increase health check start_period or retries

### Issue 2: Container Can't Reach Prefect Server

**Symptom**: ml-automl logs show "Waiting..." continuously

**Test connectivity**:
```bash
# Enter the ml-automl container
docker-compose exec ml-automl bash

# Try to reach prefect-server
curl http://prefect-server:4200/api/health
ping prefect-server

# Check environment variables
echo $PREFECT_API_URL
```

**Solution**: Check network configuration

### Issue 3: Startup Script Hangs

**Symptom**: ml-automl shows "Waiting..." but prefect-server is healthy

**Debug**:
```bash
# Check if the entrypoint script is running
docker-compose exec ml-automl ps aux

# Run startup commands manually
docker-compose exec ml-automl bash
curl http://prefect-server:4200/api/health
prefect work-pool create default-pool --type process
```

## Nuclear Option: Start Without Dependencies

If all else fails, start services manually in order:

```bash
# Stop everything
docker-compose down

# Start Prefect stack only
docker-compose up -d prefect-postgres prefect-server

# Wait for health
sleep 30
docker-compose ps prefect-server

# Start ml-automl
docker-compose up -d ml-automl

# Watch logs
docker-compose logs -f ml-automl
```

## Rebuild and Fresh Start

```bash
# Complete clean restart
docker-compose down -v
docker-compose build ml-automl
docker-compose up -d

# Follow logs
docker-compose logs -f prefect-server ml-automl
```

## Test Without Docker

For ultimate debugging, test the startup script directly:

```bash
# Build the image
docker-compose build ml-automl

# Run interactively
docker-compose run --rm ml-automl bash

# Inside container, run commands manually
echo "PREFECT_API_URL: $PREFECT_API_URL"
curl $PREFECT_API_URL/health
prefect work-pool ls
prefect work-pool create default-pool --type process
prefect worker start --pool default-pool
```

## Expected Output

When working correctly, you should see:

```
ml-automl-1  | === Prefect Worker Initialization ===
ml-automl-1  | Prefect API URL: http://prefect-server:4200/api
ml-automl-1  | Work Pool: default-pool
ml-automl-1  | 
ml-automl-1  | Waiting for Prefect server...
ml-automl-1  | ✓ Prefect server is ready!
ml-automl-1  | 
ml-automl-1  | Allowing server to fully initialize...
ml-automl-1  | Creating work pool if it does not exist...
ml-automl-1  | 
ml-automl-1  | === Starting Prefect Worker ===
ml-automl-1  | 
ml-automl-1  | Starting worker for work pool 'default-pool'...
ml-automl-1  | Worker started successfully
```

## Quick Fix: Simplify Dependencies

Edit `docker-compose.yml` and change:

```yaml
  ml-automl:
    depends_on:
      postgres:
        condition: service_started
      minio:
        condition: service_healthy
      prefect-server:
        condition: service_healthy  # <- This might be the issue
```

To:

```yaml
  ml-automl:
    depends_on:
      - postgres
      - minio
      - prefect-server  # Simple dependency without health check
```

The entrypoint script will handle waiting for readiness itself.


