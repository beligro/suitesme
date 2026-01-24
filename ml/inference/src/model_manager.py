"""
ModelManager: Thread-safe model weight reloading with zero-downtime
Automatically detects and loads latest weights from MinIO
"""

import os
import json
import logging
import threading
import time
from datetime import datetime
from typing import Optional, Tuple, Dict
from pathlib import Path
import tempfile
import shutil

from minio import Minio
from minio.error import S3Error

from .ensemble_classifier import EnsembleClassifier

logger = logging.getLogger(__name__)


class ModelManager:
    """
    Manages ML model lifecycle with zero-downtime weight reloading.
    
    Features:
    - Thread-safe atomic model switching
    - Automatic detection of new weights from MinIO
    - Fallback to previous weights on load failure
    - Periodic background checks for updates
    - Version tracking and metadata management
    """
    
    def __init__(self, 
                 minio_client: Minio,
                 bucket: str,
                 checkpoints_prefix: str = "models/checkpoints/latest",
                 local_cache_dir: str = "/tmp/model_cache",
                 fallback_model_path: str = "./assets/checkpoints/best_model.pth",
                 fallback_centroids_path: str = "./assets/face_centroids.pkl",
                 auto_check_interval: int = 300):
        """
        Initialize ModelManager.
        
        Args:
            minio_client: MinIO client instance
            bucket: Bucket name for ML artifacts
            checkpoints_prefix: Path prefix for model checkpoints in MinIO
            local_cache_dir: Local directory for caching downloaded weights
            fallback_model_path: Local fallback model path (bundled with service)
            fallback_centroids_path: Local fallback centroids path
            auto_check_interval: Seconds between automatic update checks (0 to disable)
        """
        self.minio_client = minio_client
        self.bucket = bucket
        self.checkpoints_prefix = checkpoints_prefix
        self.local_cache_dir = Path(local_cache_dir)
        self.fallback_model_path = fallback_model_path
        self.fallback_centroids_path = fallback_centroids_path
        self.auto_check_interval = auto_check_interval
        
        # Thread safety
        self._lock = threading.RLock()
        self._model: Optional[EnsembleClassifier] = None
        self._model_info: Dict = {}
        
        # Background check thread
        self._check_thread: Optional[threading.Thread] = None
        self._stop_check = threading.Event()
        
        # Initialize cache directory
        self.local_cache_dir.mkdir(parents=True, exist_ok=True)
        
        # Load initial model
        logger.info("Initializing ModelManager...")
        self._initialize_model()
        
        # Start background checker if enabled
        if self.auto_check_interval > 0:
            self._start_background_checker()
    
    def _initialize_model(self):
        """Initialize model on startup (restart-agnostic)."""
        logger.info("Loading initial model weights...")
        
        try:
            # Try to load latest weights from MinIO
            model_path, centroids_path, metadata = self.get_latest_weights_from_minio()
            
            if model_path and centroids_path:
                logger.info(f"Found latest weights in MinIO: {metadata.get('version', 'unknown')}")
                success = self._load_model_internal(model_path, centroids_path, metadata)
                
                if success:
                    logger.info("✓ Loaded latest weights from MinIO")
                    return
                else:
                    logger.warning("Failed to load MinIO weights, falling back to bundled weights")
            else:
                logger.info("No weights found in MinIO, using bundled weights")
        
        except Exception as e:
            logger.warning(f"Error checking MinIO for weights: {e}, using bundled weights")
        
        # Fallback to bundled weights
        logger.info("Loading bundled fallback weights...")
        metadata = {
            "version": "bundled",
            "source": "local_fallback",
            "loaded_at": datetime.now().isoformat()
        }
        success = self._load_model_internal(
            self.fallback_model_path,
            self.fallback_centroids_path,
            metadata
        )
        
        if not success:
            raise RuntimeError("Failed to load both MinIO and fallback weights")
        
        logger.info("✓ Loaded fallback weights successfully")
    
    def get_latest_weights_from_minio(self) -> Tuple[Optional[str], Optional[str], Dict]:
        """
        Download latest model weights from MinIO.
        
        Returns:
            Tuple of (model_path, centroids_path, metadata)
            Returns (None, None, {}) if not found or error
        """
        try:
            # Check if metadata exists
            metadata_path = f"{self.checkpoints_prefix}/metadata.json"
            
            try:
                response = self.minio_client.get_object(self.bucket, metadata_path)
                metadata_str = response.read().decode('utf-8')
                response.close()
                response.release_conn()
                metadata = json.loads(metadata_str)
            except S3Error as e:
                if e.code == 'NoSuchKey':
                    logger.info("No metadata.json found in MinIO")
                    return None, None, {}
                raise
            
            # Download model and centroids to temp directory
            temp_dir = tempfile.mkdtemp(prefix="model_download_", dir=self.local_cache_dir)
            
            model_remote_path = f"{self.checkpoints_prefix}/best_model.pth"
            centroids_remote_path = f"{self.checkpoints_prefix}/face_centroids.pkl"
            
            model_local_path = os.path.join(temp_dir, "best_model.pth")
            centroids_local_path = os.path.join(temp_dir, "face_centroids.pkl")
            
            # Download model
            logger.info(f"Downloading model from {model_remote_path}")
            self.minio_client.fget_object(self.bucket, model_remote_path, model_local_path)
            
            # Download centroids
            logger.info(f"Downloading centroids from {centroids_remote_path}")
            self.minio_client.fget_object(self.bucket, centroids_remote_path, centroids_local_path)
            
            logger.info("✓ Downloaded weights successfully")
            return model_local_path, centroids_local_path, metadata
        
        except S3Error as e:
            if e.code == 'NoSuchKey':
                logger.info("Model weights not found in MinIO")
            else:
                logger.error(f"MinIO error: {e}")
            return None, None, {}
        
        except Exception as e:
            logger.error(f"Error downloading weights from MinIO: {e}")
            return None, None, {}
    
    def _load_model_internal(self, model_path: str, centroids_path: str, metadata: Dict) -> bool:
        """
        Internal method to load model with the lock held.
        
        Args:
            model_path: Path to model weights
            centroids_path: Path to centroids
            metadata: Model metadata
        
        Returns:
            True if successful, False otherwise
        """
        try:
            logger.info(f"Loading model from {model_path}")
            
            # Load new model instance
            new_model = EnsembleClassifier(model_path, centroids_path)
            
            # If successful, atomically swap with lock
            with self._lock:
                old_model = self._model
                self._model = new_model
                self._model_info = {
                    **metadata,
                    "loaded_at": datetime.now().isoformat(),
                    "model_path": model_path,
                    "centroids_path": centroids_path
                }
            
            logger.info(f"✓ Model loaded successfully: {metadata.get('version', 'unknown')}")
            
            # Clean up old model (happens outside lock)
            del old_model
            
            return True
        
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            return False
    
    def reload_weights(self, model_path: Optional[str] = None, 
                      centroids_path: Optional[str] = None) -> bool:
        """
        Reload model weights (manual trigger or from MinIO).
        
        Args:
            model_path: Optional path to model weights (downloads from MinIO if None)
            centroids_path: Optional path to centroids
        
        Returns:
            True if reload successful, False otherwise
        """
        logger.info("Manual weight reload triggered")
        
        if model_path is None or centroids_path is None:
            # Download latest from MinIO
            model_path, centroids_path, metadata = self.get_latest_weights_from_minio()
            
            if model_path is None or centroids_path is None:
                logger.error("No weights available for reload")
                return False
        else:
            metadata = {
                "version": "manual",
                "source": "manual_reload",
                "loaded_at": datetime.now().isoformat()
            }
        
        return self._load_model_internal(model_path, centroids_path, metadata)
    
    def get_current_model(self) -> Optional[EnsembleClassifier]:
        """
        Get current model instance (thread-safe read).
        
        Returns:
            Current model instance or None
        """
        with self._lock:
            return self._model
    
    def get_model_info(self) -> Dict:
        """
        Get current model metadata.
        
        Returns:
            Dictionary with model version, loaded time, etc.
        """
        with self._lock:
            return self._model_info.copy()
    
    def _background_check_loop(self):
        """Background thread loop for checking updates."""
        logger.info(f"Started background update checker (interval: {self.auto_check_interval}s)")
        
        while not self._stop_check.wait(self.auto_check_interval):
            try:
                self._check_for_updates()
            except Exception as e:
                logger.error(f"Error in background update check: {e}")
    
    def _check_for_updates(self):
        """Check if new weights are available and load them."""
        try:
            # Get current version
            current_info = self.get_model_info()
            current_version = current_info.get('version', 'unknown')
            
            # Check MinIO for latest
            model_path, centroids_path, metadata = self.get_latest_weights_from_minio()
            
            if model_path is None or centroids_path is None:
                return
            
            new_version = metadata.get('version', 'unknown')
            
            # Compare versions
            if new_version != current_version:
                logger.info(f"New model version detected: {new_version} (current: {current_version})")
                logger.info("Initiating automatic weight reload...")
                
                success = self._load_model_internal(model_path, centroids_path, metadata)
                
                if success:
                    logger.info("✓ Automatic weight reload successful")
                else:
                    logger.error("✗ Automatic weight reload failed, keeping current model")
            else:
                logger.debug(f"Model version unchanged: {current_version}")
        
        except Exception as e:
            logger.error(f"Error checking for updates: {e}")
    
    def _start_background_checker(self):
        """Start background thread for automatic update checking."""
        if self._check_thread is not None and self._check_thread.is_alive():
            logger.warning("Background checker already running")
            return
        
        self._stop_check.clear()
        self._check_thread = threading.Thread(
            target=self._background_check_loop,
            daemon=True,
            name="ModelManager-UpdateChecker"
        )
        self._check_thread.start()
    
    def stop_background_checker(self):
        """Stop background update checker (for cleanup)."""
        if self._check_thread is not None:
            logger.info("Stopping background update checker...")
            self._stop_check.set()
            self._check_thread.join(timeout=5)
            logger.info("✓ Background checker stopped")
    
    def cleanup(self):
        """Cleanup resources."""
        self.stop_background_checker()
        
        # Clean up cache directory
        try:
            if self.local_cache_dir.exists():
                shutil.rmtree(self.local_cache_dir)
                logger.info("✓ Cleaned up cache directory")
        except Exception as e:
            logger.error(f"Error cleaning up cache: {e}")

