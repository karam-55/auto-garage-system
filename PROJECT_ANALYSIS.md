# Garage Go - Project Analysis Report

**Generated:** May 24, 2026  
**Project:** Auto Garage Management System (Garage Go)  
**Analysis Type:** Comprehensive Codebase Analysis  
**Status:** Complete

---

## 📋 Executive Summary

**Garage Go** is a full-stack enterprise resource planning (ERP) system for auto garage management, combining CRM, accounting, inventory management, human resources, and manufacturing modules. The system follows Clean Architecture principles with a Dart/Stack backend, Flutter frontends (Web and Mobile), and PostgreSQL database. The project is production-ready with 44 domain entities, 38 repositories, 88 use cases, and 70+ frontend screens.

---

## 🏗️ Project Structure Analysis

### Root Directory Structure

```
auto-garage-system/
├── backend/                    # Dart + Shelf Backend Server
├── admin_frontend/             # Flutter Web Admin Dashboard
├── mechanic_app_new/           # Flutter Mobile Mechanic App
├── customer-frontend/          # Static HTML/JS Customer Tracking
├── garage-go-catalog/          # Spare Parts Catalog
├── lib/                        # Shared Libraries
├── graphify-out/               # Knowledge Graph Analysis
├── docker-compose.yml          # Docker Orchestration
├── supabase-schema.sql         # Database Schema
├── seed_data*.ps1              # Database Seeding Scripts
├── .cursorrules                # Project Rules & Guidelines
├── AGENTS.md                   # AI Memory Documentation
└── PROJECT_ANALYSIS.md         # This File
```

---

## 📦 Component Analysis

### 1. Backend Components

#### Architecture Layers

**Domain Layer** (`backend/lib/domain/`)
- **Purpose:** Business logic and entity definitions
- **Components:**
  - 44 Entities (User, Customer, Vehicle, Booking, Account, JournalEntry, etc.)
  - 38 Repository Interfaces (BookingRepository, AccountRepository, etc.)
  - Validators (input validation logic)
- **Key Files:**
  - `entities/booking.dart` - Booking entity with status management
  - `entities/journal_entry.dart` - Accounting journal entries
  - `entities/account.dart` - Chart of accounts hierarchy
  - `repositories/booking_repository.dart` - Booking data access interface

**Application Layer** (`backend/lib/application/`)
- **Purpose:** Use cases and business services
- **Components:**
  - 88 Use Cases (CreateBooking, ProcessPayment, CreateJournalEntry, etc.)
  - 13 Services (AuthService, JournalService, CRMService, etc.)
- **Key Files:**
  - `usecases/create_booking_usecase.dart` - Booking creation logic
  - `usecases/process_booking_payment_usecase.dart` - Payment processing
  - `services/journal_service.dart` - Journal entry management
  - `services/auth_service.dart` - Authentication logic

**Infrastructure Layer** (`backend/lib/infrastructure/`)
- **Purpose:** External system implementations
- **Components:**
  - Database Connection (PostgreSQL pool management)
  - 38 Repository Implementations
  - Database Migrations/Seeding
- **Key Files:**
  - `database/database_connection.dart` - DB connection pool (max 20 connections)
  - `repositories/booking_repository_impl.dart` - Booking repository implementation
  - `database/accounting_seeder.dart` - Chart of accounts seeding

**Presentation Layer** (`backend/lib/presentation/`)
- **Purpose:** API endpoints and middleware
- **Components:**
  - 22 Route Files (auth_routes, booking_routes, accounting_routes, etc.)
  - 4 Middlewares (Auth, Error, JSON, Logging)
  - WebSocket Support
- **Key Files:**
  - `routes/booking_routes.dart` - Booking API endpoints
  - `routes/accounting_routes.dart` - Accounting API endpoints
  - `middlewares/auth_middleware.dart` - JWT authentication
  - `middlewares/error_middleware.dart` - Unified error handling

**Core Layer** (`backend/lib/core/`)
- **Purpose:** Shared utilities and constants
- **Components:**
  - JWT Service (token generation/validation)
  - Pagination Result (paginated response wrapper)
  - Error Types (Exceptions, Failures)
  - App Constants
- **Key Files:**
  - `utils/jwt_service.dart` - JWT token management
  - `utils/pagination_result.dart` - Pagination utilities
  - `errors/exceptions.dart` - Custom exceptions
  - `errors/failures.dart` - Failure types

#### Entry Point

**File:** `backend/bin/server.dart`
- Initializes database connection
- Loads environment variables
- Sets up all repositories
- Registers all routes
- Applies middleware pipeline
- Starts server on configured port (default: 8080)

---

### 2. Admin Frontend Components

#### Architecture

**Core Layer** (`admin_frontend/lib/core/`)
- **Purpose:** Shared services and utilities
- **Components:**
  - API Service (HTTP client with token management)
  - Auth Service (authentication logic)
  - WebSocket Service (real-time updates)
  - Providers (Riverpod state management)
  - Models (data models for API responses)
  - Constants (API endpoints, app constants)
  - Theme (app theming)
  - Widgets (reusable UI components)
- **Key Files:**
  - `services/api_service.dart` - HTTP client with interceptors
  - `services/auth_service.dart` - Authentication state management
  - `providers/accounting_providers.dart` - Accounting state providers
  - `models/journal_entry.dart` - Journal entry data model
  - `widgets/animated_card.dart` - Reusable animated card widget

**Screens Layer** (`admin_frontend/lib/screens/`)
- **Purpose:** UI screens organized by module
- **Components:**
  - 70+ Screens organized in subdirectories
  - Accounting Module (20 screens)
  - ERP Modules (Purchasing, Sales, Warehouse, Manufacturing)
  - HR Module (Contracts, Leave Requests, Performance Reviews)
  - CRM Module (Leads, Activities)
  - Fixed Assets Module
  - Maintenance Contracts Module
- **Key Screens:**
  - `accounting/journal_entries_screen.dart` - Journal entries list
  - `accounting/create_journal_entry_screen.dart` - Create journal entry
  - `bookings_screen.dart` - Bookings management
  - `dashboard_screen.dart` - Main dashboard
  - `inventory_screen.dart` - Inventory management

**Localization Layer** (`admin_frontend/lib/l10n/`)
- **Purpose:** Internationalization support
- **Components:**
  - Arabic (primary language)
  - English (secondary language)
  - App localization files (ARB format)
- **Key Files:**
  - `app_localizations_ar.dart` - Arabic translations
  - `app_localizations_en.dart` - English translations

---

### 3. Mechanic App Components

#### Architecture (Clean Architecture)

**Core Layer** (`mechanic_app_new/lib/core/`)
- **Purpose:** Core utilities and networking
- **Components:**
  - Dio Client (HTTP client with interceptors)
  - Error Handling (exceptions, failures)
  - Logger (logging utility)
  - Constants (backend endpoints)
  - Environment configuration
- **Key Files:**
  - `network/dio_client.dart` - Dio HTTP client with token refresh
  - `error/exceptions.dart` - Custom exceptions
  - `logger.dart` - Logging utility

**Domain Layer** (`mechanic_app_new/lib/domain/`)
- **Purpose:** Business entities and use cases
- **Components:**
  - Entities (Booking, MechanicAssignment, PartSuggestion)
  - Repository Interfaces
  - Use Cases (Login, GetAvailableBookings, AssignBooking, etc.)
- **Key Files:**
  - `entities/booking.dart` - Booking entity
  - `usecases/login_usecase.dart` - Login logic
  - `usecases/get_available_bookings_usecase.dart` - Fetch available bookings

**Data Layer** (`mechanic_app_new/lib/data/`)
- **Purpose:** Data sources and repository implementations
- **Components:**
  - Remote Data Sources (API calls)
  - Local Data Source (SharedPreferences cache)
  - Data Models (DTOs)
  - Repository Implementations
- **Key Files:**
  - `datasources/remote/booking_remote_datasource.dart` - Booking API calls
  - `datasources/local/cache_datasource.dart` - Local caching
  - `repositories/booking_repository_impl.dart` - Booking repository implementation

**Presentation Layer** (`mechanic_app_new/lib/presentation/`)
- **Purpose:** UI screens and state management
- **Components:**
  - 6 Screens (Login, Available Bookings, My Assignments, Vehicle Detail, Update Status, Consume Part)
  - Providers (Riverpod state management)
- **Key Files:**
  - `screens/login/login_screen.dart` - Login screen
  - `screens/available_bookings/available_bookings_screen.dart` - Available bookings
  - `providers/auth_provider.dart` - Authentication state

---

### 4. Customer Frontend Components

#### Architecture

**Single File Application** (`customer-frontend/index.html`)
- **Purpose:** Public booking tracking
- **Components:**
  - HTML structure
  - Embedded JavaScript
  - Tailwind CSS (via CDN)
  - Google Fonts (Cairo)
  - SVG icons
- **Features:**
  - Public token-based booking tracking
  - Responsive design (mobile-first)
  - Dark mode support
  - RTL support (Arabic)
  - Timeline view of booking status
  - Language toggle (Arabic/English)

---

## 🛠️ Technologies & Libraries Analysis

### Backend Technologies

**Language & Framework:**
- **Dart 3.11.5+** - Primary language
- **Shelf 1.4.2** - HTTP server framework
- **Shelf Router 1.1.2** - Route handling
- **Shelf Multipart 1.0.0** - Multipart form data
- **Shelf Static 1.0.0** - Static file serving
- **Shelf WebSocket 2.0.0** - WebSocket support

**Database:**
- **PostgreSQL 3.0.0** - Database driver
- **Supabase 2.0.0** - Supabase client (optional)

**Authentication & Security:**
- **bcrypt 1.1.3** - Password hashing
- **JWT Decoder 2.0.1** - JWT token validation
- **Crypto 3.0.5** - Cryptographic operations
- **UUID 4.4.0** - UUID generation

**Utilities:**
- **Logger 2.3.0** - Logging
- **Dotenv 4.2.0** - Environment variables
- **Intl 0.19.0** - Internationalization
- **QR 3.0.1** - QR code generation
- **PDF 3.10.7** - PDF generation
- **Excel 4.0.3** - Excel export
- **OpenAPI Spec 0.7.0** - API documentation

**Testing:**
- **Test 1.25.6** - Testing framework
- **HTTP 1.2.2** - HTTP client for testing
- **Lints 6.0.0** - Dart linter

---

### Admin Frontend Technologies

**Framework:**
- **Flutter SDK 3.11.5+** - UI framework
- **Flutter Localizations** - Internationalization

**UI Components:**
- **Cupertino Icons 1.0.8** - iOS-style icons
- **FL Chart 0.66.0** - Charting library

**HTTP & Networking:**
- **HTTP 1.2.2** - HTTP client
- **WebSocket Channel 2.4.0** - WebSocket client

**State Management:**
- **Provider 6.1.2** - State management
- **Flutter Riverpod 2.4.0** - State management (preferred)

**Local Storage:**
- **Shared Preferences 2.2.3** - Local key-value storage

**Internationalization:**
- **Intl 0.20.2** - Internationalization

**Additional Features:**
- **QR Flutter 4.1.0** - QR code generation/scanning
- **Printing 5.12.0** - PDF printing
- **File Picker 8.0.0** - File selection
- **WebView Flutter** - Web view integration
- **PDF** - PDF rendering

**Testing:**
- **Flutter Test** - Widget testing
- **Flutter Lints 6.0.0** - Flutter linter

---

### Mechanic App Technologies

**Framework:**
- **Flutter SDK 3.11.5+** - UI framework
- **Flutter Localizations** - Internationalization

**UI Components:**
- **Cupertino Icons 1.0.8** - iOS-style icons

**HTTP & Networking:**
- **HTTP 1.2.2** - HTTP client
- **Dio 5.4.0** - HTTP client with interceptors (preferred)
- **WebSocket Channel 2.4.0** - WebSocket client

**State Management:**
- **Provider 6.1.2** - State management
- **Flutter Riverpod 2.4.9** - State management (preferred)

**Local Storage:**
- **Shared Preferences 2.2.3** - Local key-value storage
- **Flutter Secure Storage 9.2.2** - Secure storage for sensitive data

**Internationalization:**
- **Intl 0.20.2** - Internationalization

**Fonts:**
- **Google Fonts 6.1.0** - Google fonts integration

**Logging:**
- **Logging 1.2.0** - Logging utility

**Testing:**
- **Flutter Test** - Widget testing
- **Flutter Lints 6.0.0** - Flutter linter

---

### Customer Frontend Technologies

**Core:**
- **HTML5** - Markup
- **CSS3** - Styling
- **Vanilla JavaScript** - Logic

**Libraries:**
- **Tailwind CSS** (via CDN) - CSS framework
- **Google Fonts (Cairo)** - Typography
- **SVG Icons** - Icons

---

## 🗄️ Database Structure Analysis

### Schema Overview

**Database:** PostgreSQL 15  
**Primary Key Strategy:** UUID (gen_random_uuid())  
**Foreign Key Strategy:** ON DELETE CASCADE for dependent records

### Core Tables (9 tables)

#### 1. users
```sql
- id (UUID, PK)
- full_name (VARCHAR(255), NOT NULL)
- username (VARCHAR(100), UNIQUE, NOT NULL)
- password_hash (VARCHAR(255), NOT NULL)
- role (VARCHAR(50), NOT NULL)
  - Values: OWNER, MANAGER, RECEPTIONIST, MECHANIC
- is_active (BOOLEAN, DEFAULT true)
- created_at (TIMESTAMP WITH TIME ZONE)
- updated_at (TIMESTAMP WITH TIME ZONE)

Indexes:
- idx_users_username
- idx_users_role
```

#### 2. customers
```sql
- id (UUID, PK)
- full_name (VARCHAR(255), NOT NULL)
- phone (VARCHAR(20), NOT NULL)
- address (TEXT)
- created_at (TIMESTAMP WITH TIME ZONE)
- updated_at (TIMESTAMP WITH TIME ZONE)

Indexes:
- idx_customers_phone

Relationships:
- vehicles.customer_id → customers.id (ON DELETE CASCADE)
- bookings.customer_id → customers.id (ON DELETE CASCADE)
```

#### 3. vehicles
```sql
- id (UUID, PK)
- customer_id (UUID, FK, NOT NULL)
- make (VARCHAR(100), NOT NULL)
- model (VARCHAR(100), NOT NULL)
- year (INTEGER, NOT NULL)
- license_plate (VARCHAR(20))
- vin (VARCHAR(50))
- public_car_id (VARCHAR(255), UNIQUE, NOT NULL, DEFAULT '')
- created_at (TIMESTAMP WITH TIME ZONE)
- updated_at (TIMESTAMP WITH TIME ZONE)

Indexes:
- idx_vehicles_customer_id
- idx_vehicles_license_plate
- idx_vehicles_public_car_id

Relationships:
- bookings.vehicle_id → vehicles.id (ON DELETE CASCADE)
```

#### 4. services
```sql
- id (UUID, PK)
- name (VARCHAR(255), NOT NULL)
- description (TEXT)
- price_syp (DECIMAL(12, 2), NOT NULL)
- estimated_duration_minutes (INTEGER)
- is_active (BOOLEAN, DEFAULT true)
- created_at (TIMESTAMP WITH TIME ZONE)
- updated_at (TIMESTAMP WITH TIME ZONE)

Relationships:
- booking_services.service_id → services.id (ON DELETE CASCADE)
```

#### 5. bookings
```sql
- id (UUID, PK)
- customer_id (UUID, FK, NOT NULL)
- vehicle_id (UUID, FK, NOT NULL)
- status (VARCHAR(50), NOT NULL, DEFAULT 'PENDING')
  - Values: PENDING, IN_PROGRESS, WAITING_PARTS, READY, DELIVERED, CANCELLED
- public_token (VARCHAR(255), UNIQUE, NOT NULL)
- notes (TEXT)
- estimated_completion_date (TIMESTAMP WITH TIME ZONE)
- created_at (TIMESTAMP WITH TIME ZONE)
- updated_at (TIMESTAMP WITH TIME ZONE)

Indexes:
- idx_bookings_customer_id
- idx_bookings_vehicle_id
- idx_bookings_status
- idx_bookings_created_at

Relationships:
- booking_services.booking_id → bookings.id (ON DELETE CASCADE)
- mechanic_assignments.booking_id → bookings.id (ON DELETE CASCADE)
- part_suggestions.booking_id → bookings.id (ON DELETE CASCADE)
```

#### 6. booking_services (Junction Table)
```sql
- id (UUID, PK)
- booking_id (UUID, FK, NOT NULL)
- service_id (UUID, FK, NOT NULL)
- price_syp (DECIMAL(12, 2), NOT NULL)
- notes (TEXT)
- UNIQUE(booking_id, service_id)

Indexes:
- idx_booking_services_booking_id
- idx_booking_services_service_id
```

#### 7. mechanic_assignments
```sql
- id (UUID, PK)
- booking_id (UUID, FK, NOT NULL)
- mechanic_user_id (UUID, FK, NOT NULL)
- status (VARCHAR(50), NOT NULL, DEFAULT 'ASSIGNED')
  - Values: ASSIGNED, IN_PROGRESS, WAITING_PARTS, READY, DELIVERED
- notes (TEXT)
- assigned_at (TIMESTAMP WITH TIME ZONE, DEFAULT CURRENT_TIMESTAMP)
- updated_at (TIMESTAMP WITH TIME ZONE)
- UNIQUE(booking_id)

Indexes:
- idx_mechanic_assignments_booking_id
- idx_mechanic_assignments_mechanic_user_id
- idx_mechanic_assignments_status

Relationships:
- booking_id → bookings.id (ON DELETE CASCADE)
- mechanic_user_id → users.id (ON DELETE CASCADE)
```

#### 8. part_suggestions
```sql
- id (UUID, PK)
- booking_id (UUID, FK, NOT NULL)
- mechanic_user_id (UUID, FK, NOT NULL)
- type (VARCHAR(50), NOT NULL)
  - Values: ORIGINAL, COMMERCIAL, USED
- description (TEXT, NOT NULL)
- price_syp (DECIMAL(12, 2))
- status (VARCHAR(50), NOT NULL, DEFAULT 'PENDING_CUSTOMER_APPROVAL')
  - Values: PENDING_CUSTOMER_APPROVAL, APPROVED, REJECTED
- created_at (TIMESTAMP WITH TIME ZONE)
- updated_at (TIMESTAMP WITH TIME ZONE)

Indexes:
- idx_part_suggestions_booking_id
- idx_part_suggestions_mechanic_user_id
- idx_part_suggestions_status

Relationships:
- booking_id → bookings.id (ON DELETE CASCADE)
- mechanic_user_id → users.id (ON DELETE CASCADE)
```

#### 9. company_settings
```sql
- id (SERIAL, PK)
- company_name (VARCHAR(255), NOT NULL, DEFAULT 'Garage Go')
- company_logo_url (TEXT)
- created_at (TIMESTAMP WITH TIME ZONE)
- updated_at (TIMESTAMP WITH TIME ZONE)
```

### Extended ERP Tables (20+ tables)

#### Accounting Tables
- **accounts** - Chart of accounts (hierarchical structure)
- **journal_entries** - Journal entries
- **journal_lines** - Journal entry lines (debit/credit)
- **fiscal_periods** - Fiscal periods

#### Inventory Tables
- **inventory_items** - Inventory items
- **inventory_variants** - Item variants
- **inventory_transactions** - Stock movements
- **warehouses** - Warehouse locations
- **inventory_transfers** - Stock transfers between warehouses

#### Purchasing & Sales Tables
- **vendors** - Vendors
- **purchase_orders** - Purchase orders
- **purchase_invoices** - Purchase invoices
- **quotations** - Sales quotations
- **sales_orders** - Sales orders

#### Manufacturing Tables
- **bill_of_materials** - BOMs
- **manufacturing_orders** - Manufacturing orders

#### HR Tables
- **employee_contracts** - Employee contracts
- **leave_requests** - Leave requests
- **performance_reviews** - Performance reviews
- **salary_payments** - Salary payments
- **payroll_settings** - Payroll configuration

#### Fixed Assets Tables
- **fixed_assets** - Fixed assets

#### CRM Tables
- **crm_leads** - CRM leads
- **crm_activities** - CRM activities

#### Banking Tables
- **bank_accounts** - Bank accounts
- **bank_reconciliations** - Bank reconciliations

#### Other Tables
- **expenses** - Expenses
- **alerts** - System alerts
- **maintenance_contracts** - Maintenance contracts
- **booking_invoice_data** - Invoice data per booking

### Database Relationships Summary

```
customers (1) ──────< (N) vehicles
customers (1) ──────< (N) bookings
vehicles (1) ───────< (N) bookings
bookings (1) ───────< (N) booking_services
services (1) ───────< (N) booking_services
bookings (1) ───────< (N) mechanic_assignments
users (1) ──────────< (N) mechanic_assignments
bookings (1) ───────< (N) part_suggestions
users (1) ──────────< (N) part_suggestions
```

---

## 🔄 Data Flow Analysis

### 1. Booking Creation Flow

```
User (Admin Frontend)
  ↓
CreateBookingScreen
  ↓ [POST /api/bookings]
BookingRoutes._createBooking
  ↓
CreateBookingUseCase
  ↓
BookingRepositoryImpl.createWithServices()
  ↓
Database Transaction:
  - INSERT bookings
  - INSERT booking_services
  - INSERT booking_invoice_data
  ↓
Response: Booking with publicToken
  ↓
Frontend: Update state, show success
```

### 2. Payment Processing Flow

```
User (Admin Frontend)
  ↓
InvoiceScreen
  ↓ [POST /api/bookings/:id/payment]
BookingRoutes._processPayment
  ↓
ProcessBookingPaymentUseCase
  ↓
Database Transaction:
  - UPDATE booking_invoice_data (payment_status, paid_amount)
  - INSERT journal_entries
  - INSERT journal_lines
    - Debit: Cash/Bank Account
    - Credit: Service Revenue
  - UPDATE bookings (status → DELIVERED)
  ↓
Response: Updated invoice
  ↓
Frontend: Show confirmation
```

### 3. Journal Entry Flow

```
User (Admin Frontend)
  ↓
CreateJournalEntryScreen
  ↓ [POST /api/journal-entries]
AccountingRoutes._createJournalEntry
  ↓
JournalService.createJournalEntry()
  ↓
Validation:
  - total_debit == total_credit
  - All accounts exist
  - Fiscal period is open
  ↓
Database Transaction:
  - INSERT journal_entries
  - INSERT journal_lines
  - UPDATE account balances
  ↓
Response: Created entry with lines
  ↓
Frontend: Update journal entries list
```

### 4. Mechanic Assignment Flow

```
User (Mechanic App)
  ↓
AvailableBookingsScreen
  ↓ [POST /api/mechanics/assign]
MechanicRoutes._assignBooking
  ↓
AssignMechanicUseCase
  ↓
Database Transaction:
  - INSERT mechanic_assignments
  - UPDATE bookings (status → IN_PROGRESS)
  ↓
Response: Assignment created
  ↓
Frontend: Update my assignments list
```

### 5. Inventory Consumption Flow

```
User (Mechanic App)
  ↓
ConsumePartScreen
  ↓ [POST /api/inventory/consume]
InventoryRoutes._consumePart
  ↓
ConsumePartUseCase
  ↓
Database Transaction:
  - UPDATE inventory_variants (quantity - consumed)
  - INSERT inventory_transactions
  - UPDATE booking_invoice_data
  - INSERT journal_entries (if enabled)
    - Debit: Cost of Goods Sold
    - Credit: Inventory
  - Check low stock alerts
  ↓
Response: Consumption confirmed
  ↓
Frontend: Show success, update inventory
```

---

## 🔐 Security & Authentication Analysis

### Authentication Flow

```
User
  ↓ [POST /api/auth/login]
AuthRoutes._login
  ↓
AuthService.login()
  ↓
Validation:
  - Rate limiting (5 attempts/15min)
  - Username exists
  - Password verification (bcrypt)
  ↓
JWT Generation:
  - Access Token (15min expiry)
  - Refresh Token (7days expiry)
  ↓
Response: { token, refreshToken, user }
  ↓
Frontend: Store tokens in SharedPreferences
```

### Authorization Flow

```
User Request
  ↓ [Authorization: Bearer {token}]
AuthMiddleware.authenticate()
  ↓
Token Validation:
  - Token exists
  - Token format valid
  - Token signature valid
  - Token not expired
  ↓
User Lookup:
  - User exists
  - User is active
  ↓
Role Check:
  - User role >= required role
  ↓
Request Handler
```

### Role Hierarchy

```
OWNER (Level 5)
  ├─ All permissions
  ├─ User management
  └─ Account deletion

MANAGER (Level 4)
  ├─ Most functions
  ├─ Resource management
  └─ Approvals

ACCOUNTANT (Level 3)
  ├─ Accounting functions
  ├─ Journal entries
  └─ Financial reports

RECEPTIONIST (Level 2)
  ├─ Booking management
  ├─ Customer management
  └─ Payment processing

MECHANIC (Level 1)
  ├─ View available bookings
  ├─ Assign bookings
  └─ Update status
```

---

## 📊 API Endpoints Analysis

### Authentication Endpoints

| Method | Path | Handler | Auth | Description |
|--------|------|---------|------|-------------|
| POST | /api/auth/login | _login | Public | Login with rate limiting |
| POST | /api/auth/refresh | _refreshToken | Public | Refresh access token |
| POST | /api/auth/register | _register | OWNER | Register new user |
| GET | /api/auth/me | _getMe | Authenticated | Get current user |

### Booking Endpoints

| Method | Path | Handler | Auth | Description |
|--------|------|---------|------|-------------|
| GET | /api/bookings | _getAllBookings | RECEPTIONIST | List bookings (paginated) |
| GET | /api/bookings/:id | _getBookingById | RECEPTIONIST | Get booking details |
| POST | /api/bookings | _createBooking | RECEPTIONIST | Create booking |
| PUT | /api/bookings/:id | _updateBooking | RECEPTIONIST | Update booking |
| PATCH | /api/bookings/:id/status | _updateBookingStatus | MECHANIC+ | Update status |
| POST | /api/bookings/:id/payment | _processPayment | RECEPTIONIST+ | Process payment |
| GET | /api/bookings/:id/invoice | _getInvoice | RECEPTIONIST+ | Get invoice (JSON) |
| GET | /public/bookings/:token | _getBookingByToken | Public | Public tracking |

### Accounting Endpoints

| Method | Path | Handler | Auth | Description |
|--------|------|---------|------|-------------|
| GET | /api/accounts | _getAccounts | OWNER+ | Get chart of accounts |
| POST | /api/accounts | _createAccount | ACCOUNTANT+ | Create account |
| GET | /api/journal-entries | _getJournalEntries | OWNER+ | List journal entries |
| POST | /api/journal-entries | _createJournalEntry | ACCOUNTANT+ | Create journal entry |
| GET | /api/trial-balance | _getTrialBalance | OWNER+ | Trial balance report |
| GET | /api/reports/profit-loss | _getProfitLoss | OWNER+ | P&L statement |
| GET | /api/reports/balance-sheet | _getBalanceSheet | OWNER+ | Balance sheet |

### Mechanic Endpoints

| Method | Path | Handler | Auth | Description |
|--------|------|---------|------|-------------|
| GET | /api/mechanics/available-bookings | _getAvailableBookings | MECHANIC | Available bookings |
| GET | /api/mechanics/my-assignments | _getMyAssignments | MECHANIC | My assignments |
| POST | /api/mechanics/assign | _assignBooking | MECHANIC | Assign booking |
| PATCH | /api/mechanics/assignments/:id/status | _updateAssignmentStatus | MECHANIC+ | Update status |

---

## 🎯 Key Patterns & Conventions

### Code Style

**Backend (Dart):**
- File naming: snake_case (`booking_repository.dart`)
- Class naming: PascalCase (`BookingRepository`)
- Method naming: camelCase (`createBooking`)
- Private fields: underscore prefix (`_db`)
- Use async/await for async operations
- Use extension methods for utilities

**Frontend (Flutter):**
- Widget naming: PascalCase with Screen suffix (`BookingsScreen`)
- Provider naming: camelCase with Provider suffix (`bookingsProvider`)
- Use const constructors where possible
- Use ConsumerWidget/ConsumerStatefulWidget for Riverpod
- Use trailing commas for multi-line parameters

### API Conventions

- Path naming: kebab-case (`/api/journal-entries`)
- Plural nouns for collections (`/api/bookings`)
- Singular nouns for single resources (`/api/bookings/:id`)
- Nested routes for relationships (`/api/bookings/:id/services`)
- Query parameters: `?page=1&limit=20&search=keyword`

### Database Conventions

- Table naming: snake_case (`bookings`, `booking_services`)
- Column naming: snake_case (`customer_id`, `created_at`)
- UUID for primary keys
- Foreign keys: `table_name_id`
- ON DELETE CASCADE for dependent records
- CHECK constraints for enums

### Field Name Mapping

- Database: snake_case (`entry_date`, `account_type`)
- Backend entities: camelCase (`entryDate`, `accountType`)
- Frontend models: Handle both formats
- **Always verify field names match between API and Frontend**

---

## ⚠️ Known Issues & Solutions

### 1. Field Name Mismatches

**Problem:** Backend uses snake_case, Frontend expects camelCase  
**Solution:** Always verify field names match between API response and Frontend model  
**Recent Fixes:** Journal entries pagination, accountName field addition

### 2. Null Safety Issues

**Problem:** Null reference exceptions in journal entry screens  
**Solution:** Use `String?` for optional fields, check null before use  
**Recent Fixes:** String? errors in journal entry screens

### 3. Pagination Not Working

**Problem:** Frontend not sending page/limit parameters  
**Solution:** Always include `page` and `limit` in API calls  
**Recent Fixes:** Pagination in journal entries screen

### 4. Authentication Failures

**Problem:** 401 errors despite valid token  
**Solution:** Check token expiration, implement refresh mechanism  
**Recent Fixes:** JWT refresh token implementation

### 5. Database Transaction Failures

**Problem:** Partial updates on error  
**Solution:** Always use `runInTransaction` for multi-step operations

---

## 📈 Performance Considerations

### Backend

- Connection pooling (max 20 connections)
- Pagination for all list endpoints
- Caching for frequently accessed data
- Indexes on frequently queried columns
- Optimize N+1 queries with joins

### Frontend

- Use const widgets where possible
- Lazy loading for large lists
- FutureProvider.autoDispose for one-time fetches
- Debounce search inputs
- Image caching

---

## 🧪 Testing Strategy

### Backend Testing

- Unit tests for use cases
- Integration tests for repositories
- API tests for routes
- Mock database for unit tests

### Frontend Testing

- Widget tests for screens
- Provider tests for state management
- Integration tests for API calls
- Golden tests for UI snapshots

---

## 🚀 Deployment Strategy

### Environment Variables

Required for production:
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - 32+ character secret
- `JWT_REFRESH_SECRET` - 32+ character secret
- `PORT` - Server port (default: 8080)
- `CORS_ORIGIN` - Admin frontend URL
- `CUSTOMER_CORS_ORIGIN` - Customer frontend URL
- `MECHANIC_CORS_ORIGIN` - Mechanic app URLs

### Build Commands

```bash
# Backend
cd backend
dart pub get
dart run build_runner build
dart bin/server.dart

# Admin Frontend
cd admin_frontend
flutter pub get
flutter build web

# Mechanic App
cd mechanic_app_new
flutter pub get
flutter build apk

# Docker
docker-compose up -d
```

### Deployment Platforms

- **Backend:** Render (Docker)
- **Admin Frontend:** Cloudflare Pages (Flutter Web)
- **Mechanic App:** Google Play Store / Apple App Store
- **Database:** Supabase (PostgreSQL)

---

## 📝 Documentation Status

### Existing Documentation

- ✅ README.md - Project overview
- ✅ PROJECT_OVERVIEW.md - Detailed overview
- ✅ DEPLOYMENT.md - Deployment instructions
- ✅ AGENTS.md - AI memory documentation
- ✅ .cursorrules - Project rules & guidelines
- ✅ PROJECT_ANALYSIS.md - This file

### Audit Reports

- ✅ AUDIT_REPORT.md
- ✅ BACKEND_AUDIT_REPORT.md
- ✅ FINAL_SYSTEM_AUDIT_REPORT.md
- ✅ ERP_TRANSFORMATION_REPORT.md
- ✅ ACCOUNTING_AUDIT_FINAL.md
- ✅ CRITICAL_ISSUES_FIX_REPORT.md
- ✅ COMPREHENSIVE_MICROSCOPIC_AUDIT_REPORT.md
- ✅ OMNI_AUDIT_REPORT.md

---

## 🎯 Recommendations

### Immediate Actions

1. **Update Graphify Analysis** - Last update was May 17, recent fixes not included
2. **Add Integration Tests** - Critical for accounting module
3. **Implement API Rate Limiting** - Beyond login endpoint
4. **Add Request Validation** - Comprehensive input validation
5. **Implement Caching Layer** - Redis for frequently accessed data

### Long-term Improvements

1. **Microservices Migration** - Split accounting into separate service
2. **Event-Driven Architecture** - Implement message queue for async operations
3. **Real-time Notifications** - WebSocket for live updates
4. **Advanced Analytics** - Business intelligence dashboard
5. **Mobile App Enhancements** - Offline support, push notifications

---

## 📊 Project Statistics

| Category | Count |
|----------|-------|
| Backend Entities | 44 |
| Backend Repositories | 38 |
| Backend Use Cases | 88 |
| Backend Services | 13 |
| Backend Routes | 22 |
| Backend Middlewares | 4 |
| Admin Screens | 70+ |
| Mechanic Screens | 6 |
| Database Tables (Basic) | 9 |
| Database Tables (Extended) | 20+ |
| Database Indexes | 15+ |
| User Roles | 8 |
| API Endpoints | 50+ |

---

## 🔗 Related Files

- `.cursorrules` - Project rules & guidelines
- `AGENTS.md` - AI memory documentation
- `backend/.env.example` - Environment variables template
- `supabase-schema.sql` - Database schema
- `docker-compose.yml` - Docker configuration

---

**Analysis Completed:** May 24, 2026  
**Next Phase:** Task Breakdown Plan (TASK_BREAKDOWN_PLAN.md)
