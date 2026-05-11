# Auto Garage Management System

An enterprise-level car garage management system built with Dart and Flutter, featuring a clean architecture backend, staff management app, mechanic app, and customer tracking frontend.

## 🏗️ Architecture

### Backend (Dart + Shelf)
- **Clean Architecture**: Domain, Application, Infrastructure, and Presentation layers
- **Database**: PostgreSQL with UUID primary keys and proper constraints
- **Authentication**: JWT-based with role-based authorization (OWNER, MANAGER, RECEPTIONIST, MECHANIC)
- **API**: RESTful endpoints with middleware for auth, logging, error handling, and CORS

### Frontend Applications
- **Staff App**: Flutter app for garage staff (Windows, Android, Web) with dashboard and full CRUD operations
- **Mechanic App**: Flutter app for mechanics to view available bookings, assign tasks, update status, and suggest parts
- **Customer Frontend**: Web-only Flutter app for customers to track their booking status using public tokens

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
├── staff_app/             # Flutter app for staff
│   ├── lib/
│   │   ├── core/          # Services, constants
│   │   ├── models/        # Data models
│   │   ├── providers/     # State management
│   │   └── screens/       # UI screens
│   └── pubspec.yaml
├── mechanic_app/          # Flutter app for mechanics
│   ├── lib/
│   │   ├── core/          # Services, constants
│   │   ├── models/        # Data models
│   │   ├── providers/     # State management
│   │   └── screens/       # UI screens
│   └── pubspec.yaml
└── customer_frontend/     # Flutter web app for customers
    ├── lib/
    │   ├── core/          # Services, constants
    │   ├── models/        # Data models
    │   └── screens/       # UI screens
    ├── wrangler.toml      # Cloudflare Pages config
    └── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites
- Dart SDK 3.11.5 or higher
- Flutter SDK
- PostgreSQL database
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

### Staff App Setup

1. Navigate to the staff_app directory:
```bash
cd staff_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Mechanic App Setup

1. Navigate to the mechanic_app directory:
```bash
cd mechanic_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Customer Frontend Setup

1. Navigate to the customer_frontend directory:
```bash
cd customer_frontend
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

## � Deployment

### Backend (Render)

The backend is configured for deployment on Render using `render.yaml`.

**Steps:**
1. Push the backend code to a Git repository
2. Connect the repository to Render
3. Render will automatically detect the `render.yaml` and deploy

**Environment Variables Required:**
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: Secret key for JWT token generation
- `PORT`: Server port (default: 8080)

### Customer Frontend (Cloudflare Pages)

The customer frontend can be deployed to Cloudflare Pages as a static site.

**Steps:**
1. Build the web version locally:
```bash
cd customer_frontend
flutter build web
```

2. Deploy the `build/web` directory to Cloudflare Pages:
   - Connect your GitHub repository
   - Set build command: `cd customer_frontend && flutter build web`
   - Set output directory: `customer_frontend/build/web`
   - Or use the `wrangler.toml` file for automated deployment

### Staff App & Mechanic App

These are Flutter applications designed for Windows, Android, and Web platforms:
- Build for Windows: `flutter build windows`
- Build for Android: `flutter build apk`
- Build for Web: `flutter build web`

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
