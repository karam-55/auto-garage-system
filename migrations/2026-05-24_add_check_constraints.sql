-- Add check constraints for data validation
-- Created: 2026-05-24

-- Ensure fiscal period start date is before end date
ALTER TABLE fiscal_periods ADD CONSTRAINT check_dates CHECK (start_date < end_date);

-- Ensure quotation validity date is after quotation date
ALTER TABLE quotations ADD CONSTRAINT check_validity CHECK (valid_until > quotation_date);

-- Ensure leave request start date is before end date
ALTER TABLE leave_requests ADD CONSTRAINT check_dates CHECK (start_date < end_date);
