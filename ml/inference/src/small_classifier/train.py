import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader, random_split
from torch.optim.lr_scheduler import OneCycleLR
from facenet_pytorch import MTCNN, InceptionResnetV1
from PIL import Image
import numpy as np
import os
import ssl
from tqdm import tqdm
from collections import defaultdict
import pickle
from pathlib import Path
import torchvision.transforms as transforms
import torch.nn.functional as F

# Fix SSL certificate issues
ssl._create_default_https_context = ssl._create_unverified_context

class FocalLoss(nn.Module):
    """Focal Loss for handling class imbalance"""
    def __init__(self, alpha=None, gamma=2, reduction='mean'):
        super(FocalLoss, self).__init__()
        self.alpha = alpha
        self.gamma = gamma
        self.reduction = reduction
        
    def forward(self, inputs, targets):
        ce_loss = nn.CrossEntropyLoss(reduction='none')(inputs, targets)
        pt = torch.exp(-ce_loss)
        
        # Apply class weights if provided
        if self.alpha is not None:
            # Get the weights for each target class
            alpha = self.alpha[targets]
            focal_loss = alpha * (1-pt)**self.gamma * ce_loss
        else:
            focal_loss = (1-pt)**self.gamma * ce_loss
        
        if self.reduction == 'mean':
            return focal_loss.mean()
        elif self.reduction == 'sum':
            return focal_loss.sum()
        return focal_loss

class FaceDataset(Dataset):
    """Dataset class for face classification with simplified augmentation"""
    
    def __init__(self, image_paths, labels, mtcnn, resnet, is_training=True):
        self.image_paths = image_paths
        self.labels = labels
        self.mtcnn = mtcnn
        self.resnet = resnet
        self.is_training = is_training
        
        # Simplified augmentations for small dataset
        self.train_transform = transforms.Compose([
            transforms.RandomHorizontalFlip(p=0.5),
            transforms.RandomRotation(10),
            transforms.ColorJitter(brightness=0.1, contrast=0.1),
        ])
        
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
            
            # Apply augmentations during training
            if self.is_training:
                img = self.train_transform(img)
            
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

class HierarchicalClassifier(nn.Module):
    def __init__(self, input_dim=512, num_classes=15, hidden_dim=256, dropout_prob=0.3, 
                 class_to_idx=None, idx_to_class=None):
        super().__init__()
        
        # Store class mappings
        self.class_to_idx = class_to_idx
        self.idx_to_class = idx_to_class
        
        # Define super-classes and their member classes
        self.super_classes = {
            'queen_like': ['Queen', 'Business', 'Fire', 'Inferno'],
            'fragile_like': ['Fragile', 'Warm', 'Vintage'],
            'strong_like': ['Strong', 'Aristocratic', 'Renaissance'],
            'soft_like': ['Soft', 'Sunny'],
            'serious_like': ['Serious', 'Heroin', 'Melting']
        }
        
        # First level classifier (super-classes)
        self.super_classifier = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.BatchNorm1d(hidden_dim),
            nn.ReLU(),
            nn.Dropout(dropout_prob),
            nn.Linear(hidden_dim, len(self.super_classes))
        )
        
        # Second level classifiers (sub-classes)
        self.sub_classifiers = nn.ModuleDict()
        for super_class, sub_classes in self.super_classes.items():
            self.sub_classifiers[super_class] = nn.Sequential(
                nn.Linear(input_dim, hidden_dim),
                nn.BatchNorm1d(hidden_dim),
                nn.ReLU(),
                nn.Dropout(dropout_prob),
                nn.Linear(hidden_dim, len(sub_classes))
            )
        
        self.num_classes = num_classes
        self.class_to_super = self._create_class_mapping()
        
    def _create_class_mapping(self):
        """Create mapping from class to super-class"""
        mapping = {}
        for super_class, sub_classes in self.super_classes.items():
            for sub_class in sub_classes:
                mapping[sub_class] = super_class
        return mapping
    
    def forward(self, x):
        # Get super-class predictions
        super_logits = self.super_classifier(x)
        super_probs = F.softmax(super_logits, dim=1)
        
        # Initialize final logits
        batch_size = x.size(0)
        final_logits = torch.zeros(batch_size, self.num_classes, device=x.device)
        
        # For each super-class, get sub-class predictions
        for i, (super_class, sub_classes) in enumerate(self.super_classes.items()):
            # Get sub-class logits
            sub_logits = self.sub_classifiers[super_class](x)
            
            # Scale sub-class logits by super-class probability
            super_prob = super_probs[:, i].unsqueeze(1)
            scaled_sub_logits = sub_logits * super_prob
            
            # Map sub-class logits to final logits
            for j, sub_class in enumerate(sub_classes):
                class_idx = self.class_to_idx[sub_class]
                final_logits[:, class_idx] = scaled_sub_logits[:, j]
        
        return final_logits

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
        dataset = FaceDataset(all_image_paths, all_labels, self.mtcnn, self.resnet, is_training=True)
        
        # Split into train and validation
        val_size = int(len(dataset) * validation_split)
        train_size = len(dataset) - val_size
        
        train_dataset, val_dataset = random_split(dataset, [train_size, val_size])
        
        # Set validation dataset to non-training mode
        val_dataset.dataset.is_training = False
        
        print(f"Train size: {train_size}, Validation size: {val_size}")
        
        return train_dataset, val_dataset
    
    def train(self, num_epochs=20, batch_size=16, learning_rate=0.001, validation_split=0.2, 
              save_path="./assets/small_classifier.pth", patience=5, pretrained_model_path=None):
        """
        Train the hierarchical classifier.
        
        Args:
            num_epochs: Number of training epochs
            batch_size: Batch size for training
            learning_rate: Learning rate
            validation_split: Fraction of data to use for validation
            save_path: Path to save the best model
            patience: Early stopping patience
            pretrained_model_path: Optional path to pretrained weights for fine-tuning
        """
        print("="*60)
        print("TRAINING HIERARCHICAL CLASSIFIER")
        if pretrained_model_path:
            print("MODE: FINE-TUNING FROM EXISTING WEIGHTS")
        else:
            print("MODE: TRAINING FROM SCRATCH")
        print("="*60)
        
        # Create checkpoints directory
        checkpoints_dir = os.path.join(os.path.dirname(save_path), 'checkpoints')
        os.makedirs(checkpoints_dir, exist_ok=True)
        
        # Prepare data
        train_dataset, val_dataset = self.prepare_data(validation_split)
        
        # Create data loaders
        train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True, num_workers=2)
        val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False, num_workers=2)
        
        # Get class counts from the dataset preparation
        face_paths = self._load_dataset_paths()
        class_counts = {self.class_to_idx[name]: len(paths) for name, paths in face_paths.items()}
        
        # Calculate weights using inverse frequency
        total_samples = sum(class_counts.values())
        class_weights = torch.FloatTensor([
            total_samples / (len(class_counts) * class_counts[i])
            for i in range(len(class_counts))
        ])
        
        # Print class distribution and weights
        print("\nClass Distribution and Weights:")
        print("-" * 50)
        for idx, (class_name, count) in enumerate(sorted(self.idx_to_class.items())):
            print(f"{self.idx_to_class[idx]:<15} | Count: {class_counts[idx]:>3} | Weight: {class_weights[idx]:.3f}")
        print("-" * 50)
        
        # Initialize model with class mappings
        num_classes = len(self.class_to_idx)
        model = HierarchicalClassifier(
            input_dim=512, 
            num_classes=num_classes, 
            hidden_dim=256, 
            dropout_prob=0.3,
            class_to_idx=self.class_to_idx,
            idx_to_class=self.idx_to_class
        )
        
        # Load pretrained weights for fine-tuning if provided
        if pretrained_model_path and os.path.exists(pretrained_model_path):
            print(f"\n{'='*60}")
            print(f"LOADING PRETRAINED WEIGHTS FOR FINE-TUNING")
            print(f"{'='*60}")
            try:
                checkpoint = torch.load(pretrained_model_path, map_location='cpu')
                
                # Load model state dict
                if 'model_state_dict' in checkpoint:
                    model.load_state_dict(checkpoint['model_state_dict'])
                    print(f"✓ Loaded pretrained weights from checkpoint")
                    
                    # Log previous best accuracy if available
                    if 'best_val_accuracy' in checkpoint:
                        prev_accuracy = checkpoint['best_val_accuracy']
                        print(f"  Previous best validation accuracy: {prev_accuracy:.2f}%")
                else:
                    print("⚠️  No model_state_dict found in checkpoint, training from scratch")
                
                print(f"{'='*60}\n")
            except Exception as e:
                print(f"⚠️  Error loading pretrained weights: {e}")
                print(f"   Continuing with fresh initialization")
                print(f"{'='*60}\n")
        
        # Loss with class weights and focal loss
        criterion = FocalLoss(alpha=class_weights, gamma=2)
        
        # Optimizer with reduced weight decay for small dataset
        optimizer = optim.AdamW(model.parameters(), lr=learning_rate, weight_decay=1e-5)
        
        # Learning rate scheduler with longer warmup
        scheduler = OneCycleLR(
            optimizer,
            max_lr=learning_rate,
            epochs=num_epochs,
            steps_per_epoch=len(train_loader),
            pct_start=0.4,  # Longer warmup
            div_factor=25,
            final_div_factor=1e4
        )
        
        # Early stopping
        best_val_accuracy = 0
        best_model_state = None
        epochs_without_improvement = 0
        
        # Training loop
        train_losses = []
        val_accuracies = []
        
        # Diagnostic metrics
        class_confusion = {i: {j: 0 for j in range(num_classes)} for i in range(num_classes)}
        class_losses = {i: [] for i in range(num_classes)}
        super_class_confusion = {i: {j: 0 for j in range(len(model.super_classes))} 
                               for i in range(len(model.super_classes))}
        
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
                
                # Track per-class training loss
                with torch.no_grad():
                    for label, output in zip(labels, outputs):
                        class_losses[label.item()].append(criterion(output.unsqueeze(0), label.unsqueeze(0)).item())
                
                loss.backward()
                optimizer.step()
                scheduler.step()
                
                running_loss += loss.item()
                train_pbar.set_postfix({
                    "Loss": f"{loss.item():.4f}",
                    "LR": f"{scheduler.get_last_lr()[0]:.6f}"
                })
            
            avg_train_loss = running_loss / len(train_loader)
            train_losses.append(avg_train_loss)
            
            # Validation phase
            model.eval()
            val_correct = 0
            val_total = 0
            val_loss = 0.0
            class_correct = defaultdict(int)
            class_total = defaultdict(int)
            
            with torch.no_grad():
                val_pbar = tqdm(val_loader, desc="Validation")
                for embeddings, labels in val_pbar:
                    outputs = model(embeddings)
                    loss = criterion(outputs, labels)
                    val_loss += loss.item()
                    
                    _, predicted = torch.max(outputs.data, 1)
                    val_total += labels.size(0)
                    val_correct += (predicted == labels).sum().item()
                    
                    # Track per-class accuracy and confusion
                    for label, pred in zip(labels, predicted):
                        class_total[label.item()] += 1
                        if label == pred:
                            class_correct[label.item()] += 1
                        class_confusion[label.item()][pred.item()] += 1
                        
                        # Track super-class confusion
                        label_super = list(model.super_classes.keys()).index(
                            model.class_to_super[model.idx_to_class[label.item()]]
                        )
                        pred_super = list(model.super_classes.keys()).index(
                            model.class_to_super[model.idx_to_class[pred.item()]]
                        )
                        super_class_confusion[label_super][pred_super] += 1
                    
                    accuracy = 100 * val_correct / val_total
                    val_pbar.set_postfix({"Accuracy": f"{accuracy:.2f}%"})
            
            val_accuracy = 100 * val_correct / val_total
            val_accuracies.append(val_accuracy)
            
            print(f"Train Loss: {avg_train_loss:.4f}, Val Accuracy: {val_accuracy:.2f}%")
            
            # Print per-class validation accuracy and analysis
            print("\nPer-class Validation Accuracy and Analysis:")
            print("-" * 80)
            for idx in range(num_classes):
                if class_total[idx] > 0:
                    class_acc = 100 * class_correct[idx] / class_total[idx]
                    avg_class_loss = np.mean(class_losses[idx]) if class_losses[idx] else 0
                    
                    # Find most common misclassification
                    misclassifications = [(j, class_confusion[idx][j]) for j in range(num_classes) if j != idx]
                    most_common_misclass = max(misclassifications, key=lambda x: x[1]) if misclassifications else (None, 0)
                    
                    print(f"{self.idx_to_class[idx]:<15} | "
                          f"Accuracy: {class_acc:>6.2f}% | "
                          f"Avg Loss: {avg_class_loss:.4f} | "
                          f"Most confused with: {self.idx_to_class[most_common_misclass[0]] if most_common_misclass[0] is not None else 'None'} "
                          f"({most_common_misclass[1]} times)")
            print("-" * 80)
            
            # Print super-class confusion matrix
            print("\nSuper-class Confusion Matrix:")
            print("-" * 80)
            super_class_names = list(model.super_classes.keys())
            print("True\\Pred", end="\t")
            for pred in super_class_names:
                print(f"{pred:<15}", end="")
            print()
            for i, true in enumerate(super_class_names):
                print(f"{true:<15}", end="")
                for j in range(len(super_class_names)):
                    print(f"{super_class_confusion[i][j]:<15}", end="")
                print()
            print("-" * 80)
            
            # Save checkpoint after each epoch
            checkpoint_path = os.path.join(checkpoints_dir, f'epoch_{epoch+1}.pth')
            torch.save({
                'epoch': epoch + 1,
                'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'scheduler_state_dict': scheduler.state_dict(),
                'train_loss': avg_train_loss,
                'val_accuracy': val_accuracy,
                'class_to_idx': self.class_to_idx,
                'idx_to_class': self.idx_to_class,
                'num_classes': num_classes,
                'class_weights': class_weights,
                'class_confusion': class_confusion,
                'class_losses': class_losses,
                'super_class_confusion': super_class_confusion
            }, checkpoint_path)
            print(f"✓ Checkpoint saved: {checkpoint_path}")
            
            # Early stopping
            if val_accuracy > best_val_accuracy:
                best_val_accuracy = val_accuracy
                best_model_state = model.state_dict().copy()
                epochs_without_improvement = 0
                print(f"✓ New best validation accuracy: {best_val_accuracy:.2f}%")
                
                # Save best model
                best_model_path = os.path.join(checkpoints_dir, 'best_model.pth')
                torch.save({
                    'epoch': epoch + 1,
                    'model_state_dict': best_model_state,
                    'optimizer_state_dict': optimizer.state_dict(),
                    'scheduler_state_dict': scheduler.state_dict(),
                    'train_loss': avg_train_loss,
                    'val_accuracy': val_accuracy,
                    'class_to_idx': self.class_to_idx,
                    'idx_to_class': self.idx_to_class,
                    'num_classes': num_classes,
                    'class_weights': class_weights,
                    'class_confusion': class_confusion,
                    'class_losses': class_losses,
                    'super_class_confusion': super_class_confusion
                }, best_model_path)
                print(f"✓ Best model saved: {best_model_path}")
            else:
                epochs_without_improvement += 1
                print(f"⚠️  No improvement for {epochs_without_improvement} epochs")
                
                if epochs_without_improvement >= patience:
                    print(f"⚠️  Early stopping triggered after {epoch+1} epochs")
                    break
        
        # Restore best model
        if best_model_state is not None:
            model.load_state_dict(best_model_state)
            print(f"✓ Restored best model with validation accuracy: {best_val_accuracy:.2f}%")
        
        # Save the final model and class mappings
        os.makedirs(os.path.dirname(save_path), exist_ok=True)
        torch.save({
            'model_state_dict': model.state_dict(),
            'class_to_idx': self.class_to_idx,
            'idx_to_class': self.idx_to_class,
            'num_classes': num_classes,
            'best_val_accuracy': best_val_accuracy,
            'class_weights': class_weights,
            'class_confusion': class_confusion,
            'class_losses': class_losses,
            'super_class_confusion': super_class_confusion
        }, save_path)
        
        # Also save class mappings separately
        with open(save_path.replace('.pth', '_classes.pkl'), 'wb') as f:
            pickle.dump({
                'class_to_idx': self.class_to_idx,
                'idx_to_class': self.idx_to_class,
                'num_classes': num_classes,
                'best_val_accuracy': best_val_accuracy,
                'class_weights': class_weights,
                'class_confusion': class_confusion,
                'class_losses': class_losses,
                'super_class_confusion': super_class_confusion
            }, f)
        
        print(f"\n✓ Model saved to {save_path}")
        print(f"✓ Class mappings saved to {save_path.replace('.pth', '_classes.pkl')}")
        print(f"✓ Best validation accuracy: {best_val_accuracy:.2f}%")
        
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
        batch_size=16,
        learning_rate=0.001,
        validation_split=0.2,
        save_path="./assets/small_classifier.pth",
        patience=5
    )
    
    print("\n✓ Training completed!") 