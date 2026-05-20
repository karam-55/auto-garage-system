-- Migration: Add CHECK constraint to journal_lines table
-- Description: Ensures that debit and credit cannot both be non-zero in the same line
--              (Double-entry accounting principle: each line must have either debit OR credit, not both)
-- Date: 2025-01-18

-- Add CHECK constraint to ensure debit OR credit (not both)
ALTER TABLE journal_lines 
ADD CONSTRAINT check_debit_or_credit 
CHECK (debit = 0 OR credit = 0);

-- Note: This constraint ensures data integrity in double-entry accounting
-- If the constraint already exists, this will fail gracefully in production
