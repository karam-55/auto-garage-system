# Auto Garage Management System - Complete Project Memory

## 📋 Project Overview
- **CorpusName**: karam-55/auto-garage-system
- **Name**: Auto Garage Management System (نظام إدارة مرآب السيارات)
- **Type**: Full-stack Automotive Service Management System (ERP + CRM + Accounting)
- **Status**: Active Development - Production-Ready
- **Language**: Arabic UI with English code
- **Architecture**: Clean Architecture (Domain-Driven Design)

---

## 🏗️ System Architecture

### Backend (Dart + Shelf)
- **Path**: `backend/`
- **Architecture**: Clean Architecture (4 layers)
  - Domain Layer: Entities, Repository Interfaces
  - Application Layer: Use Cases, Services
  - Infrastructure Layer: Repository Implementations, Database
  - Presentation Layer: Routes, Middlewares
- **Database**: PostgreSQL 15 with UUID primary keys
- **Auth**: JWT-based with 8 roles
- **Entry Point**: `backend/bin/server.dart`
- **Generated Code**: `dart run build_runner build`

### Frontend Applications
1. **Admin Frontend** - Flutter Web (70+ screens)
   - Path: `admin_frontend/`
   - Target: OWNER, MANAGER, RECEPTIONIST, ACCOUNTANT, HR_MANAGER
   - Features: Dashboard, Bookings, Accounting (20 screens), ERP modules, CRM, HR
2. **Mechanic App** - Flutter Mobile (6 screens)
   - Path: `mechanic_app_new/`
   - Target: MECHANIC
   - Features: Login, Available Bookings, My Assignments, Vehicle Details, Status Updates, Part Consumption
3. **Customer Frontend** - Static HTML/JS
   - Path: `customer-frontend/`
   - Target: Public customers
   - Features: Booking tracking via public token

### Additional Components
- **garage-go-catalog/**: Spare parts catalog
- **lib/**: Shared libraries
- **graphify-out/**: Knowledge graph analysis (outdated - May 17)

---

## 🗄️ Database Schema

### Tables (9 main tables in supabase-schema.sql)
- `users` - Users with roles (OWNER, MANAGER, RECEPTIONIST, MECHANIC, ACCOUNTANT, HR_MANAGER)
- `customers` - Customer information
- `vehicles` - Vehicle details with public_car_id
- `services` - Available services with pricing
- `bookings` - Bookings with status (PENDING, IN_PROGRESS, WAITING_PARTS, READY, DELIVERED, CANCELLED)
- `booking_services` - Junction table for booking-service relationships
- `mechanic_assignments` - Mechanic to booking assignments
- `part_suggestions` - Part suggestions (ORIGINAL, COMMERCIAL, USED)
- `company_settings` - Company configuration

### Additional Tables (Extended ERP)
- `accounts` - Chart of accounts (hierarchical)
- `journal_entries` - Journal entries with lines
- `journal_lines` - Debit/credit lines
- `inventory_items` - Inventory items
- `inventory_variants` - Item variants
- `inventory_transactions` - Stock movements
- `vendors` - Vendors
- `expenses` - Expenses
- `purchase_orders` - Purchase orders
- `purchase_invoices` - Purchase invoices
- `sales_orders` - Sales orders
- `quotations` - Quotations
- `warehouses` - Warehouses
- `inventory_transfers` - Stock transfers
- `bill_of_materials` - BOMs
- `manufacturing_orders` - Manufacturing orders
- `fixed_assets` - Fixed assets
- `employee_contracts` - Employee contracts
- `leave_requests` - Leave requests
- `performance_reviews` - Performance reviews
- `salary_payments` - Salary payments
- `payroll_settings` - Payroll configuration
- `crm_leads` - CRM leads
- `crm_activities` - CRM activities
- `bank_accounts` - Bank accounts
- `bank_reconciliations` - Bank reconciliations
- `fiscal_periods` - Fiscal periods
- `booking_invoice_data` - Invoice data per booking
- `alerts` - System alerts
- `maintenance_contracts` - Maintenance contracts

### Indexes (15+)
- idx_users_username, idx_users_role
- idx_customers_phone
- idx_vehicles_customer_id, idx_vehicles_license_plate, idx_vehicles_public_car_id
- idx_bookings_customer_id, idx_bookings_vehicle_id, idx_bookings_status, idx_bookings_created_at
- idx_booking_services_booking_id, idx_booking_services_service_id
- idx_mechanic_assignments_booking_id, idx_mechanic_assignments_mechanic_user_id, idx_mechanic_assignments_status
- idx_part_suggestions_booking_id, idx_part_suggestions_mechanic_user_id, idx_part_suggestions_status

---

## 🔌 API Endpoints

### Authentication Routes (`/api/auth/*`)
- POST `/api/auth/login` - Login (rate limited: 5 attempts/15min)
- POST `/api/auth/refresh` - Refresh access token
- POST `/api/auth/register` - Register new user (OWNER only)
- POST `/api/auth/mechanic-register` - Self-register mechanic
- GET `/api/auth/me` - Get current user
- GET/POST/DELETE `/api/users` - User management

### Booking Routes (`/api/bookings/*`)
- GET `/api/bookings` - List bookings (with pagination)
- GET `/api/bookings/:id` - Get booking details
- GET `/api/bookings/customer/:customerId` - Get customer bookings
- GET `/api/bookings/status/:status` - Get bookings by status
- POST `/api/bookings` - Create booking
- PUT `/api/bookings/:id` - Update booking
- PATCH `/api/bookings/:id/status` - Update status
- PATCH `/api/bookings/:id/services` - Update services
- POST `/api/bookings/:id/payment` - Process payment
- GET `/api/bookings/:id/invoice` - Get invoice (JSON)
- GET `/api/bookings/:id/invoice/pdf` - Get invoice (PDF)
- DELETE `/api/bookings/:id` - Delete booking
- GET `/public/bookings/:publicToken` - Public tracking

### Accounting Routes (`/api/accounts/*`, `/api/journal-entries/*`)
- GET/POST/PUT/DELETE `/api/accounts` - Chart of accounts management
- GET `/api/journal-entries` - List journal entries (with pagination)
- POST `/api/journal-entries` - Create journal entry
- PUT/DELETE `/api/journal-entries/:id` - Update/delete entry
- GET `/api/journal-entries/:id` - Get entry details
- GET `/api/trial-balance` - Trial balance report
- GET `/api/reports/profit-loss` - P&L statement
- GET `/api/reports/balance-sheet` - Balance sheet
- GET `/api/reports/general-ledger` - General ledger
- GET `/api/reports/cash-flow` - Cash flow statement
- GET `/api/reports/break-even` - Break-even analysis
- GET `/api/reports/trading` - Trading account

### Inventory Routes (`/api/inventory/*`)
- GET/POST/PUT/DELETE `/api/inventory/items` - Item management
- GET/POST/PUT/DELETE `/api/inventory/variants` - Variant management
- GET `/api/inventory/low-stock` - Low stock alerts
- POST `/api/inventory/consume` - Consume part (mechanic)

### Mechanic Routes (`/api/mechanics/*`)
- GET `/api/mechanics/available-bookings` - Available bookings
- GET `/api/mechanics/my-assignments` - My assignments
- POST `/api/mechanics/assign` - Assign booking
- PATCH `/api/mechanics/assignments/:id/status` - Update assignment status
- POST `/api/mechanics/bookings/:bookingId/part-suggestions` - Create part suggestion
- GET `/api/mechanics/bookings/:bookingId/part-suggestions` - Get suggestions
- PATCH `/public/part-suggestions/:id/status` - Update suggestion status

### Dashboard Routes (`/api/dashboard/*`)
- GET `/api/dashboard/stats` - General statistics
- GET `/api/dashboard/revenue` - Revenue statistics
- GET `/api/dashboard/sales-stats` - Sales statistics
- GET `/api/dashboard/purchase-stats` - Purchase statistics
- GET `/api/dashboard/inventory-stats` - Inventory statistics
- GET `/api/dashboard/manufacturing-stats` - Manufacturing statistics
- GET `/api/dashboard/hr-stats` - HR statistics
- GET `/api/dashboard/fixed-assets-stats` - Fixed assets statistics

### Other Routes
- `/api/customers/*` - Customer management
- `/api/vehicles/*` - Vehicle management
- `/api/services/*` - Service management
- `/api/inventory/*` - Inventory management
- `/api/vendors/*` - Vendor management
- `/api/expenses/*` - Expense management
- `/api/payroll/*` - Payroll management
- `/api/erp/*` - ERP modules
- `/api/hr/*` - HR management
- `/api/crm/*` - CRM management
- `/api/company/settings` - Company settings

---

## 🔄 Data Flows

### Booking Creation Flow
1. Admin Frontend: CreateBookingScreen validates form
2. POST `/api/bookings` with customer, vehicle, services
3. Backend: BookingRoutes._createBooking
   - Parse & validate JSON
   - Create Booking entity
   - Create BookingService entities
   - Execute CreateBookingUseCase
   - Save to DB (bookings, booking_services, booking_invoice_data)
   - Fetch vehicle for publicCarId
4. Return booking with publicToken
5. Frontend: Update state, show success, generate QR code

### Payment & Invoice Flow
1. GET `/api/bookings/:id/invoice` - Fetch invoice data
2. User confirms payment (amount, method)
3. POST `/api/bookings/:id/payment`
4. Backend: ProcessBookingPaymentUseCase
   - Update invoice_data (payment_status, paid_amount, payment_date)
   - Create journal entries:
     - Debit: Cash/Bank Account
     - Credit: Service Revenue
   - Update booking status → DELIVERED
5. Return updated invoice
6. Frontend: Show confirmation, update status

### Journal Entries Flow
1. Admin Frontend: JournalEntriesScreen (list with pagination)
2. POST `/api/journal-entries` with:
   - entry_date, reference, description
   - lines: [{account_id, debit, credit, description}]
   - source_type, source_id, fiscal_period_id
3. Backend: JournalService.createJournalEntry
   - Validate debit = credit
   - Create journal_entries record
   - Create journal_lines records
   - Update account balances
   - Generate audit trail
4. Return created entry with lines
5. Related: GET `/api/trial-balance`, `/api/reports/general-ledger`

### Inventory Management Flow
1. Admin Frontend: InventoryScreen
2. GET/POST `/api/inventory/items` - Item management
3. GET/POST `/api/inventory/variants` - Variant management
4. Mechanic: POST `/api/inventory/consume`
   - Decrease variant quantity
   - Create inventory_transaction
   - Update booking_invoice_data
   - Create journal entries (if enabled)
   - Check low stock alerts
5. GET `/api/inventory/low-stock` - Low stock alerts

---

## 🛡️ Middlewares

### Auth Middleware
- `authenticate()` - Verify JWT token, check user is active
- `requireRole(Role)` - Check user role (hierarchy: OWNER > MANAGER > ACCOUNTANT > RECEPTIONIST > MECHANIC)
- `requireAnyRole(List<Role>)` - Check if user has any of allowed roles

### Other Middlewares
- `ErrorMiddleware` - Unified error handling (converts exceptions to JSON responses)
- `JsonMiddleware` - JSON content type headers, JSON body parsing
- `LoggingMiddleware` - Request/response logging with timing
- `CORS Middleware` - Cross-origin resource sharing

---

## 👥 User Roles & Permissions

| Role | Access Level | Responsibilities |
|------|-------------|------------------|
| **OWNER** | Full access | System management, user creation, account deletion, all reports |
| **MANAGER** | Most functions | Booking management, statistics, resources, approvals |
| **MANAGER_SALES** | Sales | Sales management, quotations, sales orders |
| **MANAGER_WAREHOUSE** | Warehouse | Warehouse management, inventory |
| **RECEPTIONIST** | Bookings & Inventory | Create bookings, manage customers, process payments, inventory |
| **MECHANIC** | Own bookings | View available bookings, assign bookings, update status, suggest parts, consume inventory |
| **ACCOUNTANT** | Accounting | Create journal entries, manage accounts, financial reports |
| **HR_MANAGER** | HR | Employee contracts, leave requests, performance reviews, payroll |

---

## 📱 Admin Frontend Screens (70+)

### Core Screens
- `dashboard_screen.dart` - Main dashboard
- `overview_screen.dart` - System overview
- `bookings_screen.dart` - Bookings list
- `create_booking_screen.dart` - Create booking
- `quick_booking_screen.dart` - Quick booking
- `customers_screen.dart` - Customers list
- `vehicles_screen.dart` - Vehicles list
- `services_screen.dart` - Services list
- `inventory_screen.dart` - Inventory management
- `invoice_screen.dart` - Invoice display
- `employees_screen.dart` - Employees list
- `company_settings_screen.dart` - Company settings
- `change_password_screen.dart` - Change password
- `reports_screen.dart` - Reports hub
- `api_docs_screen.dart` - API documentation

### Accounting Screens (20)
- `accounting_screen.dart` - Accounting hub
- `chart_of_accounts_screen.dart` - Chart of accounts
- `journal_entries_screen.dart` - Journal entries list
- `journal_entry_details_screen.dart` - Entry details
- `create_journal_entry_screen.dart` - Create entry
- `trial_balance_screen.dart` - Trial balance
- `profit_loss_screen.dart` - P&L statement
- `balance_sheet_screen.dart` - Balance sheet
- `general_ledger_screen.dart` - General ledger
- `cash_flow_screen.dart` - Cash flow statement
- `trading_account_screen.dart` - Trading account
- `break_even_screen.dart` - Break-even analysis
- `vendors_screen.dart` - Vendors
- `purchase_invoices_screen.dart` - Purchase invoices
- `expenses_screen.dart` - Expenses
- `payroll_screen.dart` - Payroll
- `payroll_settings_screen.dart` - Payroll settings
- `payroll_report_screen.dart` - Payroll report
- `bank_accounts_screen.dart` - Bank accounts
- `bank_reconciliation_screen.dart` - Bank reconciliation

### ERP Modules
- **Purchasing:** `purchase_orders_screen.dart`, `create_purchase_order_screen.dart`
- **Sales:** `quotations_screen.dart`, `sales_orders_screen.dart`, `create_quotation_screen.dart`, `create_sales_order_screen.dart`
- **Warehouse:** `warehouses_screen.dart`, `inventory_transfers_screen.dart`, `create_warehouse_screen.dart`, `create_inventory_transfer_screen.dart`
- **Manufacturing:** `manufacturing_orders_screen.dart`, `boms_screen.dart`, `create_manufacturing_order_screen.dart`, `create_bom_screen.dart`
- **HR:** `hr_screen.dart`, `employee_contracts_screen.dart`, `leave_requests_screen.dart`, `create_employee_contract_screen.dart`, `create_leave_request_screen.dart`
- **Fixed Assets:** `fixed_assets_screen.dart`, `create_fixed_asset_screen.dart`
- **CRM:** `crm_screen.dart`, `leads_screen.dart`, `create_lead_screen.dart`
- **Maintenance:** `maintenance_contracts_screen.dart`, `create_maintenance_contract_screen.dart`

---

## 📱 Mechanic App Screens (6)

- `login_screen.dart` - Mechanic login
- `available_bookings_screen.dart` - Available bookings to assign
- `my_assignments_screen.dart` - Assigned bookings
- `vehicle_detail_screen.dart` - Vehicle and service details
- `update_maintenance_status_screen.dart` - Update maintenance status
- `consume_part_screen.dart` - Consume inventory parts

---

## 🔧 Recent Fixes (May 22-23, 2026)

1. **Journal Entries Pagination** - Fixed query string in journalEntriesProvider
2. **Journal Entry Details** - Added accountName and pagination support
3. **Journal Entries Screen** - Fixed pagination - sending page and limit to Backend
4. **Account Name Fetching** - Fetch account name from accounts table
5. **Type Cast Fix** - Fixed type cast in journal repository using named column mapping
6. **Null Safety** - Fixed String? errors in journal entry screens
7. **Backend API Compatibility** - Fixed JournalEntry compatibility with Backend API - added missing fields and improved null safety
8. **Minified Error** - Fixed minified:C0 error - improved null safety in JournalEntry
9. **Financial Amounts** - Fixed financial amounts display - fetching invoice data per booking
10. **Card Layout** - Fixed card design - reduced childAspectRatio to prevent overflow

---

## 🚀 Key Commands

### Backend
```bash
cd backend
dart pub get
dart run build_runner build
dart bin/server.dart
```

### Admin Frontend
```bash
cd admin_frontend
flutter pub get
flutter run -d chrome
flutter build web
```

### Mechanic App
```bash
cd mechanic_app_new
flutter pub get
flutter run
flutter build apk
```

### Docker
```bash
docker-compose up -d
docker-compose down
docker-compose logs -f backend
```

---

## 🐛 Known Issues & Notes

### Field Name Consistency
- Backend uses snake_case in database (entry_date, account_type)
- Backend entities use camelCase (entryDate, accountType)
- Frontend models handle both formats for compatibility
- **Always check Backend API field names match Frontend models**

### Null Safety
- Use `String?` for optional fields
- Check for null before use
- Journal entries require careful null handling

### Pagination
- Use `page` and `limit` parameters
- Supports offset-based pagination
- Default: page=1, limit=20

### Authentication
- All routes protected by JWT (except `/public/*`)
- Use `Authorization: Bearer {token}` header
- Token refresh mechanism available

### Error Handling
- Use unified Failure types
- Centralized error handling in ErrorMiddleware
- All errors return JSON responses

### Database Transactions
- Use `runInTransaction` for complex operations
- Automatic rollback on failure

---

## 📁 Important Files

### Configuration
- `docker-compose.yml` - Docker orchestration
- `supabase-schema.sql` - Database schema
- `backend/.env` - Environment variables
- `backend/render.yaml` - Render deployment config
- `backend/Dockerfile` - Backend Docker image
- `nginx.conf` - Nginx configuration

### Seed Data
- `seed_data.ps1` - Database seeding script
- `seed_data_fixed.ps1` - Fixed seeding script
- `seed_data_simple.ps1` - Simple seeding script
- `backend/bin/seed_data.dart` - Dart seed data

### Documentation
- `README.md` - Project documentation
- `PROJECT_OVERVIEW.md` - Project overview
- `DEPLOYMENT.md` - Deployment instructions
- `AGENTS.md` - This file (AI memory)

### Audit Reports
- `AUDIT_REPORT.md`
- `BACKEND_AUDIT_REPORT.md`
- `FINAL_SYSTEM_AUDIT_REPORT.md`
- `ERP_TRANSFORMATION_REPORT.md`
- `ACCOUNTING_AUDIT_FINAL.md`
- `CRITICAL_ISSUES_FIX_REPORT.md`
- `COMPREHENSIVE_MICROSCOPIC_AUDIT_REPORT.md`
- `OMNI_AUDIT_REPORT.md`

---

## 📊 Project Statistics

| Category | Count |
|----------|-------|
| Entities | 44 |
| Repositories | 38 |
| Use Cases | 88 |
| Routes | 22 |
| Middlewares | 4 |
| Admin Screens | 70+ |
| Mechanic Screens | 6 |
| Database Tables | 9 (basic) + 20+ (extended) |
| Database Indexes | 15+ |
| Services | 13 |
| Frontend Models | 3+ |

---

## �️ Tech Stack

### Backend
- Dart 3.11.5+
- Shelf (HTTP server)
- PostgreSQL 15
- JWT authentication
- bcrypt password hashing
- Logger package
- uuid package
- dotenv

### Admin Frontend
- Flutter Web
- Riverpod (state management)
- http package
- shared_preferences
- fl_chart (charts)
- google_fonts
- Flutter Localizations

### Mechanic App
- Flutter Mobile
- Riverpod (state management)
- dio (HTTP client)
- shared_preferences

### Customer Frontend
- HTML/CSS/JS (Vanilla)
- Tailwind CSS
- Google Fonts (Cairo)
- SVG icons

### DevOps
- Docker
- Docker Compose
- Render (backend deployment)
- Cloudflare Pages (frontend deployment)
- Supabase (PostgreSQL)

---

## 💡 Developer Guidelines

1. **Always verify field name alignment** between frontend models and backend API responses
2. **Use null-safe types** (`String?`) for optional fields
3. **Implement pagination** for list endpoints (page, limit parameters)
4. **Handle errors gracefully** using Failure types and ErrorMiddleware
5. **Use database transactions** for multi-step operations
6. **Test authentication** - ensure JWT tokens are properly validated
7. **Check role permissions** - use appropriate middleware for each route
8. **Validate input** - both on frontend and backend
9. **Log important operations** - use Logger package
10. **Keep Arabic UI consistent** - use app_localizations for all user-facing text

---

**Last Updated:** May 24, 2026
**Status:** Production-Ready
**Version:** 1.0.0
