-- Add missing columns to manufacturing_orders table
ALTER TABLE manufacturing_orders 
ADD COLUMN IF NOT EXISTS start_date DATE,
ADD COLUMN IF NOT EXISTS expected_completion_date DATE,
ADD COLUMN IF NOT EXISTS actual_completion_date DATE;
