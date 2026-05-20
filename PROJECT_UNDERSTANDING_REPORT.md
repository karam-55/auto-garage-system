# تقرير الفهم الشامل لمشروع Garage Go

## ملخص المشروع

**الاسم:** Garage Go - Auto Garage Management System  
**التاريخ:** 20 مايو 2026  
**الهدف:** نظام إدارة ورشة سيارات شامل يتضمن المحاسبة المزدوجة، المخزون، CRM، ERP، والموارد البشرية

## المكونات الرئيسية

### 1. Backend (Dart + Shelf Framework)
**الموقع:** `C:\Users\FIX 11\projects\auto garrage\backend`

**التقنيات:**
- Dart SDK 3.11.5+
- Shelf Framework (REST API)
- PostgreSQL (قاعدة البيانات)
- JWT (المصادقة)
- bcrypt (تشفير كلمات المرور)
- Clean Architecture

**البنية:**
- **domain/entities/** (43 ملف) - الكيانات: User, Customer, Vehicle, Service, Booking, Account, JournalEntry, Vendor, Expense, FixedAsset, etc.
- **infrastructure/repositories/** (37 ملف) - تطبيقات المستودعات
- **application/services/** (14 ملف) - الخدمات: AuthService, JournalService, CRMService, HRService
- **application/usecases/** (40+ ملف) - حالات الاستخدام
- **presentation/routes/** (15 ملف) - المسارات: accounting_routes, auth_routes, booking_routes, financial_routes, public_routes, etc.
- **presentation/middlewares/** - الوسطاء: auth_middleware, error_middleware, json_middleware, logging_middleware

**الملفات الرئيسية:**
- `bin/server.dart` - نقطة الدخول الرئيسية
- `pubspec.yaml` - الحزم المستخدمة
- `lib/infrastructure/database/schema.sql` - هيكل قاعدة البيانات (670 سطر)

### 2. Admin Frontend (Flutter Web)
**الموقع:** `C:\Users\FIX 11\projects\auto garrage\admin_frontend`

**التقنيات:**
- Flutter Web
- Riverpod (State Management)
- HTTP (API Calls)
- FlChart (الرسوم البيانية)
- QR Flutter (QR Codes)
- Printing (طباعة الفواتير)

**البنية:**
- **lib/screens/** (42 شاشة)
  - **accounting/** (19 شاشة): chart_of_accounts, journal_entries, trial_balance, profit_loss, balance_sheet, general_ledger, cash_flow, break_even, trading_account, payroll, vendors, purchase_invoices, expenses, bank_accounts
  - **crm/** (3 شاشات): leads, crm_screen, create_lead
  - **hr/** (4 شاشات): employee_contracts, leave_requests, create_employee_contract, create_leave_request
  - **fixed_assets/** (2 شاشة): fixed_assets, create_fixed_asset
  - **manufacturing/** (2 شاشة): boms, manufacturing_orders
  - **purchasing/** (1 شاشة): purchase_orders
  - **sales/** (2 شاشات): quotations, sales_orders
  - **warehouse/** (2 شاشة): warehouses, inventory_transfers
  - **maintenance/** (1 شاشة): maintenance_contracts
  - **الشاشات الأساسية:** dashboard_screen, bookings_screen, customers_screen, services_screen, vehicles_screen, employees_screen, inventory_screen, company_settings_screen, change_password_screen

- **lib/core/**
  - **providers/** (7 ملف): accounting_providers, dashboard_providers, financial_providers, payroll_providers, report_providers, auth_provider, erp_providers
  - **services/**: api_service, auth_service, accounting_settings_service
  - **models/**: account, journal_entry, accounting_settings
  - **widgets/**: animated_sidebar, professional_dialog, loading_screen
  - **constants/**: api_constants
  - **theme/**: app_theme

### 3. Mechanic App (Flutter Mobile)
**الموقع:** `C:\Users\FIX 11\projects\auto garrage\mechanic_app_new`

**التقنيات:**
- Flutter (Mobile)
- Riverpod (State Management)
- Dio (HTTP Client)
- WebSocket (Real-time updates)
- SharedPreferences (Local Storage)
- Flutter Secure Storage

**البنية:**
- **lib/screens/** (6 شاشات):
  - login/login_screen.dart
  - available_bookings/available_bookings_screen.dart
  - my_assignments/my_assignments_screen.dart
  - consume_part/consume_part_screen.dart
  - update_maintenance_status/update_maintenance_status_screen.dart
  - vehicle_detail/vehicle_detail_screen.dart

- **lib/core/**
  - **constants/**: backend_constants
  - **network/**: dio_client
  - **error/**: exceptions, failures
  - **utils/**: error_handler
  - **logger**

- **lib/data/**
  - **datasources/**: auth_remote_datasource, booking_remote_datasource, inventory_remote_datasource, cache_datasource
  - **repositories/**: auth_repository_impl, booking_repository_impl, inventory_repository_impl
  - **models/**: booking_model, inventory_item_model, mechanic_assignment_model, user_model

- **lib/domain/**
  - **entities/**: booking, inventory_item, mechanic_assignment, part_suggestion, user
  - **repositories/**: auth_repository, booking_repository, inventory_repository, part_suggestion_repository
  - **usecases/**: login_usecase, get_available_bookings_usecase, assign_booking_usecase, consume_part_usecase, get_my_assignments_usecase, update_booking_status_usecase

### 4. Customer Frontend (HTML/JS)
**الموقع:** `C:\Users\FIX 11\projects\auto garrage\customer-frontend\index.html`

**التقنيات:**
- HTML5
- TailwindCSS (Styling)
- JavaScript (Vanilla)
- Google Fonts (Cairo)

**الخصائص:**
- ملف HTML واحد فقط
- يعتمد على `publicToken` للوصول إلى بيانات الحجز
- لا يتطلب أي شكل من أشكال تسجيل الدخول (لا username/password، لا OTP، لا مصادقة)
- يدعم اللغتين العربية والإنجليزية
- يدعم الوضع الليلي
- يعرض حالة السيارة، الخدمات، الملاحظات، وتاريخ التسليم المقدر
- تحديث تلقائي كل دقيقتين
- يمكن طباعة الفاتورة ومشاركة الرابط

**الـ API Endpoint المستخدم:**
- `GET /public/car/{publicCarId}` - لجلب بيانات السيارة والحجز

## قاعدة البيانات (PostgreSQL)

**الموقع:** `backend/lib/infrastructure/database/schema.sql`  
**عدد الجداول:** 40+ جدول

### الجداول المحاسبية (Accounting Tables):
1. **fiscal_periods** - الفترات المالية
2. **accounts** - دليل الحسابات (هرمي)
3. **journal_entries** - القيود اليومية
4. **journal_lines** - خطوط القيود (debit/credit)
5. **bank_accounts** - الحسابات البنكية
6. **bank_reconciliations** - التسويات البنكية
7. **reconciliation_lines** - خطوط التسوية
8. **vendors** - الموردين
9. **purchase_invoices** - فواتير الشراء
10. **purchase_invoice_items** - عناصر فواتير الشراء
11. **expenses** - النفقات
12. **payroll_settings** - إعدادات الرواتب
13. **salary_payments** - دفعات الرواتب

### الجداول الأساسية (Core System Tables):
1. **users** - المستخدمين (OWNER, MANAGER, RECEPTIONIST, MECHANIC, ACCOUNTANT, HR_MANAGER, MANAGER_SALES, MANAGER_WAREHOUSE)
2. **customers** - العملاء
3. **vehicles** - السيارات
4. **services** - الخدمات
5. **bookings** - الحجوزات
6. **booking_services** - خدمات الحجز
7. **mechanic_assignments** - تعيينات الميكانيكيين
8. **part_suggestions** - اقتراحات قطع الغيار
9. **company_settings** - إعدادات الشركة
10. **inventory_items** - عناصر المخزون
11. **inventory_variants** - متغيرات المخزون
12. **inventory_transactions** - معاملات المخزون
13. **booking_invoice_data** - بيانات فاتورة الحجز
14. **alerts** - التنبيهات

### جداول ERP:
1. **fixed_assets** - الأصول الثابتة
2. **depreciation_entries** - قيود الإهلاك
3. **maintenance_contracts** - عقود الصيانة
4. **quotations** - عروض الأسعار
5. **quotation_items** - عناصر عروض الأسعار
6. **sales_orders** - أوامر البيع
7. **sales_order_items** - عناصر أوامر البيع
8. **purchase_orders** - أوامر الشراء
9. **purchase_order_items** - عناصر أوامر الشراء
10. **warehouses** - المستودعات
11. **bill_of_materials** - قوائم المواد (BOM)
12. **bom_items** - عناصر BOM
13. **manufacturing_orders** - أوامر التصنيع

### جداول CRM:
1. **crm_leads** - العملاء المحتملين
2. **crm_activities** - أنشطة CRM

### جداول HR:
1. **employee_contracts** - عقود الموظفين
2. **leave_requests** - طلبات الإجازة
3. **performance_reviews** - تقييمات الأداء

## الـ API Endpoints الرئيسية

### Authentication
- `POST /api/auth/login` - تسجيل الدخول
- `POST /api/auth/register` - التسجيل (محمي بـ OWNER فقط)

### Customers
- `GET /api/customers` - قائمة العملاء
- `POST /api/customers` - إنشاء عميل
- `GET /api/customers/:id` - عرض عميل
- `PUT /api/customers/:id` - تحديث عميل
- `DELETE /api/customers/:id` - حذف عميل

### Vehicles
- `GET /api/vehicles` - قائمة السيارات
- `POST /api/vehicles` - إنشاء سيارة
- `GET /api/vehicles/:id` - عرض سيارة
- `PUT /api/vehicles/:id` - تحديث سيارة
- `GET /api/vehicles/customer/:customerId` - سيارات العميل

### Services
- `GET /api/services` - قائمة الخدمات
- `POST /api/services` - إنشاء خدمة
- `GET /api/services/:id` - عرض خدمة
- `PUT /api/services/:id` - تحديث خدمة

### Bookings
- `GET /api/bookings` - قائمة الحجوزات
- `POST /api/bookings` - إنشاء حجز
- `GET /api/bookings/:id` - عرض حجز
- `PATCH /api/bookings/:id/status` - تحديث حالة الحجز
- `GET /api/bookings/customer/:customerId` - حجوزات العميل
- `GET /api/bookings/status/:status` - حجوزات بحالة معينة

### Mechanics
- `GET /api/mechanics/available-bookings` - الحجوزات المتاحة للميكانيكيين
- `POST /api/mechanics/assign` - تعيين حجز للميكانيكي
- `GET /api/mechanics/my-assignments` - تعييناتي
- `PATCH /api/mechanics/assignments/:id/status` - تحديث حالة التعيين
- `POST /api/mechanics/bookings/:id/part-suggestions` - اقتراح قطعة غيار

### Inventory
- `GET /api/inventory/items` - قائمة عناصر المخزون
- `POST /api/inventory/items` - إنشاء عنصر (MANAGER)
- `PUT /api/inventory/items/:id` - تحديث عنصر (MANAGER)
- `DELETE /api/inventory/items/:id` - حذف عنصر (OWNER)
- `GET /api/inventory/variants` - قائمة المتغيرات
- `POST /api/inventory/variants` - إنشاء متغير (MANAGER)
- `PUT /api/inventory/variants/:id` - تحديث متغير (MANAGER)
- `DELETE /api/inventory/variants/:id` - حذف متغير (OWNER)
- `GET /api/inventory/low-stock` - عناصر المخزون المنخفض
- `POST /api/inventory/consume` - استهلاك قطعة (MECHANIC)

### Accounting
- `GET /api/accounts` - دليل الحسابات (OWNER, MANAGER, ACCOUNTANT)
- `POST /api/accounts` - إنشاء حساب (OWNER, ACCOUNTANT)
- `PUT /api/accounts/:id` - تحديث حساب (OWNER, ACCOUNTANT)
- `DELETE /api/accounts/:id` - حذف حساب (OWNER)
- `GET /api/journal-entries` - القيود اليومية (OWNER, MANAGER, ACCOUNTANT)
- `POST /api/journal-entries` - إنشاء قيد (OWNER, ACCOUNTANT)
- `GET /api/trial-balance` - ميزان المراجعة
- `GET /api/profit-loss` - قائمة الدخل
- `GET /api/balance-sheet` - الميزانية العمومية
- `GET /api/general-ledger` - دفتر الأستاذ العام
- `GET /api/cash-flow` - التدفقات النقدية
- `GET /api/break-even` - نقطة التعادل
- `GET /api/trading-account` - تقرير المتاجرة

### Financial (غير منفذ بالكامل)
- `GET /api/vendors` - الموردين
- `POST /api/vendors` - إنشاء مورد
- `PUT /api/vendors/:id` - تحديث مورد
- `DELETE /api/vendors/:id` - حذف مورد
- `GET /api/purchase-invoices` - فواتير الشراء
- `POST /api/purchase-invoices` - إنشاء فاتورة شراء
- `GET /api/expenses` - النفقات
- `POST /api/expenses` - إنشاء نفقة
- `GET /api/bank-accounts` - الحسابات البنكية
- `POST /api/bank-accounts` - إنشاء حساب بنكي

### Payroll
- `GET /api/payroll-settings` - إعدادات الرواتب
- `POST /api/payroll-settings` - تحديث إعدادات الرواتب
- `GET /api/salary-payments` - دفعات الرواتب
- `POST /api/salary-payments` - دفع الرواتب
- `GET /api/payroll-report` - تقرير الرواتب

### ERP
- `GET /api/fixed-assets` - الأصول الثابتة
- `POST /api/fixed-assets` - إنشاء أصل ثابت
- `GET /api/quotations` - عروض الأسعار
- `POST /api/quotations` - إنشاء عرض أسعار
- `GET /api/sales-orders` - أوامر البيع
- `POST /api/sales-orders` - إنشاء أمر بيع
- `GET /api/purchase-orders` - أوامر الشراء
- `POST /api/purchase-orders` - إنشاء أمر شراء
- `GET /api/warehouses` - المستودعات
- `POST /api/warehouses` - إنشاء مستودع
- `GET /api/inventory-transfers` - نقل المخزون
- `POST /api/inventory-transfers` - إنشاء نقل مخزون
- `GET /api/bill-of-materials` - قوائم المواد
- `POST /api/bill-of-materials` - إنشاء قائمة مواد
- `GET /api/manufacturing-orders` - أوامر الإنتاج
- `POST /api/manufacturing-orders` - إنشاء أمر إنتاج

### CRM
- `GET /api/crm-leads` - العملاء المحتملين
- `POST /api/crm-leads` - إنشاء عميل محتمل
- `GET /api/crm-activities` - أنشطة CRM
- `POST /api/crm-activities` - إنشاء نشاط

### HR
- `GET /api/employee-contracts` - عقود الموظفين
- `POST /api/employee-contracts` - إنشاء عقد موظف
- `GET /api/leave-requests` - طلبات الإجازة
- `POST /api/leave-requests` - إنشاء طلب إجازة

### Public (للزبائن)
- `GET /public/car/{publicCarId}` - عرض حالة السيارة والحجز
- `POST /public/seed-data` - إضافة بيانات تجريبية (للتطوير فقط)

## الأدوار والصلاحيات

### OWNER
- صلاحية كاملة على جميع الميزات
- إدارة المستخدمين والأدوار
- عرض جميع البيانات المالية
- تنفيذ جميع العمليات المحاسبية

### MANAGER
- صلاحية كاملة على الحجوزات، العملاء، السيارات، الخدمات
- عرض إحصائيات لوحة القيادة
- عرض التقارير المالية (قراءة فقط)
- لا يمكنه إدارة المستخدمين
- لا يمكنه إنشاء القيود اليومية

### ACCOUNTANT
- صلاحية كاملة على ميزات المحاسبة
- إدارة دليل الحسابات
- إنشاء وتعديل القيود اليومية
- عرض جميع التقارير المالية
- إدارة الموردين، فواتير الشراء، النفقات
- إجراء التسويات البنكية
- لا يمكنه الوصول للعمليات (الحجوزات، المخزون، إلخ)
- لا يمكنه إدارة المستخدمين

### RECEPTIONIST
- إنشاء وعرض الحجوزات
- إنشاء وعرض العملاء
- إنشاء وعرض السيارات
- لا يمكنه تعديل الخدمات أو المستخدمين
- لا يمكنه الوصول لميزات المحاسبة

### MECHANIC
- عرض الحجوزات المتاحة
- تعيين الحجوزات لنفسه
- تحديث حالة التعيين
- إنشاء اقتراحات قطع الغيار
- الوصول للمخزون (استهلاك القطع فقط)
- لا يمكنه الوصول للبيانات المالية

### HR_MANAGER
- إدارة عقود الموظفين
- إدارة طلبات الإجازة
- إدارة الرواتب

### MANAGER_SALES
- إدارة المبيعات
- إدارة عروض الأسعار
- إدارة أوامر البيع

### MANAGER_WAREHOUSE
- إدارة المخزون
- إدارة المستودعات
- إدارة نقل المخزون

## مدى الالتزام بالسياسات

### سياسة عدم استخدام البريد الإلكتروني

**النتيجة:** ❌ **انتهاك جزئي**

**الملفات التي تحتوي على "email":**
1. **crm_activity.dart** - `activity_type` يمكن أن يكون 'email' (هذا مجرد enum value لنوع النشاط، ليس تخزين بريد إلكتروني فعلي) - ✅ مقبول
2. **schema.sql** - `activity_type` يمكن أن يكون 'email' (مثل أعلاه) - ✅ مقبول
3. **database_connection.dart** - `activity_type` يمكن أن يكون 'email' (مثل أعلاه) - ✅ مقبول
4. **crm_screen.dart** - يستخدم `lead['email']` و `_emailController` - ❌ **انتهاك حقيقي**

**التوصية:** إزالة حقول البريد الإلكتروني من `crm_screen.dart` و `crm_leads` table في قاعدة البيانات.

### واجهة الزبون (Customer UI)

**النتيجة:** ✅ **مطابقة للسياسة**

- ملف HTML واحد فقط (`index.html`)
- يعتمد على `publicToken` للوصول إلى البيانات
- لا يتطلب أي شكل من أشكال تسجيل الدخول
- لا يخزن أي بيانات حساسة
- يستخدم الـ endpoint العام: `GET /public/car/{publicCarId}`

### واجهة الميكانيكي (Mechanic App)

**النتيجة:** ✅ **مطابقة للسياسة**

- مشروع Flutter منفصل
- يستخدم `username` و `password` لتسجيل الدخول
- لا يستخدم البريد الإلكتروني للمصادقة
- يستخدم الـ endpoints المخصصة للميكانيكيين

### واجهة الأدمن والموظفين (Admin Panel)

**النتيجة:** ✅ **مطابقة للسياسة**

- مشروع Flutter Web
- يستخدم `username` و `password` لتسجيل الدخول
- لا يستخدم البريد الإلكتروني للمصادقة
- يستخدم JWT tokens للمصادقة

## المشاكل الحرجة

### 1. Role.ACCOUNTANT لا يمكنه الوصول إلى endpoints المحاسبية
**الملف:** `backend/lib/presentation/routes/accounting_routes.dart`  
**الحالة:** ❌ غير مكتمل  
**التوصية:** إضافة `Role.ACCOUNTANT` إلى جميع endpoints المحاسبية

### 2. Financial routes غير منفذة
**الملف:** `backend/lib/presentation/routes/financial_routes.dart`  
**الحالة:** ❌ غير مكتمل  
**التوصية:** تنفيذ جميع endpoints في financial_routes

### 3. حقول البريد الإلكتروني تنتهك سياسة النظام
**الملفات:** `admin_frontend/lib/screens/crm/crm_screen.dart`, `backend/lib/infrastructure/database/schema.sql`  
**الحالة:** ❌ انتهاك  
**التوصية:** إزالة حقول البريد الإلكتروني من CRM

### 4. كلمات المرور مزيفة في seed.sql
**الملف:** `backend/lib/infrastructure/database/seed.sql`  
**الحالة:** ❌ غير آمن  
**التوصية:** استخدام bcrypt لتشفير كلمات المرور

## البيانات الحالية في قاعدة البيانات

- 10 عملاء
- 15 خدمة
- 5 سيارات
- 19 حساب محاسبي
- 10 عناصر مخزون
- 10 متغيرات مخزون

## معلومات النشر

### Backend
- **URL:** https://auto-garage-system-backend.onrender.com
- **Platform:** Render
- **Environment Variables:**
  - `DATABASE_URL`
  - `JWT_SECRET`
  - `JWT_REFRESH_SECRET`
  - `PORT`

### Admin Frontend
- **Platform:** Cloudflare Pages (Static Site)
- **Build Command:** `cd admin_frontend && flutter build web`
- **Output Directory:** `admin_frontend/build/web`

### بيانات تسجيل الدخول الافتراضية
- **Admin:** username: `admin`, password: `admin123`
- **Receptionist:** username: `receptionist`, password: `receptionist123`
- **Mechanic:** username: `mechanic`, password: `mechanic123`

## التوصيات للتحسين

1. **إصلاح المشاكل الحرجة الأربعة** قبل الإنتاج
2. **إزالة حقول البريد الإلكتروني** من CRM
3. **تنفيذ financial routes** بالكامل
4. **إضافة Role.ACCOUNTANT** إلى endpoints المحاسبية
5. **تشفير كلمات المرور** في seed.sql
6. **إضافة اختبارات وحدة** للباك إند
7. **إضافة اختبارات تكامل** للواجهات
8. **تحسين الأمان** بإضافة rate limiting على جميع endpoints
9. **إضافة logging** شامل لجميع العمليات
10. **إضافة monitoring** للأداء والأخطاء

## الخلاصة

المشروع "Garage Go" هو نظام إدارة ورشة سيارات شامل ومتطور يتضمن:
- Backend قوي باستخدام Clean Architecture
- واجهة أدمن ويب شاملة بـ 42 شاشة
- تطبيق ميكانيكي موبايل
- واجهة زبون عامة بسيطة
- نظام محاسبة مزدوجة متكامل
- نظام ERP شامل (المخزون، المبيعات، الشراء، التصنيع)
- نظام CRM لإدارة العملاء المحتملين
- نظام HR لإدارة الموظفين

المشروع جاهز للإنتاج بعد إصلاح المشاكل الحرجة الأربعة.
