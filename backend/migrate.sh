#!/bin/bash

# Database Migration Script for Docker Environment
# Usage: ./migrate.sh [upgrade|downgrade|verify|backup]

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Change to script directory
cd "$(dirname "$0")/.."

# Load environment variables
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi

export $(cat .env | grep -v '^#' | xargs)

# Database connection parameters
DB_HOST="localhost"
DB_PORT="5433"

# Create backups directory
mkdir -p backend/backups

function backup_database() {
    echo -e "${YELLOW}Creating backup...${NC}"
    BACKUP_FILE="backend/backups/backup_$(date +%Y%m%d_%H%M%S).dump"
    
    PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -F c -f $BACKUP_FILE
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Backup created: $BACKUP_FILE${NC}"
    else
        echo -e "${RED}✗ Backup failed${NC}"
        exit 1
    fi
}

function run_migration() {
    local migration_file=$1
    echo -e "${YELLOW}Running migration: $migration_file${NC}"
    
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $migration_file
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Migration completed successfully${NC}"
    else
        echo -e "${RED}✗ Migration failed${NC}"
        exit 1
    fi
}

function verify_schema() {
    echo -e "${YELLOW}Verifying schema...${NC}"
    
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\d db_user_styles"
    
    echo -e "\n${YELLOW}Column details:${NC}"
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_name = 'db_user_styles'
        ORDER BY ordinal_position;
    "
    
    echo -e "\n${YELLOW}Statistics:${NC}"
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        SELECT 
            COUNT(*) as total_records,
            COUNT(photo_urls) as has_photo_urls,
            COUNT(initial_prediction) as has_prediction,
            ROUND(AVG(confidence)::numeric, 2) as avg_confidence,
            SUM(CASE WHEN is_verified THEN 1 ELSE 0 END) as verified_count
        FROM db_user_styles;
    "
}

# Main script logic
case "${1:-}" in
    upgrade)
        echo -e "${GREEN}=== Upgrade to auto_ml_service ===${NC}\n"
        backup_database
        run_migration "backend/migrations/001_upgrade_to_automl.sql"
        verify_schema
        echo -e "\n${GREEN}✓ Upgrade complete! Deploy auto_ml_service code now.${NC}"
        ;;
    
    downgrade)
        echo -e "${YELLOW}=== Downgrade to main ===${NC}\n"
        echo -e "${RED}WARNING: This will DELETE data in new columns!${NC}"
        read -p "Are you sure? Type 'yes' to continue: " confirm
        if [ "$confirm" != "yes" ]; then
            echo "Cancelled."
            exit 0
        fi
        backup_database
        run_migration "backend/migrations/002_downgrade_from_automl.sql"
        verify_schema
        echo -e "\n${GREEN}✓ Downgrade complete! Deploy main branch code now.${NC}"
        ;;
    
    verify)
        echo -e "${GREEN}=== Verifying Schema ===${NC}\n"
        verify_schema
        ;;
    
    backup)
        backup_database
        ;;
    
    *)
        echo "Usage: $0 {upgrade|downgrade|verify|backup}"
        echo ""
        echo "Commands:"
        echo "  upgrade    - Migrate from main to auto_ml_service"
        echo "  downgrade  - Migrate from auto_ml_service to main (LOSES DATA)"
        echo "  verify     - Check current schema and data"
        echo "  backup     - Create database backup"
        exit 1
        ;;
esac

