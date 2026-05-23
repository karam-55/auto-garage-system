# Deployment Checklist - Garage Go
**التاريخ:** 2026-05-24
**الإصدار:** Supabase Database + Render Backend + Cloudflare Frontend

---

## 🏗️ البنية الحالية

### Database: Supabase (PostgreSQL 15)
- **الموقع:** Supabase Cloud
- **المزايا:** قاعدة بيانات دائمة، لا تُحذف تلقائياً ✅
- **الجداول:** 30+ جدول (Core + Accounting + Inventory + ERP + HR + CRM)

### Backend: Render (Dart + Shelf)
- **الموقع:** Render Web Service
- **Database URL:** Supabase connection string
- **Environment Variables:** CORS_ORIGINS, JWT_SECRET, etc.

### Frontend: Cloudflare Pages
- **Admin Frontend:** Flutter Web (staff dashboard)
- **Customer Frontend:** Static HTML/JS (public tracking)

---

## ✅ خطوات النشر (Deployment Steps)

### 1. إعداد Database في Supabase

#### الخطوة 1.1: إنشاء Schema
1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. اختر مشروعك
3. اذهب إلى SQL Editor
4. انسخ محتوى `schema_supabase_simple.sql`
5. الصقه في SQL Editor
6. اضغط "Run" لإنشاء جميع الجداول

#### الخطوة 1.2: تشغيل Migrations
بعد إنشاء الجداول، شغّل ملفات الـ migration الثلاثة بالترتيب:

**الملف 1:** `migrations/2026-05-24_add_missing_indexes.sql`
```sql
CREATE INDEX IF NOT EXISTS idx_customers_full_name ON customers(full_name);
CREATE INDEX IF NOT EXISTS idx_services_name ON services(name);
CREATE INDEX IF NOT EXISTS idx_accounts_account_type ON accounts(account_type);
CREATE INDEX IF NOT EXISTS idx_accounts_parent_id ON accounts(parent_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_created_by ON journal_entries(created_by);
CREATE INDEX IF NOT EXISTS idx_journal_entries_approved_by ON journal_entries(approved_by);
CREATE INDEX IF NOT EXISTS idx_part_suggestions_mechanic_user_id ON part_suggestions(mechanic_user_id);
CREATE INDEX IF NOT EXISTS idx_part_suggestions_created_at ON part_suggestions(created_at);
CREATE INDEX IF NOT EXISTS idx_inventory_items_name ON inventory_items(name);
CREATE INDEX IF NOT EXISTS idx_vendors_name ON vendors(name);
CREATE INDEX IF NOT EXISTS idx_bookings_estimated_completion_date ON bookings(estimated_completion_date);
CREATE INDEX IF NOT EXISTS idx_bookings_notes ON bookings(notes);
CREATE INDEX IF NOT EXISTS idx_journal_lines_account_id ON journal_lines(account_id);
CREATE INDEX IF NOT EXISTS idx_journal_lines_journal_entry_id ON journal_lines(journal_entry_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_item_id ON inventory_transactions(item_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_created_at ON inventory_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_vendor_id ON purchase_orders(vendor_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_status ON purchase_orders(status);
CREATE INDEX IF NOT EXISTS idx_sales_orders_customer_id ON sales_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_quotations_customer_id ON quotations(customer_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_user_id ON leave_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_status ON leave_requests(status);
CREATE INDEX IF NOT EXISTS idx_crm_leads_status ON crm_leads(status);
CREATE INDEX IF NOT EXISTS idx_crm_leads_assigned_to ON crm_leads(assigned_to);
```

**الملف 2:** `migrations/2026-05-24_add_unique_constraints.sql`
```sql
DO $$
BEGIN
  ALTER TABLE vehicles ADD CONSTRAINT unique_license_plate UNIQUE (license_plate);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$
BEGIN
  ALTER TABLE vehicles ADD CONSTRAINT unique_vin UNIQUE (vin);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$
BEGIN
  ALTER TABLE purchase_invoices ADD CONSTRAINT unique_invoice_number UNIQUE (invoice_number);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$
BEGIN
  ALTER TABLE salary_payments ADD CONSTRAINT unique_user_month UNIQUE (user_id, month_year);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$
BEGIN
  ALTER TABLE inventory_variants ADD CONSTRAINT unique_item_variant UNIQUE (item_id, variant_type);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
```

**الملف 3:** `migrations/2026-05-24_add_check_constraints.sql`
```sql
DO $$
BEGIN
  ALTER TABLE fiscal_periods ADD CONSTRAINT check_dates CHECK (start_date < end_date);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$
BEGIN
  ALTER TABLE quotations ADD CONSTRAINT check_validity CHECK (valid_until > quotation_date);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$
BEGIN
  ALTER TABLE leave_requests ADD CONSTRAINT check_dates CHECK (start_date < end_date);
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
```

#### الخطوة 1.3: الحصول على Connection String
1. في Supabase Dashboard، اذهب إلى Settings → Database
2. انسخ "Connection string" (URI format)
3. الصيغة: `postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres`

---

### 2. إعداد Backend في Render

#### الخطوة 2.1: تحديث Environment Variables
اذهب إلى Backend Service في Render → Environment Variables وأضف/حدّث المتغيرات التالية:

| Key | Value | مطلوب؟ |
|-----|-------|--------|
| `DATABASE_URL` | Supabase connection string (من الخطوة 1.3) | ✅ نعم |
| `CORS_ORIGINS` | `https://auto-garage-staff-frontend.pages.dev,https://auto-garage-customer-frontend.pages.dev` | ✅ نعم |
| `JWT_SECRET` | قيمة عشوائية قوية (min 32 chars) | ✅ نعم |
| `PORT` | `8080` | ✅ نعم |

**ملاحظة:** في `CORS_ORIGINS`، افصل بين الـ domains بفاصلة `,` بدون مسافات.

#### الخطوة 2.2: Redeploy Backend
1. اذهب إلى Backend Service في Render
2. اضغط "Manual Deploy" → "Deploy latest commit"
3. راقب logs للتأكد من نجاح الاتصال بقاعدة البيانات

---

### 3. إعداد Frontend في Cloudflare Pages

#### الخطوة 3.1: تحديث Backend URL
في `admin_frontend/lib/core/services/api_service.dart`:
```dart
static const String baseUrl = 'https://auto-garage-system-backend.onrender.com';
```

#### الخطوة 3.2: Rebuild Frontend
1. ادفع التغييرات إلى GitHub
2. Cloudflare Pages سيقوم بـ rebuild تلقائياً
3. راقب build logs للتأكد من نجاح البناء

---

## ✅ بعد النشر

### التحقق من النجاح
1. **Database:** تحقق من وجود جميع الجداول في Supabase Table Editor
2. **Backend:** اختبر https://auto-garage-system-backend.onrender.com/api/dashboard/stats
3. **Admin Frontend:** اختبر تسجيل الدخول
4. **Customer Frontend:** اختبر تتبع الحجز

### اختبار الاتصال
```bash
# اختبار Backend API
curl https://auto-garage-system-backend.onrender.com/api/dashboard/stats

# اختبار Database connection (من Render logs)
# ابحث عن: "Database connection established"
```

---

## 📊 ملخص التغييرات

### Database (Supabase)
- ✅ 30+ جدول (Core + Accounting + Inventory + ERP + HR + CRM)
- ✅ 50+ فهرس للـ performance
- ✅ 5 UNIQUE constraints
- ✅ 3 CHECK constraints
- ✅ جميع الـ constraints مُعرّفة inline (بدون ALTER TABLE)
- ✅ DO $$ blocks لمعالجة الأخطاء

### Backend (Render)
- ✅ Security middlewares (Rate Limit, CORS, CSRF, Sanitizer)
- ✅ Password validation محسّن (8 chars min, 3 of 4 categories)
- ✅ إصلاح N+1 query في journal_service.dart
- ✅ Cache infrastructure (InMemoryCache)
- ✅ Batch endpoint لـ invoices
- ✅ Input validation
- ✅ Supabase connection string

### Frontend (Cloudflare)
- ✅ FlutterSecureStorage بدلاً من SharedPreferences
- ✅ Input validators (customerId, vehicleId, phone, email)
- ✅ Rate limiting أمامي (5 attempts = 15 min block)
- ✅ Hive caching
- ✅ Pagination محسّن (500 record limit)

---

## 📝 Commits الرئيسية

- `aa729fa`: fix: update migration files for Supabase compatibility
- `753aad5`: feat: add simplified Supabase-compatible schema
- `0eaef4c`: fix: resolve Supabase ENUM type creation error
- `70513c4`: fix: update schema.sql for full compatibility with backend
- `c9b010f`: feat: comprehensive security and performance improvements

---

## ⚠️ ملاحظات مهمة

### RLS (Row Level Security)
- **لا تفعّل RLS** في Supabase ❌
- Backend يدير جميع الصلاحيات عبر JWT و middlewares ✅

### CSRF Protection
- CSRF middleware يتخطى `/public/*` endpoints ✅
- Customer Frontend يستخدم `/public/bookings/:publicToken` بدون session ✅

### Rate Limiting
- Login: 5 محاولات فاشلة = 15 دقيقة حظر ✅
- API: 100 request/min لكل IP ✅

---

**تم إنشاء هذا الملف بواسطة Devin - 2026-05-24**
