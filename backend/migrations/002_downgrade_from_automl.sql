-- Migration: Downgrade from auto_ml_service to main branch
-- Description: Remove ML-related fields from db_user_styles table
-- Date: 2025-11-10
-- WARNING: This will drop columns and lose data!

BEGIN;

-- Drop indexes first
DROP INDEX IF EXISTS idx_db_user_styles_is_verified;
DROP INDEX IF EXISTS idx_db_user_styles_verified_by;

-- Drop foreign key constraint
ALTER TABLE db_user_styles 
    DROP CONSTRAINT IF EXISTS fk_db_user_styles_verified_by;

-- Drop new columns (data will be lost!)
ALTER TABLE db_user_styles 
    DROP COLUMN IF EXISTS photo_urls,
    DROP COLUMN IF EXISTS initial_prediction,
    DROP COLUMN IF EXISTS confidence,
    DROP COLUMN IF EXISTS is_verified,
    DROP COLUMN IF EXISTS verified_by,
    DROP COLUMN IF EXISTS verified_at;

COMMIT;

