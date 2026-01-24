-- Migration: Upgrade from main to auto_ml_service branch
-- Description: Add ML-related fields to db_user_styles table
-- Date: 2025-11-10

BEGIN;

-- Add new columns to db_user_styles table
ALTER TABLE db_user_styles 
    ADD COLUMN IF NOT EXISTS photo_urls JSONB,
    ADD COLUMN IF NOT EXISTS initial_prediction VARCHAR(64),
    ADD COLUMN IF NOT EXISTS confidence FLOAT8 DEFAULT 0,
    ADD COLUMN IF NOT EXISTS is_verified BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS verified_by INT,
    ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP;

-- Add foreign key constraint for verified_by
ALTER TABLE db_user_styles 
    ADD CONSTRAINT fk_db_user_styles_verified_by 
    FOREIGN KEY (verified_by) 
    REFERENCES db_admin_users(id) 
    ON DELETE SET NULL;

-- Create index on is_verified for faster queries
CREATE INDEX IF NOT EXISTS idx_db_user_styles_is_verified ON db_user_styles(is_verified);

-- Create index on verified_by for faster queries
CREATE INDEX IF NOT EXISTS idx_db_user_styles_verified_by ON db_user_styles(verified_by);

-- Optional: Migrate existing data
-- Set initial_prediction to style_id for existing records (assuming they were correct)
UPDATE db_user_styles 
SET initial_prediction = style_id 
WHERE initial_prediction IS NULL;

-- Set confidence to 1.0 for existing records (assuming they were manually verified)
UPDATE db_user_styles 
SET confidence = 1.0 
WHERE confidence = 0 OR confidence IS NULL;

COMMIT;

