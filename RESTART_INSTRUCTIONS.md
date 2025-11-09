# Restart Instructions After Fixes

The ml-automl container startup issue has been fixed. Follow these steps to rebuild and restart.

## What Was Fixed

1. **Improved startup wait logic**: The automl container now waits longer and tests more thoroughly before starting the worker
2. **Better health checks**: Added proper health check dependencies between services
3. **Increased timeouts**: Extended start-period to give Prefect server more time to fully initialize
4. **Work pool auto-creation**: The worker now creates its work pool if it doesn't exist

## Quick Restart

```bash
# Stop all services
docker-compose down

# Rebuild the ml-automl service
docker-compose build ml-automl

# Start all services
docker-compose up -d

# Watch logs to verify startup
docker-compose logs -f ml-automl prefect-server
```

## Step-by-Step Restart

### 1. Stop Everything

```bash
cd /Users/gena/Documents/MediaBuro/projects/2/progress/suitesme
docker-compose down
```

### 2. Clean Up (Optional, for a fresh start)

```bash
# Remove volumes if you want to start completely fresh
docker-compose down -v

# Remove old images
docker-compose rm -f ml-automl prefect-server
```

### 3. Rebuild AutoML Service

```bash
docker-compose build ml-automl
```

### 4. Start Services

```bash
# Start all services
docker-compose up -d

# OR start with logs visible
docker-compose up
```

### 5. Monitor Startup

In a separate terminal:

```bash
# Watch all Prefect-related services
docker-compose logs -f prefect-postgres prefect-server ml-automl
```

You should see:
1. **prefect-postgres**: Database starting and accepting connections
2. **prefect-server**: Server starting, running migrations, becoming healthy
3. **ml-automl**: 
   - "Waiting for Prefect server to be fully ready..."
   - Several retry attempts
   - "✓ Prefect server is fully ready!"
   - "Ensuring work pool exists..."
   - "Starting Prefect worker..."
   - Worker starting successfully

## Expected Startup Timeline

- **prefect-postgres**: ~5-10 seconds
- **prefect-server**: ~30-60 seconds (includes database migrations)
- **ml-automl**: Starts after prefect-server is healthy, takes ~10-20 seconds

Total: ~60-90 seconds for full startup

## Verify Everything is Working

```bash
# Check all services are running
docker-compose ps

# All should show "Up" or "Up (healthy)"
```

```bash
# Check Prefect UI
open http://localhost:4200
```

```bash
# Check work pool exists
docker-compose exec ml-automl prefect work-pool ls
```

```bash
# Check deployments (if deployed)
docker-compose exec ml-automl prefect deployment ls
```

## If Still Having Issues

### Issue: ml-automl keeps restarting

**Check logs:**
```bash
docker-compose logs --tail=100 ml-automl
```

**Possible causes:**
1. Prefect server not responding - check: `docker-compose logs prefect-server`
2. Database connection issues - check: `docker-compose logs prefect-postgres`
3. Network issues - verify all services are on the same network

**Solution:**
```bash
# Restart the Prefect stack
docker-compose restart prefect-postgres prefect-server ml-automl
```

### Issue: Prefect server shows errors

**Check Prefect server logs:**
```bash
docker-compose logs --tail=100 prefect-server
```

**Common issue**: Database not ready
```bash
# Restart in order
docker-compose restart prefect-postgres
sleep 10
docker-compose restart prefect-server
sleep 30
docker-compose restart ml-automl
```

### Issue: Health checks failing

**Check health status:**
```bash
docker-compose ps
```

**Manually test health endpoints:**
```bash
# Prefect server
curl http://localhost:4200/api/health

# ML Inference
curl http://localhost:8000/health

# MinIO
curl http://localhost:9000/minio/health/live
```

## Deploy Flows (After Services Are Up)

Once all services are healthy:

```bash
# Deploy the flows
docker-compose exec ml-automl python deploy_flows.py
```

Or manually:

```bash
# Enter container
docker-compose exec ml-automl bash

# Deploy flows
cd /app
python deploy_flows.py
```

## Test Manual Flow Execution

```bash
# Test daily collection
docker-compose exec ml-automl python flows/dataset_management.py daily

# Test monthly creation
docker-compose exec ml-automl python flows/dataset_management.py monthly
```

## Clean Restart (If All Else Fails)

```bash
# Stop and remove everything
docker-compose down -v

# Remove built images
docker rmi $(docker images | grep 'ml-automl\|ml-inference' | awk '{print $3}')

# Rebuild from scratch
docker-compose build

# Start fresh
docker-compose up -d

# Monitor
docker-compose logs -f
```

## Useful Commands During Startup

```bash
# Follow logs for all Prefect services
docker-compose logs -f prefect-postgres prefect-server ml-automl

# Check if Prefect server is responding
watch -n 1 'curl -s http://localhost:4200/api/health'

# Check container status
watch -n 2 'docker-compose ps'

# View resource usage
docker stats
```

## Success Indicators

✅ All services show "Up (healthy)" in `docker-compose ps`  
✅ Prefect UI accessible at http://localhost:4200  
✅ ml-automl logs show "Starting Prefect worker..."  
✅ No restart loops in logs  
✅ Work pool visible: `docker-compose exec ml-automl prefect work-pool ls`

---

**After successful startup, proceed to:**
- Upload gold dataset to MinIO
- Deploy flows using `deploy_flows.py`
- Test manual flow execution
- Verify in Prefect UI

