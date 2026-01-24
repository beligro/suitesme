"""
Training configuration for model training.
"""

import os
from dataclasses import dataclass


@dataclass
class TrainingConfig:
    """Configuration for model training"""
    
    # Model settings
    model_type: str = "hierarchical_ensemble"
    hidden_dim: int = 256
    dropout_prob: float = 0.3
    
    # Training settings
    batch_size: int = 32
    learning_rate: float = 0.001
    num_epochs: int = 50
    early_stopping_patience: int = 5
    
    # Comparison settings
    min_accuracy_improvement: float = 0.02  # 2% minimum improvement
    
    # Cloud settings (for later implementation)
    yandex_cloud_enabled: bool = False
    yandex_compute_instance_id: str = ""
    yandex_api_token: str = ""
    
    @classmethod
    def from_env(cls):
        """Load configuration from environment variables"""
        return cls(
            # Model settings
            model_type=os.getenv('MODEL_TYPE', 'hierarchical_ensemble'),
            hidden_dim=int(os.getenv('MODEL_HIDDEN_DIM', '256')),
            dropout_prob=float(os.getenv('MODEL_DROPOUT', '0.3')),
            
            # Training settings
            batch_size=int(os.getenv('TRAINING_BATCH_SIZE', '32')),
            learning_rate=float(os.getenv('TRAINING_LR', '0.001')),
            num_epochs=int(os.getenv('TRAINING_EPOCHS', '50')),
            early_stopping_patience=int(os.getenv('EARLY_STOPPING_PATIENCE', '5')),
            
            # Comparison settings
            min_accuracy_improvement=float(os.getenv('MIN_ACCURACY_IMPROVEMENT', '0.02')),
            
            # Cloud settings
            yandex_cloud_enabled=os.getenv('YANDEX_CLOUD_ENABLED', 'false').lower() == 'true',
            yandex_compute_instance_id=os.getenv('YANDEX_COMPUTE_INSTANCE_ID', ''),
            yandex_api_token=os.getenv('YANDEX_API_TOKEN', '')
        )


# Global training config instance
training_config = TrainingConfig.from_env()

