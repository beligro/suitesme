#!/bin/bash

# Script to restore PostgreSQL backup to production database
# Usage: ./restore_backup.sh <backup_file>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if backup file is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No backup file specified${NC}"
    echo "Usage: $0 <backup_file>"
    echo ""
    echo "Available backups:"
    ls -lh backups/*.sql 2>/dev/null || echo "No backups found in backups/"
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Error: Backup file '$BACKUP_FILE' not found${NC}"
    exit 1
fi

# Load environment variables
if [ ! -f "../.env" ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi

source ../.env

CONTAINER_NAME="suitesme_postgres_1"
DB_NAME="${DB_NAME:-suitesme}"
DB_USER="${DB_USER:-postgres}"

echo -e "${YELLOW}=== PostgreSQL Backup Restore ===${NC}"
echo "Backup file: $BACKUP_FILE"
echo "Container: $CONTAINER_NAME"
echo "Database: $DB_NAME"
echo ""

# Confirm before proceeding
read -p "⚠️  This will OVERWRITE the current database. Are you sure? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Restore cancelled${NC}"
    exit 0
fi

echo -e "${GREEN}Step 1: Creating backup of current database...${NC}"
CURRENT_BACKUP="backups/pre_restore_backup_$(date +%Y%m%d_%H%M%S).sql"
docker exec -i "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" > "$CURRENT_BACKUP"
echo -e "${GREEN}✓ Current database backed up to: $CURRENT_BACKUP${NC}"

echo -e "${GREEN}Step 2: Stopping backend service...${NC}"
cd ..
docker-compose stop backend
echo -e "${GREEN}✓ Backend stopped${NC}"

echo -e "${GREEN}Step 3: Dropping and recreating database...${NC}"
if [ "$DB_NAME" = "postgres" ]; then
    # Special handling for postgres database - can't drop it, so we'll clear all data instead
    echo "Detected 'postgres' database - clearing all tables instead of dropping database..."
    docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO postgres; GRANT ALL ON SCHEMA public TO public;"
else
    # For custom databases, we can safely drop and recreate
    docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d template1 -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME';"
    docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d template1 -c "DROP DATABASE IF EXISTS $DB_NAME;"
    docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d template1 -c "CREATE DATABASE $DB_NAME;"
fi
echo -e "${GREEN}✓ Database recreated${NC}"

echo -e "${GREEN}Step 4: Restoring backup...${NC}"
cd backend
cat "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME"
echo -e "${GREEN}✓ Backup restored${NC}"

echo -e "${GREEN}Step 5: Restarting backend service...${NC}"
cd ..
docker-compose start backend
echo -e "${GREEN}✓ Backend started${NC}"

echo ""
echo -e "${GREEN}=== Restore Complete ===${NC}"
echo -e "${YELLOW}Pre-restore backup saved at: $CURRENT_BACKUP${NC}"
echo ""
echo "You can verify the restore by checking the application or running:"
echo "docker exec -it $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c '\\dt'"
