-- Add inventory_item_id to part_suggestions table
-- Created: 2026-05-24
-- Updated for Supabase compatibility with DO $$ block

-- Add inventory_item_id column with foreign key to inventory_items
DO $$
BEGIN
  ALTER TABLE part_suggestions 
  ADD COLUMN IF NOT EXISTS inventory_item_id UUID REFERENCES inventory_items(id) ON DELETE SET NULL;
EXCEPTION
  WHEN duplicate_column THEN null;
END $$;

-- Add index for better performance on inventory_item_id lookups
CREATE INDEX IF NOT EXISTS idx_part_suggestions_inventory_item_id ON part_suggestions(inventory_item_id);
