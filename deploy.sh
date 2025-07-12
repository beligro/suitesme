#!/bin/bash

# Скрипт для развертывания приложения SuitesMe
# Этот скрипт может быть использован для ручного развертывания приложения на сервере

# Установка переменных
GITHUB_REPOSITORY="beligro/suitesme"
GITHUB_SHA=$(git rev-parse HEAD)

# Проверка, предоставлен ли токен GitHub
if [ -z "$1" ]; then
  echo "Ошибка: Требуется токен GitHub"
  echo "Использование: ./deploy.ru.sh <github_token>"
  exit 1
fi

GITHUB_TOKEN=$1

# Вход в GitHub Container Registry
echo "Вход в GitHub Container Registry..."
echo $GITHUB_TOKEN | docker login ghcr.io -u $(echo $GITHUB_REPOSITORY | cut -d'/' -f1) --password-stdin

if [ $? -ne 0 ]; then
  echo "Ошибка: Не удалось войти в GitHub Container Registry"
  exit 1
fi

# Экспорт переменных для docker-compose
export GITHUB_REPOSITORY=$GITHUB_REPOSITORY
export GITHUB_SHA=$GITHUB_SHA

# Загрузка последних образов
echo "Загрузка последних Docker-образов..."
docker-compose -f docker-compose.prod.yml pull

if [ $? -ne 0 ]; then
  echo "Ошибка: Не удалось загрузить Docker-образы"
  exit 1
fi

# Остановка и удаление существующих контейнеров
echo "Остановка существующих контейнеров..."
docker-compose -f docker-compose.prod.yml down

# Запуск новых контейнеров
echo "Запуск новых контейнеров..."
docker-compose -f docker-compose.prod.yml up -d

if [ $? -ne 0 ]; then
  echo "Ошибка: Не удалось запустить контейнеры"
  exit 1
fi

# Очистка неиспользуемых образов
echo "Очистка неиспользуемых образов..."
docker image prune -af

echo "Развертывание успешно завершено!"
