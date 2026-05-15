# دليل المشروع الشامل - Auto Garage Management System
## للموديل الذكاء الاصطناعي

هذا التقرير الشامل يشرح المشروع بالكامل للذكاء الاصطناعي لفهمه والتعديل عليه بدون إتلافه.

---

## نظرة عامة على المشروع

**نظام إدارة ورشة سيارات (Auto Garage Management System)** - نظام مؤسسي لإدارة ورشة سيارات مبني باستخدام:
- **Backend**: Dart + Shelf (Clean Architecture)
- **Admin Frontend**: Flutter Web
- **Customer Frontend**: HTML/JS Static
- **Mechanic App**: Flutter Mobile
- **Database**: PostgreSQL

---

## هيكل المشروع

```
auto-garage-system/
├── backend/                 # Dart Backend (Clean Architecture)
│   ├── lib/
│   │   ├── core/           # Constants, errors, utils
│   │   ├── domain/         # Entities and repository interfaces
│   │   ├── infrastructure/ # Database connection and repository implementations
│   │   ├── application/    # Use cases and services
│   │   └── presentation/   # Routes, middlewares
│   ├── bin/server.dart     # Main server entry point
│   ├── pubspec.yaml
│   └── Dockerfile
├── admin_frontend/         # Flutter Web Admin App
│   ├── lib/
│   │   ├── core/          # Services, constants
│   │   ├── screens/       # UI screens
│   │   └── main.dart      # Main app file
│   └── pubspec.yaml
├── mechanic_app_new/       # Flutter Mobile Mechanic App
├── customer-frontend/      # Static HTML/JS customer tracking
│   └── index.html
└── docker-compose.yml
```

---

## Backend (Dart + Shelf)

### الاعتماديات الرئيسية
```yaml
dependencies:
  shelf: ^1.4.2              # Web server framework
  shelf_router: ^1.1.2       # Routing
  shelf_multipart: ^1.0.0     # File uploads
  shelf_web_socket: ^2.0.0   # WebSocket support
  postgres: ^3.0.0            # PostgreSQL driver
  bcrypt: ^1.1.3              # Password hashing
  uuid: ^4.4.0                # UUID generation
  logger: ^2.3.0              # Logging
  jwt_decoder: ^2.0.1         # JWT decoding
  crypto: ^3.0.5              # Cryptographic functions
  qr: ^3.0.1                  # QR code generation
  pdf: ^3.10.7                # PDF generation
  excel: ^4.0.3               # Excel export
```

### هيكل الـ Clean Architecture

#### 1. Core Layer (`lib/core/`)
- **Constants**: الثوابت المستخدمة في المشروع
- **Errors**: أنواع الأخطاء المخصصة
- **Utils**: دوال مساعدة

#### 2. Domain Layer (`lib/domain/`)
- **Entities**: الكيانات الأساسية (Customer, Vehicle, Booking, Service, etc.)
- **Repository Interfaces**: واجهات المستودعات

#### 3. Infrastructure Layer (`lib/infrastructure/`)
- **Database Connection**: اتصال قاعدة البيانات
- **Repository Implementations**: تطبيقات المستودعات الفعلية
- **Migrations**: ترحيلات قاعدة البيانات

#### 4. Application Layer (`lib/application/`)
- **Use Cases**: حالات الاستخدام
- **Services**: الخدمات

#### 5. Presentation Layer (`lib/presentation/`)
- **Routes**: تعريف مسارات API
- **Middlewares**: البرمجيات الوسيطة (Auth, CORS, Error Handling, Logging)

### ملفات Routes الرئيسية

#### 1. `auth_routes.dart` - المصادقة
- `POST /api/auth/login` - تسجيل الدخول
- `POST /api/auth/register` - التسجيل (محمي بـ OWNER فقط)
- `POST /api/auth/refresh` - تجديد التوكن
- `POST /api/auth/logout` - تسجيل الخروج

#### 2. `customer_routes.dart` - العملاء
- `GET /api/customers` - قائمة العملاء (RECEPTIONIST+)
- `POST /api/customers` - إنشاء عميل (RECEPTIONIST+)
- `GET /api/customers/:id` - عرض عميل (RECEPTIONIST+)
- `PUT /api/customers/:id` - تعديل عميل (RECEPTIONIST+)
- `DELETE /api/customers/:id` - حذف عميل (OWNER فقط)

#### 3. `vehicle_routes.dart` - السيارات
- `GET /api/vehicles` - قائمة السيارات (RECEPTIONIST+)
- `POST /api/vehicles` - إنشاء سيارة (RECEPTIONIST+)
- `GET /api/vehicles/:id` - عرض سيارة (RECEPTIONIST+)
- `PUT /api/vehicles/:id` - تعديل سيارة (RECEPTIONIST+)
- `DELETE /api/vehicles/:id` - حذف سيارة (OWNER فقط)
- `GET /api/vehicles/customer/:customerId` - سيارات العميل (RECEPTIONIST+)

#### 4. `service_routes.dart` - الخدمات
- `GET /api/services` - قائمة الخدمات (RECEPTIONIST+)
- `POST /api/services` - إنشاء خدمة (MANAGER+)
- `GET /api/services/:id` - عرض خدمة (RECEPTIONIST+)
- `PUT /api/services/:id` - تعديل خدمة (MANAGER+)
- `DELETE /api/services/:id` - حذف خدمة (OWNER فقط)

#### 5. `booking_routes.dart` - الحجوزات
- `GET /api/bookings` - قائمة الحجوزات (RECEPTIONIST+)
- `POST /api/bookings` - إنشاء حجز (RECEPTIONIST+)
- `GET /api/bookings/:id` - عرض حجز (RECEPTIONIST+)
- `PUT /api/bookings/:id` - تعديل حجز (RECEPTIONIST+)
- `DELETE /api/bookings/:id` - حذف حجز (OWNER فقط)
- `PATCH /api/bookings/:id/status` - تحديث حالة الحجز (RECEPTIONIST+)
- `GET /api/bookings/customer/:customerId` - حجوزات العميل (RECEPTIONIST+)
- `GET /api/bookings/status/:status` - حجوزات بحالة (RECEPTIONIST+)

#### 6. `mechanic_routes.dart` - الميكانيكيين
- `GET /api/mechanics/available-bookings` - الحجوزات المتاحة (MECHANIC+)
- `POST /api/mechanics/assign` - تعيين حجز لميكانيكي (MECHANIC+)
- `GET /api/mechanics/my-assignments` - مهامي (MECHANIC+)
- `PATCH /api/mechanics/assignments/:id/status` - تحديث حالة المهمة (MECHANIC+)
- `POST /api/mechanics/bookings/:id/part-suggestions` - اقتراح قطع غيار (MECHANIC+)

#### 7. `inventory_routes.dart` - المخزون
- `GET /api/inventory/items` - قائمة العناصر (RECEPTIONIST+)
- `POST /api/inventory/items` - إنشاء عنصر (MANAGER+)
- `PUT /api/inventory/items/:id` - تعديل عنصر (MANAGER+)
- `DELETE /api/inventory/items/:id` - حذف عنصر (OWNER فقط)
- `GET /api/inventory/variants` - قائمة المتغيرات (RECEPTIONIST+)
- `POST /api/inventory/variants` - إنشاء متغير (MANAGER+)
- `PUT /api/inventory/variants/:id` - تعديل متغير (MANAGER+)
- `DELETE /api/inventory/variants/:id` - حذف متغير (OWNER فقط)
- `GET /api/inventory/low-stock` - عناصر منخفضة المخزون (RECEPTIONIST+)
- `POST /api/inventory/consume` - استهلاك قطع غيار (MECHANIC+)

#### 8. `invoice_routes.dart` - الفواتير
- `GET /api/bookings/:id/invoice` - عرض فاتورة (RECEPTIONIST+)
- `GET /api/bookings/:id/invoice/pdf` - تحميل PDF (RECEPTIONIST+)

#### 9. `dashboard_routes.dart` - لوحة التحكم
- `GET /api/dashboard/stats` - إحصائيات (RECEPTIONIST+)
- `GET /api/dashboard/revenue?period=month` - الإيرادات (MANAGER+)

#### 10. `public_routes.dart` - المسارات العامة
- `GET /public/car/:publicCarId` - تتبع السيارة (بدون مصادقة)
- `GET /public/bookings/:publicToken` - تتبع الحجز (بدون مصادقة) - قديم

#### 11. `company_settings_routes.dart` - إعدادات الشركة
- `GET /api/company/settings` - عرض الإعدادات (RECEPTIONIST+)
- `PUT /api/company/settings` - تعديل الإعدادات (OWNER فقط)

### الأدوار والصلاحيات

```
OWNER (4) - أعلى صلاحية
├── Full access to all features
├── Can manage users and roles
└── Can view all financial data

MANAGER (3)
├── Full access to bookings, customers, vehicles, services
├── Can view dashboard statistics
└── Cannot manage users

RECEPTIONIST (2)
├── Can create and view bookings
├── Can create and view customers
├── Can create and view vehicles
└── Cannot modify services or users

MECHANIC (1) - أقل صلاحية
├── Can view available bookings
├── Can assign bookings to self
├── Can update assignment status
├── Can create part suggestions
└── Cannot access financial data
```

### قواعد مهمة للتعديل على Backend

1. **استخدام Sql.named**: دائماً استخدم `Sql.named` مع `Map<String, dynamic>` للمعاملات لمنع SQL Injection
2. **命名约定**: PostgreSQL تستخدم snake_case (full_name, created_at)، لكن الكيانات تستخدم camelCase (fullName, createdAt). Repository يتعامل مع التحويل.
3. **UUID**: جميع المفاتيح الأساسية هي UUID
4. **التحقق من الصلاحيات**: استخدم `_authMiddleware.authenticate()` و `_authMiddleware.requireRole()` للمسارات المحمية
5. **معالجة الأخطاء**: استخدم ErrorHandler.parseError(e) للتعامل مع الأخطاء بشكل موحد
6. **الترحيل**: استخدم runInTransaction للعمليات التي تحتاج commit صريح
7. **الإجابة**: Backend يُرجع JSON arrays مباشرة، ليس wrapped في `{data: [...]}`

---

## Admin Frontend (Flutter Web)

### الاعتماديات الرئيسية
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations: sdk: flutter
  http: ^1.2.2              # HTTP requests
  web_socket_channel: ^2.4.0  # WebSocket for real-time updates
  provider: ^6.1.2          # State management
  shared_preferences: ^2.2.3  # Local storage
  intl: ^0.20.2             # Internationalization
  qr_flutter: ^4.1.0         # QR code generation
  printing: ^5.12.0         # PDF printing
  file_picker: ^8.0.0       # File picker
  webview_flutter: any
  pdf: any
```

### هيكل المشروع

#### 1. Core Layer (`lib/core/`)
- **services/**: ApiService, AuthService, WebSocketService
- **constants/**: ApiConstants, app constants
- **widgets/**: Custom widgets (LoadingScreen, ProfessionalDialog, AnimatedSidebar)
- **utils/**: ErrorHandler, utilities

#### 2. Screens Layer (`lib/screens/`)

##### `main.dart`
- Entry point للـ app
- LoginScreen - تسجيل الدخول
- DashboardScreen - لوحة التحكم الرئيسية
- القائمة الجانبية (Sidebar) مع التنقل بين الشاشات

##### `overview_screen.dart`
- نظرة عامة على الإحصائيات
- Charts للإيرادات والحجوزات
- عرض الحجوزات الأخيرة

##### `bookings_screen.dart`
- قائمة الحجوزات مع البحث والتصفية
- **مهم**: زر "حجز لعميل جديد" (كان اسمه "حجز كامل") - ينقل إلى create_booking_screen.dart
- **مهم**: زر "إضافة حجز جديد" عندما تكون القائمة فارغة - يعمل مثل "حجز لعميل جديد"
- عرض تفاصيل الحجز
- تحديث حالة الحجز
- حذف الحجز
- عرض الفاتورة

##### `create_booking_screen.dart`
- إنشاء حجز لعميل جديد
- إدخال بيانات العميل
- إدخال بيانات السيارة
- اختيار الخدمات
- إضافة ملاحظات
- إنشاء الحجز

##### `quick_booking_screen.dart` - **مهم جداً**
- حجز لعميل مسجل مسبقاً (كان اسمه "حجز سريع")
- **مهم**: يستخدم Autocomplete للبحث عن العملاء المسجلين (ليس DropdownButtonFormField)
- **مهم**: عند اختيار عميل، يتم تحميل سياراته المسجلة مسبقاً
- يمكن إضافة سيارة جديدة إذا لم يكن لديه سيارات
- اختيار الخدمات
- إضافة ملاحظات
- إنشاء الحجز

##### `customers_screen.dart`
- قائمة العملاء مع البحث
- إنشاء عميل جديد
- تعديل عميل
- حذف عميل
- عرض سيارات العميل

##### `vehicles_screen.dart`
- قائمة السيارات
- إنشاء سيارة جديدة
- تعديل سيارة
- حذف سيارة

##### `services_screen.dart`
- قائمة الخدمات
- إنشاء خدمة جديدة
- تعديل خدمة
- حذف خدمة
- تفعيل/تعطيل خدمة

##### `employees_screen.dart`
- قائمة الموظفين
- إنشاء موظف جديد
- تعديل موظف
- حذف موظف
- تعديل الصلاحيات

##### `inventory_screen.dart`
- قائمة المخزون
- إنشاء عنصر جديد
- إنشاء متغير (ORIGINAL, COMMERCIAL, USED)
- تعديل الكميات
- عرض تنبيهات المخزون المنخفض

##### `reports_screen.dart`
- التقارير المالية
- تقارير الحجوزات
- تصدير Excel

##### `company_settings_screen.dart`
- إعدادات الشركة
- اسم الشركة
- شعار الشركة

##### `change_password_screen.dart`
- تغيير كلمة المرور

##### `invoice_screen.dart`
- عرض الفاتورة
- طباعة الفاتورة
- تحميل PDF
- عرض QR Code

##### `api_docs_screen.dart`
- وثائق API

### القائمة الجانبية (Sidebar)
القائمة الجانبية تحتوي على:
1. نظرة عامة
2. الحجوزات
3. حجز لعميل مسجل مسبقاً (كان اسمه "حجز سريع")
4. العملاء
5. السيارات
6. الخدمات
7. الموظفين
8. التقارير
9. المخزون
10. إعدادات النظام
11. كلمة المرور

### قواعد مهمة للتعديل على Admin Frontend

1. **API Response Handling**: Backend يُرجع JSON arrays مباشرة، استخدم `List<Map<String, dynamic>>` للتعامل معها
2. **Autocomplete vs Dropdown**: استخدم Autocomplete للبحث والاختيار من قائمة كبيرة، DropdownButtonFormField قد لا يعمل بشكل صحيح
3. **State Management**: استخدم setState لإدارة الحالة المحلية
4. **Error Handling**: استخدم ErrorHandler.showError لعرض الأخطاء
5. **Loading States**: استخدم CircularProgressIndicator أثناء التحميل
6. **WebSocket**: WebSocketService يستخدم للتحديثات الحية (مثل تنبيهات المخزون المنخفض)
7. **Language**: التطبيق يدعم العربية والإنجليزية، استخدم flutter_localizations
8. **Theme**: التطبيق يدعم Dark Mode و Light Mode

---

## Customer Frontend (HTML/JS Static)

### الملف الرئيسي
- `customer-frontend/index.html` - صفحة واحدة فقط

### الوظائف
1. **تتبع الحجز عبر QR Code**:
   - يدعم URL parameters: `publicCarId` أو `car`
   - عند وجود `publicCarId` في URL، يتم تحميل بيانات الحجز مباشرة بدون إدخال رمز
   - يستدعي API: `${API_BASE_URL}/public/car/${publicCarId}`

2. **تتبع الحجز يدوياً**:
   - إذا لم يوجد `publicCarId` في URL، يظهر نموذج إدخال رمز التتبع
   - يدخل المستخدم رمز التتبع (publicToken أو publicCarId)
   - يستدعي API: `${API_BASE_URL}/public/car/${token}`

3. **عرض البيانات**:
   - معلومات السيارة (الماركة، الموديل، اللوحة، اللون)
   - معلومات العميل (الاسم، الهاتف)
   - الخدمات المطلوبة مع الأسعار
   - حالة الحجز
   - تاريخ الانتهاء المتوقع
   - الملاحظات
   - QR Code (إن وجد)

4. **دعم اللغتين**:
   - العربية (RTL)
   - الإنجليزية (LTR)
   - زر تبديل اللغة

5. **إعدادات الشركة**:
   - اسم الشركة
   - شعار الشركة
   - يتم تحميلها من API: `${API_BASE_URL}/public/company-settings`

### قواعد مهمة للتعديل على Customer Frontend

1. **URL Parameters**: دائماً افحص `publicCarId` و `car` في URL
2. **API Endpoint**: استخدم `/public/car/{publicCarId}` وليس `/public/bookings/{publicToken}`
3. **Direct Access**: عند وجود `publicCarId` في URL، لا تظهر نموذج إدخال الرمز
4. **No Email**: لا توجد أي إشارة للبريد الإلكتروني في هذا الملف
5. **Public Access**: هذه الصفحة عامة ولا تتطلب مصادقة

---

## قاعدة البيانات (PostgreSQL)

### الجداول الرئيسية

#### 1. `users` - مستخدمي النظام
```sql
- id: UUID (PK)
- full_name: VARCHAR(255) NOT NULL
- username: VARCHAR(100) UNIQUE NOT NULL
- password_hash: VARCHAR(255) NOT NULL
- role: VARCHAR(50) NOT NULL (OWNER, MANAGER, RECEPTIONIST, MECHANIC)
- is_active: BOOLEAN DEFAULT true
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

#### 2. `customers` - العملاء
```sql
- id: UUID (PK)
- full_name: VARCHAR(255) NOT NULL
- phone: VARCHAR(20) NOT NULL
- address: TEXT
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

#### 3. `vehicles` - السيارات
```sql
- id: UUID (PK)
- customer_id: UUID (FK to customers)
- make: VARCHAR(100) NOT NULL
- model: VARCHAR(100) NOT NULL
- year: INTEGER NOT NULL
- license_plate: VARCHAR(20)
- vin: VARCHAR(50)
- public_car_id: VARCHAR(255) UNIQUE NOT NULL DEFAULT '' (مضاف لاحقاً)
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

#### 4. `services` - الخدمات
```sql
- id: UUID (PK)
- name: VARCHAR(255) NOT NULL
- description: TEXT
- price_syp: DECIMAL(12, 2) NOT NULL
- estimated_duration_minutes: INTEGER
- is_active: BOOLEAN DEFAULT true
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

#### 5. `bookings` - الحجوزات
```sql
- id: UUID (PK)
- customer_id: UUID (FK to customers)
- vehicle_id: UUID (FK to vehicles)
- status: VARCHAR(50) NOT NULL (PENDING, IN_PROGRESS, WAITING_PARTS, READY, DELIVERED, CANCELLED)
- public_token: VARCHAR(255) UNIQUE NOT NULL
- notes: TEXT
- estimated_completion_date: TIMESTAMP
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

#### 6. `booking_services` - الخدمات لكل حجز
```sql
- id: UUID (PK)
- booking_id: UUID (FK to bookings)
- service_id: UUID (FK to services)
- price_syp: DECIMAL(12, 2) NOT NULL
- notes: TEXT
- UNIQUE(booking_id, service_id)
```

#### 7. `mechanic_assignments` - تعيينات الميكانيكيين
```sql
- id: UUID (PK)
- booking_id: UUID (FK to bookings)
- mechanic_user_id: UUID (FK to users)
- status: VARCHAR(50) (ASSIGNED, IN_PROGRESS, WAITING_PARTS, READY, DELIVERED)
- notes: TEXT
- assigned_at: TIMESTAMP
- updated_at: TIMESTAMP
- UNIQUE(booking_id)
```

#### 8. `part_suggestions` - اقتراحات القطع
```sql
- id: UUID (PK)
- booking_id: UUID (FK to bookings)
- mechanic_user_id: UUID (FK to users)
- type: VARCHAR(50) (ORIGINAL, COMMERCIAL, USED)
- description: TEXT NOT NULL
- price_syp: DECIMAL(12, 2)
- status: VARCHAR(50) (PENDING_CUSTOMER_APPROVAL, APPROVED, REJECTED)
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

#### 9. `company_settings` - إعدادات الشركة
```sql
- id: SERIAL (PK)
- company_name: VARCHAR(255) NOT NULL DEFAULT 'Garage Go'
- company_logo_url: TEXT
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

#### 10. `inventory_items` - عناصر المخزون
```sql
- id: UUID (PK)
- name: VARCHAR(255) NOT NULL
- category: VARCHAR(100)
- unit: VARCHAR(50)
- low_stock_threshold: INTEGER DEFAULT 5
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

#### 11. `inventory_variants` - متغيرات المخزون
```sql
- id: UUID (PK)
- item_id: UUID (FK to inventory_items)
- variant_type: VARCHAR(50) (ORIGINAL, COMMERCIAL, USED)
- quantity: INTEGER DEFAULT 0
- cost_price: DECIMAL(12, 2) DEFAULT 0
- selling_price: DECIMAL(12, 2) DEFAULT 0
- supplier: VARCHAR(255)
- created_at: TIMESTAMP
```

#### 12. `inventory_transactions` - معاملات المخزون
```sql
- id: UUID (PK)
- item_id: UUID (FK to inventory_items)
- variant_id: UUID (FK to inventory_variants)
- booking_id: UUID (FK to bookings)
- mechanic_id: UUID (FK to users)
- type: VARCHAR(50) (CONSUME, ADD, RETURN)
- quantity: INTEGER NOT NULL
- notes: TEXT
- created_at: TIMESTAMP
```

#### 13. `booking_invoice_data` - بيانات الفاتورة
```sql
- id: UUID (PK)
- booking_id: UUID (FK to bookings) UNIQUE
- services_snapshot: JSONB
- parts_snapshot: JSONB
- total_price: DECIMAL(12, 2) DEFAULT 0
- invoice_created_at: TIMESTAMP
- public_token: VARCHAR(255)
- qr_code_url: TEXT
```

#### 14. `alerts` - التنبيهات
```sql
- id: UUID (PK)
- type: VARCHAR(50) (LOW_STOCK, SYSTEM, BOOKING)
- related_id: UUID
- message: TEXT NOT NULL
- is_read: BOOLEAN DEFAULT false
- created_at: TIMESTAMP
```

### الفهارس (Indexes)
- جميع المفاتيح الأجنبية مفهرسة
- indexes على: username, role, phone, customer_id, license_plate, status, public_token, is_active, etc.

---

## API Endpoints الكاملة

### Authentication
```
POST /api/auth/login
POST /api/auth/register (OWNER only)
POST /api/auth/refresh
POST /api/auth/logout
```

### Customers
```
GET /api/customers (RECEPTIONIST+)
POST /api/customers (RECEPTIONIST+)
GET /api/customers/:id (RECEPTIONIST+)
PUT /api/customers/:id (RECEPTIONIST+)
DELETE /api/customers/:id (OWNER only)
```

### Vehicles
```
GET /api/vehicles (RECEPTIONIST+)
POST /api/vehicles (RECEPTIONIST+)
GET /api/vehicles/:id (RECEPTIONIST+)
PUT /api/vehicles/:id (RECEPTIONIST+)
DELETE /api/vehicles/:id (OWNER only)
GET /api/vehicles/customer/:customerId (RECEPTIONIST+)
```

### Services
```
GET /api/services (RECEPTIONIST+)
POST /api/services (MANAGER+)
GET /api/services/:id (RECEPTIONIST+)
PUT /api/services/:id (MANAGER+)
DELETE /api/services/:id (OWNER only)
```

### Bookings
```
GET /api/bookings (RECEPTIONIST+)
POST /api/bookings (RECEPTIONIST+)
GET /api/bookings/:id (RECEPTIONIST+)
PUT /api/bookings/:id (RECEPTIONIST+)
DELETE /api/bookings/:id (OWNER only)
PATCH /api/bookings/:id/status (RECEPTIONIST+)
GET /api/bookings/customer/:customerId (RECEPTIONIST+)
GET /api/bookings/status/:status (RECEPTIONIST+)
```

### Mechanics
```
GET /api/mechanics/available-bookings (MECHANIC+)
POST /api/mechanics/assign (MECHANIC+)
GET /api/mechanics/my-assignments (MECHANIC+)
PATCH /api/mechanics/assignments/:id/status (MECHANIC+)
POST /api/mechanics/bookings/:id/part-suggestions (MECHANIC+)
```

### Inventory
```
GET /api/inventory/items (RECEPTIONIST+)
POST /api/inventory/items (MANAGER+)
PUT /api/inventory/items/:id (MANAGER+)
DELETE /api/inventory/items/:id (OWNER only)
GET /api/inventory/variants (RECEPTIONIST+)
POST /api/inventory/variants (MANAGER+)
PUT /api/inventory/variants/:id (MANAGER+)
DELETE /api/inventory/variants/:id (OWNER only)
GET /api/inventory/low-stock (RECEPTIONIST+)
POST /api/inventory/consume (MECHANIC+)
```

### Invoices
```
GET /api/bookings/:id/invoice (RECEPTIONIST+)
GET /api/bookings/:id/invoice/pdf (RECEPTIONIST+)
```

### Dashboard
```
GET /api/dashboard/stats (RECEPTIONIST+)
GET /api/dashboard/revenue?period=month (MANAGER+)
```

### Public (No Authentication)
```
GET /public/car/:publicCarId - تتبع السيارة
GET /public/bookings/:publicToken - تتبع الحجز (قديم)
GET /public/company-settings - إعدادات الشركة
```

### Company Settings
```
GET /api/company/settings (RECEPTIONIST+)
PUT /api/company/settings (OWNER only)
```

---

## قواعد ذهبية للتعديل

### ❌ لا تفعل أبداً
1. **لا تضيف حقول email** في أي جدول أو واجهة - المشروع ممنوع استخدام البريد الإلكتروني
2. **لا تستخدم SQL مباشرة** بدون Sql.named - استخدم دائماً Sql.named مع parameters
3. **لا تُرجع wrapped responses** مثل `{data: [...]}` - Backend يُرجع arrays مباشرة
4. **لا تستخدم DropdownButtonFormField** للقوائم الكبيرة - استخدم Autocomplete بدلاً منها
5. **لا تنسى التحقق من الصلاحيات** - استخدم دائماً auth middleware للتحقق
6. **لا تنسى التحقق من null** - استخدم ?? للتعامل مع null values
7. **لا تستخدم snake_case في الكيانات** - استخدم camelCase، Repository يتعامل مع التحويل

### ✅ افعل دائماً
1. **استخدم UUID** لجميع المفاتيح الأساسية
2. **استخدم Sql.named** مع Map<String, dynamic> للمعاملات
3. **استخدم runInTransaction** للعمليات التي تحتاج commit صريح
4. **استخدم ErrorHandler.parseError** للتعامل مع الأخطاء
5. **استخدم List<Map<String, dynamic>>** للتعامل مع API responses
6. **استخدم setState** لإدارة الحالة في Flutter
7. **استخدم Autocomplete** للبحث والاختيار من قائمة كبيرة
8. **تحقق من الصلاحيات** قبل السماح بالوصول
9. **استخدم type-safe parsing** للقيم العددية (int.tryParse, double.tryParse)
10. **استخدم logging** للتصحيح (print statements)

### 🎯 التسمية والاتفاقيات
1. **Database**: snake_case (full_name, created_at)
2. **Backend Entities**: camelCase (fullName, createdAt)
3. **Frontend**: camelCase
4. **API Endpoints**: kebab-case (/api/customers/:id)
5. **File Names**: snake_case (customer_routes.dart)
6. **Class Names**: PascalCase (CustomerRepository)
7. **Variable Names**: camelCase (selectedCustomerId)

### 🔐 الأمان
1. **JWT Tokens**: تستخدم HS256 مع JWT_SECRET
2. **Password Hashing**: bcrypt
3. **CORS**: قابلة للتكوين عبر CORS_ORIGIN
4. **Rate Limiting**: 5 محاولات تسجيل دخول كل 15 دقيقة
5. **Input Validation**: trimming و رفض strings فارغة
6. **SQL Injection**: محمي عبر Sql.named

---

## نصائح للموديل الذكاء الاصطناعي

### عند التعديل على Backend
1. اقرأ أولاً الملفات الموجودة في نفس المجلح لفهم النمط
2. استخدم نفس نمط Clean Architecture
3. تأكد من استخدام Sql.named لجميع الاستعلامات
4. تأكد من التحقق من الصلاحيات
5. تأكد من معالجة الأخطاء بشكل صحيح
6. أضف logging للتصحيح
7. اختبر التغييرات قبل الالتزام

### عند التعديل على Admin Frontend
1. استخدم Autocomplete للقوائم الكبيرة
2. استخدم List<Map<String, dynamic>> للـ API responses
3. استخدم setState لإدارة الحالة
4. استخدم ErrorHandler.showError للأخطاء
5. استخدم CircularProgressIndicator للتحميل
6. تأكد من دعم RTL للعربية
7. اختبر التغييرات قبل الالتزام

### عند التعديل على Customer Frontend
1. تأكد من دعم publicCarId و car في URL
2. استخدم /public/car/{publicCarId} API endpoint
3. تأكد من العمل بدون مصادقة
4. تأكد من دعم اللغتين العربية والإنجليزية
5. لا تضيف أي إشارة للبريد الإلكتروني

### عند التعديل على قاعدة البيانات
1. استخدم UUID للمفاتيح الأساسية
2. استخدم snake_case لأسماء الأعمدة
3. أضف indexes للأعمدة المستخدمة في البحث
4. استخدم proper constraints (FK, UNIQUE, CHECK)
5. استخدم DECIMAL(12, 2) للأسعار
6. استخدم TIMESTAMP WITH TIME ZONE للتواريخ

---

## المشاكل الشائعة والحلول

### المشكلة: DropdownButtonFormField لا يعمل
**الحل**: استخدم Autocomplete بدلاً من DropdownButtonFormField للقوائم الكبيرة

### المشكلة: API response parsing error
**الحل**: استخدم List<Map<String, dynamic>> للتعامل مع arrays، Backend يُرجع arrays مباشرة

### المشكلة: SQL Injection
**الحل**: استخدم Sql.named مع Map<String, dynamic> للمعاملات

### المشكلة: Transaction not committed
**الحل**: استخدم runInTransaction للعمليات التي تحتاج commit صريح

### المشكلة: Null pointer exception
**الحل**: استخدم ?? للتعامل مع null values، تحقق من null قبل الاستخدام

### المشكلة: CORS error
**الحل**: تأكد من إعداد CORS_ORIGIN في .env

---

## البيانات الحساسة

### Environment Variables (backend/.env)
```
DATABASE_URL=postgresql://...
JWT_SECRET=...
JWT_REFRESH_SECRET=...
PORT=8080
CORS_ORIGIN=...
```

### Default Users
- Admin: username: `admin`, password: `admin123`
- Receptionist: username: `receptionist`, password: `receptionist123`
- Mechanic: username: `mechanic`, password: `mechanic123`

---

## النشر

### Backend (Render)
- يتم نشره على Render تلقائياً عند git push
- يستخدم render.yaml للتكوين
- يتطلب DATABASE_URL, JWT_SECRET, JWT_REFRESH_SECRET, PORT

### Admin Frontend (Cloudflare Pages)
- يتم نشره يدوياً عبر upload build/web folder
- أو يمكن ربطه بـ GitHub للنشر التلقائي
- يتطلب flutter build web قبل النشر

### Customer Frontend (Cloudflare Pages)
- ملف static HTML/JS
- يتم نشره يدوياً عبر upload customer-frontend folder
- URL: https://auto-garage-customer-frontend.pages.dev/

---

## الخلاصة

هذا المشروع هو نظام إدارة ورشة سيارات كامل باستخدام:
- Backend: Dart + Shelf مع Clean Architecture
- Admin Frontend: Flutter Web
- Customer Frontend: Static HTML/JS
- Database: PostgreSQL

**أهم قاعدة**: لا تضيف أي إشارة للبريد الإلكتروني في أي مكان من المشروع.

**أهم تقنية**: استخدم Sql.named مع Map<String, dynamic> لجميع الاستعلامات في Backend.

**أهم UI pattern**: استخدم Autocomplete بدلاً من DropdownButtonFormField للقوائم الكبيرة في Flutter.

**أهم API pattern**: Backend يُرجع JSON arrays مباشرة، ليس wrapped في `{data: []}`.

عند التعديل، اتبع دائماً الأنماط الموجودة ولا تبتكر أنماط جديدة بدون سبب واضح.
