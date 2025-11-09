#!/bin/sh

# Wait for MinIO to be ready
echo "Waiting for MinIO to be ready..."
until mc alias set myminio http://minio:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD} --insecure; do
  echo "MinIO not ready yet, waiting..."
  sleep 1
done

echo "MinIO is ready! Creating buckets and setting policies..."

# Create buckets if they don't exist
mc mb myminio/${STYLE_PHOTO_BUCKET} --insecure || true
mc mb myminio/${STYLE_PDF_BUCKET} --insecure || true
mc mb myminio/${ML_ARTIFACTS_BUCKET} --insecure || true

# Set public read policy for the buckets
cat > /tmp/public-read-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ["*"]
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::${STYLE_PHOTO_BUCKET}/*",
        "arn:aws:s3:::${STYLE_PDF_BUCKET}/*",
        "arn:aws:s3:::${ML_ARTIFACTS_BUCKET}/*"
      ]
    }
  ]
}
EOF

# Apply the policy to the buckets
mc admin policy create myminio public-read /tmp/public-read-policy.json --insecure || true
mc admin policy attach myminio public-read --user ${MINIO_ROOT_USER} --insecure

# Set anonymous policy for the buckets
mc anonymous set download myminio/${STYLE_PHOTO_BUCKET} --insecure
mc anonymous set download myminio/${STYLE_PDF_BUCKET} --insecure
mc anonymous set download myminio/${ML_ARTIFACTS_BUCKET} --insecure

# Create ML artifacts bucket directory structure
echo "Creating ML artifacts bucket directory structure..."

# Create placeholder files to ensure directories exist
echo "Gold training dataset directory" > /tmp/README_gold.txt
echo "Verified datasets directory - contains monthly verified training datasets" > /tmp/README_verified.txt
echo "Full datasets directory - contains monthly verified + unverified training datasets" > /tmp/README_full.txt
echo "Daily candidate collections directory" > /tmp/README_candidates.txt
echo "Model checkpoints directory" > /tmp/README_checkpoints.txt
echo "Dataset metadata directory" > /tmp/README_metadata.txt

# Upload README files to create directory structure
mc cp /tmp/README_gold.txt myminio/${ML_ARTIFACTS_BUCKET}/datasets/gold/README.txt --insecure || true
mc cp /tmp/README_verified.txt myminio/${ML_ARTIFACTS_BUCKET}/datasets/verified/README.txt --insecure || true
mc cp /tmp/README_full.txt myminio/${ML_ARTIFACTS_BUCKET}/datasets/full/README.txt --insecure || true
mc cp /tmp/README_candidates.txt myminio/${ML_ARTIFACTS_BUCKET}/datasets/candidates/README.txt --insecure || true
mc cp /tmp/README_checkpoints.txt myminio/${ML_ARTIFACTS_BUCKET}/models/checkpoints/README.txt --insecure || true
mc cp /tmp/README_metadata.txt myminio/${ML_ARTIFACTS_BUCKET}/metadata/README.txt --insecure || true

# Clean up temp files
rm -f /tmp/README_*.txt

echo "✓ ML artifacts directory structure created"
echo "MinIO initialization completed successfully!"

# Keep the container running
tail -f /dev/null
