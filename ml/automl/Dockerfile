# AutoML Dataset Management Service
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY config/ ./config/
COPY tasks/ ./tasks/
COPY flows/ ./flows/
COPY __init__.py .

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create entrypoint script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "=== Prefect Worker Initialization ==="\n\
echo "Prefect API URL: ${PREFECT_API_URL}"\n\
echo "Work Pool: ${PREFECT_WORK_POOL}"\n\
echo ""\n\
\n\
# Simple wait for Prefect server\n\
echo "Waiting for Prefect server..."\n\
MAX_WAIT=120\n\
WAITED=0\n\
\n\
until curl -sf ${PREFECT_API_URL}/health > /dev/null 2>&1; do\n\
  if [ $WAITED -ge $MAX_WAIT ]; then\n\
    echo "ERROR: Prefect server not available after ${MAX_WAIT}s"\n\
    echo "Trying to connect to: ${PREFECT_API_URL}"\n\
    curl -v ${PREFECT_API_URL}/health || true\n\
    exit 1\n\
  fi\n\
  echo "Waiting... ($WAITED/${MAX_WAIT}s)"\n\
  sleep 3\n\
  WAITED=$((WAITED + 3))\n\
done\n\
\n\
echo "✓ Prefect server is ready!"\n\
echo ""\n\
\n\
# Give server a moment to fully initialize\n\
echo "Allowing server to fully initialize..."\n\
sleep 5\n\
\n\
# Create work pool if needed\n\
echo "Creating work pool if it does not exist..."\n\
prefect work-pool create ${PREFECT_WORK_POOL} --type process 2>&1 | grep -v "already exists" || true\n\
\n\
echo ""\n\
echo "=== AutoML Service Ready ==="\n\
echo "Prefect worker not started automatically due to events compatibility issues."\n\
echo "You can run flows directly using:"\n\
echo "  docker compose exec ml-automl python flows/dataset_management.py daily"\n\
echo "  docker compose exec ml-automl python flows/dataset_management.py monthly"\n\
echo ""\n\
echo "Or deploy and trigger via Prefect UI:"\n\
echo "  docker compose exec ml-automl python deploy_flows.py"\n\
echo ""\n\
echo "Container will stay alive for manual flow execution..."\n\
\n\
# Keep container running\n\
tail -f /dev/null\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f ${PREFECT_API_URL}/health || exit 1

# Run the worker
ENTRYPOINT ["/entrypoint.sh"]

