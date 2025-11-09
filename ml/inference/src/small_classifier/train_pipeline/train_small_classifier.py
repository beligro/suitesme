#!/usr/bin/env python3
"""
Training script for the small classifier.
This script trains a simple one-layer fully connected classifier on face embeddings.
"""

import os
import sys
from pathlib import Path

# Add src to path
sys.path.append('src')

from src.small_classifier.train_pipeline.train import TrainPipeline
from src.small_classifier.sml import SmallClassifier
from PIL import Image

def main():
    """Main training and demo script"""
    print("="*60)
    print("SMALL CLASSIFIER TRAINING PIPELINE")
    print("="*60)
    
    # Check if training data exists
    faces_dir = "raw_data/faces"
    faces_v0_dir = "raw_data/faces_v0"
    
    if not os.path.exists(faces_dir) and not os.path.exists(faces_v0_dir):
        print(f"❌ Training data not found!")
        print(f"Expected directories:")
        print(f"  - {faces_dir}")
        print(f"  - {faces_v0_dir}")
        print("\nPlease create these directories and add your face classification data.")
        print("Each subdirectory should contain images for a specific face class.")
        return
    
    # Create models directory if it doesn't exist
    os.makedirs("models", exist_ok=True)
    
    # Initialize training pipeline
    print("Initializing training pipeline...")
    trainer = TrainPipeline(faces_dir=faces_dir, faces_v0_dir=faces_v0_dir)
    
    # Train the model
    print("\nStarting training...")
    model, train_losses, val_accuracies = trainer.train(
        num_epochs=15,  # Reduced for faster training
        batch_size=16,  # Smaller batch size for stability
        learning_rate=0.001,
        validation_split=0.2,
        save_path="models/small_classifier.pth"
    )
    
    print("\n" + "="*60)
    print("TRAINING COMPLETED!")
    print("="*60)
    print(f"Final validation accuracy: {val_accuracies[-1]:.2f}%")
    print(f"Best validation accuracy: {max(val_accuracies):.2f}%")
    
    # Demo inference
    print("\n" + "="*60)
    print("INFERENCE DEMO")
    print("="*60)
    
    try:
        # Initialize the inference classifier
        classifier = SmallClassifier("models/small_classifier.pth")
        
        # Get class information
        class_names = classifier.get_class_names()
        print(f"Loaded model with {len(class_names)} classes:")
        for i, name in enumerate(class_names):
            print(f"  {i}: {name}")
        
        # Example: if you have a test image, you can test it here
        # test_image_path = "path/to/test/image.jpg"
        # if os.path.exists(test_image_path):
        #     print(f"\nTesting on: {test_image_path}")
        #     image = Image.open(test_image_path)
        #     
        #     # Get logits (for ensemble)
        #     logits = classifier.predict_logits(image)
        #     print(f"Logits shape: {logits.shape}")
        #     print(f"Logits: {logits}")
        #     
        #     # Get class prediction
        #     class_id, class_name, confidence = classifier.predict_class(image)
        #     print(f"Predicted: {class_name} (ID: {class_id}, Confidence: {confidence:.4f})")
        
        print("\n✓ Inference demo completed successfully!")
        print("✓ The model is ready for ensemble combination!")
        
    except FileNotFoundError as e:
        print(f"❌ Model not found: {e}")
        print("Please train the model first.")
    except Exception as e:
        print(f"❌ Error during inference demo: {e}")

if __name__ == "__main__":
    main() 