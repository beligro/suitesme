"""
Ensemble Classifier: Combining HierarchicalClassifier + CentroidDistanceCalculator
"""

import numpy as np
import torch
import torch.nn.functional as F
from PIL import Image
import os
import sys

# Add src directory to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__)))

# Import our models
from small_classifier.train import HierarchicalClassifier
from centroid_based.cdc import CentroidDistanceCalculator
from facenet_pytorch import MTCNN, InceptionResnetV1

class EnsembleClassifier:
    """
    Ensemble classifier combining HierarchicalClassifier and CentroidDistanceCalculator
    """
    
    def __init__(self, model_path="./assets/checkpoints/best_model.pth", 
                 centroids_path="./assets/face_centroids.pkl"):
        """
        Initialize the ensemble classifier
        
        Args:
            model_path (str): Path to the trained HierarchicalClassifier weights
            centroids_path (str): Path to the face centroids file
        """
        print("Initializing EnsembleClassifier...")
        
        # Initialize face processing components
        self.mtcnn = MTCNN(keep_all=True, device='cpu')
        self.resnet = InceptionResnetV1(pretrained='vggface2').eval()
        
        # Freeze the resnet parameters
        for param in self.resnet.parameters():
            param.requires_grad = False
        
        # Load the trained hierarchical classifier
        print(f"Loading trained model from {model_path}")
        checkpoint = torch.load(model_path, map_location='cpu')
        
        self.class_to_idx = checkpoint['class_to_idx']
        self.idx_to_class = checkpoint['idx_to_class']
        self.num_classes = checkpoint['num_classes']
        
        # Initialize the hierarchical classifier
        self.hierarchical_model = HierarchicalClassifier(
            input_dim=512,
            num_classes=self.num_classes,
            hidden_dim=256,
            dropout_prob=0.3,
            class_to_idx=self.class_to_idx,
            idx_to_class=self.idx_to_class
        )
        
        # Load the trained weights
        self.hierarchical_model.load_state_dict(checkpoint['model_state_dict'])
        self.hierarchical_model.eval()
        
        print(f"✓ Loaded hierarchical classifier with {self.num_classes} classes")
        print(f"✓ Best validation accuracy: {checkpoint.get('val_accuracy', 'unknown'):.2f}%")
        
        # Initialize and load the centroid distance calculator
        print(f"Loading centroids from {centroids_path}")
        self.centroid_calc = CentroidDistanceCalculator()
        self.centroid_calc.import_centroids(centroids_path)
        
        print("✓ EnsembleClassifier initialized successfully")
    
    def _process_image_for_classifier(self, image_path):
        """
        Process image to get embedding for the hierarchical classifier
        
        Args:
            image_path (str): Path to the image
            
        Returns:
            torch.Tensor or None: Face embedding (512-dim) or None if failed
        """
        try:
            img = Image.open(image_path)
            
            # Convert RGBA to RGB if necessary
            if img.mode == 'RGBA':
                img = img.convert('RGB')
            
            # Detect face using MTCNN
            face = self.mtcnn(img)
            
            if face is None:
                return None
            
            # Handle multiple faces - use the first one
            if isinstance(face, list):
                if len(face) == 0:
                    return None
                face = face[0]
            
            # Fix tensor dimensions if needed
            if face.dim() == 5:  # [1, 1, 3, H, W]
                face = face.squeeze(1)  # Remove extra dimension
            elif face.dim() == 3:  # [3, H, W]
                face = face.unsqueeze(0)  # Add batch dimension
                
            # Generate embedding using InceptionResnetV1
            with torch.no_grad():
                embedding = self.resnet(face)
                
                # If batch dimension exists, take the first embedding
                if embedding.dim() > 1 and embedding.shape[0] > 1:
                    embedding = embedding[0:1]
                    
                return embedding.flatten()
                
        except Exception as e:
            print(f"Error processing {image_path}: {str(e)}")
            return None
    
    def predict(self, image_path, weights={'hierarchical': 0.6, 'centroid': 0.4}, 
                distance_metric='euclidean', return_details=False):
        """
        Make ensemble prediction for an image
        
        Args:
            image_path (str): Path to the image
            weights (dict): Weights for ensemble combination
            distance_metric (str): Distance metric for centroid classifier
            return_details (bool): If True, return detailed prediction info
            
        Returns:
            If return_details=False: predicted_class_name
            If return_details=True: (predicted_class_name, confidence, individual_predictions)
        """
        # Get embedding for hierarchical classifier
        embedding = self._process_image_for_classifier(image_path)
        
        if embedding is None:
            if return_details:
                return None, 0.0, None
            return None
        
        # Get hierarchical classifier prediction
        with torch.no_grad():
            hierarchical_logits = self.hierarchical_model(embedding.unsqueeze(0))
            hierarchical_probabilities = F.softmax(hierarchical_logits, dim=1).squeeze().numpy()
        
        # Get centroid distances
        centroid_distances = self.centroid_calc.process(image_path, distance_metric)
        
        # Convert distances to logits (lower distance = higher logit)
        epsilon = 1e-8
        temperature = 0.1
        centroid_logits = -centroid_distances / (temperature + epsilon)
        centroid_logits = np.where(np.isinf(centroid_logits), -100.0, centroid_logits)
        
        # Ensure same dimensionality
        min_len = min(len(hierarchical_probabilities), len(centroid_logits))
        hierarchical_logits_np = hierarchical_logits.squeeze().detach().numpy()[:min_len]
        centroid_logits = centroid_logits[:min_len]
        
        # Weighted combination
        ensemble_logits = (weights['hierarchical'] * hierarchical_logits_np + 
                          weights['centroid'] * centroid_logits)
        
        # Convert to probabilities
        ensemble_probabilities = torch.softmax(torch.from_numpy(ensemble_logits), dim=0).numpy()
        
        # Get prediction
        predicted_idx = np.argmax(ensemble_probabilities)
        predicted_class = self.idx_to_class[predicted_idx]
        confidence = ensemble_probabilities[predicted_idx]
        
        if not return_details:
            return predicted_class
        
        # Individual predictions for comparison
        hierarchical_pred_idx = np.argmax(hierarchical_probabilities)
        hierarchical_pred_class = self.idx_to_class[hierarchical_pred_idx]
        
        centroid_pred_idx = np.argmin(centroid_distances[:min_len])
        centroid_pred_class = self.centroid_calc.get_class_names()[centroid_pred_idx]
        
        individual_predictions = {
            'hierarchical': {
                'class': hierarchical_pred_class,
                'confidence': hierarchical_probabilities[hierarchical_pred_idx]
            },
            'centroid': {
                'class': centroid_pred_class,
                'distance': centroid_distances[centroid_pred_idx]
            },
            'ensemble': {
                'class': predicted_class,
                'confidence': confidence,
                'probabilities': ensemble_probabilities
            }
        }
        
        return predicted_class, confidence, individual_predictions
    
    def predict_top_k(self, image_path, k=3, weights={'hierarchical': 0.6, 'centroid': 0.4}, 
                     distance_metric='euclidean'):
        """
        Get top-k predictions from the ensemble
        
        Args:
            image_path (str): Path to the image
            k (int): Number of top predictions to return
            weights (dict): Weights for ensemble combination
            distance_metric (str): Distance metric for centroid classifier
            
        Returns:
            list: List of (class_name, confidence) tuples sorted by confidence
        """
        predicted_class, confidence, details = self.predict(
            image_path, weights, distance_metric, return_details=True
        )
        
        if predicted_class is None:
            return []
        
        # Get top-k from ensemble probabilities
        ensemble_probs = details['ensemble']['probabilities']
        top_k_indices = np.argsort(ensemble_probs)[-k:][::-1]  # Sort descending
        
        top_k_predictions = []
        for idx in top_k_indices:
            class_name = self.idx_to_class[idx]
            confidence = ensemble_probs[idx]
            top_k_predictions.append((class_name, confidence))
        
        return top_k_predictions
    
    def get_class_names(self):
        """Get all available class names"""
        return list(self.idx_to_class.values())


# Example usage
if __name__ == "__main__":
    print("Ensemble Classifier - Single File Demo")
    print("="*50)
    
    # Check if required files exist
    model_path = "./assets/checkpoints/best_model.pth"
    centroids_path = "./assets/face_centroids.pkl"
    
    if not os.path.exists(model_path):
        print(f"Error: Model file not found at {model_path}")
        print("Please make sure you have trained the model first.")
        sys.exit(1)
    
    if not os.path.exists(centroids_path):
        print(f"Error: Centroids file not found at {centroids_path}")
        print("Please make sure you have generated the centroids first.")
        sys.exit(1)
    
    # Initialize ensemble classifier
    ensemble = EnsembleClassifier(model_path, centroids_path)
    
    print(f"\nAvailable classes: {ensemble.get_class_names()}")
    
    # Example prediction (you would replace this with your actual image path)
    test_image_path = "path/to/your/test/image.jpg"
    
    if os.path.exists(test_image_path):
        print(f"\nTesting on: {test_image_path}")
        
        # Simple prediction
        predicted_class = ensemble.predict(test_image_path)
        print(f"Predicted class: {predicted_class}")
        
        # Detailed prediction
        pred_class, confidence, details = ensemble.predict(test_image_path, return_details=True)
        print(f"Detailed prediction:")
        print(f"  Ensemble: {pred_class} (confidence: {confidence:.3f})")
        print(f"  Hierarchical: {details['hierarchical']['class']} (confidence: {details['hierarchical']['confidence']:.3f})")
        print(f"  Centroid: {details['centroid']['class']} (distance: {details['centroid']['distance']:.3f})")
        
        # Top-3 predictions
        top_k = ensemble.predict_top_k(test_image_path, k=3)
        print(f"Top-3 predictions:")
        for i, (class_name, conf) in enumerate(top_k, 1):
            print(f"  {i}. {class_name}: {conf:.3f}")
    else:
        print(f"\nTo test the classifier, provide a valid image path in the main section.")
        print("Example usage:")
        print("  ensemble = EnsembleClassifier()")
        print("  prediction = ensemble.predict('path/to/image.jpg')")
        print("  print(f'Predicted class: {prediction}')") 