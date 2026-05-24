-- Supabase Performance Diagnostic Script
-- Run this in Supabase SQL Editor to check performance

-- 1. Check if pg_stat_statements is enabled (should be enabled by default in Supabase)
SELECT 
    name,
    setting,
    unit,
    short_desc
FROM pg_settings
WHERE name = 'pg_stat_statements.track';

-- 2. Check current indexes on all tables
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- 3. Check table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 4. Check row counts for key tables
SELECT 
    'journal_entries' as table_name,
    COUNT(*) as row_count
FROM journal_entries
UNION ALL
SELECT 
    'journal_lines' as table_name,
    COUNT(*) as row_count
FROM journal_lines
UNION ALL
SELECT 
    'accounts' as table_name,
    COUNT(*) as row_count
FROM accounts
UNION ALL
SELECT 
    'bookings' as table_name,
    COUNT(*) as row_count
FROM bookings
UNION ALL
SELECT 
    'customers' as table_name,
    COUNT(*) as row_count
FROM customers;

-- 5. Check slow queries (if pg_stat_statements is enabled)
-- This shows the most time-consuming queries
SELECT 
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    max_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- 6. Test Trial Balance Query Performance
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT 
    a.id,
    a.code,
    a.name_ar,
    a.name_en,
    a.account_type,
    COALESCE(SUM(jl.debit), 0) as total_debit,
    COALESCE(SUM(jl.credit), 0) as total_credit
FROM accounts a
LEFT JOIN journal_lines jl ON a.id = jl.account_id
LEFT JOIN journal_entries je ON jl.entry_id = je.id
WHERE je.entry_date >= '2026-01-01' AND je.entry_date <= '2026-12-31'
GROUP BY a.id, a.code, a.name_ar, a.name_en, a.account_type
ORDER BY a.code;

-- 7. Test Profit/Loss Query Performance
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT 
    a.id,
    a.code,
    a.name_ar,
    a.name_en,
    a.account_type,
    CASE 
        WHEN a.account_type = 'revenue' THEN COALESCE(SUM(jl.credit - jl.debit), 0)
        WHEN a.account_type IN ('expense', 'cogs') THEN COALESCE(SUM(jl.debit - jl.credit), 0)
        ELSE 0
    END as balance
FROM accounts a
LEFT JOIN journal_lines jl ON a.id = jl.account_id
LEFT JOIN journal_entries je ON jl.entry_id = je.id
WHERE je.entry_date >= '2026-01-01' AND je.entry_date <= '2026-12-31'
    AND a.account_type IN ('revenue', 'expense', 'cogs')
GROUP BY a.id, a.code, a.name_ar, a.name_en, a.account_type
HAVING CASE 
    WHEN a.account_type = 'revenue' THEN COALESCE(SUM(jl.credit - jl.debit), 0)
    WHEN a.account_type IN ('expense', 'cogs') THEN COALESCE(SUM(jl.debit - jl.credit), 0)
    ELSE 0
END != 0
ORDER BY a.code;

-- 8. Check index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- 9. Check sequential scan statistics (high values may indicate missing indexes)
SELECT 
    schemaname,
    tablename,
    seq_scan as sequential_scans,
    seq_tup_read as tuples_read_seq,
    idx_scan as index_scans,
    idx_tup_fetch as tuples_fetched_idx
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY seq_scan DESC;

-- 10. Check connection pool settings
SELECT 
    name,
    setting,
    unit
FROM pg_settings
WHERE name IN ('max_connections', 'shared_buffers', 'effective_cache_size', 'work_mem');

-- 11. Check for missing indexes on foreign keys
SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
    AND NOT EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE schemaname = 'public'
            AND tablename = tc.table_name
            AND indexdef LIKE '%' || kcu.column_name || '%'
    );

-- 12. Check if composite indexes exist for common query patterns
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
    AND indexdef LIKE '%,%'
ORDER BY tablename, indexname;
