-- Add check constraints for data validation
-- Created: 2026-05-24
-- Updated for Supabase compatibility with DO $$ blocks

-- Ensure fiscal period start date is before end date
DO $$
BEGIN
  ALTER TABLE fiscal_periods ADD CONSTRAINT check_dates CHECK (start_date < end_date);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Ensure quotation validity date is after quotation date
DO $$
BEGIN
  ALTER TABLE quotations ADD CONSTRAINT check_validity CHECK (valid_until > quotation_date);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Ensure leave request start date is before end date
DO $$
BEGIN
  ALTER TABLE leave_requests ADD CONSTRAINT check_dates CHECK (start_date < end_date);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
