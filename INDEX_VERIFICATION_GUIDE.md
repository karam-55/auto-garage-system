# Database Index Verification Guide

## Overview

This guide explains how to verify and maintain database indexes in Supabase for optimal query performance in the Auto Garage Management System.

## Running the Index Verification Script

### Step 1: Locate the Script

The verification script is located at:
```
scripts/supabase_index_verification.sql
```

### Step 2: Open Supabase SQL Editor

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor: https://app.supabase.com/project/_/sql
3. Click "New Query" to open a new query window

### Step 3: Execute the Script

1. Open the `scripts/supabase_index_verification.sql` file in your code editor
2. Copy the entire content of the file
3. Paste it into the Supabase SQL Editor
4. Click "Run" to execute the script

## What the Script Checks

The script performs three main checks:

### 1. Main Table Indexes

Queries all indexes on the core tables:
- `customers`
- `vehicles`
- `services`
- `bookings`
- `journal_entries`
- `journal_lines`
- `accounts`

**Output columns:**
- `schemaname` - Schema name (usually 'public')
- `tablename` - Table name
- `indexname` - Index name
- `indexdef` - Index definition (CREATE INDEX statement)

### 2. Foreign Key Index Status

Identifies foreign key columns and checks if they have indexes.

**Output columns:**
- `table_name` - Table containing the foreign key
- `column_name` - Foreign key column name
- `foreign_table_name` - Referenced table
- `foreign_column_name` - Referenced column
- `index_status` - "INDEXED" or "NOT INDEXED"

### 3. Index Sizes

Shows the size of each index to identify large indexes that might impact performance.

**Output columns:**
- `schemaname` - Schema name
- `tablename` - Table name
- `indexname` - Index name
- `index_size` - Human-readable size (e.g., "8192 bytes", "16 MB")

## Understanding the Results

### Primary Key Indexes

Every table should have a primary key index (automatically created on the `id` column). These are essential for:
- Fast lookups by ID
- Foreign key relationships
- Data integrity

### Foreign Key Indexes

Foreign key columns should have indexes to improve JOIN performance. Common foreign keys in this system:
- `bookings.customer_id` → `customers.id`
- `vehicles.customer_id` → `customers.id`
- `journal_lines.journal_entry_id` → `journal_entries.id`
- `journal_lines.account_id` → `accounts.id`

**If you see "NOT INDEXED" for foreign keys, consider adding indexes.**

### Query Performance Indexes

Columns frequently used in WHERE clauses, ORDER BY, or JOIN conditions should have indexes:
- `bookings.status` - Filtering by booking status
- `bookings.created_at` - Date range queries
- `vehicles.license_plate` - Looking up vehicles by plate
- `journal_entries.entry_date` - Financial reporting by date

### Composite Indexes

For queries that filter on multiple columns, composite indexes can significantly improve performance:
- `bookings(status, created_at)` - Filter by status and sort by date
- `journal_entries(fiscal_period_id, entry_date)` - Financial period queries

## Expected Indexes

### customers Table
- `customers_pkey` (PRIMARY KEY on `id`)
- `idx_customers_email` (on `email`)
- `idx_customers_phone` (on `phone`)

### vehicles Table
- `vehicles_pkey` (PRIMARY KEY on `id`)
- `idx_vehicles_customer_id` (on `customer_id`)
- `idx_vehicles_license_plate` (on `license_plate`)

### services Table
- `services_pkey` (PRIMARY KEY on `id`)
- `idx_services_is_active` (on `is_active`)

### bookings Table
- `bookings_pkey` (PRIMARY KEY on `id`)
- `idx_bookings_customer_id` (on `customer_id`)
- `idx_bookings_status` (on `status`)
- `idx_bookings_created_at` (on `created_at`)
- `idx_bookings_status_created` (composite on `status, created_at`)

### journal_entries Table
- `journal_entries_pkey` (PRIMARY KEY on `id`)
- `idx_journal_entries_entry_date` (on `entry_date`)
- `idx_journal_entries_fiscal_period_id` (on `fiscal_period_id`)

### journal_lines Table
- `journal_lines_pkey` (PRIMARY KEY on `id`)
- `idx_journal_lines_journal_entry_id` (on `journal_entry_id`)
- `idx_journal_lines_account_id` (on `account_id`)

### accounts Table
- `accounts_pkey` (PRIMARY KEY on `id`)
- `idx_accounts_account_code` (on `account_code`)

## Adding Missing Indexes

If the verification script shows missing indexes, you can add them using the following patterns:

### Single Column Index

```sql
CREATE INDEX idx_table_name_column_name ON table_name(column_name);
```

**Example:**
```sql
CREATE INDEX idx_bookings_customer_id ON bookings(customer_id);
```

### Composite Index

```sql
CREATE INDEX idx_table_name_column1_column2 ON table_name(column1, column2);
```

**Example:**
```sql
CREATE INDEX idx_bookings_status_created ON bookings(status, created_at);
```

### Unique Index (for columns that should be unique)

```sql
CREATE UNIQUE INDEX idx_table_name_column_name ON table_name(column_name);
```

**Example:**
```sql
CREATE UNIQUE INDEX idx_vehicles_license_plate ON vehicles(license_plate);
```

## When to Run Verification

Run the index verification script:

1. **After schema changes** - When you add new tables or columns
2. **Performance issues** - When you notice slow queries
3. **Regular maintenance** - Monthly or quarterly as part of database maintenance
4. **Before deployment** - Before deploying to production

## Performance Impact

### Benefits of Proper Indexing

- **Faster queries** - Indexes can speed up queries by 10-100x
- **Reduced load** - Less CPU and memory usage for query execution
- **Better user experience** - Faster page loads and API responses

### Trade-offs

- **Storage** - Indexes consume disk space
- **Write performance** - Indexes slow down INSERT/UPDATE/DELETE operations
- **Maintenance** - Indexes need to be updated as data changes

**Best practice:** Index columns that are frequently queried but rarely updated.

## Removing Unused Indexes

If you identify indexes that are never used, you can remove them to save space and improve write performance:

```sql
DROP INDEX IF EXISTS index_name;
```

**Example:**
```sql
DROP INDEX IF EXISTS idx_customers_unused_column;
```

## Monitoring Index Usage

To check which indexes are actually being used, run this query in Supabase:

```sql
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE tablename IN (
    'customers',
    'vehicles',
    'services',
    'bookings',
    'journal_entries',
    'journal_lines',
    'accounts'
)
ORDER BY idx_scan DESC;
```

- `index_scans` - Number of times the index was used
- `tuples_read` - Number of index entries read
- `tuples_fetched` - Number of table rows fetched using the index

Indexes with zero or very low scan counts might be candidates for removal.

## Troubleshooting

### Query Still Slow After Adding Index

1. **Check if the query is using the index:**
   ```sql
   EXPLAIN ANALYZE your_query_here;
   ```

2. **Verify the index matches the query:**
   - Index on `status` won't help if query filters on `created_at`
   - Composite index order matters: `idx(a, b)` helps queries on `a` or `a AND b`, but not `b` alone

3. **Consider ANALYZE:**
   ```sql
   ANALYZE table_name;
   ```
   This updates statistics to help the query planner choose better execution plans.

### Index Not Being Used

1. **Table is too small** - PostgreSQL may prefer sequential scans for small tables
2. **Selectivity is too low** - If a column has few distinct values, a full table scan might be faster
3. **Index doesn't match query pattern** - Ensure the index matches your WHERE, JOIN, and ORDER BY clauses

## Additional Resources

- [PostgreSQL Index Documentation](https://www.postgresql.org/docs/current/indexes.html)
- [Supabase Database Performance](https://supabase.com/docs/guides/database/performance)
- [EXPLAIN ANALYZE Guide](https://www.postgresql.org/docs/current/using-explain.html)

## Summary

Regular index verification is essential for maintaining optimal database performance. Use the provided script to:
1. Check existing indexes on core tables
2. Identify missing foreign key indexes
3. Monitor index sizes
4. Add missing indexes as needed
5. Remove unused indexes to optimize storage and write performance

This proactive approach ensures your Auto Garage Management System remains fast and responsive as it grows.
