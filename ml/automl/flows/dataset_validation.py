"""
Dataset validation flow.
Validates dataset structure after monthly creation.
"""

from datetime import datetime
from typing import Optional

from prefect import flow, get_run_logger
from prefect.events import emit_event

from tasks.data_collection import connect_to_minio
from tasks.dataset_validation import (
    validate_manifest,
    validate_split_structure,
    validate_class_distribution,
    validate_file_counts,
    create_validation_report,
    ValidationReport
)
from config import settings


@flow(name="validate_dataset_structure", log_prints=True)
def validate_dataset_structure_flow(
    dataset_type: str,
    year: int,
    month: int
) -> ValidationReport:
    """
    Validate dataset structure and integrity.
    
    Args:
        dataset_type: 'verified' or 'full'
        year: Dataset year
        month: Dataset month
    
    Returns:
        ValidationReport with status and details
    """
    logger = get_run_logger()
    
    logger.info("=" * 80)
    logger.info(f"DATASET VALIDATION FLOW - {dataset_type.upper()} {year}-{month:02d}")
    logger.info("=" * 80)
    
    # Dataset path
    dataset_path = f"datasets/{dataset_type}/{year}-{month:02d}"
    logger.info(f"Validating dataset: {dataset_path}")
    
    # Connect to MinIO
    logger.info("Step 1: Connecting to MinIO")
    minio_client = connect_to_minio()
    
    # Validate manifest
    logger.info("Step 2: Validating manifest")
    manifest, manifest_issues = validate_manifest(minio_client, dataset_path)
    
    # Validate split structure
    logger.info("Step 3: Validating split structure (train/val/test)")
    structure_valid, structure_issues, split_counts = validate_split_structure(
        minio_client, dataset_path
    )
    
    # Validate class distribution (only if manifest is valid)
    class_valid = True
    class_issues = []
    class_warnings = []
    
    if manifest:
        logger.info("Step 4: Validating class distribution")
        class_valid, class_issues, class_warnings = validate_class_distribution(
            minio_client, dataset_path, manifest
        )
    else:
        logger.warning("Skipping class validation (no valid manifest)")
        class_issues.append("Skipped due to invalid manifest")
    
    # Validate file counts
    count_valid = True
    count_issues = []
    
    if manifest:
        logger.info("Step 5: Validating file counts")
        count_valid, count_issues = validate_file_counts(manifest, split_counts)
    else:
        logger.warning("Skipping count validation (no valid manifest)")
        count_issues.append("Skipped due to invalid manifest")
    
    # Create comprehensive report
    logger.info("Step 6: Creating validation report")
    report = create_validation_report(
        dataset_type=dataset_type,
        year=year,
        month=month,
        manifest=manifest,
        manifest_issues=manifest_issues,
        structure_valid=structure_valid,
        structure_issues=structure_issues,
        split_counts=split_counts,
        class_valid=class_valid,
        class_issues=class_issues,
        class_warnings=class_warnings,
        count_valid=count_valid,
        count_issues=count_issues
    )
    
    # Emit Prefect event if validation passed
    if report.status == 'pass':
        logger.info("Step 7: Emitting validation success event")
        
        try:
            emit_event(
                event=f"dataset.validated.{dataset_type}",
                resource={
                    "prefect.resource.id": f"dataset.{dataset_type}.{year}-{month:02d}",
                    "prefect.resource.name": f"{dataset_type.capitalize()} Dataset {year}-{month:02d}"
                },
                payload={
                    "dataset_type": dataset_type,
                    "year": year,
                    "month": month,
                    "version": manifest.get('version') if manifest else 'unknown',
                    "total_images": report.statistics.get('total_images', 0),
                    "validation_status": "pass"
                }
            )
            logger.info(f"✓ Emitted event: dataset.validated.{dataset_type}")
        except Exception as e:
            logger.warning(f"Failed to emit event: {e}")
    else:
        logger.error("Validation failed, no event emitted")
    
    # Summary
    logger.info("=" * 80)
    logger.info("VALIDATION COMPLETE")
    logger.info(f"Status: {report.status.upper()}")
    logger.info(f"Issues: {len(report.issues)}")
    logger.info(f"Warnings: {len(report.warnings)}")
    if report.statistics:
        logger.info(f"Statistics: {report.statistics}")
    logger.info("=" * 80)
    
    return report


if __name__ == "__main__":
    """For local testing"""
    import sys
    
    if len(sys.argv) >= 4:
        dataset_type = sys.argv[1]  # 'verified' or 'full'
        year = int(sys.argv[2])
        month = int(sys.argv[3])
        
        report = validate_dataset_structure_flow(dataset_type, year, month)
        print("\n=== VALIDATION REPORT ===")
        print(f"Status: {report.status}")
        print(f"Issues: {report.issues}")
        print(f"Warnings: {report.warnings}")
        print(f"Statistics: {report.statistics}")
    else:
        print("Usage: python dataset_validation.py <dataset_type> <year> <month>")
        print("Example: python dataset_validation.py verified 2025 11")

