from PIL import Image

from src.centroid_based.cdc import CentroidDistanceCalculator
from src.big_classifier.big import BigClassifier
from src.small_classifier.sml import SmallClassifier
from src.cfg import Config


class Inference:
    def __init__(self):
        ...

    def predict(self, image: Image.Image) -> int:
        ...
