import torch
from facenet_pytorch import MTCNN, InceptionResnetV1
from PIL import Image
import numpy as np
from sklearn.decomposition import PCA
from sklearn.metrics.pairwise import euclidean_distances, cosine_distances
from tqdm import tqdm
import os
import ssl
import pickle
from collections import defaultdict
from pathlib import Path

# Fix SSL certificate issues
ssl._create_default_https_context = ssl._create_unverified_context

class CentroidDistanceCalculator:
    """
    A class for computing distances to face embedding centroids.
    
    Features:
    1. Generate and export centroids from face directories
    2. Import pre-computed centroids
    3. Process images and return distance vectors to all centroids
    """
    
    def __init__(self):
        """Initialize the calculator with face detection and embedding models."""
        print("Initializing CentroidDistanceCalculator...")
        
        # Initialize MTCNN for face detection
        self.mtcnn = MTCNN(keep_all=True, device='cpu')
        
        # Initialize InceptionResnetV1 for embeddings
        try:
            self.resnet = InceptionResnetV1(pretrained='vggface2').eval()
            print("✓ InceptionResnetV1 model loaded successfully")
        except Exception as e:
            print(f"Error loading pretrained model: {str(e)}")
            self._download_model_manually()
        
        # Initialize storage for centroids and metadata
        self.centroids = None
        self.class_names = None
        self.pca = None
        self.use_pca = False
        
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
        
        print("✓ CentroidDistanceCalculator initialized")
    
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
    
    def _process_image(self, image_path):
        """
        Process a single image to extract face embedding.
        
        Args:
            image_path (str): Path to the image file
            
        Returns:
            np.ndarray or None: Face embedding vector (512-dimensional) or None if failed
        """
        try:
            # Load image
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
                    
                return embedding.detach().numpy().flatten()  # Return 1D array
                
        except Exception as e:
            print(f"Error processing {image_path}: {str(e)}")
            return None
    
    def _load_dataset_paths(self, faces_dir, faces_v0_dir):
        """
        Load image paths from both faces directories and organize by class.
        
        Args:
            faces_dir (str): Path to faces directory
            faces_v0_dir (str): Path to faces_v0 directory
            
        Returns:
            dict: Dictionary mapping normalized class names to lists of image paths
        """
        face_paths = defaultdict(list)
        
        # Process faces directory
        if os.path.exists(faces_dir):
            print(f"Loading from {faces_dir}...")
            for class_folder in os.listdir(faces_dir):
                if class_folder.startswith('.'):
                    continue
                    
                class_path = os.path.join(faces_dir, class_folder)
                if os.path.isdir(class_path):
                    # Normalize class name
                    normalized_name = self.class_mapping.get(class_folder, class_folder)
                    
                    # Find all image files
                    for file_name in os.listdir(class_path):
                        if self._is_image_file(file_name):
                            face_paths[normalized_name].append(os.path.join(class_path, file_name))
        
        # Process faces_v0 directory
        if os.path.exists(faces_v0_dir):
            print(f"Loading from {faces_v0_dir}...")
            for class_folder in os.listdir(faces_v0_dir):
                if class_folder.startswith('.'):
                    continue
                    
                class_path = os.path.join(faces_v0_dir, class_folder)
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
    
    def _is_image_file(self, filename):
        """Check if a file is an image based on its extension."""
        image_extensions = {'.jpg', '.jpeg', '.png', '.bmp', '.gif', '.tiff', '.webp'}
        return os.path.splitext(filename.lower())[1] in image_extensions
    
    def generate_centroids(self, faces_dir="raw_data/faces", faces_v0_dir="raw_data/faces_v0", 
                          use_pca=True, pca_components=30):
        """
        Generate centroids from face directories using MTCNN + InceptionResnetV1 + PCA.
        
        Args:
            faces_dir (str): Path to faces directory
            faces_v0_dir (str): Path to faces_v0 directory  
            use_pca (bool): Whether to apply PCA dimensionality reduction
            pca_components (int): Number of PCA components to use
            
        Returns:
            tuple: (centroids_dict, class_names_list)
        """
        print("="*60)
        print("GENERATING CENTROIDS FROM FACE DIRECTORIES")
        print("="*60)
        
        # Load all image paths organized by class
        face_paths = self._load_dataset_paths(faces_dir, faces_v0_dir)
        
        if not face_paths:
            raise ValueError("No face classes found in the specified directories!")
        
        # Generate embeddings for each class
        embeddings_by_class = defaultdict(list)
        
        print("\nGenerating embeddings...")
        for class_name, image_paths in tqdm(face_paths.items(), desc="Processing classes"):
            print(f"\nProcessing class: {class_name}")
            valid_count = 0
            
            for image_path in tqdm(image_paths, desc=f"  Images", leave=False):
                embedding = self._process_image(image_path)
                if embedding is not None:
                    embeddings_by_class[class_name].append(embedding)
                    valid_count += 1
            
            print(f"  ✓ Generated {valid_count}/{len(image_paths)} valid embeddings")
        
        if not embeddings_by_class:
            raise ValueError("No valid embeddings were generated!")
        
        # Convert to numpy arrays and collect all embeddings for PCA
        all_embeddings = []
        class_embeddings = {}
        
        for class_name, embeddings in embeddings_by_class.items():
            if len(embeddings) > 0:
                class_embeddings[class_name] = np.array(embeddings)
                all_embeddings.extend(embeddings)
        
        all_embeddings = np.array(all_embeddings)
        print(f"\nTotal embeddings generated: {len(all_embeddings)}")
        print(f"Embedding dimension: {all_embeddings.shape[1]}")
        
        # Apply PCA if requested
        if use_pca and pca_components < all_embeddings.shape[1]:
            print(f"\nApplying PCA (components: {pca_components})...")
            self.pca = PCA(n_components=pca_components)
            all_embeddings_pca = self.pca.fit_transform(all_embeddings)
            
            explained_variance = self.pca.explained_variance_ratio_.sum()
            print(f"✓ PCA explained variance: {explained_variance:.4f}")
            
            # Transform class embeddings
            for class_name in class_embeddings:
                class_embeddings[class_name] = self.pca.transform(class_embeddings[class_name])
            
            self.use_pca = True
        else:
            self.use_pca = False
            print("\nSkipping PCA - using original embeddings")
        
        # Calculate centroids (average embeddings for each class)
        centroids = {}
        class_names = []
        
        print("\nCalculating centroids...")
        for class_name, embeddings in class_embeddings.items():
            if len(embeddings) > 0:
                centroid = np.mean(embeddings, axis=0)
                centroids[class_name] = centroid
                class_names.append(class_name)
                print(f"  ✓ {class_name}: centroid from {len(embeddings)} embeddings")
        
        # Sort class names for consistency
        class_names.sort()
        
        # Store the results
        self.centroids = centroids
        self.class_names = class_names
        
        print(f"\n✓ Generated centroids for {len(class_names)} classes")
        print(f"✓ Centroid dimension: {len(next(iter(centroids.values())))}")
        
        return centroids, class_names
    
    def export_centroids(self, filepath):
        """
        Export centroids and metadata to a file.
        
        Args:
            filepath (str): Path where to save the centroids file
        """
        if self.centroids is None:
            raise ValueError("No centroids to export! Generate centroids first.")
        
        data = {
            'centroids': self.centroids,
            'class_names': self.class_names,
            'pca': self.pca,
            'use_pca': self.use_pca,
            'centroid_dimension': len(next(iter(self.centroids.values()))),
            'num_classes': len(self.class_names)
        }
        
        with open(filepath, 'wb') as f:
            pickle.dump(data, f)
        
        print(f"✓ Centroids exported to {filepath}")
        print(f"  - {len(self.class_names)} classes")
        print(f"  - {data['centroid_dimension']} dimensions")
        print(f"  - PCA: {'Yes' if self.use_pca else 'No'}")
    
    def import_centroids(self, filepath):
        """
        Import centroids and metadata from a file.
        
        Args:
            filepath (str): Path to the centroids file
        """
        if not os.path.exists(filepath):
            raise FileNotFoundError(f"Centroids file not found: {filepath}")
        
        with open(filepath, 'rb') as f:
            data = pickle.load(f)
        
        self.centroids = data['centroids']
        self.class_names = data['class_names']
        self.pca = data.get('pca', None)
        self.use_pca = data.get('use_pca', False)
        
        print(f"✓ Centroids imported from {filepath}")
        print(f"  - {len(self.class_names)} classes: {', '.join(self.class_names)}")
        print(f"  - {data.get('centroid_dimension', 'unknown')} dimensions")
        print(f"  - PCA: {'Yes' if self.use_pca else 'No'}")
    
    def process(self, image_path, distance_metric='euclidean'):
        """
        Process an image and return distances to all centroids.
        
        Args:
            image_path (str): Path to the image to process
            distance_metric (str): 'euclidean' or 'cosine'
            
        Returns:
            np.ndarray: Array of distances to each centroid, ordered by class_names
        """
        if self.centroids is None:
            raise ValueError("No centroids loaded! Import or generate centroids first.")
        
        # Generate embedding for the input image
        embedding = self._process_image(image_path)
        
        if embedding is None:
            print(f"Warning: No face detected in {image_path}")
            # Return high distances if no face detected
            return np.full(len(self.class_names), float('inf'))
        
        # Apply PCA if it was used during centroid generation
        if self.use_pca and self.pca is not None:
            embedding = self.pca.transform(embedding.reshape(1, -1)).flatten()
        
        # Calculate distances to all centroids
        distances = []
        
        for class_name in self.class_names:
            centroid = self.centroids[class_name]
            
            if distance_metric == 'euclidean':
                distance = np.linalg.norm(embedding - centroid)
            elif distance_metric == 'cosine':
                # Cosine distance = 1 - cosine similarity
                dot_product = np.dot(embedding, centroid)
                norms = np.linalg.norm(embedding) * np.linalg.norm(centroid)
                cosine_sim = dot_product / norms if norms > 0 else 0
                distance = 1 - cosine_sim
            else:
                raise ValueError("distance_metric must be 'euclidean' or 'cosine'")
            
            distances.append(distance)
        
        return np.array(distances)
    
    def get_class_names(self):
        """
        Get the ordered list of class names.
        
        Returns:
            list: List of class names in the order they appear in distance vectors
        """
        if self.class_names is None:
            raise ValueError("No class names loaded! Import or generate centroids first.")
        return self.class_names.copy()
    
    def predict_class(self, image_path, distance_metric='euclidean'):
        """
        Predict the most likely class for an image based on minimum distance.
        
        Args:
            image_path (str): Path to the image to classify
            distance_metric (str): 'euclidean' or 'cosine'
            
        Returns:
            tuple: (predicted_class, distances_array)
        """
        distances = self.process(image_path, distance_metric)
        
        if np.all(np.isinf(distances)):
            return None, distances
        
        min_index = np.argmin(distances)
        predicted_class = self.class_names[min_index]
        
        return predicted_class, distances


# Example usage
if __name__ == "__main__":
    # Initialize the calculator
    calc = CentroidDistanceCalculator()
    
    # Generate centroids from face directories
    print("Generating centroids...")
    centroids, class_names = calc.generate_centroids(
        faces_dir="/Users/gena/Documents/SuitsMe/train_pipeline/faces",
        faces_v0_dir="/Users/gena/Documents/SuitsMe/train_pipeline/faces_v0",
        use_pca=True,
        pca_components=30
    )
    
    # Export centroids
    calc.export_centroids("face_centroids.pkl")
    
    # Import centroids (to demonstrate the import functionality)
    calc_new = CentroidDistanceCalculator()
    calc_new.import_centroids("face_centroids.pkl")
    
    # Example: Process an image and get distances
    # distances = calc_new.process("path/to/test/image.jpg")
    # print("Distances to centroids:", distances)
    # print("Class names:", calc_new.get_class_names())
    
    print("\n✓ CentroidDistanceCalculator setup complete!")