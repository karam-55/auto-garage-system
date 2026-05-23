# تحليل قاعدة البيانات - نظام إدارة مرآب السيارات (Garage Go)
# Database Analysis Report - Auto Garage Management System

**التاريخ:** 2026-05-24  
**المشروع:** Auto Garage Management System (Garage Go)  
**المسار:** `c:\Users\FIX 11\projects\auto garrage\`  
**الحالة:** تحليل شامل لقاعدة البيانات

---

## 📊 ملخص تنفيذي

### إحصائيات قاعدة البيانات
- **إجمالي الجداول:** 30 جدول
- **الجداول الأساسية:** 9 جداول (Core Tables)
- **جداول المحاسبة:** 4 جداول
- **جداول المخزون:** 3 جداول
- **جداول الفواتير:** 1 جدول
- **جداول ERP:** 5 جداول
- **جداول الموارد البشرية:** 4 جداول
- **جداول الأصول الثابتة:** 2 جداول
- **جداول أخرى:** 2 جدول

### نقاط القوة
- ✅ استخدام UUID للمفاتيح الأساسية (جيد للتوزيع)
- ✅ تصميم junction table صحيح للعلاقات
- ✅ فهارس شاملة للاستعلامات الشائعة
- ✅ ON DELETE CASCADE للحفاظ على التكامل
- ✅ استخدام JSONB للمرونة
- ✅ دعم القيود العكسية في المحاسبة

### نقاط الضعف الرئيسية
- ⚠️ 20+ فهرس مفقود للأعمدة المهمة
- ⚠️ بعض UNIQUE constraints مفقودة
- ⚠️ بعض CHECK constraints مفقودة
- ⚠️ احتمالية N+1 queries في بعض الاستعلامات
- ⚠️ لا يوجد فهرس على بعض الأعمدة المستخدمة في البحث

---

## 📋 جدول المحتويات

1. [تحليل الجداول الأساسية](#1-تحليل-الجداول-الأساسية-core-tables)
2. [تحليل جداول المحاسبة](#2-تحليل-جداول-المحاسبة-accounting-tables)
3. [تحليل جداول المخزون](#3-تحليل-جداول-المخزون-inventory-tables)
4. [تحليل جداول الفواتير](#4-تحليل-جداول-الفواتير-invoice-tables)
5. [تحليل جداول ERP](#5-تحليل-جداول-erp)
6. [تحليل جداول الموارد البشرية](#6-تحليل-جداول-الموارد-البشرية-hr-tables)
7. [تحليل جداول الأصول الثابتة](#7-تحليل-جداول-الأصول-الثابتة-fixed-assets-tables)
8. [تحليل الفهارس](#8-تحليل-الفهارس-indexes-analysis)
9. [تحليل الاستعلامات المعقدة](#9-تحليل-الاستعلامات-المعقدة-complex-queries-analysis)
10. [التوصيات](#10-التوصيات-recommendations)

---

## 1. تحليل الجداول الأساسية (Core Tables)

### 1.1 جدول المستخدمين (users)
**المسار:** `supabase-schema.sql:8-17` و `schema.sql:160-169`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | معرف فريد |
| full_name | VARCHAR(255) | NOT NULL | اسم المستخدم الكامل |
| username | VARCHAR(100) | UNIQUE, NOT NULL | اسم المستخدم |
| password_hash | VARCHAR(255) | NOT NULL | كلمة المرور المشفرة |
| role | VARCHAR(50) | CHECK, NOT NULL | الأدوار: OWNER, MANAGER, MANAGER_SALES, MANAGER_WAREHOUSE, RECEPTIONIST, MECHANIC, ACCOUNTANT, HR_MANAGER |
| is_active | BOOLEAN | DEFAULT true | حالة النشاط |
| base_salary | DECIMAL(15,2) | DEFAULT 0 | الراتب الأساسي (مضاف لاحقاً) |
| hire_date | DATE | NULL | تاريخ التوظيف |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | NULL | تاريخ التحديث |

**الفهارس:**
- `idx_users_username` على `username`
- `idx_users_role` على `role`

**الملاحظات:**
- ✅ استخدام UUID للمفاتيح الأساسية (جيد للتوزيع)
- ✅ CHECK constraint على الأدوار
- ⚠️ يجب إضافة UNIQUE constraint على `username` في جميع الحالات

---

### 1.2 جدول العملاء (customers)
**المسار:** `supabase-schema.sql:20-27` و `schema.sql:172-179`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY | معرف فريد |
| full_name | VARCHAR(255) | NOT NULL | اسم العميل |
| phone | VARCHAR(20) | NOT NULL | رقم الهاتف |
| address | TEXT | NULL | العنوان |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | NULL | تاريخ التحديث |

**الفهارس:**
- `idx_customers_phone` على `phone`

**الملاحظات:**
- ⚠️ لا يوجد UNIQUE constraint على `phone` (قد يكون مقصوداً)
- ⚠️ يجب إضافة فهرس على `full_name` للبحث السريع

---

### 1.3 جدول المركبات (vehicles)
**المسار:** `supabase-schema.sql:30-41` و `schema.sql:182-192`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY | معرف فريد |
| customer_id | UUID | FOREIGN KEY → customers(id) ON DELETE CASCADE | العميل المالك |
| make | VARCHAR(100) | NOT NULL | الصانع (مثل Toyota) |
| model | VARCHAR(100) | NOT NULL | الموديل |
| year | INTEGER | NOT NULL | سنة الصنع |
| license_plate | VARCHAR(20) | NULL | لوحة الترخيص |
| vin | VARCHAR(50) | NULL | رقم الهيكل |
| public_car_id | VARCHAR(255) | UNIQUE, DEFAULT '' | معرف عام للمركبة |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | NULL | تاريخ التحديث |

**الفهارس:**
- `idx_vehicles_customer_id` على `customer_id`
- `idx_vehicles_license_plate` على `license_plate`
- `idx_vehicles_public_car_id` على `public_car_id`

**الملاحظات:**
- ✅ استخدام ON DELETE CASCADE للحفاظ على التكامل
- ✅ وجود `public_car_id` للتتبع العام
- ⚠️ يجب إضافة UNIQUE constraint على `license_plate` و `vin`

---

### 1.4 جدول الخدمات (services)
**المسار:** `supabase-schema.sql:44-53` و `schema.sql:195-204`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY | معرف فريد |
| name | VARCHAR(255) | NOT NULL | اسم الخدمة |
| description | TEXT | NULL | وصف الخدمة |
| price_syp | DECIMAL(12,2) | NOT NULL | السعر بالليرة السورية |
| estimated_duration_minutes | INTEGER | NULL | المدة المتوقعة |
| is_active | BOOLEAN | DEFAULT true | حالة النشاط |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | NULL | تاريخ التحديث |

**الفهارس:**
- `idx_services_is_active` على `is_active`

**الملاحظات:**
- ✅ تصميم بسيط وفعال
- ⚠️ يجب إضافة فهرس على `name` للبحث

---

### 1.5 جدول الحجوزات (bookings)
**المسار:** `supabase-schema.sql:56-66` و `schema.sql:218-228`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY | معرف فريد |
| customer_id | UUID | FOREIGN KEY → customers(id) ON DELETE CASCADE | العميل |
| vehicle_id | UUID | FOREIGN KEY → vehicles(id) ON DELETE CASCADE | المركبة |
| status | VARCHAR(50) | CHECK, DEFAULT 'PENDING' | الحالة: PENDING, IN_PROGRESS, WAITING_PARTS, READY, DELIVERED, CANCELLED |
| public_token | VARCHAR(255) | UNIQUE, NOT NULL | رمز التتبع العام |
| notes | TEXT | NULL | ملاحظات |
| estimated_completion_date | TIMESTAMP | NULL | تاريخ الإنجاز المتوقع |
| invoice_generated | BOOLEAN | DEFAULT false | هل تم إنشاء الفاتورة |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | NULL | تاريخ التحديث |

**الفهارس:**
- `idx_bookings_customer_id` على `customer_id`
- `idx_bookings_vehicle_id` على `vehicle_id`
- `idx_bookings_status` على `status`
- `idx_bookings_public_token` على `public_token`
- `idx_bookings_created_at` على `created_at`

**الملاحظات:**
- ✅ فهارس شاملة للاستعلامات الشائعة
- ✅ ON DELETE CASCADE للحفاظ على التكامل
- ✅ UNIQUE على `public_token` لتجنب التكرار

---

### 1.6 جدول خدمات الحجز (booking_services)
**المسار:** `supabase-schema.sql:69-76` و `schema.sql:231-238`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY | معرف فريد |
| booking_id | UUID | FOREIGN KEY → bookings(id) ON DELETE CASCADE | الحجز |
| service_id | UUID | FOREIGN KEY → services(id) ON DELETE CASCADE | الخدمة |
| price_syp | DECIMAL(12,2) | NOT NULL | السعر المطبق |
| notes | TEXT | NULL | ملاحظات |
| UNIQUE(booking_id, service_id) | - | - | منع التكرار |

**الفهارس:**
- `idx_booking_services_booking_id` على `booking_id`
- `idx_booking_services_service_id` على `service_id`

**الملاحظات:**
- ✅ UNIQUE constraint على (booking_id, service_id)
- ✅ تصميم junction table صحيح

---

### 1.7 جدول تعيينات الميكانيكيين (mechanic_assignments)
**المسار:** `supabase-schema.sql:79-88` و `schema.sql:241-250`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY | معرف فريد |
| booking_id | UUID | FOREIGN KEY → bookings(id) ON DELETE CASCADE | الحجز |
| mechanic_user_id | UUID | FOREIGN KEY → users(id) ON DELETE CASCADE | الميكانيكي |
| status | VARCHAR(50) | CHECK, DEFAULT 'ASSIGNED' | الحالة: ASSIGNED, IN_PROGRESS, WAITING_PARTS, READY, DELIVERED |
| notes | TEXT | NULL | ملاحظات |
| UNIQUE(booking_id) | - | - | ميكانيكي واحد فقط لكل حجز |
| assigned_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ التعيين |
| updated_at | TIMESTAMP | NULL | تاريخ التحديث |

**الفهارس:**
- `idx_mechanic_assignments_booking_id` على `booking_id`
- `idx_mechanic_assignments_mechanic_user_id` على `mechanic_user_id`
- `idx_mechanic_assignments_status` على `status`

**الملاحظات:**
- ✅ UNIQUE على `booking_id` لضمان ميكانيكي واحد فقط
- ✅ فهارس جيدة للاستعلامات

---

### 1.8 جدول اقتراحات الأجزاء (part_suggestions)
**المسار:** `supabase-schema.sql:91-101` و `schema.sql:253-263`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY | معرف فريد |
| booking_id | UUID | FOREIGN KEY → bookings(id) ON DELETE CASCADE | الحجز |
| mechanic_user_id | UUID | FOREIGN KEY → users(id) ON DELETE CASCADE | الميكانيكي المقترح |
| type | VARCHAR(50) | CHECK | النوع: ORIGINAL, COMMERCIAL, USED |
| description | TEXT | NOT NULL | وصف الجزء |
| price_syp | DECIMAL(12,2) | NULL | السعر |
| status | VARCHAR(50) | CHECK, DEFAULT 'PENDING_CUSTOMER_APPROVAL' | الحالة: PENDING_CUSTOMER_APPROVAL, APPROVED, REJECTED |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | NULL | تاريخ التحديث |

**الفهارس:**
- `idx_part_suggestions_booking_id` على `booking_id`
- `idx_part_suggestions_status` على `status`

**الملاحظات:**
- ⚠️ يجب إضافة فهرس على `mechanic_user_id`
- ⚠️ يجب إضافة فهرس على `created_at` للترتيب الزمني

---

### 1.9 جدول إعدادات الشركة (company_settings)
**المسار:** `supabase-schema.sql:104-110` و `schema.sql:266-278`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| company_name | VARCHAR(255) | NOT NULL, DEFAULT 'Garage Go' | اسم الشركة |
| company_name_en | VARCHAR(255) | NULL | اسم الشركة بالإنجليزية |
| company_logo_url | TEXT | NULL | رابط الشعار |
| address | TEXT | NULL | العنوان |
| phone | VARCHAR(50) | NULL | الهاتف |
| tax_number | VARCHAR(100) | NULL | رقم الضريبة |
| fiscal_year_start | DATE | NULL | بداية السنة المالية |
| currency_code | VARCHAR(10) | DEFAULT 'SAR' | رمز العملة |
| accounting_settings | JSONB | DEFAULT '{}' | إعدادات المحاسبة |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | NULL | تاريخ التحديث |

**الملاحظات:**
- ✅ استخدام JSONB للإعدادات المرنة
- ⚠️ يجب إضافة UNIQUE constraint على `id` (يجب أن يكون سجل واحد فقط)

---

## 2. تحليل جداول المحاسبة (Accounting Tables)

### 2.1 جدول الفترات المالية (fiscal_periods)
**المسار:** `schema.sql:6-13`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| name | VARCHAR(100) | NOT NULL | اسم الفترة |
| start_date | DATE | NOT NULL | تاريخ البداية |
| end_date | DATE | NOT NULL | تاريخ النهاية |
| is_closed | BOOLEAN | DEFAULT FALSE | هل الفترة مغلقة |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |

**الملاحظات:**
- ⚠️ يجب إضافة CHECK constraint للتأكد من `start_date < end_date`
- ⚠️ يجب إضافة فهرس على `is_closed` و `start_date`

---

### 2.2 جدول الحسابات (accounts)
**المسار:** `schema.sql:16-26`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| code | VARCHAR(20) | UNIQUE, NOT NULL | رمز الحساب |
| name_ar | VARCHAR(255) | NOT NULL | الاسم بالعربية |
| name_en | VARCHAR(255) | NOT NULL | الاسم بالإنجليزية |
| parent_id | INT | FOREIGN KEY → accounts(id) ON DELETE CASCADE | الحساب الأب (للهيكل الهرمي) |
| account_type | account_type_enum | NOT NULL | النوع: asset, liability, equity, revenue, expense, cogs |
| is_active | BOOLEAN | DEFAULT TRUE | حالة النشاط |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |

**الملاحظات:**
- ✅ استخدام ENUM للأنواع
- ✅ دعم الهيكل الهرمي (parent_id)
- ✅ UNIQUE على `code`
- ⚠️ يجب إضافة فهرس على `account_type` و `parent_id`

---

### 2.3 جدول القيود اليومية (journal_entries)
**المسار:** `schema.sql:29-42`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| entry_date | DATE | NOT NULL | تاريخ القيد |
| reference | VARCHAR(50) | NULL | المرجع |
| description | TEXT | NULL | الوصف |
| is_reversing | BOOLEAN | DEFAULT FALSE | هل هو قيد عكسي |
| reversing_date | DATE | NULL | تاريخ القيد العكسي |
| is_reversed | BOOLEAN | DEFAULT FALSE | هل تم عكسه |
| created_by | UUID | FOREIGN KEY → users(id) | من أنشأه |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| approved_by | UUID | FOREIGN KEY → users(id) | من وافق عليه |
| approved_at | TIMESTAMP | NULL | تاريخ الموافقة |
| fiscal_period_id | INT | FOREIGN KEY → fiscal_periods(id) | الفترة المالية |

**الملاحظات:**
- ✅ دعم القيود العكسية
- ✅ تتبع من أنشأ وأقر
- ⚠️ يجب إضافة فهارس على `entry_date` و `fiscal_period_id` و `created_by`

---

### 2.4 جدول بنود القيود (journal_lines)
**المسار:** `schema.sql:45-54`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| entry_id | INT | FOREIGN KEY → journal_entries(id) ON DELETE CASCADE | القيد |
| account_id | INT | FOREIGN KEY → accounts(id) | الحساب |
| debit | DECIMAL(15,2) | DEFAULT 0 | المدين |
| credit | DECIMAL(15,2) | DEFAULT 0 | الدائن |
| description | TEXT | NULL | الوصف |
| source_type | VARCHAR(50) | NULL | نوع المصدر (booking, purchase, etc.) |
| source_id | VARCHAR(100) | NULL | معرف المصدر |
| CHECK (debit = 0 OR credit = 0) | - | - | يجب أن يكون أحدهما صفر فقط |

**الملاحظات:**
- ✅ CHECK constraint لضمان المحاسبة المزدوجة
- ✅ تتبع المصدر
- ⚠️ يجب إضافة فهارس على `entry_id` و `account_id` و `source_id`

---

## 3. تحليل جداول المخزون (Inventory Tables)

### 3.1 جدول عناصر المخزون (inventory_items)
**المسار:** `schema.sql:294-302`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY | معرف فريد |
| name | VARCHAR(255) | NOT NULL | اسم العنصر |
| category | VARCHAR(100) | NULL | الفئة |
| unit | VARCHAR(50) | NULL | وحدة القياس |
| low_stock_threshold | INTEGER | DEFAULT 5 | حد المخزون المنخفض |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | NULL | تاريخ التحديث |

**الفهارس:**
- `idx_inventory_items_category` على `category`

**الملاحظات:**
- ⚠️ يجب إضافة فهرس على `name` للبحث
- ⚠️ يجب إضافة UNIQUE constraint على `name`

---

### 3.2 جدول متغيرات المخزون (inventory_variants)
**المسار:** `schema.sql:305-314`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY | معرف فريد |
| item_id | UUID | FOREIGN KEY → inventory_items(id) ON DELETE CASCADE | العنصر |
| variant_type | VARCHAR(50) | CHECK | النوع: ORIGINAL, COMMERCIAL, USED |
| quantity | INTEGER | DEFAULT 0 | الكمية |
| cost_price | DECIMAL(12,2) | DEFAULT 0 | سعر التكلفة |
| selling_price | DECIMAL(12,2) | DEFAULT 0 | سعر البيع |
| supplier | VARCHAR(255) | NULL | المورد |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |

**الفهارس:**
- `idx_inventory_variants_item_id` على `item_id`
- `idx_inventory_variants_variant_type` على `variant_type`

**الملاحظات:**
- ✅ تصميم جيد للمتغيرات
- ⚠️ يجب إضافة UNIQUE constraint على (item_id, variant_type)

---

### 3.3 جدول معاملات المخزون (inventory_transactions)
**المسار:** `schema.sql:317-327`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY | معرف فريد |
| item_id | UUID | FOREIGN KEY → inventory_items(id) ON DELETE CASCADE | العنصر |
| variant_id | UUID | FOREIGN KEY → inventory_variants(id) ON DELETE CASCADE | المتغير |
| booking_id | UUID | FOREIGN KEY → bookings(id) ON DELETE SET NULL | الحجز (اختياري) |
| mechanic_id | UUID | FOREIGN KEY → users(id) ON DELETE SET NULL | الميكانيكي |
| type | VARCHAR(50) | CHECK | النوع: CONSUME, ADD, RETURN |
| quantity | INTEGER | NOT NULL | الكمية |
| notes | TEXT | NULL | ملاحظات |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |

**الفهارس:**
- `idx_inventory_transactions_item_id` على `item_id`
- `idx_inventory_transactions_variant_id` على `variant_id`
- `idx_inventory_transactions_booking_id` على `booking_id`
- `idx_inventory_transactions_mechanic_id` على `mechanic_id`
- `idx_inventory_transactions_type` على `type`

**الملاحظات:**
- ✅ فهارس شاملة
- ✅ تتبع كامل للمعاملات

---

## 4. تحليل جداول الفواتير (Invoice Tables)

### 4.1 جدول بيانات فاتورة الحجز (booking_invoice_data)
**المسار:** `schema.sql:330-344`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | UUID | PRIMARY KEY | معرف فريد |
| booking_id | UUID | FOREIGN KEY → bookings(id) ON DELETE CASCADE UNIQUE | الحجز |
| services_snapshot | JSONB | NULL | لقطة الخدمات |
| parts_snapshot | JSONB | NULL | لقطة الأجزاء |
| total_price | DECIMAL(12,2) | DEFAULT 0 | السعر الإجمالي |
| invoice_created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ إنشاء الفاتورة |
| public_token | VARCHAR(255) | NULL | رمز التتبع العام |
| qr_code_url | TEXT | NULL | رابط رمز QR |
| journal_entry_id | INTEGER | FOREIGN KEY → journal_entries(id) ON DELETE SET NULL | القيد المحاسبي |
| payment_method | VARCHAR(50) | CHECK, DEFAULT 'cash' | طريقة الدفع: cash, electronic |
| payment_status | VARCHAR(50) | CHECK, DEFAULT 'unpaid' | حالة الدفع: unpaid, partial, paid |
| amount_paid | DECIMAL(12,2) | DEFAULT 0 | المبلغ المدفوع |
| amount_remaining | DECIMAL(12,2) | DEFAULT 0 | المبلغ المتبقي |

**الفهارس:**
- `idx_booking_invoice_data_booking_id` على `booking_id`

**الملاحظات:**
- ✅ UNIQUE على `booking_id` (فاتورة واحدة فقط لكل حجز)
- ✅ استخدام JSONB للمرونة
- ✅ تتبع الدفع

---

## 5. تحليل جداول ERP

### 5.1 جدول الفواتير الشرائية (purchase_invoices)
**المسار:** `schema.sql:96-107`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| vendor_id | INT | FOREIGN KEY → vendors(id) | المورد |
| invoice_number | VARCHAR(50) | NOT NULL | رقم الفاتورة |
| issue_date | DATE | NOT NULL | تاريخ الإصدار |
| due_date | DATE | NULL | تاريخ الاستحقاق |
| total_amount | DECIMAL(15,2) | NOT NULL | المبلغ الإجمالي |
| paid_amount | DECIMAL(15,2) | DEFAULT 0 | المبلغ المدفوع |
| status | VARCHAR(20) | DEFAULT 'unpaid' | الحالة |
| journal_entry_id | INT | FOREIGN KEY → journal_entries(id) ON DELETE SET NULL | القيد المحاسبي |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |

**الملاحظات:**
- ⚠️ يجب إضافة UNIQUE constraint على `invoice_number`
- ⚠️ يجب إضافة فهارس على `vendor_id` و `status` و `issue_date`

---

### 5.2 جدول الاقتباسات (quotations)
**المسار:** `schema.sql:474-489`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| customer_id | UUID | FOREIGN KEY → customers(id) ON DELETE CASCADE | العميل |
| vehicle_id | UUID | FOREIGN KEY → vehicles(id) ON DELETE CASCADE | المركبة |
| quotation_number | VARCHAR(50) | UNIQUE, NOT NULL | رقم الاقتباس |
| quotation_date | DATE | NOT NULL | تاريخ الاقتباس |
| valid_until | DATE | NULL | صالح حتى |
| total_amount | DECIMAL(15,2) | DEFAULT 0 | المبلغ الإجمالي |
| discount_amount | DECIMAL(15,2) | DEFAULT 0 | مبلغ الخصم |
| tax_amount | DECIMAL(15,2) | DEFAULT 0 | مبلغ الضريبة |
| notes | TEXT | NULL | ملاحظات |
| status | VARCHAR(50) | CHECK, DEFAULT 'draft' | الحالة: draft, sent, accepted, rejected, expired, converted_to_order |
| created_by | UUID | FOREIGN KEY → users(id) | من أنشأه |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ التحديث |

**الفهارس:**
- `idx_quotations_customer_id` على `customer_id`
- `idx_quotations_status` على `status`
- `idx_quotations_date` على `quotation_date`

**الملاحظات:**
- ✅ تصميم شامل للاقتباسات
- ⚠️ يجب إضافة CHECK constraint للتأكد من `valid_until > quotation_date`

---

### 5.3 جدول أوامر البيع (sales_orders)
**المسار:** `schema.sql:505-520`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| customer_id | UUID | FOREIGN KEY → customers(id) ON DELETE CASCADE | العميل |
| vehicle_id | UUID | FOREIGN KEY → vehicles(id) ON DELETE CASCADE | المركبة |
| order_number | VARCHAR(50) | UNIQUE, NOT NULL | رقم الأمر |
| order_date | DATE | NOT NULL | تاريخ الأمر |
| quotation_id | INT | FOREIGN KEY → quotations(id) ON DELETE SET NULL | الاقتباس |
| total_amount | DECIMAL(15,2) | DEFAULT 0 | المبلغ الإجمالي |
| discount_amount | DECIMAL(15,2) | DEFAULT 0 | مبلغ الخصم |
| tax_amount | DECIMAL(15,2) | DEFAULT 0 | مبلغ الضريبة |
| notes | TEXT | NULL | ملاحظات |
| status | VARCHAR(50) | CHECK, DEFAULT 'pending' | الحالة: pending, confirmed, in_progress, completed, cancelled |
| created_by | UUID | FOREIGN KEY → users(id) | من أنشأه |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ التحديث |

**الفهارس:**
- `idx_sales_orders_customer_id` على `customer_id`
- `idx_sales_orders_status` على `status`
- `idx_sales_orders_date` على `order_date`

---

### 5.4 جدول أوامر الشراء (purchase_orders)
**المسار:** `schema.sql:536-548`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| vendor_id | INT | FOREIGN KEY → vendors(id) ON DELETE SET NULL | المورد |
| order_number | VARCHAR(50) | UNIQUE, NOT NULL | رقم الأمر |
| order_date | DATE | NOT NULL | تاريخ الأمر |
| expected_delivery_date | DATE | NULL | تاريخ التسليم المتوقع |
| total_amount | DECIMAL(15,2) | DEFAULT 0 | المبلغ الإجمالي |
| notes | TEXT | NULL | ملاحظات |
| status | VARCHAR(50) | CHECK, DEFAULT 'pending' | الحالة: pending, confirmed, received, cancelled |
| created_by | UUID | FOREIGN KEY → users(id) | من أنشأه |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ التحديث |

**الفهارس:**
- `idx_purchase_orders_vendor_id` على `vendor_id`
- `idx_purchase_orders_status` على `status`

---

## 6. تحليل جداول الموارد البشرية (HR Tables)

### 6.1 جدول عقود الموظفين (employee_contracts)
**المسار:** `schema.sql:636-650`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| user_id | UUID | FOREIGN KEY → users(id) ON DELETE CASCADE | الموظف |
| contract_number | VARCHAR(50) | UNIQUE, NOT NULL | رقم العقد |
| start_date | DATE | NOT NULL | تاريخ البداية |
| end_date | DATE | NULL | تاريخ النهاية |
| contract_type | VARCHAR(50) | CHECK, DEFAULT 'full_time' | النوع: full_time, part_time, contract |
| base_salary | DECIMAL(15,2) | NOT NULL | الراتب الأساسي |
| position | VARCHAR(255) | NULL | المنصب |
| department | VARCHAR(255) | NULL | القسم |
| status | VARCHAR(50) | CHECK, DEFAULT 'active' | الحالة: active, terminated, expired |
| notes | TEXT | NULL | ملاحظات |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ التحديث |

**الفهارس:**
- `idx_employee_contracts_user_id` على `user_id`
- `idx_employee_contracts_status` على `status`

---

### 6.2 جدول طلبات الإجازة (leave_requests)
**المسار:** `schema.sql:653-667`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| user_id | UUID | FOREIGN KEY → users(id) ON DELETE CASCADE | الموظف |
| leave_type | VARCHAR(50) | CHECK | النوع: annual, sick, unpaid, other |
| start_date | DATE | NOT NULL | تاريخ البداية |
| end_date | DATE | NOT NULL | تاريخ النهاية |
| total_days | INTEGER | NOT NULL | عدد الأيام |
| reason | TEXT | NULL | السبب |
| status | VARCHAR(50) | CHECK, DEFAULT 'pending' | الحالة: pending, approved, rejected, cancelled |
| approved_by | UUID | FOREIGN KEY → users(id) | من وافق |
| approved_at | TIMESTAMP | NULL | تاريخ الموافقة |
| rejection_reason | TEXT | NULL | سبب الرفض |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ التحديث |

**الفهارس:**
- `idx_leave_requests_user_id` على `user_id`
- `idx_leave_requests_status` على `status`

**الملاحظات:**
- ⚠️ يجب إضافة CHECK constraint للتأكد من `start_date < end_date`

---

### 6.3 جدول تقييمات الأداء (performance_reviews)
**المسار:** `schema.sql:670-682`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| user_id | UUID | FOREIGN KEY → users(id) ON DELETE CASCADE | الموظف |
| reviewer_id | UUID | FOREIGN KEY → users(id) | المقيّم |
| review_period | VARCHAR(50) | NOT NULL | فترة التقييم |
| rating | DECIMAL(3,2) | CHECK (0-5) | التقييم |
| strengths | TEXT | NULL | نقاط القوة |
| areas_for_improvement | TEXT | NULL | مجالات التحسين |
| goals | TEXT | NULL | الأهداف |
| status | VARCHAR(50) | CHECK, DEFAULT 'draft' | الحالة: draft, submitted, reviewed |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ التحديث |

**الفهارس:**
- `idx_performance_reviews_user_id` على `user_id`

---

### 6.4 جدول الرواتب (salary_payments)
**المسار:** `schema.sql:137-149`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| user_id | UUID | FOREIGN KEY → users(id) | الموظف |
| month_year | DATE | NOT NULL | الشهر والسنة |
| base_salary | DECIMAL(15,2) | NULL | الراتب الأساسي |
| working_days | INT | NULL | أيام العمل |
| bonuses | DECIMAL(15,2) | DEFAULT 0 | المكافآت |
| deductions | DECIMAL(15,2) | DEFAULT 0 | الخصومات |
| net_salary | DECIMAL(15,2) | NULL | الراتب الصافي |
| payment_date | DATE | NULL | تاريخ الدفع |
| is_paid | BOOLEAN | DEFAULT FALSE | هل تم الدفع |
| journal_entry_id | INT | FOREIGN KEY → journal_entries(id) | القيد المحاسبي |

**الملاحظات:**
- ⚠️ يجب إضافة UNIQUE constraint على (user_id, month_year)
- ⚠️ يجب إضافة فهارس على `user_id` و `month_year` و `is_paid`

---

## 7. تحليل جداول الأصول الثابتة (Fixed Assets Tables)

### 7.1 جدول الأصول الثابتة (fixed_assets)
**المسار:** `schema.sql:416-429`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| name | VARCHAR(255) | NOT NULL | اسم الأصل |
| acquisition_date | DATE | NOT NULL | تاريخ الاستحواذ |
| acquisition_cost | DECIMAL(15,2) | NOT NULL | تكلفة الاستحواذ |
| salvage_value | DECIMAL(15,2) | DEFAULT 0 | القيمة المتبقية |
| useful_life_years | INTEGER | NOT NULL | سنوات الحياة الافتراضية |
| depreciation_method | VARCHAR(50) | DEFAULT 'straight_line' | طريقة الاستهلاك |
| current_net_book_value | DECIMAL(15,2) | NULL | القيمة الدفترية الحالية |
| location | VARCHAR(255) | NULL | الموقع |
| status | VARCHAR(50) | DEFAULT 'active' | الحالة |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ التحديث |

**الفهارس:**
- `idx_fixed_assets_status` على `status`
- `idx_fixed_assets_acquisition_date` على `acquisition_date`

---

### 7.2 جدول إدخالات الاستهلاك (depreciation_entries)
**المسار:** `schema.sql:432-439`

| العمود | النوع | القيود | الملاحظات |
|-------|-------|--------|---------|
| id | SERIAL | PRIMARY KEY | معرف فريد |
| asset_id | INT | FOREIGN KEY → fixed_assets(id) ON DELETE CASCADE | الأصل |
| period | DATE | NOT NULL | الفترة |
| depreciation_amount | DECIMAL(15,2) | NOT NULL | مبلغ الاستهلاك |
| journal_entry_id | INT | FOREIGN KEY → journal_entries(id) ON DELETE SET NULL | القيد المحاسبي |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | تاريخ الإنشاء |

**الفهارس:**
- `idx_depreciation_entries_asset_id` على `asset_id`
- `idx_depreciation_entries_period` على `period`

---

## 8. تحليل الفهارس (Indexes Analysis)

### 8.1 الفهارس الموصى بها (Recommended Indexes)

| الجدول | الأعمدة | السبب | الأولوية |
|-------|--------|-------|---------|
| customers | full_name | للبحث السريع عن العملاء بالاسم | ⭐⭐⭐ |
| services | name | للبحث عن الخدمات | ⭐⭐ |
| accounts | account_type | للفلترة حسب نوع الحساب | ⭐⭐⭐ |
| accounts | parent_id | للهيكل الهرمي | ⭐⭐⭐ |
| journal_entries | created_by | لتتبع من أنشأ القيد | ⭐⭐ |
| journal_entries | approved_by | لتتبع من وافق على القيد | ⭐⭐ |
| part_suggestions | mechanic_user_id | لتتبع من الميكانيكي المقترح | ⭐⭐ |
| part_suggestions | created_at | للترتيب الزمني | ⭐⭐ |
| inventory_items | name | للبحث عن عناصر المخزون | ⭐⭐⭐ |
| vendors | name | للبحث عن الموردين | ⭐⭐⭐ |
| quotations | valid_until | للفلترة الاقتباسات المنتهية | ⭐⭐ |
| sales_orders | order_date | للترتيب أوامر البيع | ⭐⭐⭐ |
| purchase_orders | order_date | للترتيب أوامر الشراء | ⭐⭐⭐ |
| purchase_invoices | issue_date | للترتيب فواتير الشراء | ⭐⭐⭐ |
| employee_contracts | start_date | للترتيب تاريخ البداية | ⭐⭐ |
| employee_contracts | end_date | للترتيب تاريخ النهاية | ⭐⭐ |
| leave_requests | start_date | للترتيب تاريخ البداية | ⭐⭐ |
| leave_requests | end_date | للترتيب تاريخ النهاية | ⭐⭐ |
| salary_payments | month_year | للفلترة الشهر والسنة | ⭐⭐⭐ |
| salary_payments | payment_date | للترتيب تاريخ الدفع | ⭐⭐⭐ |
| fiscal_periods | start_date | للترتيب بداية الفترة | ⭐⭐⭐ |
| fiscal_periods | end_date | للترتيب نهاية الفترة | ⭐⭐⭐ |
| depreciation_entries | period | للترتيب الفترة | ⭐⭐⭐ |

---

## 9. تحليل الاستعلامات المعقدة (Complex Queries Analysis)

### 9.1 استعلامات N+1 المحتملة

#### مشكلة: جلب الحجوزات مع الخدمات والعملاء والمركبات
**الحل المقترح:**
```sql
SELECT 
  b.*,
  c.full_name as customer_name,
  v.make, v.model, v.year, v.license_plate,
  json_agg(json_build_object(
    'service_id', s.id,
    'service_name', s.name,
    'price_syp', s.price_syp
  )) as services
FROM bookings b
LEFT JOIN customers c ON b.customer_id = c.id
LEFT JOIN vehicles v ON b.vehicle_id = v.id
LEFT JOIN booking_services bs ON b.id = bs.booking_id
LEFT JOIN services s ON bs.service_id = s.id
WHERE b.status = 'PENDING'
GROUP BY b.id
ORDER BY b.created_at DESC
```

**الفائدة:**
- ✅ استعلام واحد فقط
- ✅ يستخدم JOINs بدلاً من N+1
- ✅ يستخدم json_agg لتجميع البيانات

---

## 10. التوصيات (Recommendations)

### 10.1 التوصيات الفورية (High Priority)

1. **إضافة الفهارس المفقودة**
   ```sql
   CREATE INDEX idx_customers_full_name ON customers(full_name);
   CREATE INDEX idx_services_name ON services(name);
   CREATE INDEX idx_accounts_account_type ON accounts(account_type);
   CREATE INDEX idx_accounts_parent_id ON accounts(parent_id);
   CREATE INDEX idx_journal_entries_created_by ON journal_entries(created_by);
   CREATE INDEX idx_journal_entries_approved_by ON journal_entries(approved_by);
   CREATE INDEX idx_part_suggestions_mechanic_user_id ON part_suggestions(mechanic_user_id);
   CREATE INDEX idx_part_suggestions_created_at ON part_suggestions(created_at);
   CREATE INDEX idx_inventory_items_name ON inventory_items(name);
   CREATE INDEX idx_vendors_name ON vendors(name);
   ```

2. **إضافة UNIQUE Constraints المفقودة**
   ```sql
   ALTER TABLE vehicles ADD CONSTRAINT unique_license_plate UNIQUE (license_plate);
   ALTER TABLE vehicles ADD CONSTRAINT unique_vin UNIQUE (vin);
   ALTER TABLE purchase_invoices ADD CONSTRAINT unique_invoice_number UNIQUE (invoice_number);
   ALTER TABLE salary_payments ADD CONSTRAINT unique_user_month UNIQUE (user_id, month_year);
   ALTER TABLE inventory_variants ADD CONSTRAINT unique_item_variant UNIQUE (item_id, variant_type);
   ```

3. **إضافة CHECK Constraints المفقودة**
   ```sql
   ALTER TABLE fiscal_periods ADD CONSTRAINT check_dates CHECK (start_date < end_date);
   ALTER TABLE quotations ADD CONSTRAINT check_validity CHECK (valid_until > quotation_date);
   ALTER TABLE leave_requests ADD CONSTRAINT check_dates CHECK (start_date < end_date);
   ```

### 10.2 التوصيات المتوسطة (Medium Priority)

4. **حل N+1 Queries**
   - استخدام JOINs بدلاً من استعلامات متعددة
   - استخدام json_agg لتجميع البيانات المرتبطة

5. **تحسين الاستعلامات البطيئة**
   - إضافة فهارس على الأعمدة المستخدمة في WHERE و JOIN
   - استخدام EXPLAIN ANALYZE لتحليل الاستعلامات

### 10.3 التوصيات طويلة الأمد (Low Priority)

6. **تطبيق Database Partitioning**
   - تقسيم الجداول الكبيرة حسب التاريخ (مثل journal_entries)
   - تحسين الأداء للاستعلامات التاريخية

7. **تطبيق Database Replication**
   - استخدام Read Replicas لتحسين أداء القراءة
   - فصل عمليات القراءة والكتابة

---

## ✅ الخلاصة

**نقاط القوة:**
- تصميم قاعدة البيانات جيد ومنظم
- استخدام UUID للمفاتيح الأساسية
- فهارس شاملة للاستعلامات الشائعة
- دعم المحاسبة المزدوجة
- استخدام JSONB للمرونة

**نقاط الضعف الرئيسية:**
- 20+ فهرس مفقود
- بعض UNIQUE constraints مفقودة
- بعض CHECK constraints مفقودة
- احتمالية N+1 queries
- لا يوجد partitioning للجداول الكبيرة

**التوصية الرئيسية:**
1. إضافة الفهارس المفقودة فوراً
2. إضافة UNIQUE و CHECK constraints
3. حل N+1 queries باستخدام JOINs
4. تحسين الاستعلامات البطيئة
