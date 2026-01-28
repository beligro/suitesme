#!/bin/bash
# Скрипт для сброса пароля PostgreSQL пользователя
# Использование: ./reset_password.sh <новый_пароль>

set -e

if [ -z "$1" ]; then
    echo "Использование: $0 <новый_пароль>"
    echo "Пример: $0 mynewpassword123"
    exit 1
fi

NEW_PASSWORD="$1"
CONTAINER_NAME="suitesme_postgres_1"

echo "Сброс пароля для пользователя postgres..."

# Проверяем, запущен ли контейнер
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Ошибка: Контейнер $CONTAINER_NAME не запущен"
    echo "Запустите: docker compose up -d postgres"
    exit 1
fi

# Сбрасываем пароль
docker exec -e PGPASSWORD="${DB_PASSWORD:-postgres}" "$CONTAINER_NAME" psql -U postgres -c "ALTER USER postgres WITH PASSWORD '$NEW_PASSWORD';" 2>/dev/null || \
docker exec "$CONTAINER_NAME" psql -U postgres -c "ALTER USER postgres WITH PASSWORD '$NEW_PASSWORD';"

echo "Пароль успешно изменен!"
echo "Обновите DB_PASSWORD в .env файле на: $NEW_PASSWORD"
echo "После этого перезапустите backend: docker compose restart backend"
