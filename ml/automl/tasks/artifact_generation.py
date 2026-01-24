"""
Artifact generation tasks.
Creates comprehensive markdown artifacts for model update pipeline visibility.
"""

from datetime import datetime
from typing import Dict, Any, Optional, Union

from prefect import task, get_run_logger
from prefect.artifacts import create_markdown_artifact

# Import ValidationReport for type checking
try:
    from tasks.dataset_validation import ValidationReport
except ImportError:
    ValidationReport = None


def _to_dict(obj: Union[Dict, Any]) -> Dict:
    """Convert object to dict if it has to_dict method, otherwise return as is."""
    if hasattr(obj, 'to_dict'):
        return obj.to_dict()
    elif isinstance(obj, dict):
        return obj
    else:
        return {}


@task(name="create_pipeline_report_artifact")
def create_pipeline_artifact(
    verified_validation: Optional[Union[Dict[str, Any], Any]],
    full_validation: Optional[Union[Dict[str, Any], Any]],
    verified_training: Optional[Dict[str, Any]],
    full_training: Optional[Dict[str, Any]],
    deployment: Dict[str, Any],
    pipeline_duration: float
) -> str:
    """
    Create comprehensive Markdown artifact for model update pipeline.
    
    Args:
        verified_validation: Verified dataset validation results (ValidationReport or dict)
        full_validation: Full dataset validation results (ValidationReport or dict)
        verified_training: Verified model training results
        full_training: Full model training results
        deployment: Deployment results
        pipeline_duration: Total pipeline duration in seconds
    
    Returns:
        Artifact key for reference
    """
    logger = get_run_logger()
    
    logger.info("Creating pipeline report artifact...")
    
    # Convert ValidationReport objects to dicts if needed
    verified_val_dict = _to_dict(verified_validation) if verified_validation else {}
    full_val_dict = _to_dict(full_validation) if full_validation else {}
    
    # Build markdown report
    markdown = f"""# 🚀 Model Update Pipeline Report

## Pipeline Summary

- **Execution Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- **Total Duration**: {pipeline_duration:.2f}s ({pipeline_duration/60:.1f} minutes)
- **Deployed Model**: {deployment.get('deployed_model', 'N/A')}
- **Version**: `{deployment.get('version', 'N/A')}`
- **Status**: ✅ SUCCESS

---

## 📊 Dataset Validation

"""
    
    # Verified Dataset section
    if verified_val_dict:
        v_stats = verified_val_dict.get('statistics', {})
        v_warnings = verified_val_dict.get('warnings', [])
        markdown += f"""### Verified Dataset
- **Status**: {verified_val_dict.get('status', 'N/A').upper()}
- **Total Images**: {v_stats.get('total_images', 'N/A')}
- **Gold Images**: {v_stats.get('gold_images', 'N/A')}
- **New Images**: {v_stats.get('new_images', 'N/A')}
- **Classes**: {len(v_stats.get('class_distribution', {}))}
- **Warnings**: {len(v_warnings)}

"""
        if v_warnings:
            markdown += "**Validation Warnings:**\n"
            for warning in v_warnings[:5]:  # Show first 5 warnings
                markdown += f"- ⚠️  {warning}\n"
            markdown += "\n"
    
    # Full Dataset section
    if full_val_dict:
        f_stats = full_val_dict.get('statistics', {})
        f_warnings = full_val_dict.get('warnings', [])
        markdown += f"""### Full Dataset
- **Status**: {full_val_dict.get('status', 'N/A').upper()}
- **Total Images**: {f_stats.get('total_images', 'N/A')}
- **Gold Images**: {f_stats.get('gold_images', 'N/A')}
- **New Images**: {f_stats.get('new_images', 'N/A')}
- **Classes**: {len(f_stats.get('class_distribution', {}))}
- **Warnings**: {len(f_warnings)}

"""
        if f_warnings:
            markdown += "**Validation Warnings:**\n"
            for warning in f_warnings[:5]:
                markdown += f"- ⚠️  {warning}\n"
            markdown += "\n"
    
    markdown += "---\n\n## 🎯 Training Results\n\n"
    
    # Verified training results
    if verified_training and verified_training.get('status') == 'success':
        v_metrics = verified_training.get('metrics', {})
        markdown += f"""### Verified Dataset Model
- **Checkpoint**: `{verified_training.get('checkpoint_version', 'N/A')}`
- **Test Accuracy**: **{v_metrics.get('test_accuracy', 0):.2f}%**
- **Training Duration**: {verified_training.get('training_duration', 0):.2f}s
- **Epochs**: {verified_training.get('final_epoch', 'N/A')}
- **Status**: ✅ {verified_training.get('status', 'N/A').upper()}

"""
    elif verified_training:
        markdown += f"""### Verified Dataset Model
- **Status**: ❌ {verified_training.get('status', 'FAILED').upper()}
- **Message**: {verified_training.get('message', 'Unknown error')}

"""
    
    # Full training results
    if full_training and full_training.get('status') == 'success':
        f_metrics = full_training.get('metrics', {})
        markdown += f"""### Full Dataset Model
- **Checkpoint**: `{full_training.get('checkpoint_version', 'N/A')}`
- **Test Accuracy**: **{f_metrics.get('test_accuracy', 0):.2f}%**
- **Training Duration**: {full_training.get('training_duration', 0):.2f}s
- **Epochs**: {full_training.get('final_epoch', 'N/A')}
- **Status**: ✅ {full_training.get('status', 'N/A').upper()}

"""
    elif full_training:
        markdown += f"""### Full Dataset Model
- **Status**: ❌ {full_training.get('status', 'FAILED').upper()}
- **Message**: {full_training.get('message', 'Unknown error')}

"""
    
    markdown += "---\n\n## 🏆 Model Comparison\n\n"
    
    # Comparison summary
    comparison_summary = deployment.get('comparison_summary', [])
    if comparison_summary:
        markdown += "### Candidates Evaluated\n\n"
        for i, candidate in enumerate(comparison_summary, 1):
            icon = "🥇" if candidate.get('is_winner') else "  "
            markdown += f"{icon} {i}. **{candidate['name']}**: {candidate['accuracy']:.2f}%\n"
        markdown += "\n"
    
    # Winner details
    markdown += f"""### Winner
**{deployment.get('deployed_model', 'N/A')}** - **{deployment.get('winner_accuracy', 0):.2f}%**

**Reason**: {deployment.get('reason', 'N/A')}

"""
    
    # Alternative models
    alternatives = deployment.get('alternatives', [])
    if alternatives:
        markdown += "**Alternatives Compared:**\n"
        for alt in alternatives:
            markdown += f"- {alt['name']}: {alt['accuracy']:.2f}%\n"
        markdown += "\n"
    
    markdown += "---\n\n## 🚀 Deployment Details\n\n"
    
    markdown += f"""- **Production Version**: `{deployment.get('version', 'N/A')}`
- **Checkpoint Path**: `{deployment.get('checkpoint_path', 'N/A')}`
- **Dataset Type**: {deployment.get('dataset_type', 'N/A')}
- **Deployed At**: {deployment.get('deployed_at', 'N/A')}
- **Previous Production**: `{deployment.get('previous_version', 'None')}`

### Model Serving Status
- ✅ Production pointer updated
- ✅ Latest checkpoint updated
- ⏳ ModelManager will auto-reload within 5 minutes
- ✅ Zero-downtime deployment

"""
    
    markdown += "---\n\n## 📈 Per-Class Accuracy\n\n"
    
    # Per-class accuracy table
    winner_metrics = deployment.get('winner_metrics', {})
    per_class = winner_metrics.get('per_class_accuracy', {})
    
    if per_class:
        markdown += "### Winner Model Performance\n\n"
        markdown += "| Class | Accuracy |\n"
        markdown += "|-------|----------|\n"
        for class_name, accuracy in sorted(per_class.items(), key=lambda x: x[1], reverse=True):
            # Add visual indicator for performance
            if accuracy >= 80:
                icon = "🟢"
            elif accuracy >= 60:
                icon = "🟡"
            else:
                icon = "🔴"
            markdown += f"| {icon} {class_name} | {accuracy:.2f}% |\n"
        markdown += "\n"
    else:
        markdown += "*Per-class accuracy data not available*\n\n"
    
    markdown += "---\n\n## 💾 Artifacts Preserved\n\n"
    markdown += "All training artifacts are preserved in MinIO:\n\n"
    
    if verified_training and verified_training.get('checkpoint_version'):
        markdown += f"- **Verified checkpoint**: `models/checkpoints/{verified_training.get('checkpoint_version')}/`\n"
    
    if full_training and full_training.get('checkpoint_version'):
        markdown += f"- **Full checkpoint**: `models/checkpoints/{full_training.get('checkpoint_version')}/`\n"
    
    markdown += f"""- **Production pointer**: `models/production_model.json`
- **Active model** (inference): `models/checkpoints/latest/`

### Checkpoint Contents
Each checkpoint directory contains:
- `best_model.pth` - Model weights
- `face_centroids.pkl` - Face centroids for classification
- `metadata.json` - Training metadata and metrics

"""
    
    markdown += "---\n\n"
    markdown += f"*Report generated by AutoML Pipeline at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n"
    
    # Create artifact
    try:
        artifact_key = f"model-update-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        artifact_id = create_markdown_artifact(
            key=artifact_key,
            markdown=markdown,
            description=f"Model update pipeline report - Deployed {deployment.get('deployed_model', 'model')}"
        )
        
        logger.info(f"✓ Pipeline report artifact created: {artifact_key}")
        return artifact_id
    
    except Exception as e:
        logger.error(f"Failed to create artifact: {e}")
        # Don't fail the pipeline if artifact creation fails
        return ""

