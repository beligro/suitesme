# MinIO Configuration

This document explains how MinIO is configured in this project and how to make buckets publicly readable.

## Overview

MinIO is used as an S3-compatible object storage service. It stores files such as user photos and style PDFs. The application requires these files to be publicly accessible via direct URLs.

## Automatic Bucket Creation and Public Access

With the recent updates to MinIO's UI, it's no longer possible to configure buckets to be publicly readable through the web interface. To solve this issue, we've implemented an automatic initialization process that:

1. Creates the required buckets if they don't exist
2. Sets appropriate policies to make the bucket contents publicly readable

This is done using a separate service in the docker-compose.yml file that runs the MinIO Client (mc) with a custom initialization script.

## How It Works

1. The `minio` service starts the MinIO server
2. The `minio-init` service waits for MinIO to be healthy
3. Once MinIO is ready, the initialization script:
   - Creates the required buckets (if they don't exist)
   - Sets a bucket policy that allows public read access
   - Configures anonymous access for downloads

## Environment Variables

The following environment variables are used for MinIO configuration:

- `MINIO_ROOT_USER`: The root user for MinIO
- `MINIO_ROOT_PASSWORD`: The root password for MinIO
- `MINIO_ENDPOINT`: The endpoint URL for MinIO
- `MINIO_FILE_PATH_ENDPOINT`: The file path endpoint for MinIO
- `MINIO_REGION`: The region for MinIO
- `STYLE_PHOTO_BUCKET`: The bucket name for style photos
- `STYLE_PDF_BUCKET`: The bucket name for style PDFs

Make sure these variables are set in your `.env` file. You can use the `.env.example` file as a template.

## Testing

To verify that the buckets are publicly accessible:

1. Start the services with `docker-compose up -d`
2. Wait for the initialization to complete
3. Try accessing a file via its URL: `http://localhost:9000/style-photos/your-file-name`

If everything is configured correctly, you should be able to access the file without authentication.

## Troubleshooting

If you encounter issues with public access:

1. Check the logs of the `minio-init` service: `docker-compose logs minio-init`
2. Verify that the buckets were created: `docker-compose exec minio mc ls myminio`
3. Check the bucket policies: `docker-compose exec minio mc admin policy info myminio public-read`
4. Ensure the anonymous access is set: `docker-compose exec minio mc anonymous get myminio/style-photos`

## Manual Configuration

If you need to manually configure the buckets, you can use the following commands:

```bash
# Set alias for MinIO
docker-compose exec minio mc alias set myminio http://localhost:9000 minioadmin minioadmin

# Create buckets
docker-compose exec minio mc mb myminio/style-photos
docker-compose exec minio mc mb myminio/style-pdfs

# Set anonymous access
docker-compose exec minio mc anonymous set download myminio/style-photos
docker-compose exec minio mc anonymous set download myminio/style-pdfs
```

Replace `minioadmin` with your actual MinIO credentials if they're different.
