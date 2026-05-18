# Auto Garage Management System

An enterprise-level car garage management system built with Dart and Flutter, featuring a clean architecture backend, admin web frontend, mechanic mobile app, and customer tracking interface.

## 🏗️ Architecture

### Backend (Dart + Shelf)
- **Clean Architecture**: Domain, Application, Infrastructure, and Presentation layers
- **Database**: PostgreSQL with UUID primary keys and proper constraints
- **Authentication**: JWT-based with role-based authorization (ADMIN, MANAGER, RECEPTIONIST, MECHANIC)
- **API**: RESTful endpoints with middleware for auth, logging, error handling, and CORS
- **Validation**: Comprehensive validation layer with reusable validators
- **Error Handling**: Unified error response middleware

### Frontend Applications
- **Admin Frontend**: Flutter Web app for garage staff (admin, manager, receptionist) with dashboard and full CRUD operations
- **Mechanic App**: Flutter mobile app for mechanics to view available bookings and manage assignments
- **Customer Frontend**: Static HTML/JS page for customers to track their booking status via public token

## 📁 Project Structure

```
auto-garage-system/
├── backend/                 # Dart backend with Clean Architecture
│   ├── lib/
│   │   ├── core/           # Constants, errors, utils
│   │   ├── domain/         # Entities and repository interfaces
│   │   ├── infrastructure/ # Database connection and repository implementations
│   │   ├── application/    # Use cases and services
│   │   └── presentation/   # Routes, middlewares
│   ├── bin/server.dart     # Main server entry point
│   ├── pubspec.yaml
│   ├── render.yaml         # Render deployment config
│   └── Dockerfile         # Docker configuration
├── admin_frontend/         # Flutter Web admin app
│   ├── lib/
│   │   ├── core/          # Services, constants
│   │   ├── screens/       # UI screens
│   │   └── main.dart      # Main app file
│   └── pubspec.yaml
├── mechanic_app_new/       # Flutter mobile mechanic app
│   ├── lib/
│   │   ├── core/          # Services, constants
│   │   ├── screens/       # UI screens
│   │   └── main.dart      # Main app file
│   └── pubspec.yaml
├── customer-frontend/      # Static HTML/JS customer tracking
│   └── index.html
└── docker-compose.yml      # Docker orchestration
```

## 🚀 Getting Started

### Prerequisites
- Dart SDK 3.11.5 or higher
- Flutter SDK
- PostgreSQL database
- Docker (optional, for containerized deployment)
- (Optional) Render account for backend deployment
- (Optional) Cloudflare Pages account for frontend deployment

### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
dart pub get
```

3. Run build_runner to generate JSON serialization files:
```bash
dart run build_runner build
```

4. Configure environment variables in `.env`:
```
DATABASE_URL=postgresql://username:password@localhost:5432/garage_db
PORT=8080
JWT_SECRET=your-secret-key-change-in-production
```

5. Run the server:
```bash
dart run bin/server.dart
```

The API will be available at `http://localhost:8080`

### Admin Frontend Setup

1. Navigate to the admin_frontend directory:
```bash
cd admin_frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Build for web:
```bash
flutter build web
```

4. Serve the web build:
```bash
flutter run -d chrome
```

### Mechanic App Setup

1. Navigate to the mechanic_app_new directory:
```bash
cd mechanic_app_new
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run on device or emulator:
```bash
flutter run
```

### Customer Frontend

The customer frontend is a static HTML file located in `customer-frontend/index.html`. It can be served by any web server or deployed as a static site.

## 🐳 Docker Deployment

### Using Docker Compose

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Edit `.env` with your configuration:
```
DATABASE_URL=postgresql://garage:garage123@postgres:5432/garage_db
JWT_SECRET=your-secret-key-change-in-production
PORT=8080
```

3. Start all services:
```bash
docker-compose up -d
```

This will start:
- PostgreSQL database
- Backend API server
- Nginx serving admin frontend and customer frontend

### Access the Applications

- **Backend API**: http://localhost:8080
- **Admin Frontend**: http://localhost
- **Customer Frontend**: http://localhost/customer

## 🚀 Deployment

### Backend (Render)

The backend is deployed on Render using `render.yaml`.

**Environment Variables Required:**
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: Secret key for JWT token generation
- `JWT_REFRESH_SECRET`: Secret key for JWT refresh token generation
- `PORT`: Server port (default: 8080)

**Default Users:**
- **Admin:** username: `admin`, password: `admin123`
- **Receptionist:** username: `receptionist`, password: `receptionist123`
- **Mechanic:** username: `mechanic`, password: `mechanic123`

### Admin Frontend (Cloudflare Pages)

The admin frontend is deployed on Cloudflare Pages as a static site.

**Steps:**
1. Build the web version locally:
```bash
cd admin_frontend
flutter build web
```

2. Deploy the `build/web` directory to Cloudflare Pages:
   - Connect your GitHub repository
   - Set build command: `cd admin_frontend && flutter build web`
   - Set output directory: `admin_frontend/build/web`
   - Or use Direct Upload: Upload the `build/web` folder directly

## �📡 API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration (initial setup only)

### Customers
- `GET /api/customers` - List all customers
- `POST /api/customers` - Create new customer
- `GET /api/customers/:id` - Get customer by ID
- `PUT /api/customers/:id` - Update customer
- `DELETE /api/customers/:id` - Delete customer

### Vehicles
- `GET /api/vehicles` - List all vehicles
- `POST /api/vehicles` - Create new vehicle
- `GET /api/vehicles/:id` - Get vehicle by ID
- `PUT /api/vehicles/:id` - Update vehicle
- `GET /api/vehicles/customer/:customerId` - Get vehicles by customer

### Services
- `GET /api/services` - List all services
- `POST /api/services` - Create new service
- `GET /api/services/:id` - Get service by ID
- `PUT /api/services/:id` - Update service

### Bookings
- `GET /api/bookings` - List all bookings
- `POST /api/bookings` - Create new booking
- `GET /api/bookings/:id` - Get booking by ID
- `PATCH /api/bookings/:id/status` - Update booking status
- `GET /api/bookings/customer/:customerId` - Get bookings by customer
- `GET /api/bookings/status/:status` - Get bookings by status
- `GET /public/bookings/:publicToken` - Public booking tracking

### Mechanics
- `GET /api/mechanics/available-bookings` - Get available bookings for mechanics
- `POST /api/mechanics/assign` - Assign booking to mechanic
- `GET /api/mechanics/my-assignments` - Get mechanic's assignments
- `PATCH /api/mechanics/assignments/:id/status` - Update assignment status
- `POST /api/mechanics/bookings/:id/part-suggestions` - Create part suggestion

### Inventory
- `GET /api/inventory/items` - List all inventory items
- `POST /api/inventory/items` - Create new inventory item (MANAGER)
- `PUT /api/inventory/items/:id` - Update inventory item (MANAGER)
- `DELETE /api/inventory/items/:id` - Delete inventory item (OWNER)
- `GET /api/inventory/variants` - List all inventory variants
- `POST /api/inventory/variants` - Create new inventory variant (MANAGER)
- `PUT /api/inventory/variants/:id` - Update inventory variant (MANAGER)
- `DELETE /api/inventory/variants/:id` - Delete inventory variant (OWNER)
- `GET /api/inventory/low-stock` - Get low stock items
- `POST /api/inventory/consume` - Consume inventory parts (MECHANIC)

### Invoices
- `GET /api/bookings/:id/invoice` - Get invoice by booking ID
- `GET /api/bookings/:id/invoice/pdf` - Get invoice PDF by booking ID

### Dashboard
- `GET /api/dashboard/stats` - Get dashboard statistics
- `GET /api/dashboard/revenue?period=month` - Get revenue statistics

## 🔐 Roles and Permissions

### OWNER
- Full access to all features
- Can manage users and roles
- Can view all financial data
- Can perform all accounting operations

### MANAGER
- Full access to bookings, customers, vehicles, services
- Can view dashboard statistics
- Can view financial reports (read-only)
- Cannot manage users
- Cannot create journal entries

### ACCOUNTANT
- Full access to accounting features
- Can manage chart of accounts
- Can create and edit journal entries
- Can view all financial reports
- Can manage vendors, purchase invoices, expenses
- Can perform bank reconciliation
- Cannot access operations (bookings, inventory, etc.)
- Cannot manage users

### RECEPTIONIST
- Can create and view bookings
- Can create and view customers
- Can create and view vehicles
- Cannot modify services or users
- Cannot access accounting features

### MECHANIC
- Can view available bookings
- Can assign bookings to self
- Can update assignment status
- Can create part suggestions
- Can access inventory (consume parts only)
- Cannot access financial data

## 🔧 Database Schema

The PostgreSQL database includes:
- `users` - System users with roles
- `customers` - Customer information
- `vehicles` - Vehicle details linked to customers
- `services` - Available services with pricing
- `bookings` - Booking records with public tokens
- `booking_services` - Many-to-many relationship between bookings and services
- `mechanic_assignments` - Mechanic assignments to bookings
- `part_suggestions` - Part suggestions from mechanics
- `inventory_items` - Inventory items (parts, materials)
- `inventory_variants` - Inventory variants (original, commercial, used)
- `inventory_transactions` - Inventory transaction history
- `booking_invoice_data` - Invoice data snapshots
- `alerts` - System alerts (low stock, etc.)
- `accounts` - Chart of accounts for accounting
- `journal_entries` - Journal entries with lines
- `journal_lines` - Individual journal entry lines
- `vendors` - Vendor information
- `purchase_invoices` - Purchase invoices from vendors
- `purchase_invoice_items` - Purchase invoice line items
- `expenses` - Operating expenses
- `bank_accounts` - Bank accounts
- `bank_reconciliations` - Bank reconciliation records
- `company_settings` - Company configuration
- `service_categories` - Service categories
- `spare_parts_categories` - Spare parts categories
- `employees` - Employee records with salary details
- `salary_payments` - Salary payment records

All tables use UUID primary keys and include appropriate indexes for performance.

## 💰 Accounting System

The system includes a comprehensive double-entry accounting module:

### Chart of Accounts
- Hierarchical account structure with parent-child relationships
- Account types: Asset, Liability, Equity, Revenue, Expense, COGS
- Support for inactive accounts

### Journal Entries
- Double-entry bookkeeping with automatic validation
- Debit/Credit balance verification
- Automatic journal entry creation from operations:
  - Bookings → Revenue entries
  - Inventory consumption → COGS entries
  - Purchase invoices → Inventory and vendor entries
  - Expenses → Expense entries
  - Salary payments → Salary expense entries

### Financial Reports
- **Trial Balance** - Summary of all account balances
- **Profit & Loss Statement** - Revenue vs Expenses
- **Balance Sheet** - Assets, Liabilities, Equity
- **General Ledger** - Detailed transaction history
- **Cash Flow Statement** - Indirect method
- **Break-even Analysis** - Fixed vs Variable costs
- **Trading Account** - Revenue, COGS, Gross Profit

### Vendor Management
- CRUD operations for vendors
- Purchase invoice creation with automatic journal entries
- Invoice payment tracking
- Automatic inventory updates

### Expense Management
- Operating expense tracking
- Automatic journal entry creation
- Attachment support (receipts)
- Expense categorization

### Bank Reconciliation
- Bank account management
- Statement reconciliation
- Automatic adjustment journal entries for discrepancies

### Payroll
- Employee salary management
- Salary payment processing
- Automatic journal entry creation
- Payroll reports

### Testing the Accounting System

Run the following test scenarios to verify the accounting system:

1. **Operations → Automatic Journal Entries**
   - Create a booking with services → Verify revenue journal entry
   - Consume inventory part → Verify COGS journal entry
   - Create purchase invoice → Verify inventory/vendor journal entry
   - Pay salary → Verify salary expense journal entry
   - Add expense → Verify expense journal entry

2. **Manual Journal Entries**
   - Create manual journal entry → Verify it appears in general ledger
   - Try unbalanced entry → Verify rejection with error
   - Edit journal entry → Verify balance update
   - Delete journal entry → Verify removal from ledger

3. **Chart of Accounts**
   - Add parent account → Verify it appears in tree
   - Add child account → Verify it appears under parent
   - Deactivate account → Verify it doesn't appear in dropdowns
   - Try deleting account with transactions → Verify error

4. **Financial Reports**
   - Run trial balance → Verify debit = credit
   - Run P&L → Verify net profit calculation
   - Run balance sheet → Verify assets = liabilities + equity
   - Run general ledger → Verify transaction history
   - Run cash flow → Verify cash balance consistency
   - Run break-even → Verify reasonable value
   - Run trading account → Verify gross profit calculation

5. **Vendors & Purchase Invoices**
   - Add vendor → Verify it appears in list
   - Create purchase invoice → Verify inventory update and journal entry
   - Pay invoice partially → Verify status update and payment journal entry
   - Pay full amount → Verify status becomes "paid"

6. **Expenses & Bank Reconciliation**
   - Add expense with receipt → Verify attachment and journal entry
   - Reconcile bank account → Verify discrepancy handling
   - Complete reconciliation → Verify record creation

7. **Payroll**
   - Create salary payment → Verify all employees included
   - Edit employee salary → Verify recalculation
   - Pay salary → Verify journal entry and status update
   - Try paying already paid salary → Verify error

8. **Permissions**
   - Login as accountant → Verify only accounting menu visible
   - Try accessing /api/users as accountant → Verify 403 error
   - Login as manager → Verify reports only (read-only)
   - Login as owner → Verify full access

## 📝 Important Notes

### No Email Policy
- **Email is strictly forbidden** in the entire system
- No email storage for users or customers
- No email login authentication
- No email notifications
- No email in invoices or accounts
- Staff/Mechanics login via username + password only
- Customers access their page via unique publicToken only
- Customer page is public (no login required)

## ⚠️ Known Issues & Current Status

### Fixed Issues
1. **Sql.named Parameters** - Fixed by using `Sql.named` with proper `Map<String, dynamic>` parameters across all repositories
2. **JWT Security** - Implemented proper HMAC-SHA256 signature verification with `JWT_SECRET`, added `exp` enforcement, and constant-time signature comparison
3. **Response Parsing** - Fixed frontend to handle direct array responses with strong typing (`List<Map<String, dynamic>>`)
4. **NoSuchMethodError in Frontend** - Fixed by converting API responses to `List<Map<String, dynamic>>` in Customers, Bookings, Services, and Employees screens
5. **N+1 Queries** - Fixed in `mechanic_routes` (`findAvailableForMechanic`) and `dashboard_routes` (`findByBookingIds` batch query)
6. **Open Registration** - Protected `POST /api/auth/register` with authentication + OWNER role requirement
7. **Open CORS** - Made CORS origin configurable via `CORS_ORIGIN` environment variable
8. **Rate Limiting** - Added login rate limiting (5 attempts per 15 minutes per IP)
9. **Input Validation** - Added trimming and empty-string rejection across all create/update endpoints
10. **Schema Default Admin** - Removed unsafe placeholder hash insert from schema.sql
11. **Missing Indexes** - Added indexes on `users.username`, `users.role`, `services.is_active`, `vehicles.license_plate`

### Current Issues
- **None critical.** All previously identified issues have been resolved.

### Important Implementation Details
- **Database Field Naming:** PostgreSQL uses snake_case (full_name, created_at), but backend entities use camelCase (fullName, createdAt). Repository mapping handles the conversion.
- **API Response Format:** Backend returns JSON arrays directly, not wrapped in `{data: [...]}`. Frontend must handle this.
- **Role Hierarchy:** OWNER (4) > MANAGER (3) > RECEPTIONIST (2) > MECHANIC (1). Higher roles can access lower role endpoints.
- **JWT Security:** Tokens are signed with HS256 using `JWT_SECRET`. Default tokens expire after 24 hours.

## 📝 Future Enhancements

- WhatsApp Business API integration for customer notifications
- Advanced reporting and analytics
- Multi-language support
- Push notifications
- Photo attachments for vehicles and parts

## 🤝 Contributing

This is a private project for enterprise use. Contributions should follow the existing clean architecture patterns and coding standards.

## 📄 License

Private - All rights reserved.
