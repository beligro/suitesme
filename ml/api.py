"""
Face Classification API using Ensemble Classifier
FastAPI-based API that receives base64 images and returns face class predictions
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import base64
import io
import os
import sys
from PIL import Image
import tempfile
import logging

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from src.ensemble_classifier import EnsembleClassifier

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Face Classification API",
    description="Ensemble classifier for face type classification using hierarchical neural network + centroid-based approach",
    version="1.0.0"
)

# Global ensemble classifier instance
ensemble_classifier = None

class ImageRequest(BaseModel):
    """Request model for image classification"""
    image: str  # base64 encoded image
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

@app.on_event("startup")
async def startup_event():
    """Initialize the ensemble classifier on startup"""
    global ensemble_classifier
    
    try:
        logger.info("Initializing Face Classification API...")
        
        # Check if required files exist
        model_path = "./assets/checkpoints/best_model.pth"
        centroids_path = "./assets/face_centroids.pkl"
        
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model file not found: {model_path}")
        
        if not os.path.exists(centroids_path):
            raise FileNotFoundError(f"Centroids file not found: {centroids_path}")
        
        # Initialize ensemble classifier
        ensemble_classifier = EnsembleClassifier(model_path, centroids_path)
        
        logger.info("✓ Face Classification API initialized successfully")
        logger.info(f"✓ Available classes: {ensemble_classifier.get_class_names()}")
        
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
    return {
        "message": "Face Classification API",
        "version": "1.0.0",
        "status": "running",
        "available_classes": ensemble_classifier.get_class_names() if ensemble_classifier else []
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "classifier_loaded": ensemble_classifier is not None
    }

@app.get("/classes")
async def get_classes():
    """Get all available face classes"""
    if ensemble_classifier is None:
        raise HTTPException(status_code=503, detail="Classifier not initialized")
    
    return {
        "classes": ensemble_classifier.get_class_names(),
        "total_classes": len(ensemble_classifier.get_class_names())
    }

@app.post("/predict", response_model=PredictionResponse)
async def predict_face_class(request: ImageRequest):
    """
    Predict face class from base64 encoded image
    
    Args:
        request (ImageRequest): Request containing base64 image and parameters
        
    Returns:
        PredictionResponse: Prediction results
    """
    if ensemble_classifier is None:
        raise HTTPException(status_code=503, detail="Classifier not initialized")
    
    temp_image_path = None
    
    try:
        # Convert base64 to temporary image file
        temp_image_path = base64_to_image(request.image)
        
        # Validate ensemble weights
        if abs(sum(request.weights.values()) - 1.0) > 0.01:
            logger.warning(f"Ensemble weights don't sum to 1.0: {request.weights}")
        
        # Make prediction based on requested format
        if request.top_k > 1:
            # Get top-k predictions
            top_predictions = ensemble_classifier.predict_top_k(
                temp_image_path, 
                k=request.top_k,
                weights=request.weights,
                distance_metric=request.distance_metric
            )
            
            if not top_predictions:
                return PredictionResponse(
                    success=False,
                    error="No face detected in the image"
                )
            
            # Format top predictions
            formatted_predictions = [
                {"class": class_name, "confidence": float(confidence)}
                for class_name, confidence in top_predictions
            ]
            
            return PredictionResponse(
                success=True,
                predicted_class=top_predictions[0][0],
                confidence=float(top_predictions[0][1]),
                top_predictions=formatted_predictions
            )
        
        elif request.return_details:
            # Get detailed prediction
            pred_class, confidence, details = ensemble_classifier.predict(
                temp_image_path,
                weights=request.weights,
                distance_metric=request.distance_metric,
                return_details=True
            )
            
            if pred_class is None:
                return PredictionResponse(
                    success=False,
                    error="No face detected in the image"
                )
            
            # Format details for JSON response
            formatted_details = {
                "ensemble": {
                    "class": details["ensemble"]["class"],
                    "confidence": float(details["ensemble"]["confidence"])
                },
                "hierarchical": {
                    "class": details["hierarchical"]["class"],
                    "confidence": float(details["hierarchical"]["confidence"])
                },
                "centroid": {
                    "class": details["centroid"]["class"],
                    "distance": float(details["centroid"]["distance"])
                }
            }
            
            return PredictionResponse(
                success=True,
                predicted_class=pred_class,
                confidence=float(confidence),
                details=formatted_details
            )
        
        else:
            # Simple prediction
            predicted_class = ensemble_classifier.predict(
                temp_image_path,
                weights=request.weights,
                distance_metric=request.distance_metric
            )
            
            if predicted_class is None:
                return PredictionResponse(
                    success=False,
                    error="No face detected in the image"
                )
            
            return PredictionResponse(
                success=True,
                predicted_class=predicted_class
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
        # Clean up temporary file
        if temp_image_path and os.path.exists(temp_image_path):
            try:
                os.unlink(temp_image_path)
            except:
                pass

@app.post("/predict/simple")
async def predict_simple(request: ImageRequest):
    """
    Simplified prediction endpoint that returns just the class name
    
    Args:
        request (ImageRequest): Request containing base64 image
        
    Returns:
        dict: Simple response with predicted class
    """
    response = await predict_face_class(request)
    
    if response.success:
        return {
            "predicted_class": response.predicted_class,
            "confidence": response.confidence
        }
    else:
        raise HTTPException(status_code=400, detail=response.error)

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
