#!/bin/bash

# Script to migrate photo_url (string) to photo_urls (JSON array)
# For all records where photo_urls is NULL/empty, create JSON array with photo_url value

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONTAINER_NAME="suitesme_postgres_1"
DB_NAME="postgres"
DB_USER="postgres"

echo -e "${YELLOW}=== Photo URLs Migration Script ===${NC}"
echo "This will migrate photo_url (string) to photo_urls (JSON array)"
echo ""

# Check records that need migration
echo -e "${GREEN}Step 1: Checking records that need migration...${NC}"
RECORDS_TO_MIGRATE=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c \
  "SELECT COUNT(*) FROM db_user_styles WHERE (photo_urls IS NULL OR photo_urls = 'null'::jsonb OR photo_urls::text = '[]') AND photo_url IS NOT NULL AND photo_url != '';")

echo "Records to migrate: $RECORDS_TO_MIGRATE"

if [ "$RECORDS_TO_MIGRATE" -eq 0 ]; then
    echo -e "${GREEN}No records need migration. All done!${NC}"
    exit 0
fi

# Show sample of what will be migrated
echo ""
echo -e "${YELLOW}Sample of records to be migrated (first 3):${NC}"
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "SELECT id, photo_url, photo_urls FROM db_user_styles WHERE (photo_urls IS NULL OR photo_urls = 'null'::jsonb OR photo_urls::text = '[]') AND photo_url IS NOT NULL AND photo_url != '' LIMIT 3;"

echo ""
read -p "Continue with migration? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Migration cancelled${NC}"
    exit 0
fi

# Perform migration
echo ""
echo -e "${GREEN}Step 2: Migrating data...${NC}"
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "UPDATE db_user_styles 
   SET photo_urls = jsonb_build_array(photo_url)
   WHERE (photo_urls IS NULL OR photo_urls = 'null'::jsonb OR photo_urls::text = '[]')
   AND photo_url IS NOT NULL 
   AND photo_url != '';"

echo -e "${GREEN}✓ Migration completed!${NC}"

# Verify migration
echo ""
echo -e "${GREEN}Step 3: Verifying migration...${NC}"
REMAINING=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c \
  "SELECT COUNT(*) FROM db_user_styles WHERE (photo_urls IS NULL OR photo_urls = 'null'::jsonb OR photo_urls::text = '[]') AND photo_url IS NOT NULL AND photo_url != '';")

echo "Records still needing migration: $REMAINING"

if [ "$REMAINING" -eq 0 ]; then
    echo -e "${GREEN}✓ All records migrated successfully!${NC}"
else
    echo -e "${YELLOW}Warning: $REMAINING records still need attention${NC}"
fi

# Show sample of migrated records
echo ""
echo -e "${YELLOW}Sample of migrated records (first 3):${NC}"
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "SELECT id, photo_url, photo_urls FROM db_user_styles WHERE photo_urls IS NOT NULL AND photo_urls != 'null'::jsonb AND photo_urls::text != '[]' LIMIT 3;"

echo ""
echo -e "${GREEN}=== Migration Complete ===${NC}"
echo "You can now refresh the admin panel predictions page to see the images!"
