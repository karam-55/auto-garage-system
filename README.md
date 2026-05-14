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

### Dashboard
- `GET /api/dashboard/stats` - Get dashboard statistics
- `GET /api/dashboard/revenue?period=month` - Get revenue statistics

## 🔐 Roles and Permissions

### OWNER
- Full access to all features
- Can manage users and roles
- Can view all financial data

### MANAGER
- Full access to bookings, customers, vehicles, services
- Can view dashboard statistics
- Cannot manage users

### RECEPTIONIST
- Can create and view bookings
- Can create and view customers
- Can create and view vehicles
- Cannot modify services or users

### MECHANIC
- Can view available bookings
- Can assign bookings to self
- Can update assignment status
- Can create part suggestions
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

All tables use UUID primary keys and include appropriate indexes for performance.

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
- Invoice generation and printing
- Advanced reporting and analytics
- Multi-language support
- Push notifications
- Photo attachments for vehicles and parts
- Inventory management system

## 🤝 Contributing

This is a private project for enterprise use. Contributions should follow the existing clean architecture patterns and coding standards.

## 📄 License

Private - All rights reserved.
