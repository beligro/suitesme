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
        "arn:aws:s3:::${STYLE_PDF_BUCKET}/*"
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

echo "MinIO initialization completed successfully!"

# Keep the container running
tail -f /dev/null
