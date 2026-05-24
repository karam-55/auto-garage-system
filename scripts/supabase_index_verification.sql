-- ============================================================================
-- Supabase Index Verification Script
-- ============================================================================
-- Purpose: This script checks all indexes on the main database tables to
--          ensure they are properly configured for optimal query performance.
--
-- How to Run:
-- 1. Open Supabase SQL Editor (https://app.supabase.com/project/_/sql)
-- 2. Copy and paste this entire script
-- 3. Click "Run" to execute
--
-- What to Look For:
-- - Each table should have at least a primary key index (automatically created)
-- - Foreign key columns should have indexes (e.g., customer_id, vehicle_id)
-- - Frequently queried columns should have indexes (e.g., status, created_at)
-- - Composite indexes for common query patterns (e.g., status + created_at)
--
-- Expected Results:
-- - customers: Index on id (PK), possibly on email, phone
-- - vehicles: Index on id (PK), customer_id (FK), license_plate
-- - services: Index on id (PK), possibly on category
-- - bookings: Index on id (PK), customer_id (FK), status, created_at
-- - journal_entries: Index on id (PK), entry_date, fiscal_period_id
-- - journal_lines: Index on id (PK), journal_entry_id (FK), account_id
-- - accounts: Index on id (PK), account_code
-- ============================================================================

SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename IN (
    'customers',
    'vehicles',
    'services',
    'bookings',
    'journal_entries',
    'journal_lines',
    'accounts'
)
ORDER BY tablename, indexname;

-- ============================================================================
-- Additional Query: Check for Missing Indexes on Foreign Keys
-- ============================================================================
-- This query identifies foreign key columns that might benefit from indexes
-- ============================================================================

SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    CASE 
        WHEN i.indexname IS NOT NULL THEN 'INDEXED'
        ELSE 'NOT INDEXED'
    END AS index_status
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
LEFT JOIN pg_indexes i
    ON i.tablename = tc.table_name
    AND i.indexdef LIKE '%' || kcu.column_name || '%'
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name IN (
        'customers',
        'vehicles',
        'services',
        'bookings',
        'journal_entries',
        'journal_lines',
        'accounts'
    )
ORDER BY tc.table_name, kcu.column_name;

-- ============================================================================
-- Additional Query: Check Index Sizes
-- ============================================================================
-- This query shows the size of each index to identify large indexes
-- ============================================================================

SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_indexes 
WHERE tablename IN (
    'customers',
    'vehicles',
    'services',
    'bookings',
    'journal_entries',
    'journal_lines',
    'accounts'
)
ORDER BY pg_relation_size(indexrelid) DESC;
