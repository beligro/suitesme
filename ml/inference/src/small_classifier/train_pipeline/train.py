import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader, random_split
from facenet_pytorch import MTCNN, InceptionResnetV1
from PIL import Image
import numpy as np
import os
import ssl
from tqdm import tqdm
from collections import defaultdict
import pickle
from pathlib import Path

# Fix SSL certificate issues
ssl._create_default_https_context = ssl._create_unverified_context

class FaceDataset(Dataset):
    """Dataset class for face classification"""
    
    def __init__(self, image_paths, labels, mtcnn, resnet):
        self.image_paths = image_paths
        self.labels = labels
        self.mtcnn = mtcnn
        self.resnet = resnet
        
    def __len__(self):
        return len(self.image_paths)
    
    def __getitem__(self, idx):
        image_path = self.image_paths[idx]
        label = self.labels[idx]
        
        try:
            # Load and process image
            img = Image.open(image_path)
            
            # Convert RGBA to RGB if necessary
            if img.mode == 'RGBA':
                img = img.convert('RGB')
            
            # Detect face using MTCNN
            face = self.mtcnn(img)
            
            if face is None:
                # Return zeros if no face detected
                return torch.zeros(512), label
            
            # Handle multiple faces - use the first one
            if isinstance(face, list):
                if len(face) == 0:
                    return torch.zeros(512), label
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
                    
                return embedding.flatten(), label
                
        except Exception as e:
            print(f"Error processing {image_path}: {str(e)}")
            return torch.zeros(512), label

class SimpleClassifier(nn.Module):
    """Simple one-layer fully connected classifier"""
    
    def __init__(self, input_dim=512, num_classes=15):
        super(SimpleClassifier, self).__init__()
        self.fc = nn.Linear(input_dim, num_classes)
        
    def forward(self, x):
        return self.fc(x)

class TrainPipeline:
    """Training pipeline for the small classifier"""
    
    def __init__(self, faces_dir="raw_data/faces", faces_v0_dir="raw_data/faces_v0"):
        self.faces_dir = faces_dir
        self.faces_v0_dir = faces_v0_dir
        
        print("Initializing TrainPipeline...")
        
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
            
        # Class mapping for consistency between faces and faces_v0
        self.class_mapping = {
            "ARISTOCRATIC LADY": "Aristocratic",
            "BUSINESS WOMAN": "Business", 
            "FIRE LADY": "Fire",
            "FRAGILE GIRL": "Fragile",
            "HEROIN GIRL": "Heroin",
            "INFERNO LADY": "Inferno",
            "MELTING LADY": "Melting",
            "QUEEN": "Queen",
            "RENAISSANCE QUEEN": "Renaissance",
            "SERIOUS GIRL": "Serious",
            "SOFT DIVA": "Soft",
            "STRONG DIVA": "Strong",
            "SUNNY GIRL": "Sunny",
            "VINTAGE GIRL": "Vintage",
            "WARM WOMAN": "Warm"
        }
        
        self.class_to_idx = {}
        self.idx_to_class = {}
        
        print("✓ TrainPipeline initialized")
    
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
    
    def _is_image_file(self, filename):
        """Check if a file is an image based on its extension."""
        image_extensions = {'.jpg', '.jpeg', '.png', '.bmp', '.gif', '.tiff', '.webp'}
        return os.path.splitext(filename.lower())[1] in image_extensions
    
    def _load_dataset_paths(self):
        """Load image paths from both faces directories and organize by class."""
        face_paths = defaultdict(list)
        
        # Process faces directory
        if os.path.exists(self.faces_dir):
            print(f"Loading from {self.faces_dir}...")
            for class_folder in os.listdir(self.faces_dir):
                if class_folder.startswith('.'):
                    continue
                    
                class_path = os.path.join(self.faces_dir, class_folder)
                if os.path.isdir(class_path):
                    # Normalize class name
                    normalized_name = self.class_mapping.get(class_folder, class_folder)
                    
                    # Find all image files
                    for file_name in os.listdir(class_path):
                        if self._is_image_file(file_name):
                            face_paths[normalized_name].append(os.path.join(class_path, file_name))
        
        # Process faces_v0 directory
        if os.path.exists(self.faces_v0_dir):
            print(f"Loading from {self.faces_v0_dir}...")
            for class_folder in os.listdir(self.faces_v0_dir):
                if class_folder.startswith('.'):
                    continue
                    
                class_path = os.path.join(self.faces_v0_dir, class_folder)
                if os.path.isdir(class_path):
                    # The faces_v0 classes should already be normalized
                    normalized_name = class_folder
                    
                    # Find all image files
                    for file_name in os.listdir(class_path):
                        if self._is_image_file(file_name):
                            face_paths[normalized_name].append(os.path.join(class_path, file_name))
        
        # Convert to regular dict and sort class names for consistency
        face_paths = dict(face_paths)
        print(f"Found {len(face_paths)} classes with images")
        for class_name, paths in face_paths.items():
            print(f"  {class_name}: {len(paths)} images")
            
        return face_paths
    
    def prepare_data(self, validation_split=0.2):
        """Prepare train and validation datasets"""
        print("Preparing datasets...")
        
        # Load all image paths
        face_paths = self._load_dataset_paths()
        
        if not face_paths:
            raise ValueError("No face classes found in the specified directories!")
        
        # Create class mappings
        class_names = sorted(face_paths.keys())
        self.class_to_idx = {name: idx for idx, name in enumerate(class_names)}
        self.idx_to_class = {idx: name for name, idx in self.class_to_idx.items()}
        
        print(f"Class mappings: {self.class_to_idx}")
        
        # Collect all image paths and labels
        all_image_paths = []
        all_labels = []
        
        for class_name, image_paths in face_paths.items():
            class_idx = self.class_to_idx[class_name]
            all_image_paths.extend(image_paths)
            all_labels.extend([class_idx] * len(image_paths))
        
        print(f"Total images: {len(all_image_paths)}")
        
        # Create dataset
        dataset = FaceDataset(all_image_paths, all_labels, self.mtcnn, self.resnet)
        
        # Split into train and validation
        val_size = int(len(dataset) * validation_split)
        train_size = len(dataset) - val_size
        
        train_dataset, val_dataset = random_split(dataset, [train_size, val_size])
        
        print(f"Train size: {train_size}, Validation size: {val_size}")
        
        return train_dataset, val_dataset
    
    def train(self, num_epochs=10, batch_size=32, learning_rate=0.001, validation_split=0.2, 
              save_path="models/small_classifier.pth"):
        """Train the small classifier"""
        print("="*60)
        print("TRAINING SMALL CLASSIFIER")
        print("="*60)
        
        # Prepare data
        train_dataset, val_dataset = self.prepare_data(validation_split)
        
        # Create data loaders
        train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True, num_workers=2)
        val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False, num_workers=2)
        
        # Initialize model
        num_classes = len(self.class_to_idx)
        model = SimpleClassifier(input_dim=512, num_classes=num_classes)
        
        # Loss and optimizer
        criterion = nn.CrossEntropyLoss()
        optimizer = optim.Adam(model.parameters(), lr=learning_rate)
        
        # Training loop
        train_losses = []
        val_accuracies = []
        
        for epoch in range(num_epochs):
            print(f"\nEpoch {epoch+1}/{num_epochs}")
            
            # Training phase
            model.train()
            running_loss = 0.0
            train_pbar = tqdm(train_loader, desc="Training")
            
            for embeddings, labels in train_pbar:
                optimizer.zero_grad()
                
                outputs = model(embeddings)
                loss = criterion(outputs, labels)
                loss.backward()
                optimizer.step()
                
                running_loss += loss.item()
                train_pbar.set_postfix({"Loss": f"{loss.item():.4f}"})
            
            avg_train_loss = running_loss / len(train_loader)
            train_losses.append(avg_train_loss)
            
            # Validation phase
            model.eval()
            val_correct = 0
            val_total = 0
            val_loss = 0.0
            
            with torch.no_grad():
                val_pbar = tqdm(val_loader, desc="Validation")
                for embeddings, labels in val_pbar:
                    outputs = model(embeddings)
                    loss = criterion(outputs, labels)
                    val_loss += loss.item()
                    
                    _, predicted = torch.max(outputs.data, 1)
                    val_total += labels.size(0)
                    val_correct += (predicted == labels).sum().item()
                    
                    accuracy = 100 * val_correct / val_total
                    val_pbar.set_postfix({"Accuracy": f"{accuracy:.2f}%"})
            
            val_accuracy = 100 * val_correct / val_total
            val_accuracies.append(val_accuracy)
            
            print(f"Train Loss: {avg_train_loss:.4f}, Val Accuracy: {val_accuracy:.2f}%")
        
        # Save the model and class mappings
        os.makedirs(os.path.dirname(save_path), exist_ok=True)
        torch.save({
            'model_state_dict': model.state_dict(),
            'class_to_idx': self.class_to_idx,
            'idx_to_class': self.idx_to_class,
            'num_classes': num_classes
        }, save_path)
        
        # Also save class mappings separately
        with open(save_path.replace('.pth', '_classes.pkl'), 'wb') as f:
            pickle.dump({
                'class_to_idx': self.class_to_idx,
                'idx_to_class': self.idx_to_class,
                'num_classes': num_classes
            }, f)
        
        print(f"\n✓ Model saved to {save_path}")
        print(f"✓ Class mappings saved to {save_path.replace('.pth', '_classes.pkl')}")
        print(f"✓ Final validation accuracy: {val_accuracies[-1]:.2f}%")
        
        return model, train_losses, val_accuracies


# Example usage
if __name__ == "__main__":
    # Initialize training pipeline
    trainer = TrainPipeline(
        faces_dir="/Users/gena/Documents/SuitsMe/train_pipeline/faces",
        faces_v0_dir="/Users/gena/Documents/SuitsMe/train_pipeline/faces_v0"
    )
    
    # Train the model
    model, train_losses, val_accuracies = trainer.train(
        num_epochs=20,
        batch_size=128,
        learning_rate=0.005,
        validation_split=0.2,
        save_path="./assets/small_classifier.pth"
    )
    
    print("\n✓ Training completed!") 