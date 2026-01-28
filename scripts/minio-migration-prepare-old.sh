#!/bin/bash
# Подготовка MinIO к миграции на СТАРОМ сервере.
# Запускать из корня репозитория: ./scripts/minio-migration-prepare-old.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$REPO_ROOT/backend/backups"
INFO_FILE="$OUT_DIR/minio-migration-info.txt"

cd "$REPO_ROOT"

echo "=== Подготовка MinIO к миграции (старый сервер) ==="

# 1. Проверка .env
if [ ! -f .env ]; then
  echo "Ошибка: файл .env не найден в $REPO_ROOT"
  exit 1
fi

# Читаем переменные из .env
get_env() { grep -E "^${1}=" .env 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'" | head -1; }
STYLE_PHOTO_BUCKET="$(get_env STYLE_PHOTO_BUCKET)"
STYLE_PDF_BUCKET="$(get_env STYLE_PDF_BUCKET)"
ML_ARTIFACTS_BUCKET="$(get_env ML_ARTIFACTS_BUCKET)"
MINIO_ROOT_USER="$(get_env MINIO_ROOT_USER)"
MINIO_ROOT_PASSWORD="$(get_env MINIO_ROOT_PASSWORD)"

STYLE_PHOTO_BUCKET="${STYLE_PHOTO_BUCKET:-style-photos}"
STYLE_PDF_BUCKET="${STYLE_PDF_BUCKET:-style-pdf}"
ML_ARTIFACTS_BUCKET="${ML_ARTIFACTS_BUCKET:-ml-artifacts}"

echo "Бакеты из .env: $STYLE_PHOTO_BUCKET, $STYLE_PDF_BUCKET, $ML_ARTIFACTS_BUCKET"

# 2. Проверка Docker и контейнера MinIO
if ! command -v docker &>/dev/null; then
  echo "Ошибка: docker не найден"
  exit 1
fi

COMPOSE_FILE="docker-compose.yml"
if [ ! -f "$COMPOSE_FILE" ]; then
  COMPOSE_FILE="docker-compose.prod.yml"
fi
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Ошибка: docker-compose.prod.yml и docker-compose.yml не найдены"
  exit 1
fi

echo "Используется: $COMPOSE_FILE"

# Проверяем по имени контейнера (не по compose), чтобы работало при любом каталоге/проекте
MINIO_CID=$(docker ps -q --filter "name=minio" | head -1)
if [ -z "$MINIO_CID" ]; then
  echo "MinIO не запущен. Запустите стек: docker-compose -f $COMPOSE_FILE up -d minio"
  exit 1
fi
echo "MinIO контейнер запущен."

# 3. Получаем имя сети MinIO (по ID контейнера)
MINIO_NET=$(docker inspect "$MINIO_CID" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null || true)
if [ -z "$MINIO_NET" ]; then
  echo "Предупреждение: не удалось определить сеть MinIO. На новом сервере используйте --network host или имя сети вашего compose."
fi

# 4. Проверка доступа к MinIO через mc (опционально)
echo "Проверка доступа к MinIO..."
if [ -n "$MINIO_NET" ]; then
  if docker run --rm \
    --network "$MINIO_NET" \
    -e "MINIO_ROOT_USER=$MINIO_ROOT_USER" \
    -e "MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD" \
    minio/mc \
    sh -c "mc alias set myminio http://minio:9000 \$MINIO_ROOT_USER \$MINIO_ROOT_PASSWORD --insecure && mc ls myminio" 2>/dev/null; then
    echo "MinIO доступен, бакеты перечислены выше."
  else
    echo "Предупреждение: не удалось перечислить бакеты через mc (проверьте MINIO_ROOT_USER/MINIO_ROOT_PASSWORD в .env)."
  fi
fi

# 5. Определение IP старого сервера (для доступа с нового)
OLD_IP=""
if command -v hostname &>/dev/null; then
  OLD_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
fi
if [ -z "$OLD_IP" ] && command -v curl &>/dev/null; then
  OLD_IP=$(curl -s --max-time 3 ifconfig.me 2>/dev/null || true)
fi
if [ -z "$OLD_IP" ]; then
  OLD_IP="YOUR_OLD_SERVER_IP"
  echo "Не удалось определить IP. Укажите его вручную в $INFO_FILE"
fi

# 6. Запись файла для переноса на новый сервер
mkdir -p "$OUT_DIR"
cat > "$INFO_FILE" << EOF
# MinIO migration — данные со СТАРОГО сервера
# Скопируйте этот файл на новый сервер вместе с .env (или переменными MINIO_* и *_BUCKET)

OLD_SERVER_IP=$OLD_IP
OLD_MINIO_PORT=9000

# Имена бакетов (должны совпадать с .env на новом сервере)
STYLE_PHOTO_BUCKET=$STYLE_PHOTO_BUCKET
STYLE_PDF_BUCKET=$STYLE_PDF_BUCKET
ML_ARTIFACTS_BUCKET=$ML_ARTIFACTS_BUCKET

# На новом сервере нужны те же MINIO_ROOT_USER и MINIO_ROOT_PASSWORD (из .env).
EOF

echo ""
echo "--- Готово ---"
echo "Файл для миграции записан: $INFO_FILE"
echo ""
echo "Дальнейшие шаги на СТАРОМ сервере:"
echo "1. Убедитесь, что порт 9000 (MinIO) доступен с нового сервера:"
echo "   - Либо откройте в файрволе: ufw allow 9000/tcp (если используете ufw)"
echo "   - Либо на новом сервере сделайте SSH-туннель: ssh -L 9000:localhost:9000 user@$OLD_IP"
echo "2. Скопируйте на новый сервер:"
echo "   - $INFO_FILE"
echo "   - .env (или минимум переменные MINIO_ROOT_USER, MINIO_ROOT_PASSWORD, STYLE_PHOTO_BUCKET, STYLE_PDF_BUCKET, ML_ARTIFACTS_BUCKET)"
echo "3. На новом сервере выполните шаги из docs/MINIO_MIGRATION.md (Часть 2 — «На новом сервере»)."
echo ""
