#!/bin/bash
# Перенос MinIO со старого сервера на НОВЫЙ. Запускать на новом сервере из корня репозитория.
# Нужно: .env и backend/backups/minio-migration-info.txt (скопировать со старого сервера).
# Перед запуском: docker compose up -d minio и minio-init уже выполнены.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INFO_FILE="$REPO_ROOT/backend/backups/minio-migration-info.txt"

cd "$REPO_ROOT"

echo "=== Перенос MinIO на новый сервер ==="

[ -f .env ] || { echo "Ошибка: нет .env"; exit 1; }
[ -f "$INFO_FILE" ] || { echo "Ошибка: нет $INFO_FILE (скопируйте со старого сервера)"; exit 1; }

get_env() { grep -E "^${1}=" "$2" 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'" | head -1; }

OLD_IP=$(get_env OLD_SERVER_IP "$INFO_FILE")
STYLE_PHOTO_BUCKET=$(get_env STYLE_PHOTO_BUCKET "$INFO_FILE")
STYLE_PDF_BUCKET=$(get_env STYLE_PDF_BUCKET "$INFO_FILE")
ML_ARTIFACTS_BUCKET=$(get_env ML_ARTIFACTS_BUCKET "$INFO_FILE")

MINIO_ROOT_USER=$(get_env MINIO_ROOT_USER .env)
MINIO_ROOT_PASSWORD=$(get_env MINIO_ROOT_PASSWORD .env)

STYLE_PHOTO_BUCKET="${STYLE_PHOTO_BUCKET:-style-photos}"
STYLE_PDF_BUCKET="${STYLE_PDF_BUCKET:-style-pdf}"
ML_ARTIFACTS_BUCKET="${ML_ARTIFACTS_BUCKET:-ml-artifacts}"

[ -n "$OLD_IP" ] || { echo "Ошибка: в minio-migration-info.txt не найден OLD_SERVER_IP"; exit 1; }

# Контейнер MinIO на этом сервере
MINIO_CID=$(docker ps -q --filter "name=minio" | head -1)
[ -n "$MINIO_CID" ] || { echo "Ошибка: MinIO не запущен. Выполните: docker compose up -d minio"; exit 1; }

NET=$(docker inspect "$MINIO_CID" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}')
[ -n "$NET" ] || { echo "Ошибка: не удалось определить сеть MinIO"; exit 1; }

OLD_URL="http://${OLD_IP}:9000"
echo "Старый MinIO: $OLD_URL"
echo "Бакеты: $STYLE_PHOTO_BUCKET, $STYLE_PDF_BUCKET, $ML_ARTIFACTS_BUCKET"
echo "Копирование..."
echo ""

docker run --rm --network "$NET" \
  -e MINIO_ROOT_USER="$MINIO_ROOT_USER" \
  -e MINIO_ROOT_PASSWORD="$MINIO_ROOT_PASSWORD" \
  -e STYLE_PHOTO_BUCKET="$STYLE_PHOTO_BUCKET" \
  -e STYLE_PDF_BUCKET="$STYLE_PDF_BUCKET" \
  -e ML_ARTIFACTS_BUCKET="$ML_ARTIFACTS_BUCKET" \
  minio/mc sh -c "
    mc alias set old $OLD_URL \$MINIO_ROOT_USER \$MINIO_ROOT_PASSWORD --insecure &&
    mc alias set new http://minio:9000 \$MINIO_ROOT_USER \$MINIO_ROOT_PASSWORD --insecure &&
    mc mirror old/\$STYLE_PHOTO_BUCKET new/\$STYLE_PHOTO_BUCKET --overwrite &&
    mc mirror old/\$STYLE_PDF_BUCKET new/\$STYLE_PDF_BUCKET --overwrite &&
    mc mirror old/\$ML_ARTIFACTS_BUCKET new/\$ML_ARTIFACTS_BUCKET --overwrite &&
    echo '' && echo 'Готово.'
"
