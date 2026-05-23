-- Add unique constraints for data integrity
-- Created: 2026-05-24
-- Updated for Supabase compatibility with DO $$ blocks

-- Ensure license plates are unique
DO $$
BEGIN
  ALTER TABLE vehicles ADD CONSTRAINT unique_license_plate UNIQUE (license_plate);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Ensure VIN numbers are unique
DO $$
BEGIN
  ALTER TABLE vehicles ADD CONSTRAINT unique_vin UNIQUE (vin);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Ensure invoice numbers are unique
DO $$
BEGIN
  ALTER TABLE purchase_invoices ADD CONSTRAINT unique_invoice_number UNIQUE (invoice_number);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Ensure salary payments are unique per user per month
DO $$
BEGIN
  ALTER TABLE salary_payments ADD CONSTRAINT unique_user_month UNIQUE (user_id, month_year);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Ensure inventory variants are unique per item
DO $$
BEGIN
  ALTER TABLE inventory_variants ADD CONSTRAINT unique_item_variant UNIQUE (item_id, variant_type);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
