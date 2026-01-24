"""
Dataset structure validation tasks.
Validates dataset integrity, structure, and manifest completeness.
"""

import json
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, field
from datetime import datetime

from minio import Minio
from minio.error import S3Error
from prefect import task, get_run_logger

from config import settings


@dataclass
class ValidationReport:
    """Dataset validation report"""
    status: str  # 'pass' or 'fail'
    dataset_type: str
    year: int
    month: int
    issues: List[str] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    statistics: Dict[str, Any] = field(default_factory=dict)
    validated_at: str = field(default_factory=lambda: datetime.now().isoformat())
    
    def add_issue(self, message: str):
        """Add a validation issue (failure)"""
        self.issues.append(message)
        self.status = 'fail'
    
    def add_warning(self, message: str):
        """Add a validation warning (non-critical)"""
        self.warnings.append(message)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'status': self.status,
            'dataset_type': self.dataset_type,
            'year': self.year,
            'month': self.month,
            'issues': self.issues,
            'warnings': self.warnings,
            'statistics': self.statistics,
            'validated_at': self.validated_at
        }


@task(name="validate_manifest")
def validate_manifest(
    minio_client: Minio,
    dataset_path: str
) -> tuple[Optional[Dict], List[str]]:
    """
    Validate that manifest exists and has required fields.
    
    Args:
        minio_client: MinIO client
        dataset_path: Path to dataset (e.g., datasets/verified/2025-11)
    
    Returns:
        Tuple of (manifest dict or None, list of issues)
    """
    logger = get_run_logger()
    bucket = settings.minio.ml_artifacts_bucket
    manifest_path = f"{dataset_path}/manifest.json"
    issues = []
    
    try:
        # Download and parse manifest
        response = minio_client.get_object(bucket, manifest_path)
        manifest_data = response.read()
        response.close()
        response.release_conn()
        
        manifest = json.loads(manifest_data)
        logger.info(f"✓ Manifest found at {manifest_path}")
        
        # Check required fields
        required_fields = [
            'dataset_type', 'version', 'total_images', 
            'class_distribution', 'year', 'month'
        ]
        
        for field in required_fields:
            if field not in manifest:
                issues.append(f"Missing required field in manifest: {field}")
        
        # Validate data types
        if 'total_images' in manifest and not isinstance(manifest['total_images'], int):
            issues.append("Field 'total_images' must be an integer")
        
        if 'class_distribution' in manifest and not isinstance(manifest['class_distribution'], dict):
            issues.append("Field 'class_distribution' must be a dictionary")
        
        return manifest, issues
    
    except S3Error as e:
        if e.code == 'NoSuchKey':
            issues.append(f"Manifest file not found: {manifest_path}")
        else:
            issues.append(f"MinIO error accessing manifest: {e}")
        return None, issues
    
    except json.JSONDecodeError as e:
        issues.append(f"Invalid JSON in manifest: {e}")
        return None, issues
    
    except Exception as e:
        issues.append(f"Error validating manifest: {e}")
        return None, issues


@task(name="validate_split_structure")
def validate_split_structure(
    minio_client: Minio,
    dataset_path: str
) -> tuple[bool, List[str], Dict[str, int]]:
    """
    Validate that train/val/test splits exist.
    
    Args:
        minio_client: MinIO client
        dataset_path: Path to dataset
    
    Returns:
        Tuple of (valid, issues, split_counts)
    """
    logger = get_run_logger()
    bucket = settings.minio.ml_artifacts_bucket
    issues = []
    split_counts = {'train': 0, 'val': 0, 'test': 0}
    
    required_splits = ['train', 'val', 'test']
    
    for split in required_splits:
        split_path = f"{dataset_path}/{split}/"
        
        try:
            # List objects in split
            objects = minio_client.list_objects(bucket, prefix=split_path, recursive=True)
            count = 0
            
            for obj in objects:
                # Skip directories and non-image files
                if obj.is_dir or obj.object_name.endswith('.json') or obj.object_name.endswith('.md'):
                    continue
                # Count actual image files
                if obj.object_name.lower().endswith(('.jpg', '.jpeg', '.png', '.webp')):
                    count += 1
            
            split_counts[split] = count
            
            if count == 0:
                issues.append(f"Split '{split}' is empty or not found")
                logger.warning(f"Split '{split}' has no images")
            else:
                logger.info(f"✓ Split '{split}' has {count} images")
        
        except Exception as e:
            issues.append(f"Error accessing split '{split}': {e}")
    
    valid = len(issues) == 0
    return valid, issues, split_counts


@task(name="validate_class_distribution")
def validate_class_distribution(
    minio_client: Minio,
    dataset_path: str,
    manifest: Dict
) -> tuple[bool, List[str], List[str]]:
    """
    Validate class distribution in train split.
    
    Args:
        minio_client: MinIO client
        dataset_path: Path to dataset
        manifest: Manifest dictionary
    
    Returns:
        Tuple of (valid, issues, warnings)
    """
    logger = get_run_logger()
    bucket = settings.minio.ml_artifacts_bucket
    issues = []
    warnings = []
    
    # Get class distribution from manifest
    class_dist = manifest.get('class_distribution', {})
    
    if not class_dist:
        issues.append("No class_distribution found in manifest")
        return False, issues, warnings
    
    # Check train split has at least 1 image per class
    train_path = f"{dataset_path}/train/"
    
    try:
        # List all objects in train split
        objects = list(minio_client.list_objects(bucket, prefix=train_path, recursive=False))
        
        # Get list of class directories
        class_dirs = set()
        for obj in objects:
            if obj.is_dir:
                # Extract class name from path
                parts = obj.object_name.rstrip('/').split('/')
                if len(parts) > 0:
                    class_name = parts[-1]
                    class_dirs.add(class_name)
        
        logger.info(f"Found {len(class_dirs)} class directories in train split")
        
        # Check each class has images
        for class_name in class_dist.keys():
            class_path = f"{train_path}{class_name}/"
            
            try:
                class_objects = list(minio_client.list_objects(bucket, prefix=class_path, recursive=True))
                image_count = sum(1 for obj in class_objects 
                                 if not obj.is_dir and obj.object_name.lower().endswith(('.jpg', '.jpeg', '.png', '.webp')))
                
                if image_count == 0:
                    issues.append(f"Class '{class_name}' has no images in train split")
                elif image_count < 5:
                    warnings.append(f"Class '{class_name}' has only {image_count} images (recommended: 5+)")
            
            except Exception as e:
                issues.append(f"Error checking class '{class_name}': {e}")
    
    except Exception as e:
        issues.append(f"Error validating class distribution: {e}")
    
    valid = len(issues) == 0
    return valid, issues, warnings


@task(name="validate_file_counts")
def validate_file_counts(
    manifest: Dict,
    split_counts: Dict[str, int]
) -> tuple[bool, List[str]]:
    """
    Validate that file counts match manifest.
    
    Args:
        manifest: Manifest dictionary
        split_counts: Actual file counts per split
    
    Returns:
        Tuple of (valid, issues)
    """
    logger = get_run_logger()
    issues = []
    
    # Calculate expected total from manifest
    manifest_total = manifest.get('total_images', 0)
    manifest_gold = manifest.get('gold_images', 0)
    manifest_new = manifest.get('new_images', 0)
    
    # Calculate actual total from splits
    actual_train = split_counts.get('train', 0)
    actual_val = split_counts.get('val', 0)
    actual_test = split_counts.get('test', 0)
    actual_total_splits = actual_train + actual_val + actual_test
    
    # Log statistics
    logger.info(f"Manifest reports: {manifest_total} total images ({manifest_gold} gold + {manifest_new} new)")
    logger.info(f"Actual splits: train={actual_train}, val={actual_val}, test={actual_test}, total={actual_total_splits}")
    
    # Validate total_images roughly matches train count
    # Note: Some images might be filtered during processing, so allow small variance
    expected_train = manifest_total
    variance = abs(actual_train - expected_train)
    variance_pct = (variance / expected_train * 100) if expected_train > 0 else 0
    
    if variance_pct > 5:  # Allow up to 5% variance
        issues.append(f"Train count significant mismatch: manifest reports {expected_train}, found {actual_train} ({variance_pct:.1f}% difference)")
    elif variance > 0:
        logger.warning(f"Minor train count difference: manifest reports {expected_train}, found {actual_train} (within acceptable range)")
    
    valid = len(issues) == 0
    return valid, issues


@task(name="create_validation_report")
def create_validation_report(
    dataset_type: str,
    year: int,
    month: int,
    manifest: Optional[Dict],
    manifest_issues: List[str],
    structure_valid: bool,
    structure_issues: List[str],
    split_counts: Dict[str, int],
    class_valid: bool,
    class_issues: List[str],
    class_warnings: List[str],
    count_valid: bool,
    count_issues: List[str]
) -> ValidationReport:
    """
    Create comprehensive validation report.
    
    Args:
        dataset_type: 'verified' or 'full'
        year: Dataset year
        month: Dataset month
        manifest: Manifest dictionary
        manifest_issues: Issues from manifest validation
        structure_valid: Structure validation passed
        structure_issues: Issues from structure validation
        split_counts: Actual split counts
        class_valid: Class validation passed
        class_issues: Issues from class validation
        class_warnings: Warnings from class validation
        count_valid: Count validation passed
        count_issues: Issues from count validation
    
    Returns:
        ValidationReport object
    """
    logger = get_run_logger()
    
    # Initialize report
    report = ValidationReport(
        status='pass' if all([
            len(manifest_issues) == 0,
            structure_valid,
            class_valid,
            count_valid
        ]) else 'fail',
        dataset_type=dataset_type,
        year=year,
        month=month
    )
    
    # Add all issues
    report.issues.extend(manifest_issues)
    report.issues.extend(structure_issues)
    report.issues.extend(class_issues)
    report.issues.extend(count_issues)
    
    # Add warnings
    report.warnings.extend(class_warnings)
    
    # Compile statistics
    if manifest:
        report.statistics = {
            'version': manifest.get('version', 'unknown'),
            'total_images': manifest.get('total_images', 0),
            'gold_images': manifest.get('gold_images', 0),
            'new_images': manifest.get('new_images', 0),
            'collection_dates': len(manifest.get('collection_dates', [])),
            'class_distribution': manifest.get('class_distribution', {}),
            'splits': split_counts,
            'total_all_splits': sum(split_counts.values())
        }
    
    # Log results
    if report.status == 'pass':
        logger.info("✓ Validation PASSED")
        logger.info(f"  Statistics: {report.statistics}")
        if report.warnings:
            logger.warning(f"  Warnings: {report.warnings}")
    else:
        logger.error("✗ Validation FAILED")
        logger.error(f"  Issues: {report.issues}")
    
    return report

