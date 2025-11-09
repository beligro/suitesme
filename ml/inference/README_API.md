# Face Classification API

A comprehensive Face Classification API that combines a hierarchical neural network classifier with a centroid-based approach for robust face type classification.

## 🎯 Features

- **Ensemble Classification**: Combines hierarchical neural network + centroid-based classification
- **15 Face Classes**: Aristocratic, Business, Fire, Fragile, Heroin, Inferno, Melting, Queen, Renaissance, Serious, Soft, Strong, Sunny, Vintage, Warm
- **Base64 Image Input**: Easy integration with web applications
- **Multiple Prediction Modes**: Simple, detailed, and top-k predictions
- **Dockerized**: Pre-built container with all models included for quick startup
- **FastAPI**: Modern, fast web framework with automatic API documentation

## 🚀 Quick Start

### 1. Build the Docker Image

```bash
docker build -t face-classifier-api .
```

### 2. Run the Container

```bash
docker run -d -p 8000:8000 --name face-classifier face-classifier-api
```

### 3. Test the API

```bash
# Health check
curl http://localhost:8000/health

# Get available classes
curl http://localhost:8000/classes

# API documentation (open in browser)
http://localhost:8000/docs
```

## 📋 API Endpoints

### Health Check
- **GET** `/health` - Check if the API is running and classifier is loaded
- **GET** `/` - Root endpoint with API information
- **GET** `/classes` - Get all available face classes

### Prediction Endpoints
- **POST** `/predict` - Main prediction endpoint with full options
- **POST** `/predict/simple` - Simplified prediction endpoint

### Interactive Documentation
- **GET** `/docs` - Swagger UI (FastAPI automatic documentation)
- **GET** `/redoc` - ReDoc alternative documentation

## 🔧 API Usage Examples

### Simple Prediction

```bash
curl -X POST "http://localhost:8000/predict/simple" \
  -H "Content-Type: application/json" \
  -d '{
    "image": "base64_encoded_image_string"
  }'
```

**Response:**
```json
{
  "predicted_class": "Queen",
  "confidence": 0.85
}
```

### Detailed Prediction

```bash
curl -X POST "http://localhost:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "image": "base64_encoded_image_string",
    "return_details": true,
    "weights": {"hierarchical": 0.6, "centroid": 0.4}
  }'
```

**Response:**
```json
{
  "success": true,
  "predicted_class": "Queen",
  "confidence": 0.85,
  "details": {
    "ensemble": {
      "class": "Queen",
      "confidence": 0.85
    },
    "hierarchical": {
      "class": "Queen",
      "confidence": 0.82
    },
    "centroid": {
      "class": "Business",
      "distance": 1.23
    }
  }
}
```

### Top-K Predictions

```bash
curl -X POST "http://localhost:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "image": "base64_encoded_image_string",
    "top_k": 3
  }'
```

**Response:**
```json
{
  "success": true,
  "predicted_class": "Queen",
  "confidence": 0.85,
  "top_predictions": [
    {"class": "Queen", "confidence": 0.85},
    {"class": "Business", "confidence": 0.12},
    {"class": "Aristocratic", "confidence": 0.03}
  ]
}
```

## 🐍 Python Client Example

```python
import requests
import base64

def predict_face_class(image_path, api_url="http://localhost:8000"):
    # Convert image to base64
    with open(image_path, "rb") as image_file:
        base64_image = base64.b64encode(image_file.read()).decode('utf-8')
    
    # Make prediction request
    response = requests.post(
        f"{api_url}/predict",
        json={
            "image": base64_image,
            "return_details": True,
            "weights": {"hierarchical": 0.6, "centroid": 0.4}
        }
    )
    
    return response.json()

# Usage
result = predict_face_class("path/to/face/image.jpg")
if result["success"]:
    print(f"Predicted class: {result['predicted_class']}")
    print(f"Confidence: {result['confidence']:.3f}")
else:
    print(f"Error: {result['error']}")
```

## 📊 Request Parameters

### ImageRequest Model

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `image` | string | **required** | Base64 encoded image |
| `weights` | dict | `{"hierarchical": 0.6, "centroid": 0.4}` | Ensemble weights |
| `distance_metric` | string | `"euclidean"` | Distance metric for centroid classifier |
| `return_details` | boolean | `false` | Return detailed prediction breakdown |
| `top_k` | integer | `1` | Number of top predictions to return |

### Response Model

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Whether prediction was successful |
| `predicted_class` | string | Predicted face class |
| `confidence` | float | Prediction confidence (0-1) |
| `top_predictions` | array | Top-k predictions with confidence |
| `details` | object | Detailed breakdown by classifier |
| `error` | string | Error message if prediction failed |

## 🔧 Configuration

### Ensemble Weights
Customize the balance between classifiers:
- `hierarchical`: 0.0-1.0 (neural network weight)
- `centroid`: 0.0-1.0 (centroid-based weight)
- Weights should sum to 1.0

### Distance Metrics
- `euclidean`: Standard Euclidean distance
- `cosine`: Cosine distance (1 - cosine similarity)

## 🏗️ Docker Configuration

### Environment Variables
- `PYTHONPATH=/app` - Python path configuration
- `PYTHONDONTWRITEBYTECODE=1` - Don't write .pyc files
- `PYTHONUNBUFFERED=1` - Unbuffered Python output

### Health Check
The container includes a health check that runs every 30 seconds:
```bash
curl -f http://localhost:8000/health || exit 1
```

### Port
- **Internal**: 8000
- **External**: Configurable (default 8000)

## 📁 Project Structure

```
FaceClassifier/
├── api.py                    # FastAPI application
├── Dockerfile               # Docker configuration
├── requirements.txt         # Python dependencies
├── test_api.py              # API test script
├── src/
│   ├── ensemble_classifier.py  # Main ensemble classifier
│   ├── small_classifier/
│   │   └── train.py           # Hierarchical classifier
│   └── centroid_based/
│       └── cdc.py             # Centroid distance calculator
└── assets/
    ├── checkpoints/
    │   └── best_model.pth     # Trained model weights
    └── face_centroids.pkl     # Pre-computed centroids
```

## 🛠️ Development

### Local Development
```bash
# Install dependencies
pip install -r requirements.txt

# Run locally
python api.py

# Test API
python test_api.py
```

### Testing
```bash
# Run the test script
python test_api.py

# Manual testing
curl http://localhost:8000/docs  # Open Swagger UI
```

## 🐛 Troubleshooting

### Common Issues

1. **"No face detected in the image"**
   - Ensure the image contains a clear, visible face
   - Image should be well-lit and face should be front-facing
   - MTCNN model is used for face detection

2. **Container startup issues**
   - Check Docker logs: `docker logs face-classifier`
   - Ensure assets directory contains required model files
   - Verify sufficient disk space for model downloads

3. **API not responding**
   - Check if container is running: `docker ps`
   - Verify port mapping: `-p 8000:8000`
   - Check health endpoint: `curl http://localhost:8000/health`

### Logs
```bash
# View container logs
docker logs face-classifier

# Follow logs in real-time
docker logs -f face-classifier
```

## 📈 Performance

- **Cold start**: ~10-15 seconds (models pre-downloaded in container)
- **Warm predictions**: ~1-3 seconds per image
- **Memory usage**: ~2-3 GB (includes all models)
- **Supported formats**: JPG, PNG, BMP, GIF, TIFF, WEBP

## 🔒 Security Notes

- API runs in container isolation
- No persistent data storage
- Temporary files are automatically cleaned up
- Base64 input validation included
