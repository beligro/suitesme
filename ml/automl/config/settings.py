"""
Configuration settings for AutoML dataset management.
Loads credentials and settings from environment variables.
"""

import os
from dataclasses import dataclass
from typing import Optional


@dataclass
class DatabaseConfig:
    """PostgreSQL database configuration"""
    host: str
    port: int
    user: str
    password: str
    database: str
    
    @classmethod
    def from_env(cls):
        """Load database config from environment variables"""
        return cls(
            host=os.getenv('DB_HOST', 'postgres'),
            port=int(os.getenv('DB_PORT', '5432')),
            user=os.getenv('DB_USER', 'postgres'),
            password=os.getenv('DB_PASSWORD', ''),
            database=os.getenv('DB_NAME', 'suitesme')
        )
    
    @property
    def connection_string(self) -> str:
        """Get PostgreSQL connection string"""
        return f"postgresql://{self.user}:{self.password}@{self.host}:{self.port}/{self.database}"


@dataclass
class MinIOConfig:
    """MinIO S3 storage configuration"""
    endpoint: str
    access_key: str
    secret_key: str
    secure: bool
    style_photo_bucket: str
    ml_artifacts_bucket: str
    
    @classmethod
    def from_env(cls):
        """Load MinIO config from environment variables"""
        return cls(
            endpoint=os.getenv('MINIO_ENDPOINT', 'minio:9000'),
            access_key=os.getenv('MINIO_ROOT_USER', 'minioadmin'),
            secret_key=os.getenv('MINIO_ROOT_PASSWORD', 'minioadmin'),
            secure=os.getenv('MINIO_SECURE', 'false').lower() == 'true',
            style_photo_bucket=os.getenv('STYLE_PHOTO_BUCKET', 'style-photos'),
            ml_artifacts_bucket=os.getenv('ML_ARTIFACTS_BUCKET', 'ml-artifacts')
        )


@dataclass
class PrefectConfig:
    """Prefect orchestration configuration"""
    api_url: str
    work_pool_name: str
    
    @classmethod
    def from_env(cls):
        """Load Prefect config from environment variables"""
        return cls(
            api_url=os.getenv('PREFECT_API_URL', 'http://prefect-server:4200/api'),
            work_pool_name=os.getenv('PREFECT_WORK_POOL', 'default-pool')
        )


@dataclass
class Settings:
    """Global application settings"""
    db: DatabaseConfig
    minio: MinIOConfig
    prefect: PrefectConfig
    
    # Dataset management settings
    daily_collection_hour: int = 0  # 00:00 UTC
    monthly_creation_day: int = 1   # 1st day of month
    monthly_creation_hour: int = 1  # 01:00 UTC
    
    # Class names for face classification
    class_names: list = None
    
    def __post_init__(self):
        """Initialize class names"""
        if self.class_names is None:
            self.class_names = [
                'Aristocratic', 'Business', 'Fire', 'Fragile', 'Heroin',
                'Inferno', 'Melting', 'Queen', 'Renaissance', 'Serious',
                'Soft', 'Strong', 'Sunny', 'Vintage', 'Warm'
            ]
    
    @classmethod
    def from_env(cls):
        """Load all settings from environment variables"""
        return cls(
            db=DatabaseConfig.from_env(),
            minio=MinIOConfig.from_env(),
            prefect=PrefectConfig.from_env()
        )


# Global settings instance
settings = Settings.from_env()

