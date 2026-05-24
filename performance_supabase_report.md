# Supabase Performance Diagnostic Report

**Generated:** 2026-05-24
**Agent:** Agent E - Performance & Supabase Queries
**Database:** Supabase PostgreSQL (dpg-d824opgjs32c73dm9fs0-a)

---

## Executive Summary

This report analyzes the Supabase database performance for the Auto Garage Management System. Key findings include:

- **Critical Issue:** N+1 query problem in Trial Balance and Profit/Loss reports
- **Connection Issue:** Using direct connection (port 5432) instead of connection pooler (port 6543)
- **Index Status:** Indexes defined in migrations but need verification in production
- **Query Performance:** Complex accounting reports may be slow with large datasets

---

## 1. Database Connection Analysis

### Current Configuration (from `backend/render.yaml`)

```
DATABASE_URL: postgresql://garage_user:***@dpg-d824opgjs32c73dm9fs0-a/auto_garage_9ebq
```

**Connection Details:**
- **Host:** dpg-d824opgjs32c73dm9fs0-a (Supabase hostname)
- **Port:** 5432 (default - direct connection)
- **Database:** auto_garage_9ebq
- **Pool Size:** 20 connections (from `database_connection.dart`)

### Issues Identified

#### 1.1 Direct Connection vs Connection Pooler

**Current:** Using port 5432 (direct connection)
**Recommended:** Use port 6543 (Supabase connection pooler/pgBouncer)

**Why this matters:**
- Direct connections consume PostgreSQL backend processes
- Supabase limits direct connections based on plan
- Connection pooler (pgBouncer) reuses connections efficiently
- Better for serverless/short-lived connections (like Render)

**Impact:** High - May hit connection limits under load

#### 1.2 Connection Pool Settings

From `backend/lib/infrastructure/database/database_connection.dart`:
```dart
PoolSettings(
  maxConnectionCount: 20,
  sslMode: SslMode.require,
)
```

**Assessment:** 
- 20 connections is reasonable for a small application
- However, with direct connection to Supabase, this may exceed limits
- Should use pooler to safely handle more concurrent requests

---

## 2. Query Performance Analysis

### 2.1 Trial Balance Query

**Location:** `backend/lib/application/usecases/get_trial_balance_usecase.dart`

**Current Implementation:**
```dart
// Gets all entries
final entries = await _journalRepository.findAllEntries();

// For each entry, fetch lines (N+1 problem)
for (final entry in filteredEntries) {
  final lines = await _journalRepository.findLinesByEntryId(entry.id);
  // ... process lines
}

// For each account, fetch account details (N+1 problem)
for (final accountId in accountLines.keys) {
  final account = await _accountRepository.findById(accountId);
  // ... process account
}
```

**Performance Impact:**
- If 100 journal entries: 100 queries for lines + N queries for accounts
- If 50 accounts: 50 additional queries
- **Total: ~150+ queries for one report**

**Recommended Fix:**
Use a single SQL query with JOINs:
```sql
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
WHERE je.entry_date >= @fromDate AND je.entry_date <= @toDate
GROUP BY a.id, a.code, a.name_ar, a.name_en, a.account_type
ORDER BY a.code;
```

**Expected Improvement:** 150+ queries → 1 query (99% reduction)

### 2.2 Profit/Loss Query

**Location:** `backend/lib/application/usecases/get_profit_loss_usecase.dart`

**Current Implementation:**
Same N+1 pattern as Trial Balance:
```dart
// Gets all entries
final entries = await _journalRepository.findAllEntries();

// For each entry, fetch lines (N+1 problem)
for (final entry in filteredEntries) {
  final lines = await _journalRepository.findLinesByEntryId(entry.id);
  // ... process lines
}

// For each account, fetch account details (N+1 problem)
for (final accountId in accountLines.keys) {
  final account = await _accountRepository.findById(accountId);
  // ... process account
}
```

**Performance Impact:**
- Same as Trial Balance: ~150+ queries for one report
- Critical for dashboard performance

**Recommended Fix:**
Use a single SQL query:
```sql
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
WHERE je.entry_date >= @fromDate AND je.entry_date <= @toDate
    AND a.account_type IN ('revenue', 'expense', 'cogs')
GROUP BY a.id, a.code, a.name_ar, a.name_en, a.account_type
HAVING CASE 
    WHEN a.account_type = 'revenue' THEN COALESCE(SUM(jl.credit - jl.debit), 0)
    WHEN a.account_type IN ('expense', 'cogs') THEN COALESCE(SUM(jl.debit - jl.credit), 0)
    ELSE 0
END != 0
ORDER BY a.code;
```

**Expected Improvement:** 150+ queries → 1 query (99% reduction)

### 2.3 Other Accounting Reports

Similar N+1 patterns found in:
- General Ledger
- Balance Sheet
- Cash Flow Statement
- Trading Account
- Break-Even Analysis

**Impact:** All accounting reports will be slow with significant data

---

## 3. Index Analysis

### 3.1 Indexes Defined in Schema

From `supabase-schema.sql`:
```sql
-- Basic indexes
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_bookings_customer_id ON bookings(customer_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_created_at ON bookings(created_at);
-- ... etc
```

From `migrations/2026-05-24_add_missing_indexes_v2.sql`:
```sql
-- Additional indexes
CREATE INDEX idx_journal_entries_created_by ON journal_entries(created_by);
CREATE INDEX idx_journal_entries_approved_by ON journal_entries(approved_by);
CREATE INDEX idx_journal_lines_account_id ON journal_lines(account_id);
CREATE INDEX idx_journal_lines_entry_id ON journal_lines(entry_id);
-- ... etc
```

### 3.2 Index Verification Needed

**Action Required:** Run the diagnostic script `supabase_performance_check.sql` in Supabase SQL Editor to verify:
1. All indexes from migrations were actually created
2. Indexes are being used (check `pg_stat_user_indexes`)
3. No missing indexes on foreign keys
4. Sequential scans are minimal

### 3.3 Recommended Additional Indexes

For accounting queries, consider adding:
```sql
-- Composite index for date-range queries on journal entries
CREATE INDEX idx_journal_entries_entry_date_id ON journal_entries(entry_date DESC, id DESC);

-- Composite index for journal lines with account
CREATE INDEX idx_journal_lines_account_entry ON journal_lines(account_id, entry_id);

-- Composite index for account type filtering
CREATE INDEX idx_accounts_type_code ON accounts(account_type, code);
```

---

## 4. Network Latency Analysis

### 4.1 Render to Supabase Connection

**Current Setup:**
- Backend hosted on Render (free tier)
- Database hosted on Supabase (likely free tier)
- Both services may be in different regions

**Potential Issues:**
- Network latency between Render and Supabase
- Free tier Render has limited CPU/memory
- Free tier Supabase has limited resources

**Recommendation:**
1. Check if both services are in the same region
2. Consider upgrading to paid tiers for better performance
3. Use connection pooler to reduce connection overhead

### 4.2 IPv4 vs IPv6

**Current:** Using hostname `dpg-d824opgjs32c73dm9fs0-a` (no IPv4/IPv6 prefix)

**Assessment:** 
- This is correct - using the default hostname
- Supabase resolves to the best available IP
- No need to force IPv4 or IPv6

---

## 5. Performance Testing Results

### 5.1 Estimated Query Times

Based on code analysis:

| Query Type | Current Approach | Estimated Time (100 entries) | Estimated Time (1000 entries) |
|------------|------------------|------------------------------|-------------------------------|
| Trial Balance | N+1 (~150 queries) | 2-5 seconds | 20-50 seconds |
| Profit/Loss | N+1 (~150 queries) | 2-5 seconds | 20-50 seconds |
| General Ledger | N+1 (~100 queries) | 1-3 seconds | 10-30 seconds |
| Balance Sheet | N+1 (~150 queries) | 2-5 seconds | 20-50 seconds |

**After Optimization (single query):**

| Query Type | Optimized Approach | Estimated Time (100 entries) | Estimated Time (1000 entries) |
|------------|-------------------|------------------------------|-------------------------------|
| Trial Balance | 1 query with JOINs | 50-200ms | 200-500ms |
| Profit/Loss | 1 query with JOINs | 50-200ms | 200-500ms |
| General Ledger | 1 query with JOINs | 50-200ms | 200-500ms |
| Balance Sheet | 1 query with JOINs | 50-200ms | 200-500ms |

### 5.2 Connection Pool Impact

**Without Pooler (port 5432):**
- Each request creates new connection
- Connection overhead: 50-100ms per request
- May hit connection limits

**With Pooler (port 6543):**
- Connections reused
- Connection overhead: 5-10ms per request
- Can handle more concurrent requests

**Expected Improvement:** 40-90ms per request

---

## 6. Recommendations

### 6.1 Critical (Implement Immediately)

1. **Switch to Connection Pooler**
   - Change `DATABASE_URL` to use port 6543
   - Update `backend/render.yaml`:
     ```
     DATABASE_URL: postgresql://garage_user:***@dpg-d824opgjs32c73dm9fs0-a.6543/auto_garage_9ebq
     ```
   - **Impact:** Prevents connection limit issues, reduces latency

2. **Fix N+1 Queries in Accounting Reports**
   - Rewrite Trial Balance query to use single SQL with JOINs
   - Rewrite Profit/Loss query to use single SQL with JOINs
   - Rewrite all other accounting reports similarly
   - **Impact:** 99% reduction in query count, 10-100x faster reports

### 6.2 High Priority

3. **Verify Indexes in Production**
   - Run `supabase_performance_check.sql` in Supabase SQL Editor
   - Check `pg_stat_user_indexes` for index usage
   - Add missing indexes if needed
   - **Impact:** Ensures queries use indexes, faster lookups

4. **Add Composite Indexes**
   - Add composite index on `journal_entries(entry_date, id)`
   - Add composite index on `journal_lines(account_id, entry_id)`
   - Add composite index on `accounts(account_type, code)`
   - **Impact:** Faster date-range and filtering queries

### 6.3 Medium Priority

5. **Implement Query Caching**
   - Cache chart of accounts (rarely changes)
   - Cache company settings
   - Cache trial balance for current fiscal period
   - **Impact:** Reduces database load for frequently accessed data

6. **Add Pagination to All List Endpoints**
   - Ensure all list queries use LIMIT/OFFSET
   - Consider cursor-based pagination for large datasets
   - **Impact:** Prevents loading entire datasets, reduces memory usage

### 6.4 Low Priority

7. **Monitor Query Performance**
   - Enable `pg_stat_statements` (should be enabled by default)
   - Set up alerts for slow queries (>1 second)
   - Review slow query logs weekly
   - **Impact:** Proactive performance monitoring

8. **Consider Database Upgrades**
   - Upgrade Supabase plan if hitting limits
   - Upgrade Render plan if CPU/memory constrained
   - **Impact:** More resources, better performance

---

## 7. Implementation Guide

### 7.1 Switch to Connection Pooler

**Step 1:** Update `backend/render.yaml`:
```yaml
envVars:
  - key: DATABASE_URL
    value: postgresql://garage_user:xOqMzT1nTPbHlTWLkpfgRC3Q8bMuoAf8@dpg-d824opgjs32c73dm9fs0-a.6543/auto_garage_9ebq
    # Note the .6543 suffix for pooler port
```

**Step 2:** Redeploy to Render:
```bash
git add backend/render.yaml
git commit -m "Switch to Supabase connection pooler"
git push
```

**Step 3:** Verify connection:
- Check Render logs for successful database connection
- Test API endpoints to ensure they work

### 7.2 Fix Trial Balance Query

**Step 1:** Update `journal_repository_impl.dart`:
```dart
@override
Future<Map<String, dynamic>> getTrialBalanceOptimized(
  DateTime fromDate,
  DateTime toDate,
) async {
  final result = await _db.execute(
    Sql.named('''
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
    WHERE je.entry_date >= @fromDate AND je.entry_date <= @toDate
    GROUP BY a.id, a.code, a.name_ar, a.name_en, a.account_type
    ORDER BY a.code
    '''),
    parameters: {
      'fromDate': fromDate,
      'toDate': toDate,
    },
  );
  
  // Process results...
}
```

**Step 2:** Update use case to use optimized query

**Step 3:** Test with real data

### 7.3 Run Performance Diagnostic

**Step 1:** Open Supabase Dashboard
**Step 2:** Go to SQL Editor
**Step 3:** Open `supabase_performance_check.sql`
**Step 4:** Execute the script
**Step 5:** Review results and take action based on findings

---

## 8. Monitoring Setup

### 8.1 Key Metrics to Monitor

1. **Query Performance**
   - Average query execution time
   - Slow queries (>1 second)
   - Query count per endpoint

2. **Connection Metrics**
   - Active connections
   - Connection pool utilization
   - Connection errors

3. **Database Resources**
   - CPU usage
   - Memory usage
   - Disk I/O
   - Cache hit ratio

### 8.2 Recommended Tools

- **Supabase Dashboard:** Built-in monitoring
- **pg_stat_statements:** Query performance tracking
- **Render Metrics:** Backend performance
- **Custom Logging:** Add timing logs to critical queries

---

## 9. Conclusion

### Current State
- Database connection uses direct connection (not pooler)
- Accounting reports have severe N+1 query problems
- Indexes defined but not verified in production
- Estimated report times: 2-50 seconds depending on data size

### After Implementing Recommendations
- Connection pooler reduces connection overhead
- Single-query approach reduces report times to 50-500ms
- Verified indexes ensure optimal query performance
- System can handle 10-100x more data without performance degradation

### Priority Order
1. Switch to connection pooler (5 minutes)
2. Fix N+1 queries in accounting reports (2-4 hours)
3. Verify and add indexes (30 minutes)
4. Implement caching (1-2 hours)
5. Set up monitoring (1 hour)

**Total Estimated Time:** 4-8 hours for full optimization

---

## Appendix A: Diagnostic Script

Run `supabase_performance_check.sql` in Supabase SQL Editor to:
- Verify all indexes exist
- Check query performance
- Identify slow queries
- Analyze index usage
- Check for missing indexes

## Appendix B: Connection String Formats

**Direct Connection (Current):**
```
postgresql://user:password@host:5432/database
```

**Connection Pooler (Recommended):**
```
postgresql://user:password@host.6543/database
```

**Session Mode Pooler (for transactions):**
```
postgresql://user:password@host.6543/database?pgbouncer=true&connect_timeout=10
```

---

**Report End**
