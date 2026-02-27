#!/bin/bash

# Простой скрипт для обновления SSL сертификатов с использованием Docker
# Автор: SuitesMe System
# Версия: 1.0

set -e

# Конфигурация
DOMAIN="ai.mne-idet.ru"
NGINX_SSL_DIR="/home/aagrom/suitesme/nginx/ssl"
PROJECT_DIR="/home/aagrom/suitesme"
LOG_FILE="/home/aagrom/suitesme/logs/ssl_renew.log"

# Функция логирования
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Функция проверки срока действия сертификата
check_certificate_expiry() {
    local cert_file="$NGINX_SSL_DIR/fullchain.pem"
    
    if [ ! -f "$cert_file" ]; then
        log "ERROR: Сертификат не найден: $cert_file"
        return 1
    fi
    
    local expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)
    local expiry_timestamp=$(date -d "$expiry_date" +%s)
    local current_timestamp=$(date +%s)
    local days_until_expiry=$(( (expiry_timestamp - current_timestamp) / 86400 ))
    
    log "Сертификат истекает: $expiry_date (через $days_until_expiry дней)"
    
    if [ $days_until_expiry -lt 30 ]; then
        log "WARNING: Сертификат истекает менее чем через 30 дней!"
        return 0
    else
        log "INFO: Сертификат действителен более 30 дней"
        return 1
    fi
}

# Первая выдача сертификата: standalone (nginx останавливается, порт 80 свободен)
renew_certificate_standalone() {
    log "Первая выдача сертификата (standalone): останавливаем nginx..."
    cd "$PROJECT_DIR"
    docker compose stop nginx || true
    
    mkdir -p "$PROJECT_DIR/certbot/conf" "$PROJECT_DIR/certbot/www" "$NGINX_SSL_DIR"
    
    if docker run --rm \
        -p 80:80 \
        -v "$PROJECT_DIR/certbot/conf:/etc/letsencrypt" \
        -v "$PROJECT_DIR/certbot/www:/var/www/certbot" \
        certbot/certbot \
        certonly --standalone \
        --non-interactive \
        --agree-tos --no-eff-email \
        --email "admin@$DOMAIN" \
        -d "$DOMAIN"; then
        copy_certs_and_start_nginx
        return $?
    else
        log "ERROR: Не удалось получить сертификат (standalone)"
        docker compose up -d nginx 2>/dev/null || true
        return 1
    fi
}

copy_certs_and_start_nginx() {
    log "Копируем сертификаты в nginx/ssl (certbot создаёт файлы от root)..."
    sudo cp "$PROJECT_DIR/certbot/conf/live/$DOMAIN/fullchain.pem" "$NGINX_SSL_DIR/"
    sudo cp "$PROJECT_DIR/certbot/conf/live/$DOMAIN/privkey.pem" "$NGINX_SSL_DIR/"
    sudo chown "$(whoami):$(whoami)" "$NGINX_SSL_DIR/fullchain.pem" "$NGINX_SSL_DIR/privkey.pem"
    chmod 644 "$NGINX_SSL_DIR/fullchain.pem"
    chmod 600 "$NGINX_SSL_DIR/privkey.pem"
    log "Запускаем nginx..."
    docker compose up -d nginx
    sleep 3
    if docker compose ps nginx | grep -q "Up"; then
        log "SUCCESS: Nginx запущен с сертификатом"
        return 0
    else
        log "ERROR: Nginx не запустился"
        return 1
    fi
}

# Обновление сертификата (webroot: nginx не останавливается)
renew_certificate() {
    cd "$PROJECT_DIR"
    mkdir -p "$PROJECT_DIR/certbot/conf" "$PROJECT_DIR/certbot/www" "$NGINX_SSL_DIR"
    
    # Первый запуск: сертификата нет — используем standalone
    if [ ! -f "$NGINX_SSL_DIR/fullchain.pem" ]; then
        log "Сертификат не найден — первая выдача (standalone)"
        renew_certificate_standalone
        return $?
    fi
    
    log "Обновление SSL для домена: $DOMAIN (webroot)"
    
    local backup_dir="$NGINX_SSL_DIR/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    cp "$NGINX_SSL_DIR/fullchain.pem" "$backup_dir/" 2>/dev/null || true
    cp "$NGINX_SSL_DIR/privkey.pem" "$backup_dir/" 2>/dev/null || true
    
    if docker run --rm \
        -v "$PROJECT_DIR/certbot/conf:/etc/letsencrypt" \
        -v "$PROJECT_DIR/certbot/www:/var/www/certbot" \
        certbot/certbot \
        certonly --webroot \
        -w /var/www/certbot \
        --non-interactive \
        --agree-tos --no-eff-email \
        --email "admin@$DOMAIN" \
        ${CERTBOT_FORCE:+"--force-renewal"} \
        -d "$DOMAIN"; then
        log "Сертификат успешно обновлен!"
        sudo cp "$PROJECT_DIR/certbot/conf/live/$DOMAIN/fullchain.pem" "$NGINX_SSL_DIR/"
        sudo cp "$PROJECT_DIR/certbot/conf/live/$DOMAIN/privkey.pem" "$NGINX_SSL_DIR/"
        sudo chown "$(whoami):$(whoami)" "$NGINX_SSL_DIR/fullchain.pem" "$NGINX_SSL_DIR/privkey.pem"
        chmod 644 "$NGINX_SSL_DIR/fullchain.pem"
        chmod 600 "$NGINX_SSL_DIR/privkey.pem"
        log "Перезагружаем nginx..."
        docker compose exec -T nginx nginx -s reload 2>/dev/null || docker compose restart nginx
        docker compose ps nginx | grep -q "Up" && return 0 || return 1
    else
        log "ERROR: Не удалось обновить сертификат"
        return 1
    fi
}

# Основная функция
main() {
    log "=== Запуск проверки SSL сертификата ==="
    
    # Проверяем срок действия сертификата
    if check_certificate_expiry; then
        log "Сертификат требует обновления"
        if renew_certificate; then
            log "Сертификат успешно обновлен"
        else
            log "ERROR: Не удалось обновить сертификат"
            exit 1
        fi
    else
        log "Сертификат действителен, обновление не требуется"
    fi
    
    log "=== Проверка SSL сертификата завершена ==="
}

# Обработка аргументов командной строки
case "${1:-}" in
    "force")
        log "Принудительное обновление сертификата"
        CERTBOT_FORCE=1 renew_certificate
        ;;
    "check")
        log "Проверка статуса сертификата"
        check_certificate_expiry
        ;;
    *)
        main
        ;;
esac
