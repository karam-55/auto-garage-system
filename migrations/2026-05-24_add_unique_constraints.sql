-- Add unique constraints for data integrity
-- Created: 2026-05-24

-- Ensure license plates are unique
ALTER TABLE vehicles ADD CONSTRAINT unique_license_plate UNIQUE (license_plate);

-- Ensure VIN numbers are unique
ALTER TABLE vehicles ADD CONSTRAINT unique_vin UNIQUE (vin);

-- Ensure invoice numbers are unique
ALTER TABLE purchase_invoices ADD CONSTRAINT unique_invoice_number UNIQUE (invoice_number);

-- Ensure salary payments are unique per user per month
ALTER TABLE salary_payments ADD CONSTRAINT unique_user_month UNIQUE (user_id, month_year);

-- Ensure inventory variants are unique per item
ALTER TABLE inventory_variants ADD CONSTRAINT unique_item_variant UNIQUE (item_id, variant_type);
