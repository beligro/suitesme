#!/bin/bash

# Comprehensive migration script for photo URLs
# This script:
# 1. Converts absolute URLs to relative paths (to avoid IP dependency)
# 2. Fixes old server IPs to use relative /files/ path
# 3. Fixes old bucket names (style -> style-photos)
# 4. Migrates photo_url to photo_urls JSONB array

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONTAINER_NAME="suitesme_postgres_1"
DB_NAME="postgres"
DB_USER="postgres"

# Old patterns to fix
OLD_SERVER_PATTERN_1="http://51.250.84.195:9000"
OLD_SERVER_PATTERN_2="http://89.232.188.182:9000"
OLD_SERVER_PATTERN_3="http://localhost:9000"
OLD_BUCKET_NAME="style"
NEW_BUCKET_NAME="style-photos"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Comprehensive Photo URLs Migration Script              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "This script will:"
echo "  1. Convert absolute URLs to relative paths (/files/...)"
echo "  2. Fix old bucket names (style -> style-photos)"
echo "  3. Migrate photo_url to photo_urls JSONB array"
echo ""

# Step 1: Check current state
echo -e "${GREEN}Step 1: Analyzing current database state...${NC}"
echo ""

echo -e "${YELLOW}Records with old IP (51.250.84.195):${NC}"
COUNT_OLD_IP=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c \
  "SELECT COUNT(*) FROM db_user_styles WHERE photo_url LIKE '%51.250.84.195%';")
echo "  Count: $COUNT_OLD_IP"

echo -e "${YELLOW}Records with localhost URLs:${NC}"
COUNT_LOCALHOST=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c \
  "SELECT COUNT(*) FROM db_user_styles WHERE photo_url LIKE '%localhost%';")
echo "  Count: $COUNT_LOCALHOST"

echo -e "${YELLOW}Records with :9000 port (direct MinIO access):${NC}"
COUNT_DIRECT=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c \
  "SELECT COUNT(*) FROM db_user_styles WHERE photo_url LIKE '%:9000%';")
echo "  Count: $COUNT_DIRECT"

echo -e "${YELLOW}Records with old bucket name 'style/' (not 'style-photos/'):${NC}"
COUNT_OLD_BUCKET=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c \
  "SELECT COUNT(*) FROM db_user_styles WHERE photo_url LIKE '%/style/%' AND photo_url NOT LIKE '%/style-photos/%';")
echo "  Count: $COUNT_OLD_BUCKET"

echo -e "${YELLOW}Records needing photo_urls migration (NULL or empty):${NC}"
COUNT_NEED_MIGRATION=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c \
  "SELECT COUNT(*) FROM db_user_styles WHERE (photo_urls IS NULL OR photo_urls = 'null'::jsonb OR photo_urls::text = '[]') AND photo_url IS NOT NULL AND photo_url != '';")
echo "  Count: $COUNT_NEED_MIGRATION"

echo -e "${YELLOW}Records already with relative URLs (/files/):${NC}"
COUNT_RELATIVE=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c \
  "SELECT COUNT(*) FROM db_user_styles WHERE photo_url LIKE '/files/%';")
echo "  Count: $COUNT_RELATIVE"

echo ""

# Show sample records
echo -e "${YELLOW}Sample of current photo_url values (first 5):${NC}"
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "SELECT id, LEFT(photo_url, 80) as photo_url_preview FROM db_user_styles LIMIT 5;"

echo ""
read -p "Continue with migration? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Migration cancelled${NC}"
    exit 0
fi

# Step 2: Fix photo_url column - convert to relative paths
echo ""
echo -e "${GREEN}Step 2: Converting absolute URLs to relative paths in photo_url...${NC}"

# Fix old server IP (51.250.84.195:9000) -> relative path, also fix bucket name
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "UPDATE db_user_styles 
   SET photo_url = REPLACE(
     REPLACE(photo_url, 'http://51.250.84.195:9000/style/', '/files/style-photos/'),
     'http://51.250.84.195:9000/', '/files/'
   )
   WHERE photo_url LIKE '%51.250.84.195%';"
echo "  ✓ Fixed old server IP (51.250.84.195)"

# Fix current server direct MinIO access (89.232.188.182:9000) -> relative path
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "UPDATE db_user_styles 
   SET photo_url = REPLACE(photo_url, 'http://89.232.188.182:9000/', '/files/')
   WHERE photo_url LIKE '%89.232.188.182:9000%';"
echo "  ✓ Fixed current server direct MinIO (89.232.188.182:9000)"

# Fix localhost URLs -> relative path
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "UPDATE db_user_styles 
   SET photo_url = REPLACE(photo_url, 'http://localhost:9000/', '/files/')
   WHERE photo_url LIKE '%localhost:9000%';"
echo "  ✓ Fixed localhost URLs"

# Fix any remaining http://SERVER/files/ to just /files/
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "UPDATE db_user_styles 
   SET photo_url = REGEXP_REPLACE(photo_url, '^https?://[^/]+/files/', '/files/')
   WHERE photo_url ~ '^https?://[^/]+/files/';"
echo "  ✓ Fixed any remaining absolute /files/ URLs"

# Step 3: Fix photo_urls JSONB column (if already populated)
echo ""
echo -e "${GREEN}Step 3: Fixing URLs in existing photo_urls JSONB...${NC}"

docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "UPDATE db_user_styles 
   SET photo_urls = (
     SELECT jsonb_agg(
       REGEXP_REPLACE(
         REGEXP_REPLACE(
           REGEXP_REPLACE(
             REGEXP_REPLACE(elem::text, '\"', '', 'g'),
             'http://51.250.84.195:9000/style/', '/files/style-photos/'
           ),
           'http://[^/]+:9000/', '/files/'
         ),
         '^https?://[^/]+/files/', '/files/'
       )
     )
     FROM jsonb_array_elements_text(photo_urls) AS elem
   )
   WHERE photo_urls IS NOT NULL 
     AND photo_urls != 'null'::jsonb 
     AND photo_urls::text != '[]'
     AND photo_urls::text LIKE '%http%';"
echo "  ✓ Fixed URLs in existing photo_urls JSONB"

# Step 4: Migrate photo_url to photo_urls for records that need it
echo ""
echo -e "${GREEN}Step 4: Migrating photo_url to photo_urls JSONB array...${NC}"

docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "UPDATE db_user_styles 
   SET photo_urls = jsonb_build_array(photo_url)
   WHERE (photo_urls IS NULL OR photo_urls = 'null'::jsonb OR photo_urls::text = '[]')
   AND photo_url IS NOT NULL 
   AND photo_url != '';"
echo "  ✓ Migrated photo_url to photo_urls"

# Step 5: Also fix db_styles table (PDF URLs)
echo ""
echo -e "${GREEN}Step 5: Fixing PDF URLs in db_styles table...${NC}"

docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "UPDATE db_styles 
   SET pdf_info_url = REGEXP_REPLACE(
     REGEXP_REPLACE(
       REGEXP_REPLACE(pdf_info_url, 'http://51.250.84.195:9000/', '/files/'),
       'http://[^/]+:9000/', '/files/'
     ),
     '^https?://[^/]+/files/', '/files/'
   )
   WHERE pdf_info_url LIKE 'http%';" 2>/dev/null || echo "  (db_styles table may not exist or have pdf_info_url column)"
echo "  ✓ Fixed PDF URLs"

# Step 6: Verification
echo ""
echo -e "${GREEN}Step 6: Verifying migration results...${NC}"
echo ""

echo -e "${YELLOW}Records still with absolute URLs:${NC}"
COUNT_STILL_ABSOLUTE=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c \
  "SELECT COUNT(*) FROM db_user_styles WHERE photo_url LIKE 'http%';")
echo "  Count: $COUNT_STILL_ABSOLUTE"

echo -e "${YELLOW}Records now with relative URLs (/files/):${NC}"
COUNT_NOW_RELATIVE=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c \
  "SELECT COUNT(*) FROM db_user_styles WHERE photo_url LIKE '/files/%';")
echo "  Count: $COUNT_NOW_RELATIVE"

echo -e "${YELLOW}Records with populated photo_urls:${NC}"
COUNT_POPULATED=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -c \
  "SELECT COUNT(*) FROM db_user_styles WHERE photo_urls IS NOT NULL AND photo_urls != 'null'::jsonb AND photo_urls::text != '[]';")
echo "  Count: $COUNT_POPULATED"

echo ""
echo -e "${YELLOW}Sample of migrated records (first 5):${NC}"
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -c \
  "SELECT id, photo_url, photo_urls FROM db_user_styles LIMIT 5;"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  Migration Complete!                       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "  1. Refresh the admin panel predictions page to see the images"
echo "  2. Ensure MINIO_FILE_PATH_ENDPOINT=/files in your .env"
echo "  3. Restart the backend service if you changed .env"
echo ""
