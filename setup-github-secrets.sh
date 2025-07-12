#!/bin/bash

# Скрипт для настройки секретов GitHub для рабочего процесса развертывания SuitesMe
# Этот скрипт требует установки и аутентификации GitHub CLI (gh)

# Проверка, установлен ли GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) не установлен. Пожалуйста, установите его сначала:"
    echo "https://cli.github.com/manual/installation"
    exit 1
fi

# Проверка, аутентифицирован ли пользователь с GitHub CLI
if ! gh auth status &> /dev/null; then
    echo "Вы не аутентифицированы с GitHub CLI. Пожалуйста, сначала выполните 'gh auth login'."
    exit 1
fi

# Получение имени репозитория
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
if [ -z "$REPO" ]; then
    echo "Не удалось определить имя репозитория. Пожалуйста, запустите этот скрипт из директории репозитория."
    echo "Альтернативно, вы можете указать имя репозитория вручную:"
    read -p "Имя репозитория (например, username/repo): " REPO
fi

echo "Настройка секретов GitHub для репозитория: $REPO"

# Функция для установки секрета
set_secret() {
    local name=$1
    local value=$2
    echo "Установка секрета: $name"
    echo "$value" | gh secret set "$name" -R "$REPO"
}

# Настройка SSH-секретов
read -p "Введите SSH-хост (IP-адрес или имя хоста сервера): " SSH_HOST
read -p "Введите имя пользователя SSH: " SSH_USERNAME
read -p "Путь к файлу приватного SSH-ключа (по умолчанию: ~/.ssh/id_ed25519): " SSH_KEY_PATH
SSH_KEY_PATH=${SSH_KEY_PATH:-~/.ssh/id_ed25519}

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "Файл SSH-ключа не найден: $SSH_KEY_PATH"
    echo "Хотите сгенерировать новую пару SSH-ключей? (y/n)"
    read -p "> " GENERATE_KEY
    if [[ "$GENERATE_KEY" =~ ^[Yy]$ ]]; then
        ssh-keygen -t ed25519 -C "github-actions" -f "$SSH_KEY_PATH" -N ""
        echo "Пара SSH-ключей сгенерирована. Пожалуйста, добавьте публичный ключ в файл authorized_keys вашего сервера:"
        echo "cat ${SSH_KEY_PATH}.pub | ssh ${SSH_USERNAME}@${SSH_HOST} \"mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys\""
    else
        echo "Пожалуйста, укажите действительный путь к файлу SSH-ключа."
        exit 1
    fi
fi

# Чтение приватного SSH-ключа
SSH_PRIVATE_KEY=$(cat "$SSH_KEY_PATH")

# Настройка переменных окружения
echo "Хотите использовать ваш локальный файл .env для секрета ENV_FILE? (y/n)"
read -p "> " USE_LOCAL_ENV
if [[ "$USE_LOCAL_ENV" =~ ^[Yy]$ ]]; then
    if [ -f ".env" ]; then
        ENV_FILE=$(cat .env)
    else
        echo "Файл .env не найден. Пожалуйста, сначала создайте его."
        exit 1
    fi
else
    echo "Пожалуйста, введите путь к вашему файлу .env:"
    read -p "> " ENV_FILE_PATH
    if [ -f "$ENV_FILE_PATH" ]; then
        ENV_FILE=$(cat "$ENV_FILE_PATH")
    else
        echo "Файл не найден: $ENV_FILE_PATH"
        exit 1
    fi
fi

# Настройка VITE_API_URL
read -p "Введите VITE_API_URL (например, https://api.example.com): " VITE_API_URL

# Установка секретов GitHub
set_secret "SSH_HOST" "$SSH_HOST"
set_secret "SSH_USERNAME" "$SSH_USERNAME"
set_secret "SSH_PRIVATE_KEY" "$SSH_PRIVATE_KEY"
set_secret "ENV_FILE" "$ENV_FILE"
set_secret "VITE_API_URL" "$VITE_API_URL"

echo "Секреты GitHub успешно настроены!"
echo "Теперь вы можете использовать рабочий процесс GitHub Actions для развертывания вашего приложения."
