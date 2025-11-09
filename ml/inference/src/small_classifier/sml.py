import torch
import torch.nn as nn
from facenet_pytorch import MTCNN, InceptionResnetV1
from PIL import Image
import numpy as np
import os
import ssl
import pickle

# Fix SSL certificate issues
ssl._create_default_https_context = ssl._create_unverified_context

class SimpleClassifierModel(nn.Module):
    """Simple one-layer fully connected classifier with optional dropout"""
    
    def __init__(self, input_dim=512, num_classes=15, hidden_dim=256, dropout_prob=0.3):
        super(SimpleClassifierModel, self).__init__()
        self.fc1 = nn.Linear(input_dim, hidden_dim)
        self.dropout1 = nn.Dropout(dropout_prob)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(hidden_dim, num_classes)
        
    def forward(self, x):
        x = self.fc1(x)
        x = self.relu(x)
        x = self.dropout1(x)
        x = self.fc2(x)
        return x

class SmallClassifier:
    """
    Small classifier for face classification using MTCNN + InceptionResnetV1 + simple FC layer.
    Returns logits vector for ensemble combination.
    """
    
    def __init__(self, model_path="models/small_classifier.pth"):
        """
        Initialize the small classifier with pre-trained model.
        
        Args:
            model_path (str): Path to the saved model file
        """
        print("Initializing SmallClassifier...")
        self.model_path = model_path
        
        # Initialize MTCNN for face detection
        self.mtcnn = MTCNN(keep_all=True, device='cpu')
        
        # Initialize InceptionResnetV1 for embeddings (frozen)
        try:
            self.resnet = InceptionResnetV1(pretrained='vggface2').eval()
            print("✓ InceptionResnetV1 model loaded successfully")
        except Exception as e:
            print(f"Error loading pretrained model: {str(e)}")
            self._download_model_manually()
        
        # Freeze the resnet parameters
        for param in self.resnet.parameters():
            param.requires_grad = False
            
        # Load the trained classifier model
        self._load_model()
        
        print("✓ SmallClassifier initialized")
    
    def _download_model_manually(self):
        """Download InceptionResnetV1 model manually if automatic download fails."""
        import urllib.request
        import shutil
        
        os.makedirs('models', exist_ok=True)
        url = "https://github.com/timesler/facenet-pytorch/releases/download/v2.2.9/20180402-114759-vggface2.pt"
        local_path = "models/20180402-114759-vggface2.pt"
        
        try:
            with urllib.request.urlopen(url) as response, open(local_path, 'wb') as out_file:
                shutil.copyfileobj(response, out_file)
            print("✓ Model downloaded successfully")
            self.resnet = InceptionResnetV1(pretrained=local_path).eval()
        except Exception as e:
            print(f"Error downloading model: {str(e)}")
            raise
    
    def _load_model(self):
        """Load the trained classifier model."""
        if not os.path.exists(self.model_path):
            raise FileNotFoundError(f"Model file not found: {self.model_path}")
        
        # Load the saved model
        checkpoint = torch.load(self.model_path, map_location='cpu')
        
        # Extract model information
        self.class_to_idx = checkpoint['class_to_idx']
        self.idx_to_class = checkpoint['idx_to_class']
        self.num_classes = checkpoint['num_classes']
        
        # Initialize and load the model
        self.model = SimpleClassifierModel(input_dim=512, num_classes=self.num_classes)
        self.model.load_state_dict(checkpoint['model_state_dict'])
        self.model.eval()
        
        print(f"✓ Loaded model with {self.num_classes} classes")
        print(f"  Classes: {list(self.class_to_idx.keys())}")
    
    def _process_image(self, image):
        """
        Process an image to extract face embedding.
        
        Args:
            image (PIL.Image): Input image
            
        Returns:
            torch.Tensor: Face embedding vector (512-dimensional) or None if failed
        """
        try:
            # Convert RGBA to RGB if necessary
            if image.mode == 'RGBA':
                image = image.convert('RGB')
            
            # Detect face using MTCNN
            face = self.mtcnn(image)
            
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
                    
                return embedding.flatten()  # Return 1D tensor
                
        except Exception as e:
            print(f"Error processing image: {str(e)}")
            return None
    
    def predict_logits(self, image):
        """
        Predict class logits for an input image.
        
        Args:
            image (PIL.Image): Input image
            
        Returns:
            np.ndarray: Logits vector of shape (num_classes,)
        """
        # Extract face embedding
        embedding = self._process_image(image)
        
        if embedding is None:
            print("Warning: No face detected in image")
            # Return zero logits if no face detected
            return np.zeros(self.num_classes, dtype=np.float32)
        
        # Get logits from the model
        with torch.no_grad():
            logits = self.model(embedding.unsqueeze(0))  # Add batch dimension
            return logits.squeeze(0).numpy()  # Remove batch dimension and convert to numpy
    
    def predict_class(self, image):
        """
        Predict the most likely class for an image.
        
        Args:
            image (PIL.Image): Input image
            
        Returns:
            tuple: (predicted_class_id, predicted_class_name, confidence_score)
        """
        logits = self.predict_logits(image)
        
        if np.all(logits == 0):
            return None, None, 0.0
        
        # Apply softmax to get probabilities
        probabilities = torch.softmax(torch.from_numpy(logits), dim=0).numpy()
        
        # Get prediction
        predicted_idx = np.argmax(probabilities)
        predicted_class = self.idx_to_class[predicted_idx]
        confidence = probabilities[predicted_idx]
        
        return predicted_idx, predicted_class, confidence
    
    def get_class_names(self):
        """
        Get the list of class names.
        
        Returns:
            list: List of class names
        """
        return [self.idx_to_class[i] for i in range(self.num_classes)]
    
    def get_class_mapping(self):
        """
        Get the class mappings.
        
        Returns:
            tuple: (class_to_idx, idx_to_class)
        """
        return self.class_to_idx.copy(), self.idx_to_class.copy()


# Example usage
if __name__ == "__main__":
    # Initialize the classifier
    classifier = SmallClassifier("models/small_classifier.pth")
    
    # Example prediction (you would need to provide an actual image)
    # from PIL import Image
    # image = Image.open("path/to/test/image.jpg")
    # logits = classifier.predict_logits(image)
    # print("Logits:", logits)
    # 
    # class_id, class_name, confidence = classifier.predict_class(image)
    # print(f"Predicted: {class_name} (ID: {class_id}, Confidence: {confidence:.4f})")
    
    print("\n✓ SmallClassifier ready for inference!")