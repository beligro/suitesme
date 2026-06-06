#!/usr/bin/env python3
"""
Evaluate production model on our verified-from-db test split.
"""

import os, sys, json, tempfile, shutil
sys.path.append('/app/ml/inference/src')
sys.path.insert(0, '/app/automl')

import torch
from torch.utils.data import DataLoader
from minio import Minio
from config import settings

DATASET_PREFIX = "datasets/verified-from-db/2026-03"
BUCKET = settings.minio.ml_artifacts_bucket


def main():
    minio = Minio(settings.minio.endpoint,
                  access_key=settings.minio.access_key,
                  secret_key=settings.minio.secret_key, secure=False)

    tmp = tempfile.mkdtemp(prefix="eval_prod_")
    print(f"Working dir: {tmp}")

    try:
        # Download production model
        model_path = os.path.join(tmp, "best_model.pth")
        minio.fget_object(BUCKET, "models/checkpoints/latest/best_model.pth", model_path)
        print("✓ Downloaded production model")

        # Download test split only
        test_dir = os.path.join(tmp, "test")
        prefix = f"{DATASET_PREFIX}/test/"
        objects = list(minio.list_objects(BUCKET, prefix=prefix, recursive=True))
        print(f"Downloading {len(objects)} test images...")
        for obj in objects:
            if obj.is_dir:
                continue
            rel = obj.object_name[len(prefix):]
            local = os.path.join(test_dir, rel)
            os.makedirs(os.path.dirname(local), exist_ok=True)
            minio.fget_object(BUCKET, obj.object_name, local)
        print(f"✓ Downloaded test split to {test_dir}")

        # Load model
        from small_classifier.train import FaceDataset, HierarchicalClassifier
        from facenet_pytorch import MTCNN, InceptionResnetV1

        ckpt = torch.load(model_path, map_location="cpu")
        class_to_idx = ckpt["class_to_idx"]
        idx_to_class = ckpt["idx_to_class"]
        num_classes   = ckpt["num_classes"]

        model = HierarchicalClassifier(
            input_dim=512, num_classes=num_classes,
            hidden_dim=256, dropout_prob=0.3,
            class_to_idx=class_to_idx, idx_to_class=idx_to_class
        )
        model.load_state_dict(ckpt["model_state_dict"])
        model.eval()
        print(f"✓ Model loaded (epoch={ckpt['epoch']}, classes={num_classes})")

        mtcnn  = MTCNN(keep_all=True, device="cpu")
        resnet = InceptionResnetV1(pretrained="vggface2").eval()
        for p in resnet.parameters():
            p.requires_grad = False

        # Collect test images
        image_paths, labels = [], []
        for cls in sorted(os.listdir(test_dir)):
            cls_path = os.path.join(test_dir, cls)
            if not os.path.isdir(cls_path):
                continue
            if cls not in class_to_idx:
                print(f"  skip unknown class: {cls}")
                continue
            idx = class_to_idx[cls]
            for f in os.listdir(cls_path):
                if f.lower().endswith((".jpg", ".jpeg", ".png")):
                    image_paths.append(os.path.join(cls_path, f))
                    labels.append(idx)

        print(f"Total test images: {len(image_paths)}")

        dataset    = FaceDataset(image_paths, labels, mtcnn, resnet, is_training=False)
        dataloader = DataLoader(dataset, batch_size=16, shuffle=False)

        correct, total = 0, 0
        per_class_correct = {i: 0 for i in range(num_classes)}
        per_class_total   = {i: 0 for i in range(num_classes)}

        with torch.no_grad():
            for batch_idx, (embeddings, batch_labels) in enumerate(dataloader):
                outputs = model(embeddings)
                _, predicted = torch.max(outputs, 1)
                total   += batch_labels.size(0)
                correct += (predicted == batch_labels).sum().item()
                for lbl, pred in zip(batch_labels, predicted):
                    per_class_total[lbl.item()]   += 1
                    if pred == lbl:
                        per_class_correct[lbl.item()] += 1
                print(f"  batch {batch_idx+1}/{len(dataloader)}, running acc: {100.*correct/total:.1f}%")

        test_accuracy = 100.0 * correct / total if total > 0 else 0.0

        print("\n" + "="*60)
        print(f"PRODUCTION MODEL EVALUATION")
        print(f"  Test accuracy : {test_accuracy:.2f}%  ({correct}/{total})")
        print(f"\nPer-class accuracy:")
        for i in range(num_classes):
            cls = idx_to_class[i]
            if per_class_total[i] > 0:
                acc = 100. * per_class_correct[i] / per_class_total[i]
                print(f"  {cls:15s}: {acc:.1f}%  ({per_class_correct[i]}/{per_class_total[i]})")
            else:
                print(f"  {cls:15s}: N/A (no test samples)")
        print("="*60)

        # Update production_model.json with real accuracy
        result = {"test_accuracy": test_accuracy, "total": total, "correct": correct}
        print(f"\nReal baseline accuracy: {test_accuracy:.2f}%")
        return test_accuracy

    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
