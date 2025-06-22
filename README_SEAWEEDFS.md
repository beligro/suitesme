# Migrating from MinIO to SeaweedFS

This document explains the changes made to migrate from MinIO to SeaweedFS as the S3-compatible storage solution.

## What is SeaweedFS?

SeaweedFS is a simple and highly scalable distributed file system. It is designed to handle billions of files and petabytes of data. It can be used as a standalone file system or as an S3-compatible object storage service.

## Changes Made

1. Replaced MinIO with SeaweedFS in the docker-compose.yml file
2. Added a simplified SeaweedFS setup with a single server that provides:
   - S3-compatible API
   - File system interface
   - Web UI for management
3. Added a configuration file for the S3 API to allow public read access to files
4. Added an initialization container to automatically create the required buckets

## How to Use

The migration should be transparent to your application as SeaweedFS provides an S3-compatible API. The application will continue to use the AWS SDK for Go to interact with the storage service.

An example .env file (.env.example) has been provided with the required environment variables for SeaweedFS. You can use this as a reference to update your existing .env file.

### Environment Variables

The same environment variables used for MinIO are used for SeaweedFS:

- `MINIO_ROOT_USER`: The access key for the S3 API
- `MINIO_ROOT_PASSWORD`: The secret key for the S3 API
- `STYLE_PHOTO_BUCKET`: The name of the bucket for style photos
- `STYLE_PDF_BUCKET`: The name of the bucket for style PDFs

### Accessing Files

Files can be accessed via the S3 API at `http://localhost:9000` or via the Filer API at `http://localhost:8888`.

For public access to files, you can use the following URL format:
```
http://localhost:9000/<bucket-name>/<file-key>
```

For example:
```
http://localhost:9000/style-photos/user-id/photo.jpg
```

### Web UI

SeaweedFS provides a web UI at `http://localhost:9001` for managing the server, and a file browser at `http://localhost:8888`.

## Advantages over MinIO

1. **Scalability**: SeaweedFS is designed to handle billions of files and petabytes of data
2. **Performance**: SeaweedFS is optimized for small files and can handle high throughput
3. **Simplicity**: SeaweedFS has a simpler architecture and is easier to deploy and manage
4. **Features**: SeaweedFS provides additional features like file versioning, tiered storage, and more

## Troubleshooting

If you encounter any issues with SeaweedFS, you can check the logs of the container:

```bash
docker logs seaweedfs
```

You can also check the status of the SeaweedFS server using the web UI at `http://localhost:9001`.

If you need to manually create a bucket, you can use the following command:

```bash
curl -X PUT http://localhost:9000/<bucket-name>
```

For example:
```bash
curl -X PUT http://localhost:9000/style-photos
```
