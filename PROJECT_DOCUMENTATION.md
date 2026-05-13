# Garage Go - توثيق المشروع الشامل

## 1) نظرة عامة على المشروع (Overview)

### اسم المشروع
**Garage Go**

### وصف مختصر
نظام إدارة حجوزات متكامل لمراكز صيانة السيارات، يوفر واجهات متعددة للأدمن والموظفين والميكانيكيين والزبائن. النظام يتيح إدارة الحجوزات، العملاء، السيارات، الخدمات، الموظفين، والتقارير بشكل سهل وفعال. يدعم النظام إعدادات الشركة المخصصة (اسم الموقع واللوغو) التي تظهر في جميع الواجهات.

### مكونات النظام الرئيسية

#### 1. Backend (الخادم / API / منطق الأعمال)
- **التقنية**: Dart with Shelf Framework
- **الموقع**: `backend/`
- **المسؤوليات**:
  - توفير RESTful APIs
  - منطق الأعمال (Business Logic)
  - إدارة قاعدة البيانات
  - المصادقة والصلاحيات
  - معالجة الطلبات من جميع الواجهات

#### 2. قاعدة البيانات (Database)
- **النوع**: PostgreSQL
- **الموقع**: `backend/lib/infrastructure/database/schema.sql`
- **المسؤوليات**:
  - تخزين جميع بيانات النظام
  - العلاقات بين الجداول
  - حفظ إعدادات الشركة

#### 3. واجهة الأدمن والموظفين (Web Admin Panel)
- **التقنية**: Flutter Web
- **الموقع**: `admin_frontend/`
- **المسؤوليات**:
  - إدارة الحجوزات
  - إدارة العملاء والسيارات
  - إدارة الخدمات والموظفين
  - عرض التقارير
  - إعدادات النظام

#### 4. واجهة الميكانيكي (Android App)
- **التقنية**: Flutter (Android)
- **الموقع**: `mechanic_app_new/`
- **المسؤوليات**:
  - عرض الحجوزات الموكلة للميكانيكي
  - تحديث حالة الحجز
  - إضافة ملاحظات الصيانة
  - اقتراح قطع الغيار

#### 5. واجهة الزبون (Customer UI - Single HTML File)
- **التقنية**: HTML + JavaScript + TailwindCSS
- **الموقع**: `customer-frontend/index.html`
- **المسؤوليات**:
  - عرض معلومات الشركة
  - تتبع حالة الحجز
  - عرض تفاصيل السيارة والخدمات

### كيفية تفاعل المكونات مع بعضها

```
┌─────────────────┐
│  Admin Panel    │
│  (Flutter Web)  │
└────────┬────────┘
         │ HTTP/REST API
         ↓
┌─────────────────┐
│   Backend       │
│   (Dart/Shelf)  │
└────────┬────────┘
         │ PostgreSQL
         ↓
┌─────────────────┐
│   Database      │
│   (PostgreSQL)  │
└─────────────────┘
         ↑
         │ HTTP/REST API
┌────────┴────────┐
│  Mechanic App   │
│  (Flutter)      │
└─────────────────┘
         ↑
         │ HTTP/REST API
┌────────┴────────┐
│  Customer UI    │
│  (HTML/JS)      │
└─────────────────┘
```

**تدفق البيانات**:
1. جميع الواجهات تتصل بالـ Backend عبر RESTful APIs
2. Backend يتصل بقاعدة البيانات PostgreSQL
3. Company Settings يتم جلبها من قاعدة البيانات وتظهر في جميع الواجهات
4. الحجوزات التي يتم إنشاؤها من أي واجهة تظهر في جميع الواجهات الأخرى

---

## 2) البنية الخلفية (Backend Architecture)

### التقنية المستخدمة
- **اللغة**: Dart
- **الإطار**: Shelf (HTTP Server Framework)
- **قاعدة البيانات**: PostgreSQL
- **المصادقة**: JWT (JSON Web Tokens)

### طبقات النظام (Layers)

```
lib/
├── domain/                    # Domain Layer
│   ├── entities/             # Business Entities
│   ├── repositories/         # Repository Interfaces
│   └── value_objects/        # Value Objects
├── infrastructure/            # Infrastructure Layer
│   ├── database/             # Database Connection
│   └── repositories/         # Repository Implementations
├── application/              # Application Layer
│   ├── services/             # Application Services
│   └── usecases/            # Use Cases
└── presentation/             # Presentation Layer
    ├── routes/               # API Routes
    └── middlewares/          # HTTP Middlewares
```

#### 1. Controllers / Routes
- **الموقع**: `lib/presentation/routes/`
- **المسؤوليات**:
  - استقبال HTTP Requests
  - التحقق من الصلاحيات
  - استدعاء Use Cases أو Repositories
  - إرجاع HTTP Responses

**الملفات الرئيسية**:
- `auth_routes.dart` - مصادقة المستخدمين
- `customer_routes.dart` - إدارة العملاء
- `vehicle_routes.dart` - إدارة السيارات
- `service_routes.dart` - إدارة الخدمات
- `booking_routes.dart` - إدارة الحجوزات
- `mechanic_routes.dart` - مهام الميكانيكيين
- `dashboard_routes.dart` - إحصائيات اللوحة
- `company_settings_routes.dart` - إعدادات الشركة
- `public_routes.dart` - نقاط الوصول العامة

#### 2. Services / UseCases
- **الموقع**: `lib/application/`
- **المسؤوليات**:
  - منطق الأعمال المعقد
  - التنسيق بين Repositories
  - معالجة الأخطاء

**الملفات الرئيسية**:
- `services/auth_service.dart` - خدمة المصادقة
- `usecases/create_booking_usecase.dart` - إنشاء حجز
- `usecases/assign_mechanic_usecase.dart` - تعيين ميكانيكي
- `usecases/update_booking_status_usecase.dart` - تحديث حالة الحجز

#### 3. Repositories / Data Access
- **الموقع**: `lib/infrastructure/repositories/`
- **المسؤوليات**:
  - التفاعل مع قاعدة البيانات
  - CRUD Operations
  - Mapping بين Database Records و Entities

**الملفات الرئيسية**:
- `user_repository_impl.dart` - إدارة المستخدمين
- `customer_repository_impl.dart` - إدارة العملاء
- `vehicle_repository_impl.dart` - إدارة السيارات
- `service_repository_impl.dart` - إدارة الخدمات
- `booking_repository_impl.dart` - إدارة الحجوزات
- `booking_service_repository_impl.dart` - خدمات الحجز
- `mechanic_assignment_repository_impl.dart` - تعيينات الميكانيكي
- `part_suggestion_repository_impl.dart` - اقتراحات قطع الغيار
- `company_settings_repository_impl.dart` - إعدادات الشركة

#### 4. Models / Entities
- **الموقع**: `lib/domain/entities/`
- **المسؤوليات**:
  - تمثيل بيانات الأعمال
  - Validation Rules
  - JSON Serialization

**الملفات الرئيسية**:
- `user.dart` - كيان المستخدم
- `customer.dart` - كيان العميل
- `vehicle.dart` - كيان السيارة
- `service.dart` - كيان الخدمة
- `booking.dart` - كيان الحجز
- `booking_service.dart` - خدمة الحجز
- `mechanic_assignment.dart` - تعيين الميكانيكي
- `part_suggestion.dart` - اقتراح قطعة غيار
- `company_settings.dart` - إعدادات الشركة
- `role.dart` - أدوار المستخدمين
- `booking_status.dart` - حالات الحجز

### منطق الأعمال الأساسي

#### 1. إدارة العملاء (Customers)
- **العمليات**:
  - إنشاء عميل جديد
  - البحث عن عميل (بالاسم أو رقم الهاتف)
  - عرض جميع العملاء
  - تحديث بيانات العميل
  - حذف العميل

- **القواعد**:
  - رقم الهاتف يجب أن يكون فريداً
  - الاسم مطلوب
  - العنوان اختياري

#### 2. إدارة السيارات (Vehicles)
- **العمليات**:
  - إنشاء سيارة جديدة
  - البحث عن سيارة (باللوحة)
  - عرض سيارات عميل معين
  - تحديث بيانات السيارة
  - حذف السيارة

- **القواعد**:
  - كل سيارة مرتبطة بعميل واحد
  - رقم اللوحة مطلوب
  - العميل يجب أن يكون موجوداً

#### 3. إدارة الحجوزات (Bookings)
- **العمليات**:
  - إنشاء حجز جديد
  - عرض جميع الحجوزات
  - عرض حجوزات عميل معين
  - تحديث حالة الحجز
  - إضافة خدمات للحجز
  - تعيين ميكانيكي للحجز

- **القواعد**:
  - كل حجز مرتبط بعميل وسيارة
  - الحجز يمكن أن يحتوي على عدة خدمات
  - حالة الحجز: PENDING, IN_PROGRESS, WAITING_PARTS, READY, DELIVERED

#### 4. إدارة الخدمات (Services)
- **العمليات**:
  - إنشاء خدمة جديدة
  - عرض جميع الخدمات
  - تحديث سعر الخدمة
  - حذف الخدمة

- **القواعد**:
  - اسم الخدمة مطلوب
  - السعر بالليرة السورية
  - الوصف اختياري

#### 5. إدارة الموظفين (Employees)
- **العمليات**:
  - إنشاء مستخدم جديد
  - تحديث كلمة المرور
  - حذف المستخدم
  - عرض جميع المستخدمين

- **القواعد**:
  - اسم المستخدم فريد
  - كلمة المرور مشفرة (BCrypt)
  - الأدوار: OWNER, MANAGER, RECEPTIONIST, MECHANIC

#### 6. إدارة التقارير (Reports)
- **العمليات**:
  - إحصائيات Dashboard
  - إحصائيات الإيرادات
  - عدد الحجوزات حسب الحالة
  - عدد العملاء والسيارات

#### 7. إعدادات النظام / الشركة (Company Settings)
- **العمليات**:
  - جلب إعدادات الشركة
  - تحديث اسم الشركة
  - تحديث رابط اللوغو

- **القواعد**:
  - اسم الشركة افتراضياً: 'Garage Go'
  - اللوغو اختياري (URL)
  - يتم استخدام هذه الإعدادات في جميع الواجهات

### المصادقة (Authentication)
- **الطريقة**: JWT (JSON Web Tokens)
- **العملية**:
  1. المستخدم يرسل username و password
  2. Backend يتحقق من البيانات
  3. Backend يُنشئ JWT Token
  4. Token يُرسل للمستخدم
  5. المستخدم يُرسل Token في Header لكل طلب
  6. Middleware يتحقق من Token قبل الوصول للـ Routes

### الصلاحيات (Authorization)
- **الأدوار (Roles)**:
  - `OWNER`: صلاحيات كاملة
  - `MANAGER`: إدارة الموظفين والحجوزات والتقارير
  - `RECEPTIONIST`: إدارة الحجوزات والعملاء والسيارات
  - `MECHANIC`: عرض الحجوزات الموكلة وتحديث حالتها

- **Middleware**: `AuthMiddleware` في `lib/presentation/middlewares/`
  - `authenticate()`: التحقق من وجود Token صالح
  - `requireRole(Role)`: التحقق من صلاحية المستخدم

### الـ APIs الرئيسية

#### 1. Endpoints الخاصة بالعملاء
- **GET `/api/customers`**: عرض جميع العملاء
  - **Output**: List<Customer>
  - **Purpose**: عرض قائمة العملاء في واجهة الأدمن

- **POST `/api/customers`**: إنشاء عميل جديد
  - **Input**: `{ fullName, phone, address }`
  - **Output**: Customer
  - **Purpose**: إضافة عميل جديد أثناء إنشاء حجز

- **GET `/api/customers/:id`**: عرض عميل معين
  - **Input**: Customer ID
  - **Output**: Customer
  - **Purpose**: عرض تفاصيل العميل

#### 2. Endpoints الخاصة بالسيارات
- **GET `/api/vehicles`**: عرض جميع السيارات
  - **Output**: List<Vehicle>
  - **Purpose**: عرض قائمة السيارات في واجهة الأدمن

- **POST `/api/vehicles`**: إنشاء سيارة جديدة
  - **Input**: `{ customerId, make, model, year, licensePlate, color }`
  - **Output**: Vehicle
  - **Purpose**: إضافة سيارة لعميل

- **GET `/api/vehicles/:id`**: عرض سيارة معينة
  - **Input**: Vehicle ID
  - **Output**: Vehicle
  - **Purpose**: عرض تفاصيل السيارة

#### 3. Endpoints الخاصة بالحجوزات
- **GET `/api/bookings`**: عرض جميع الحجوزات
  - **Output**: List<Booking>
  - **Purpose**: عرض قائمة الحجوزات في واجهة الأدمن

- **POST `/api/bookings`**: إنشاء حجز جديد
  - **Input**: `{ customerId, vehicleId, serviceIds[], notes }`
  - **Output**: Booking
  - **Purpose**: إنشاء حجز جديد (من الحجز السريع أو العادي)

- **GET `/api/bookings/:id`**: عرض حجز معين
  - **Input**: Booking ID
  - **Output**: Booking
  - **Purpose**: عرض تفاصيل الحجز

- **PATCH `/api/bookings/:id/status`**: تحديث حالة الحجز
  - **Input**: `{ status }`
  - **Output**: Booking
  - **Purpose**: تحديث حالة الحجز (من الميكانيكي أو الأدمن)

- **GET `/api/bookings/customer/:customerId`**: عرض حجوزات عميل معين
  - **Input**: Customer ID
  - **Output**: List<Booking>
  - **Purpose**: عرض حجوزات العميل في واجهة الزبون

#### 4. Endpoints الخاصة بالخدمات
- **GET `/api/services`**: عرض جميع الخدمات
  - **Output**: List<Service>
  - **Purpose**: عرض قائمة الخدمات للاختيار في الحجز

- **POST `/api/services`**: إنشاء خدمة جديدة
  - **Input**: `{ name, priceSYP, description }`
  - **Output**: Service
  - **Purpose**: إضافة خدمة جديدة

- **GET `/api/services/:id`**: عرض خدمة معينة
  - **Input**: Service ID
  - **Output**: Service
  - **Purpose**: عرض تفاصيل الخدمة

#### 5. Endpoints الخاصة بالتقارير
- **GET `/api/dashboard/stats`**: إحصائيات Dashboard
  - **Output**: `{ pendingBookings, inProgressBookings, totalCustomers, totalVehicles }`
  - **Purpose**: عرض الإحصائيات في واجهة الأدمن
  - **Authorization**: RECEPTIONIST or higher

- **GET `/api/dashboard/revenue`**: إحصائيات الإيرادات
  - **Output**: `{ totalRevenue, monthlyRevenue }`
  - **Purpose**: عرض الإيرادات في واجهة الأدمن
  - **Authorization**: MANAGER or higher

#### 6. Endpoints الخاصة بإعدادات الشركة
- **GET `/api/company/settings`**: جلب إعدادات الشركة
  - **Output**: `{ companyName, companyLogoUrl, createdAt, updatedAt }`
  - **Purpose**: جلب اسم الشركة واللوغو للاستخدام في الواجهات
  - **Authorization**: Public (لا تتطلب مصادقة)

- **PATCH `/api/company/settings`**: تحديث إعدادات الشركة
  - **Input**: `{ companyName, companyLogoUrl }`
  - **Output**: CompanySettings
  - **Purpose**: تحديث اسم الشركة واللوغو
  - **Authorization**: MANAGER or higher

#### 7. Endpoints خاصة بالميكانيكيين
- **GET `/api/mechanics/available-bookings`**: عرض الحجوزات المتاحة
  - **Output**: List<Booking>
  - **Purpose**: عرض الحجوزات التي يمكن للميكانيكي أخذها
  - **Authorization**: MECHANIC

- **POST `/api/mechanics/assign`**: تعيين ميكانيكي لحجز
  - **Input**: `{ bookingId, mechanicId }`
  - **Output**: MechanicAssignment
  - **Purpose**: تعيين ميكانيكي لحجز معين
  - **Authorization**: RECEPTIONIST or higher

- **POST `/api/part-suggestions`**: إضافة اقتراح قطعة غيار
  - **Input**: `{ bookingId, partName, quantity, estimatedPrice }`
  - **Output**: PartSuggestion
  - **Purpose**: اقتراح قطعة غيار لحجز
  - **Authorization**: MECHANIC

#### 8. Endpoints خاصة بالمصادقة
- **POST `/api/auth/login`**: تسجيل الدخول
  - **Input**: `{ username, password }`
  - **Output**: `{ token, user }`
  - **Purpose**: الحصول على JWT Token

- **POST `/api/auth/register`**: تسجيل مستخدم جديد
  - **Input**: `{ username, password, fullName, role }`
  - **Output**: User
  - **Purpose**: إنشاء مستخدم جديد

---

## 3) قاعدة البيانات (Database Design)

### نوع قاعدة البيانات
**PostgreSQL**

### الجداول الأساسية

#### 1. Users (المستخدمين)
- **الوصف**: جدول المستخدمين (الأدمن، الموظفين، الميكانيكيين)
- **الحقول**:
  - `id` (UUID, Primary Key)
  - `fullName` (VARCHAR(255), NOT NULL)
  - `username` (VARCHAR(255), UNIQUE, NOT NULL)
  - `passwordHash` (VARCHAR(255), NOT NULL)
  - `role` (VARCHAR(50), NOT NULL) - OWNER, MANAGER, RECEPTIONIST, MECHANIC
  - `createdAt` (TIMESTAMP, NOT NULL)
  - `updatedAt` (TIMESTAMP)

- **العلاقات**: لا يوجد علاقات مباشرة (يُستخدم في المصادقة)

#### 2. Customers (العملاء)
- **الوصف**: جدول العملاء
- **الحقول**:
  - `id` (UUID, Primary Key)
  - `fullName` (VARCHAR(255), NOT NULL)
  - `phone` (VARCHAR(20), UNIQUE, NOT NULL)
  - `address` (TEXT)
  - `createdAt` (TIMESTAMP, NOT NULL)
  - `updatedAt` (TIMESTAMP)

- **العلاقات**:
  - Customer ↔ Vehicles (One-to-Many)
  - Customer ↔ Bookings (One-to-Many)

- **Indexes**:
  - `idx_customers_phone` على `phone`

#### 3. Vehicles (السيارات)
- **الوصف**: جدول السيارات
- **الحقول**:
  - `id` (UUID, Primary Key)
  - `customerId` (UUID, Foreign Key → customers.id)
  - `make` (VARCHAR(100), NOT NULL)
  - `model` (VARCHAR(100), NOT NULL)
  - `year` (INTEGER)
  - `licensePlate` (VARCHAR(50), NOT NULL)
  - `color` (VARCHAR(50))
  - `createdAt` (TIMESTAMP, NOT NULL)
  - `updatedAt` (TIMESTAMP)

- **العلاقات**:
  - Vehicle ↔ Customer (Many-to-One)
  - Vehicle ↔ Bookings (One-to-Many)

- **Indexes**:
  - `idx_vehicles_customerId` على `customerId`
  - `idx_vehicles_licensePlate` على `licensePlate`

#### 4. Services (الخدمات)
- **الوصف**: جدول الخدمات
- **الحقول**:
  - `id` (UUID, Primary Key)
  - `name` (VARCHAR(255), NOT NULL)
  - `description` (TEXT)
  - `priceSYP` (DECIMAL(10, 2), NOT NULL)
  - `createdAt` (TIMESTAMP, NOT NULL)
  - `updatedAt` (TIMESTAMP)

- **العلاقات**:
  - Service ↔ BookingServices (One-to-Many)

- **Indexes**:
  - `idx_services_name` على `name`

#### 5. Bookings (الحجوزات)
- **الوصف**: جدول الحجوزات
- **الحقول**:
  - `id` (UUID, Primary Key)
  - `customerId` (UUID, Foreign Key → customers.id)
  - `vehicleId` (UUID, Foreign Key → vehicles.id)
  - `status` (VARCHAR(50), NOT NULL) - PENDING, IN_PROGRESS, WAITING_PARTS, READY, DELIVERED
  - `notes` (TEXT)
  - `publicToken` (UUID, UNIQUE)
  - `estimatedCompletionDate` (TIMESTAMP)
  - `createdAt` (TIMESTAMP, NOT NULL)
  - `updatedAt` (TIMESTAMP)

- **العلاقات**:
  - Booking ↔ Customer (Many-to-One)
  - Booking ↔ Vehicle (Many-to-One)
  - Booking ↔ BookingServices (One-to-Many)
  - Booking ↔ MechanicAssignments (One-to-Many)
  - Booking ↔ PartSuggestions (One-to-Many)

- **Indexes**:
  - `idx_bookings_customerId` على `customerId`
  - `idx_bookings_vehicleId` على `vehicleId`
  - `idx_bookings_status` على `status`
  - `idx_bookings_publicToken` على `publicToken`

#### 6. BookingServices (خدمات الحجز)
- **الوصف**: جدول ربط الحجوزات بالخدمات
- **الحقول**:
  - `id` (UUID, Primary Key)
  - `bookingId` (UUID, Foreign Key → bookings.id)
  - `serviceId` (UUID, Foreign Key → services.id)
  - `notes` (TEXT)
  - `createdAt` (TIMESTAMP, NOT NULL)

- **العلاقات**:
  - BookingService ↔ Booking (Many-to-One)
  - BookingService ↔ Service (Many-to-One)

- **Indexes**:
  - `idx_booking_services_bookingId` على `bookingId`
  - `idx_booking_services_serviceId` على `serviceId`

#### 7. MechanicAssignments (تعيينات الميكانيكي)
- **الوصف**: جدول تعيين الميكانيكيين للحجوزات
- **الحقول**:
  - `id` (UUID, Primary Key)
  - `bookingId` (UUID, Foreign Key → bookings.id)
  - `mechanicId` (UUID, Foreign Key → users.id)
  - `assignedAt` (TIMESTAMP, NOT NULL)
  - `completedAt` (TIMESTAMP)

- **العلاقات**:
  - MechanicAssignment ↔ Booking (Many-to-One)
  - MechanicAssignment ↔ User (Many-to-One)

- **Indexes**:
  - `idx_mechanic_assignments_bookingId` على `bookingId`
  - `idx_mechanic_assignments_mechanicId` على `mechanicId`

#### 8. PartSuggestions (اقتراحات قطع الغيار)
- **الوصف**: جدول اقتراحات قطع الغيار من الميكانيكيين
- **الحقول**:
  - `id` (UUID, Primary Key)
  - `bookingId` (UUID, Foreign Key → bookings.id)
  - `mechanicId` (UUID, Foreign Key → users.id)
  - `partName` (VARCHAR(255), NOT NULL)
  - `quantity` (INTEGER, NOT NULL)
  - `estimatedPrice` (DECIMAL(10, 2))
  - `createdAt` (TIMESTAMP, NOT NULL)

- **العلاقات**:
  - PartSuggestion ↔ Booking (Many-to-One)
  - PartSuggestion ↔ User (Many-to-One)

- **Indexes**:
  - `idx_part_suggestions_bookingId` على `bookingId`

#### 9. CompanySettings (إعدادات الشركة)
- **الوصف**: جدول إعدادات الشركة
- **الحقول**:
  - `id` (UUID, Primary Key)
  - `companyName` (VARCHAR(255), NOT NULL, DEFAULT 'Garage Go')
  - `companyLogoUrl` (TEXT)
  - `createdAt` (TIMESTAMP, NOT NULL)
  - `updatedAt` (TIMESTAMP)

- **العلاقات**: لا يوجد علاقات (جدول مستقل)

- **ملاحظة**: هذا الجدول يحتوي على صف واحد فقط (singleton)

### كيف يتم تخزين اسم الموقع واللوغو

- **اسم الموقع**: يُخزن في `company_name` في جدول `company_settings`
- **اللوغو**: يُخزن كـ URL في `company_logo_url` في جدول `company_settings`
- **القيم الافتراضية**:
  - `companyName`: 'Garage Go'
  - `companyLogoUrl`: null

### القيود المهمة (Constraints)

#### المفاتيح الأساسية (Primary Keys)
- جميع الجداول تستخدم `UUID` كـ Primary Key
- يُنشأ تلقائياً باستخدام `uuid_generate_v4()`

#### المفاتيح الخارجية (Foreign Keys)
- `vehicles.customerId` → `customers.id`
- `bookings.customerId` → `customers.id`
- `bookings.vehicleId` → `vehicles.id`
- `booking_services.bookingId` → `bookings.id`
- `booking_services.serviceId` → `services.id`
- `mechanic_assignments.bookingId` → `bookings.id`
- `mechanic_assignments.mechanicId` → `users.id`
- `part_suggestions.bookingId` → `bookings.id`
- `part_suggestions.mechanicId` → `users.id`

#### الفهارس (Indexes)
- جميع Foreign Keys مفهرسة لتحسين الأداء
- `customers.phone` مفهرس (UNIQUE)
- `vehicles.licensePlate` مفهرس
- `bookings.status` مفهرس
- `bookings.publicToken` مفهرس (UNIQUE)

---

## 4) واجهة الأدمن والموظفين (Web Admin Panel)

### التقنية المستخدمة
**Flutter Web**

### كيف تتصل الواجهة بالـ Backend
- **HTTP Client**: `ApiService` في `lib/core/services/api_service.dart`
- **Base URL**: يتم تعريفه في `ApiConstants`
- **Authentication**: JWT Token يُرسل في `Authorization` Header
- **Content-Type**: `application/json`

### الشاشات الرئيسية في لوحة التحكم

#### 1. Dashboard / نظرة عامة
- **الموقع**: `lib/screens/overview_screen.dart`
- **ما تعرضه**:
  - إحصائيات الحجوزات (pending, in_progress, ready, delivered)
  - عدد العملاء
  - عدد السيارات
  - إيرادات شهرية
- **الأزرار**:
  - لا توجد أزرار مباشرة (شاشة عرض فقط)
- **التفاعل مع Backend**:
  - `GET /api/dashboard/stats`

#### 2. شاشة الحجوزات (Bookings)
- **الموقع**: `lib/screens/bookings_screen.dart`
- **ما تعرضه**:
  - قائمة جميع الحجوزات
  - حالة كل حجز
  - معلومات العميل والسيارة
- **الأزرار**:
  - **إضافة حجز جديد**: يفتح `CreateBookingScreen`
  - **عرض تفاصيل**: يفتح Dialog بتفاصيل الحجز
  - **تحديث الحالة**: يفتح Dialog لتحديث حالة الحجز
  - **حذف**: يحذف الحجز
- **التفاعل مع Backend**:
  - `GET /api/bookings`
  - `POST /api/bookings`
  - `PATCH /api/bookings/:id/status`
  - `DELETE /api/bookings/:id`

#### 3. شاشة الحجز السريع (Quick Booking)
- **الموقع**: `lib/screens/quick_booking_screen.dart`
- **ما تعرضه**:
  - Dropdown لاختيار العميل (مع بحث)
  - Dropdown لاختيار السيارة (يُجلب تلقائياً عند اختيار العميل)
  - FilterChips لاختيار الخدمات
  - TextField للملاحظات
- **الأزرار**:
  - **إنشاء الحجز**: يُنشئ الحجز ويعود للشاشة السابقة
  - **إضافة سيارة جديدة**: يفتح Dialog (placeholder للمستقبل)
- **منطق العمل**:
  1. المستخدم يختار عميل من Dropdown
  2. يتم استدعاء `_loadVehicles(customerId)`
  3. تظهر سيارات العميل في Dropdown
  4. المستخدم يختار سيارة أو يضغط "إضافة سيارة جديدة"
  5. المستخدم يختار الخدمات (متعددة)
  6. المستخدم يضغط "إنشاء الحجز"
  7. يتم إرسال `POST /api/bookings` مع البيانات
- **التفاعل مع Backend**:
  - `GET /api/customers` (لجلب العملاء)
  - `GET /api/vehicles` (لجلب السيارات)
  - `GET /api/services` (لجلب الخدمات)
  - `POST /api/bookings` (لإنشاء الحجز)

#### 4. شاشة العملاء (Customers)
- **الموقع**: `lib/screens/customers_screen.dart`
- **ما تعرضه**:
  - قائمة جميع العملاء
  - معلومات الاتصال لكل عميل
- **الأزرار**:
  - **إضافة عميل**: يفتح Dialog لإضافة عميل جديد
  - **عرض التفاصيل**: يفتح Dialog بتفاصيل العميل
  - **تحديث**: يفتح Dialog لتحديث بيانات العميل
  - **حذف**: يحذف العميل
- **التفاعل مع Backend**:
  - `GET /api/customers`
  - `POST /api/customers`
  - `PATCH /api/customers/:id`
  - `DELETE /api/customers/:id`

#### 5. شاشة السيارات (Vehicles)
- **الموقع**: `lib/screens/vehicles_screen.dart`
- **ما تعرضه**:
  - قائمة جميع السيارات
  - معلومات كل سيارة (العميل، الماركة، الموديل، اللوحة)
- **الأزرار**:
  - **إضافة سيارة**: يفتح Dialog لإضافة سيارة جديدة
  - **عرض التفاصيل**: يفتح Dialog بتفاصيل السيارة
  - **تحديث**: يفتح Dialog لتحديث بيانات السيارة
  - **حذف**: يحذف السيارة
- **التفاعل مع Backend**:
  - `GET /api/vehicles`
  - `POST /api/vehicles`
  - `PATCH /api/vehicles/:id`
  - `DELETE /api/vehicles/:id`

#### 6. شاشة الخدمات (Services)
- **الموقع**: `lib/screens/services_screen.dart`
- **ما تعرضه**:
  - قائمة جميع الخدمات
  - سعر كل خدمة بالليرة السورية
- **الأزرار**:
  - **إضافة خدمة**: يفتح Dialog لإضافة خدمة جديدة
  - **عرض التفاصيل**: يفتح Dialog بتفاصيل الخدمة
  - **تحديث**: يفتح Dialog لتحديث بيانات الخدمة
  - **حذف**: يحذف الخدمة
- **التفاعل مع Backend**:
  - `GET /api/services`
  - `POST /api/services`
  - `PATCH /api/services/:id`
  - `DELETE /api/services/:id`

#### 7. شاشة الموظفين (Employees)
- **الموقع**: `lib/screens/employees_screen.dart`
- **ما تعرضه**:
  - قائمة جميع الموظفين
  - دور كل موظف
- **الأزرار**:
  - **إضافة موظف**: يفتح Dialog لإضافة موظف جديد
  - **عرض التفاصيل**: يفتح Dialog بتفاصيل الموظف
  - **تحديث**: يفتح Dialog لتحديث بيانات الموظف
  - **حذف**: يحذف الموظف
- **التفاعل مع Backend**:
  - `GET /api/users`
  - `POST /api/auth/register`
  - `PATCH /api/users/:id`
  - `DELETE /api/users/:id`

#### 8. شاشة التقارير (Reports)
- **الموقع**: `lib/screens/reports_screen.dart`
- **ما تعرضه**:
  - إحصائيات شاملة
  - رسوم بيانية (إن وجدت)
  - تقارير مالية
- **الأزرار**:
  - **تصدير**: يُصدّر التقرير (PDF/Excel - placeholder)
  - **تصفية**: يفتح Dialog لتصفية التقرير حسب التاريخ
- **التفاعل مع Backend**:
  - `GET /api/dashboard/stats`
  - `GET /api/dashboard/revenue`

#### 9. شاشة إعدادات النظام / الشركة (Company Settings)
- **الموقع**: `lib/screens/company_settings_screen.dart`
- **ما تعرضه**:
  - TextField لاسم الشركة
  - عرض الشعار الحالي
  - TextField لرابط الشعار (URL)
  - زر إزالة الشعار
- **الأزرار**:
  - **تغيير الشعار**: يفتح Dialog لإدخال رابط الشعار
  - **إزالة الشعار**: يُزيل الشعار ويستخدم الأيقونة الافتراضية
  - **إعادة تعيين**: يُرجع الإعدادات للقيم الافتراضية
  - **حفظ التغييرات**: يُحدث الإعدادات في قاعدة البيانات
- **التفاعل مع Backend**:
  - `GET /api/company/settings`
  - `PATCH /api/company/settings`
- **كيف يتم حفظ الشعار**:
  - حالياً يتم إدخال رابط الشعار يدوياً (URL)
  - في المستقبل سيتم إضافة File Upload functionality
  - الشعار يُخزن كـ URL في `company_logo_url`

#### 10. شاشة تغيير كلمة المرور
- **الموقع**: `lib/screens/change_password_screen.dart`
- **ما تعرضها**:
  - TextField لكلمة المرور الحالية
  - TextField لكلمة المرور الجديدة
  - TextField لتأكيد كلمة المرور
- **الأزرار**:
  - **تغيير كلمة المرور**: يُحدث كلمة المرور
- **التفاعل مع Backend**:
  - `PATCH /api/users/:id/password` (أو endpoint مشابه)

### كيف يتم استخدام اسم الموقع واللوغو في الواجهة

#### في AnimatedSidebar (`lib/core/widgets/animated_sidebar.dart`)
- **اسم الموقع**: يُعرض في Header بجانب الشعار
- **اللوغو**: يُعرض بدلاً من الأيقونة الافتراضية
- **كيف يتم الجلب**:
  ```dart
  Future<void> _loadCompanySettings() async {
    final response = await http.get(Uri.parse('$baseUrl/api/company/settings'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _companyName = data['companyName'] ?? 'Garage Go';
        _companyLogoUrl = data['companyLogoUrl'];
      });
    }
  }
  ```
- **مكان العرض**:
  - Header في Sidebar
  - Login Screen (اسم الشركة)

---

## 5) واجهة الميكانيكي (Android App)

### التقنية المستخدمة
**Flutter (Android)**

### كيف يتصل التطبيق بالـ Backend
- **HTTP Client**: `ApiService` في `lib/services/api_service.dart`
- **Base URL**: يتم تعريفه في `lib/core/constants/backend_constants.dart`
- **Authentication**: JWT Token يُرسل في `Authorization` Header

### الشاشات الرئيسية

#### 1. شاشة تسجيل الدخول
- **الموقع**: `lib/screens/login/login_screen.dart`
- **ما تعرضه**:
  - TextField لاسم المستخدم
  - TextField لكلمة المرور
  - Checkbox "تذكرني"
- **الأزرار**:
  - **تسجيل الدخول**: يتحقق من البيانات وينتقل لشاشة الحجوزات
  - **تسجيل حساب جديد**: ينتقل لشاشة التسجيل
- **التفاعل مع Backend**:
  - `POST /api/auth/login`

#### 2. شاشة الحجوزات المتاحة
- **الموقع**: `lib/screens/available_bookings/available_bookings_screen.dart`
- **ما تعرضه**:
  - قائمة الحجوزات المتاحة للتعيين
  - معلومات كل حجز (العميل، السيارة، الخدمات)
- **الأزرار**:
  - **أخذ الحجز**: يُعين الميكانيكي للحجز
  - **عرض التفاصيل**: يفتح شاشة تفاصيل الحجز
- **التفاعل مع Backend**:
  - `GET /api/mechanics/available-bookings`
  - `POST /api/mechanics/assign`

#### 3. شاشة حجوزاتي (My Assignments)
- **الموقع**: `lib/screens/my_assignments/my_assignments_screen.dart`
- **ما تعرضه**:
  - قائمة الحجوزات الموكلة للميكانيكي
  - حالة كل حجز
- **الأزرار**:
  - **عرض التفاصيل**: يفتح شاشة تفاصيل الحجز
  - **تحديث الحالة**: يفتح Dialog لتحديث الحالة
- **التفاعل مع Backend**:
  - `GET /api/bookings` (مع filter للميكانيكي)
  - `PATCH /api/bookings/:id/status`

#### 4. شاشة تفاصيل الحجز
- **الموقع**: `lib/screens/vehicle_detail/vehicle_detail_screen.dart`
- **ما تعرضه**:
  - معلومات السيارة
  - معلومات العميل
  - الخدمات المطلوبة
  - حالة الحجز
- **الأزرار**:
  - **تحديث الحالة**: يفتح Dialog لتحديث الحالة
  - **إضافة ملاحظات**: يفتح Dialog لإضافة ملاحظات
  - **اقتراح قطعة غيار**: يفتح Dialog لاقتراح قطعة غيار
- **التفاعل مع Backend**:
  - `GET /api/bookings/:id`
  - `PATCH /api/bookings/:id/status`
  - `POST /api/part-suggestions`

#### 5. شاشة تحديث حالة الحجز
- **الموقع**: `lib/screens/update_maintenance_status/update_maintenance_status_screen.dart`
- **ما تعرضها**:
  - Dropdown لحالة الحجز
  - TextField للملاحظات
- **الأزرار**:
  - **حفظ**: يُحدث حالة الحجز
- **التفاعل مع Backend**:
  - `PATCH /api/bookings/:id/status`

#### 6. شاشة إضافة إصلاح
- **الموقع**: `lib/screens/add_repair_screen.dart`
- **ما تعرضها**:
  - TextField لوصف الإصلاح
  - TextField للتكلفة
- **الأزرار**:
  - **حفظ**: يُضيف الإصلاح للحجز
- **التفاعل مع Backend**:
  - `POST /api/repairs` (أو endpoint مشابه)

### ما الذي يمكن للميكانيكي فعله
- **تغيير حالة الحجز**: من PENDING إلى IN_PROGRESS إلى READY
- **إضافة ملاحظات**: ملاحظات على الصيانة
- **اقتراح قطع غيار**: اقتراح قطع غيار مطلوبة
- **عرض تفاصيل الحجز**: عرض جميع المعلومات المتاحة

### كيف يتم تحديث البيانات في الـ Backend
- يتم إرسال HTTP Requests (POST/PATCH) للـ Backend
- Backend يُحدث قاعدة البيانات
- التطبيق يُحديث UI بناءً على الاستجابة

---

## 6) واجهة الزبون (Customer UI - Single HTML File)

### الوصف
واجهة الزبون عبارة عن ملف HTML واحد يحتوي على JavaScript لجلب البيانات من الـ Backend.

### ما الذي يقدمه هذا الملف
- **عرض معلومات الشركة**: اسم الشركة والشعار
- **تتبع حالة الحجز**: باستخدام Public Token
- **عرض تفاصيل السيارة**: الماركة، الموديل، اللوحة
- **عرض الخدمات المطلوبة**: الخدمات والأسعار
- **عرض ملاحظات الصيانة**: ملاحظات الميكانيكي
- **عرض حالة الحجز**: PENDING, IN_PROGRESS, READY, DELIVERED

### كيف يتم حقن اسم الموقع واللوغو

#### اسم الموقع
```javascript
async function loadCompanySettings() {
  const response = await fetch('http://localhost:8080/api/company/settings');
  if (response.ok) {
    const settings = await response.json();
    if (settings.companyName) {
      document.getElementById('pageTitle').textContent = `${settings.companyName} - تتبع السيارة`;
      document.getElementById('companyName').textContent = settings.companyName;
    }
  }
}
```

#### اللوغو
```javascript
if (settings.companyLogoUrl) {
  const logoImg = document.getElementById('companyLogo');
  const defaultLogo = document.getElementById('defaultLogo');
  
  logoImg.src = settings.companyLogoUrl;
  logoImg.onload = () => {
    logoImg.classList.remove('hidden');
    defaultLogo.classList.add('hidden');
  };
}
```

### التفاعل مع الـ Backend
- **Method**: Fetch API
- **Endpoints**:
  - `GET /api/company/settings` - لجلب اسم الشركة والشعار
  - `GET /public/bookings/:publicToken` - لجلب تفاصيل الحجز

### كيف يعمل تتبع الحجز
1. الزبون يدخل Public Token في URL (مثلاً: `?token=abc123`)
2. JavaScript يقرأ الـ Token من URL
3. يتم استدعاء `GET /public/bookings/:publicToken`
4. Backend يُرجع تفاصيل الحجز
5. يتم عرض البيانات في الصفحة

---

## 7) ترابط الأنظمة مع بعضها (System Integration)

### كيف يتدفق الحجز من البداية للنهاية

#### 1. إدخال بيانات الحجز
- **من**: واجهة الأدمن (Quick Booking أو Create Booking)
- **البيانات**: العميل، السيارة، الخدمات، الملاحظات
- **API**: `POST /api/bookings`

#### 2. تخزين الحجز في قاعدة البيانات
- **الخطوات**:
  1. Backend يستقبل البيانات
  2. يُنشئ Booking Record في جدول `bookings`
  3. يُنشئ BookingService Records في جدول `booking_services`
  4. يُرجع Booking مع ID

#### 3. ظهوره في واجهة الأدمن
- **الشاشة**: Bookings Screen
- **الـ API**: `GET /api/bookings`
- **التحديث**: يتم تحديث القائمة تلقائياً أو عند Refresh

#### 4. ظهوره في واجهة الميكانيكي
- **الشاشة**: Available Bookings Screen
- **الـ API**: `GET /api/mechanics/available-bookings`
- **الشرط**: الحجز يجب أن يكون في حالة PENDING وغير معيّن لميكانيكي

#### 5. ظهوره في التقارير
- **الشاشة**: Reports Screen
- **الـ APIs**: `GET /api/dashboard/stats`, `GET /api/dashboard/revenue`
- **التحديث**: يتم احتساب الإحصائيات من قاعدة البيانات

### كيف يتم استخدام نفس البيانات في جميع الواجهات

#### واجهة الأدمن
- **العملاء**: `GET /api/customers`
- **السيارات**: `GET /api/vehicles`
- **الحجوزات**: `GET /api/bookings`
- **الخدمات**: `GET /api/services`
- **التقارير**: `GET /api/dashboard/stats`

#### واجهة الميكانيكي
- **الحجوزات المتاحة**: `GET /api/mechanics/available-bookings`
- **حجوزاتي**: `GET /api/bookings` (مع filter)
- **تفاصيل الحجز**: `GET /api/bookings/:id`

#### واجهة الزبون
- **تفاصيل الحجز**: `GET /public/bookings/:publicToken`

### كيف يتم استخدام إعدادات الشركة في جميع الواجهات

#### واجهة الأدمن
- **AnimatedSidebar**: يعرض اسم الشركة والشعار في Header
- **Login Screen**: يعرض اسم الشركة
- **الـ API**: `GET /api/company/settings`

#### واجهة الميكانيكي
- **Placeholder**: يمكن إضافته في AppBar
- **الـ API**: `GET /api/company/settings`

#### واجهة الزبون
- **Header**: يعرض اسم الشركة والشعار
- **Page Title**: يعرض اسم الشركة
- **الـ API**: `GET /api/company/settings`

---

## 8) شرح الأزرار والعمليات (Actions & Buttons)

### زر "إضافة حجز جديد"
- **الموقع**: Bookings Screen
- **ماذا يفعل**: يفتح CreateBookingScreen
- **الخطوات**:
  1. يفتح CreateBookingScreen
  2. المستخدم يُدخل بيانات العميل
  3. المستخدم يُدخل بيانات السيارة
  4. المستخدم يختار الخدمات
  5. المستخدم يضغط "إنشاء الحجز"
  6. يتم استدعاء `POST /api/bookings`
  7. يتم العودة لقائمة الحجوزات

### زر "إضافة حجز سريع"
- **الموقع**: Sidebar (Quick Booking)
- **ماذا يفعل**: يفتح QuickBookingScreen
- **الخطوات**:
  1. يفتح QuickBookingScreen
  2. المستخدم يختار عميل من Dropdown
  3. يتم جلب سيارات العميل تلقائياً
  4. المستخدم يختار سيارة أو يضغط "إضافة سيارة جديدة"
  5. المستخدم يختار الخدمات (متعددة)
  6. المستخدم يضغط "إنشاء الحجز"
  7. يتم استدعاء `POST /api/bookings`
  8. يتم العودة للشاشة السابقة

### زر "إضافة عميل"
- **الموقع**: Customers Screen
- **ماذا يفعل**: يفتح Dialog لإضافة عميل
- **الخطوات**:
  1. يفتح Dialog
  2. المستخدم يُدخل الاسم، الهاتف، العنوان
  3. المستخدم يضغط "حفظ"
  4. يتم استدعاء `POST /api/customers`
  5. يتم تحديث قائمة العملاء

### زر "إضافة سيارة"
- **الموقع**: Vehicles Screen
- **ماذا يفعل**: يفتح Dialog لإضافة سيارة
- **الخطوات**:
  1. يفتح Dialog
  2. المستخدم يختار العميل
  3. المستخدم يُدخل بيانات السيارة
  4. المستخدم يضغط "حفظ"
  5. يتم استدعاء `POST /api/vehicles`
  6. يتم تحديث قائمة السيارات

### زر "إضافة خدمة"
- **الموقع**: Services Screen
- **ماذا يفعل**: يفتح Dialog لإضافة خدمة
- **الخطوات**:
  1. يفتح Dialog
  2. المستخدم يُدخل الاسم، الوصف، السعر
  3. المستخدم يضغط "حفظ"
  4. يتم استدعاء `POST /api/services`
  5. يتم تحديث قائمة الخدمات

### زر "حفظ" في إعدادات الشركة
- **الموقع**: Company Settings Screen
- **ماذا يفعل**: يُحدث اسم الشركة واللوغو
- **الخطوات**:
  1. المستخدم يُعدل اسم الشركة أو رابط اللوغو
  2. المستخدم يضغط "حفظ التغييرات"
  3. يتم استدعاء `PATCH /api/company/settings`
  4. يتم تحديث قاعدة البيانات
  5. جميع الواجهات سترى التغيير عند إعادة التحميل

### زر "تغيير الشعار"
- **الموقع**: Company Settings Screen
- **ماذا يفعل**: يفتح Dialog لإدخال رابط الشعار
- **الخطوات**:
  1. يفتح Dialog
  2. المستخدم يُدخل رابط الشعار (URL)
  3. المستخدم يضغط "حفظ"
  4. يتم تحديث `company_logo_url`
  5. الشعار يظهر في جميع الواجهات

### زر "إزالة الشعار"
- **الموقع**: Company Settings Screen
- **ماذا يفعل**: يُزيل الشعار ويستخدم الأيقونة الافتراضية
- **الخطوات**:
  1. المستخدم يضغط "إزالة الشعار"
  2. يتم تحديث `company_logo_url` إلى null
  3. الأيقونة الافتراضية تظهر في جميع الواجهات

### زر "أخذ الحجز" (الميكانيكي)
- **الموقع**: Available Bookings Screen (الميكانيكي)
- **ماذا يفعل**: يُعين الميكانيكي الحالي للحجز
- **الخطوات**:
  1. المستخدم يضغط "أخذ الحجز"
  2. يتم استدعاء `POST /api/mechanics/assign`
  3. الحجز ينتقل من Available إلى My Assignments

### زر "تحديث الحالة" (الميكانيكي)
- **الموقع**: My Assignments Screen (الميكانيكي)
- **ماذا يفعل**: يُحدث حالة الحجز
- **الخطوات**:
  1. المستخدم يختار الحالة الجديدة
  2. المستخدم يضغط "حفظ"
  3. يتم استدعاء `PATCH /api/bookings/:id/status`
  4. حالة الحجز تُحدث في قاعدة البيانات

---

## 9) ملاحظات تقنية عامة (Technical Notes)

### قرارات تصميمية مهمة (Design Decisions)

#### 1. استخدام Dart و Shelf للـ Backend
- **السبب**: اختيار تقنية حديثة وسريعة
- **الميزة**: Type-safe، Async/Await، سهولة الصيانة

#### 2. استخدام PostgreSQL لقاعدة البيانات
- **السبب**: قوي وموثوق، يدعم Relationships جيداً
- **الميزة**: Transactions، Constraints، Indexes

#### 3. استخدام JWT للمصادقة
- **السبب**: Stateless، آمن، مستخدم على نطاق واسع
- **الميزة**: لا يوجد Session في Server، سهل التوسع

#### 4. استخدام Flutter للواجهات
- **السبب**: Single Codebase لـ Web و Mobile
- **الميزة**: UI موحد، سهولة الصيانة

#### 5. Company Settings كـ Singleton
- **السبب**: يوجد صف واحد فقط من الإعدادات
- **الميزة**: سهولة الوصول، لا يوجد تعقيد

#### 6. Quick Booking كشاشة منفصلة
- **السبب**: لتجنب كسر CreateBookingScreen الحالي
- **الميزة**: non-breaking change، يمكن التوسع مستقبلاً

### حدود أو قيود (Limitations)

#### 1. Logo Upload
- **الحالي**: يتم إدخال رابط الشعار يدوياً (URL)
- **المستقبل**: يجب إضافة File Upload functionality
- **السبب**: يحتاج إلى Cloud Storage أو Server Storage

#### 2. Add Vehicle في Quick Booking
- **الحالي**: Placeholder فقط (Dialog بسيط)
- **المستقبل**: يجب إنشاء شاشة كاملة
- **السبب**: يحتاج إلى Form كامل مع Validation

#### 3. Mechanic App
- **الحالي**: استخدام محدود لـ Company Settings
- **المستقبل**: يجب تحديث AppBar بـ Company Settings
- **السبب**: يحتاج إلى Service لجلب الإعدادات

#### 4. API Base URL
- **الحالي**: Hardcoded في بعض الأماكن
- **المستقبل**: يجب استخدام Environment Variables
- **السبب**: سهولة التبديل بين Environments

#### 5. Error Handling
- **الحالي**: Basic Error Handling
- **المستقبل**: يجب تحسين Error Messages
- **السبب**: تجربة مستخدم أفضل

### نقاط يجب الانتباه لها عند التعديل مستقبلاً

#### 1. عدم كسر منطق الحجز السريع
- **السبب**: منطق معقد يربط بين العملاء والسيارات والخدمات
- **النصيحة**: اختبر جميع السيناريوهات قبل التعديل

#### 2. عدم تغيير شكل CompanySettings بدون تحديث الواجهات
- **السبب**: جميع الواجهات تعتمد على هيكل CompanySettings
- **النصيحة**: إذا أضفت حقول جديدة، حدث جميع الواجهات

#### 3. التعامل مع غياب اللوغو أو اسم الموقع
- **السبب**: قد تكون الإعدادات null
- **النصيحة**: استخدم Default Values دائماً
  - Default Company Name: 'Garage Go'
  - Default Logo: Icon أو Placeholder

#### 4. عدم تغيير Authentication/Authorization
- **السبب**: قد يسبب مشاكل أمنية
- **النصيحة**: اختبر جميع الأدوار بعد التعديل

#### 5. عدم تغيير Database Schema بدون Migration
- **السبب**: قد يسبب فقدان البيانات
- **النصيحة**: استخدم Migrations و Backups

#### 6. RTL Support
- **السبب**: الواجهات بالعربية (RTL)
- **النصيحة**: اختبر Layout على RTL قبل النشر

#### 7. Responsive Design
- **السبب**: الواجهات تعمل على Desktop و Tablet
- **النصيحة**: اختبر على أحجام شاشات مختلفة

#### 8. Public Token Security
- **السبب**: يستخدم في واجهة الزبون
- **النصيحة**: لا تعرض بيانات حساسة في Public API

#### 9. CORS Configuration
- **السبب**: الواجهات على Domains مختلفة
- **النصيحة**: تأكد من تكوين CORS بشكل صحيح

#### 10. JWT Token Expiration
- **السبب**: Tokens تنتهي صلاحيتها
- **النصيحة**: أضف Refresh Token Mechanism

---

## خاتمة

هذا التوثيق يغطي جميع جوانب نظام Garage Go. إذا كان لديك أي أسئلة أو تحتاج إلى توضيحات إضافية، يرجى الرجوع إلى الكود المصدري أو التواصل مع فريق التطوير.

**تاريخ التحديث**: 2026-05-14
**الإصدار**: 1.0
