# Face Classification API Docker Image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Install additional dependencies for the API
RUN pip install --no-cache-dir fastapi uvicorn python-multipart

# Create directories for models and assets
RUN mkdir -p /app/assets/checkpoints && \
    mkdir -p /app/models && \
    mkdir -p /app/src

# Copy source code
COPY src/ ./src/
COPY api.py .

# Copy assets (models, centroids, etc.)
COPY assets/ ./assets/

# Create a script to pre-download models
RUN echo 'import torch\n\
import ssl\n\
from facenet_pytorch import MTCNN, InceptionResnetV1\n\
import os\n\
\n\
ssl._create_default_https_context = ssl._create_unverified_context\n\
print("Pre-downloading MTCNN and InceptionResnetV1 models...")\n\
os.makedirs("/app/models", exist_ok=True)\n\
\n\
try:\n\
    mtcnn = MTCNN(keep_all=True, device="cpu")\n\
    print("✓ MTCNN model downloaded")\n\
    resnet = InceptionResnetV1(pretrained="vggface2").eval()\n\
    print("✓ InceptionResnetV1 model downloaded")\n\
    torch.save(resnet.state_dict(), "/app/models/inception_resnet_v1.pth")\n\
    print("✓ Models cached successfully")\n\
except Exception as e:\n\
    print(f"Error downloading models: {e}")\n\
' > download_models.py && python download_models.py && rm download_models.py

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the API
CMD ["python", "-m", "uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
