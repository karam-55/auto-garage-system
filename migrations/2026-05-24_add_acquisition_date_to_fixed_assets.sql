-- Add acquisition_date column to fixed_assets table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'fixed_assets' 
        AND column_name = 'acquisition_date'
    ) THEN
        ALTER TABLE fixed_assets ADD COLUMN acquisition_date DATE NOT NULL DEFAULT CURRENT_DATE;
    END IF;
END $$;
