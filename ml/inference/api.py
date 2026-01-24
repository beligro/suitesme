"""
Face Classification API using Ensemble Classifier
FastAPI-based API that receives base64 images and returns face class predictions
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import base64
import io
import os
import sys
from PIL import Image
import tempfile
import logging
import numpy as np

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from src.ensemble_classifier import EnsembleClassifier
from src.model_manager import ModelManager
from minio import Minio

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Face Classification API",
    description="Ensemble classifier for face type classification using hierarchical neural network + centroid-based approach",
    version="1.1.0"
)

# Global model manager instance (replaces ensemble_classifier)
model_manager = None

class ImageRequest(BaseModel):
    """Request model for image classification"""
    images: List[str]  # base64 encoded images (1-4 images)
    weights: dict = {"hierarchical": 0.6, "centroid": 0.4}  # ensemble weights
    distance_metric: str = "euclidean"  # distance metric for centroid classifier
    return_details: bool = False  # whether to return detailed predictions
    top_k: int = 1  # number of top predictions to return

class PredictionResponse(BaseModel):
    """Response model for predictions"""
    success: bool
    predicted_class: str = None
    confidence: float = None
    top_predictions: list = None
    details: dict = None
    error: str = None
    images_processed: int = None
    images_total: int = None

@app.on_event("startup")
async def startup_event():
    """Initialize the ModelManager on startup"""
    global model_manager
    
    try:
        logger.info("Initializing Face Classification API with ModelManager...")
        
        # Get configuration from environment
        minio_endpoint = os.getenv('MINIO_ENDPOINT', 'minio:9000')
        minio_access_key = os.getenv('MINIO_ROOT_USER', 'minioadmin')
        minio_secret_key = os.getenv('MINIO_ROOT_PASSWORD', 'minioadmin')
        ml_artifacts_bucket = os.getenv('ML_ARTIFACTS_BUCKET', 'ml-artifacts')
        model_check_interval = int(os.getenv('MODEL_CHECK_INTERVAL', '300'))
        
        # Initialize MinIO client
        logger.info(f"Connecting to MinIO at {minio_endpoint}")
        minio_client = Minio(
            minio_endpoint,
            access_key=minio_access_key,
            secret_key=minio_secret_key,
            secure=False
        )
        
        # Initialize ModelManager
        model_manager = ModelManager(
            minio_client=minio_client,
            bucket=ml_artifacts_bucket,
            checkpoints_prefix="models/checkpoints/latest",
            local_cache_dir="/tmp/model_cache",
            fallback_model_path="./assets/checkpoints/best_model.pth",
            fallback_centroids_path="./assets/face_centroids.pkl",
            auto_check_interval=model_check_interval
        )
        
        # Get initial model info
        model_info = model_manager.get_model_info()
        current_model = model_manager.get_current_model()
        
        logger.info("✓ Face Classification API initialized successfully")
        logger.info(f"✓ Model version: {model_info.get('version', 'unknown')}")
        logger.info(f"✓ Loaded at: {model_info.get('loaded_at', 'unknown')}")
        if current_model:
            logger.info(f"✓ Available classes: {current_model.get_class_names()}")
        
    except Exception as e:
        logger.error(f"Failed to initialize API: {str(e)}")
        raise

def base64_to_image(base64_string: str) -> str:
    """
    Convert base64 string to temporary image file
    
    Args:
        base64_string (str): Base64 encoded image
        
    Returns:
        str: Path to temporary image file
    """
    try:
        # Remove data URL prefix if present
        if "," in base64_string:
            base64_string = base64_string.split(",")[1]
        
        # Decode base64
        image_data = base64.b64decode(base64_string)
        
        # Create PIL Image
        image = Image.open(io.BytesIO(image_data))
        
        # Convert to RGB if necessary
        if image.mode in ('RGBA', 'LA', 'P'):
            image = image.convert('RGB')
        
        # Save to temporary file
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.jpg')
        image.save(temp_file.name, 'JPEG')
        temp_file.close()
        
        return temp_file.name
        
    except Exception as e:
        raise ValueError(f"Failed to process base64 image: {str(e)}")

@app.get("/")
async def root():
    """Root endpoint with API information"""
    model = model_manager.get_current_model() if model_manager else None
    model_info = model_manager.get_model_info() if model_manager else {}
    
    return {
        "message": "Face Classification API",
        "version": "1.1.0",
        "status": "running",
        "model_version": model_info.get("version", "unknown"),
        "available_classes": model.get_class_names() if model else []
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    model_info = model_manager.get_model_info() if model_manager else {}
    
    return {
        "status": "healthy",
        "model_loaded": model_manager is not None and model_manager.get_current_model() is not None,
        "model_version": model_info.get("version", "unknown"),
        "loaded_at": model_info.get("loaded_at", "unknown")
    }

@app.get("/classes")
async def get_classes():
    """Get all available face classes"""
    if model_manager is None:
        raise HTTPException(status_code=503, detail="ModelManager not initialized")
    
    model = model_manager.get_current_model()
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    return {
        "classes": model.get_class_names(),
        "total_classes": len(model.get_class_names())
    }

@app.post("/predict", response_model=PredictionResponse)
async def predict_face_class(request: ImageRequest):
    """
    Predict face class from base64 encoded images with confidence-based weighting
    
    Args:
        request (ImageRequest): Request containing base64 images (1-4) and parameters
        
    Returns:
        PredictionResponse: Prediction results aggregated from all images
    """
    if model_manager is None:
        raise HTTPException(status_code=503, detail="ModelManager not initialized")
    
    ensemble_classifier = model_manager.get_current_model()
    if ensemble_classifier is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    # Validate image count
    if len(request.images) < 1 or len(request.images) > 4:
        raise HTTPException(status_code=400, detail="Must provide 1-4 images")
    
    temp_image_paths = []
    
    try:
        # Convert all base64 images to temporary files
        for base64_img in request.images:
            temp_path = base64_to_image(base64_img)
            temp_image_paths.append(temp_path)
        
        # Validate ensemble weights
        if abs(sum(request.weights.values()) - 1.0) > 0.01:
            logger.warning(f"Ensemble weights don't sum to 1.0: {request.weights}")
        
        # Make prediction based on requested format
        if request.top_k > 1:
            # Get detailed prediction first, then extract top-k from probabilities
            pred_class, confidence, details = ensemble_classifier.predict_multi_image(
                temp_image_paths,
                weights=request.weights,
                distance_metric=request.distance_metric,
                return_details=True
            )
            
            if pred_class is None:
                raise HTTPException(
                    status_code=400,
                    detail="No face detected in any of the images"
                )
            
            # Extract top-k predictions from probability distribution
            ensemble_probs = details['ensemble']['probabilities']
            top_k_indices = np.argsort(ensemble_probs)[-request.top_k:][::-1]
            
            top_predictions = []
            for idx in top_k_indices:
                class_name = ensemble_classifier.idx_to_class[idx]
                conf = ensemble_probs[idx]
                top_predictions.append((class_name, conf))
            
            # Format top predictions
            formatted_predictions = [
                {"class": class_name, "confidence": float(conf)}
                for class_name, conf in top_predictions
            ]
            
            return PredictionResponse(
                success=True,
                predicted_class=pred_class,
                confidence=float(confidence),
                top_predictions=formatted_predictions,
                images_processed=details.get('images_processed'),
                images_total=details.get('images_total')
            )
        
        elif request.return_details:
            # Get detailed prediction
            pred_class, confidence, details = ensemble_classifier.predict_multi_image(
                temp_image_paths,
                weights=request.weights,
                distance_metric=request.distance_metric,
                return_details=True
            )
            
            if pred_class is None:
                raise HTTPException(
                    status_code=400,
                    detail="No face detected in any of the images"
                )
            
            # Format details for JSON response
            formatted_details = {
                "ensemble": {
                    "class": details["ensemble"]["class"],
                    "confidence": float(details["ensemble"]["confidence"])
                },
                "num_images_processed": details.get("num_images_processed", 1)
            }
            
            # Add per-image details if available (multi-image prediction)
            if "per_image_predictions" in details:
                formatted_details["per_image_predictions"] = [
                    {
                        "class": pred["class"],
                        "confidence": float(pred["confidence"]),
                        "weight": float(pred["weight"])
                    }
                    for pred in details["per_image_predictions"]
                ]
            # Add hierarchical/centroid details if available (single-image prediction)
            elif "hierarchical" in details:
                formatted_details["hierarchical"] = {
                    "class": details["hierarchical"]["class"],
                    "confidence": float(details["hierarchical"]["confidence"])
                }
                formatted_details["centroid"] = {
                    "class": details["centroid"]["class"],
                    "distance": float(details["centroid"]["distance"])
                }
            
            return PredictionResponse(
                success=True,
                predicted_class=pred_class,
                confidence=float(confidence),
                details=formatted_details,
                images_processed=details.get('images_processed'),
                images_total=details.get('images_total')
            )
        
        else:
            # Simple prediction - need to get details to access metadata
            pred_class, confidence, details = ensemble_classifier.predict_multi_image(
                temp_image_paths,
                weights=request.weights,
                distance_metric=request.distance_metric,
                return_details=True
            )
            
            if pred_class is None:
                raise HTTPException(
                    status_code=400,
                    detail="No face detected in any of the images"
                )
            
            images_processed = details.get('images_processed') if details else None
            images_total = details.get('images_total') if details else None
            
            logger.info(f"Simple prediction response: class={pred_class}, confidence={confidence}, "
                       f"images_processed={images_processed}, images_total={images_total}")
            
            return PredictionResponse(
                success=True,
                predicted_class=pred_class,
                confidence=float(confidence) if confidence else None,
                images_processed=images_processed,
                images_total=images_total
            )
        
    except ValueError as e:
        logger.error(f"Image processing error: {str(e)}")
        return PredictionResponse(
            success=False,
            error=f"Image processing error: {str(e)}"
        )
    
    except Exception as e:
        logger.error(f"Prediction error: {str(e)}")
        return PredictionResponse(
            success=False,
            error=f"Prediction failed: {str(e)}"
        )
    
    finally:
        # Clean up all temporary files
        for temp_path in temp_image_paths:
            if temp_path and os.path.exists(temp_path):
                try:
                    os.unlink(temp_path)
                except Exception:
                    pass

@app.post("/predict/simple")
async def predict_simple(request: ImageRequest):
    """
    Simplified prediction endpoint that returns just the class name
    
    Args:
        request (ImageRequest): Request containing base64 images (1-4)
        
    Returns:
        dict: Simple response with predicted class aggregated from all images
    """
    response = await predict_face_class(request)
    
    if response.success:
        return {
            "predicted_class": response.predicted_class,
            "confidence": response.confidence,
            "images_processed": response.images_processed,
            "images_total": response.images_total
        }
    else:
        raise HTTPException(status_code=400, detail=response.error)

@app.get("/model/info")
async def get_model_info():
    """
    Get current model information and metadata.
    
    Returns:
        dict: Model version, loaded time, source, etc.
    """
    if model_manager is None:
        raise HTTPException(status_code=503, detail="ModelManager not initialized")
    
    model_info = model_manager.get_model_info()
    
    return {
        "status": "loaded",
        "version": model_info.get("version", "unknown"),
        "loaded_at": model_info.get("loaded_at", "unknown"),
        "source": model_info.get("source", "unknown"),
        "training_date": model_info.get("training_date"),
        "dataset_version": model_info.get("dataset_version"),
        "metrics": model_info.get("metrics", {})
    }

@app.post("/reload")
async def reload_model():
    """
    Trigger manual model weight reload from MinIO.
    Downloads latest weights and reloads model with zero downtime.
    
    Returns:
        dict: Reload status and new model info
    """
    if model_manager is None:
        raise HTTPException(status_code=503, detail="ModelManager not initialized")
    
    logger.info("Manual reload triggered via API")
    
    success = model_manager.reload_weights()
    
    if success:
        model_info = model_manager.get_model_info()
        return {
            "status": "success",
            "message": "Model reloaded successfully",
            "version": model_info.get("version", "unknown"),
            "loaded_at": model_info.get("loaded_at", "unknown")
        }
    else:
        return {
            "status": "failed",
            "message": "Failed to reload model, keeping current model",
            "current_version": model_manager.get_model_info().get("version", "unknown")
        }

if __name__ == "__main__":
    import uvicorn
    
    # Run the API
    uvicorn.run(
        "api:app",
        host="0.0.0.0",
        port=8000,
        reload=False,
        log_level="info"
    )
