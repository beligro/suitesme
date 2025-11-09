from dataclasses import dataclass
import torch

@dataclass
class CentroidDistanceCalculator:
    centroids_path: str = "./assets/centroids.pkl"

class Config:
    model_path: str = "models/model.pth"
    device: str = "cuda" if torch.cuda.is_available() else "cpu"
    batch_size: int = 32
    num_workers: int = 4
    pin_memory: bool = True
    shuffle: bool = True
    num_classes: int = 1000