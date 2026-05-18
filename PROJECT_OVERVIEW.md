# Auto Garage System - Project Overview

## 📋 Project Overview

**Project Name:** Auto Garage System  
**Type:** Full-stack Automotive Service Management System  
**Architecture:** Microservices with Flutter Frontends and Dart Backend  
**Status:** Active Development  

---

## 🏗️ System Architecture

### Components

```
┌─────────────────────────────────────────────────────────────┐
│                     Auto Garage System                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Backend     │  │ Admin Front  │  │ Mechanic App │      │
│  │  (Dart)      │  │  (Flutter)   │  │  (Flutter)   │      │
│  │  - Server    │  │  - Dashboard │  │  - Mobile/Web│      │
│  │  - APIs      │  │  - Management│  │  - Tasks     │      │
│  │  - WebSocket │  │  - Reports   │  │  - Status    │      │
│  └──────┬───────┘  └──────────────┘  └──────────────┘      │
│         │                   │                   │            │
│         └───────────────────┴───────────────────┘            │
│                         │                                     │
│                    PostgreSQL                                 │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
auto garrage/
├── backend/                    # Dart backend server
│   ├── bin/
│   │   ├── server.dart       # Main server entry point
│   │   └── migrate_database.dart
│   ├── lib/
│   │   ├── application/      # Use cases & services
│   │   │   ├── services/
│   │   │   └── usecases/
│   │   ├── core/             # Core utilities
│   │   │   ├── errors/
│   │   │   └── utils/
│   │   ├── domain/           # Domain entities & repositories
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── validators/
│   │   ├── infrastructure/    # Database & implementation
│   │   │   ├── database/
│   │   │   └── repositories/
│   │   └── presentation/     # Routes & middleware
│   │       ├── middlewares/
│   │       ├── routes/
│   │       └── websocket/
│   ├── test/
│   ├── pubspec.yaml
│   └── render.yaml          # Render deployment config
│
├── admin_frontend/            # Flutter admin dashboard
│   ├── lib/
│   │   ├── core/            # Core services & utilities
│   │   ├── screens/        # Admin screens
│   │   ├── l10n/           # Localizations
│   │   └── main.dart
│   ├── web/
│   ├── pubspec.yaml
│   └── README.md
│
├── mechanic_app_new/         # Flutter mechanic application
│   ├── lib/
│   │   ├── core/           # Core utilities
│   │   │   ├── env.dart
│   │   │   ├── logger.dart
│   │   │   ├── network/    # Dio client
│   │   │   └── constants/
│   │   ├── data/           # Data layer
│   │   │   ├── datasources/
│   │   │   │   ├── local/
│   │   │   │   └── remote/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/         # Domain layer
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── presentation/   # UI layer
│   │   │   ├── providers/  # Riverpod state
│   │   │   └── screens/
│   │   ├── screens/        # Main screens
│   │   │   ├── login/
│   │   │   ├── available_bookings/
│   │   │   ├── my_assignments/
│   │   │   └── ...
│   │   ├── services/      # API & WebSocket services
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── README.md
│
├── customer-frontend/        # Simple HTML customer interface
│   └── index.html
│
├── cloudflare-worker/         # Cloudflare Worker (CDN/Proxy)
│   ├── worker.js
│   └── README.md
│
├── mcp/                       # MCP (Model Context Protocol)
│   └── super/
│
├── report/                    # Analysis reports
├── docker-compose.yml
├── supabase-schema.sql
└── README.md
```

---

## 🛠️ Technology Stack

### Backend
- **Language:** Dart
- **Framework:** Shelf (Dart web framework)
- **Database:** PostgreSQL
- **Authentication:** JWT (JSON Web Tokens)
- **WebSocket:** Real-time updates for bookings
- **Deployment:** Render.com

### Frontend
- **Framework:** Flutter
- **State Management:** Riverpod
- **HTTP Client:** Dio
- **Localization:** AR/EN support
- **Platforms:** Web, Android, iOS, Windows, macOS, Linux

### Infrastructure
- **Database:** PostgreSQL (on Render)
- **CDN:** Cloudflare Worker
- **Deployment:** Render.com
- **Containerization:** Docker

---

## 🗄️ Database Schema

### Main Tables

1. **users** - User accounts (mechanics, admins, customers)
2. **roles** - User roles (admin, mechanic, customer)
3. **companies** - Garage company settings
4. **services** - Services offered (oil change, brake repair, etc.)
5. **vehicles** - Customer vehicles
6. **bookings** - Service bookings
7. **mechanic_assignments** - Mechanic task assignments
8. **inventory_items** - Parts inventory
9. **inventory_transactions** - Inventory tracking
10. **part_suggestions** - AI-suggested parts for repairs
11. **alerts** - System alerts/notifications

### Key Relationships
- Company → Users (many-to-one)
- Customer → Vehicles (one-to-many)
- Vehicle → Bookings (one-to-many)
- Booking → Services (many-to-many)
- Booking → Mechanic Assignments (one-to-many)
- Mechanic Assignment → Part Suggestions (one-to-many)

---

## 🔌 API Endpoints

### Authentication
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `POST /auth/refresh` - Refresh JWT token

### Bookings
- `GET /bookings` - List all bookings
- `POST /bookings` - Create new booking
- `GET /bookings/:id` - Get booking details
- `PUT /bookings/:id/status` - Update booking status
- `GET /bookings/available` - Get available bookings for mechanics

### Mechanic Assignments
- `GET /mechanic-assignments` - List assignments
- `POST /mechanic-assignments` - Assign mechanic to booking
- `PUT /mechanic-assignments/:id/status` - Update assignment status

### Inventory
- `GET /inventory` - List inventory items
- `POST /inventory` - Add inventory item
- `PUT /inventory/:id` - Update inventory
- `POST /inventory/transactions` - Record inventory transaction

### Services
- `GET /services` - List services
- `POST /services` - Create service
- `PUT /services/:id` - Update service

### Vehicles
- `GET /vehicles` - List vehicles
- `POST /vehicles` - Add vehicle
- `PUT /vehicles/:id` - Update vehicle

### Company Settings
- `GET /company-settings` - Get company settings
- `PUT /company-settings` - Update company settings

### WebSocket
- `/ws/bookings` - Real-time booking updates

---

## 🎯 Key Features

### Admin Dashboard
- Manage users (mechanics, customers)
- Manage services offered
- View and manage bookings
- Manage inventory
- Generate reports
- Company settings management

### Mechanic App
- View available bookings
- Accept/reject assignments
- Update task status
- Consume parts from inventory
- View vehicle details
- Real-time notifications via WebSocket

### Customer Interface
- Book service appointments
- View booking status
- Vehicle management

---

## 🔐 Authentication Flow

```
1. User submits credentials (username/password)
2. Backend validates credentials
3. Backend generates JWT token + refresh token
4. Tokens saved to SharedPreferences (Flutter)
5. Subsequent API calls include JWT in Authorization header
6. Dio interceptor automatically adds token to requests
7. Token refresh when expired
```

---

## 🐛 Current Issues

### 1. 401 Unauthorized Error (Mechanic App)
**Problem:** After successful login, API calls return 401 Unauthorized  
**Location:** `mechanic_app_new/lib/data/datasources/remote/auth_remote_datasource.dart`  
**Status:** Logging added to debug token saving  
**Fix Needed:** Verify token is being saved and sent correctly

### 2. RenderFlex Overflow
**Problem:** UI overflow in assignments screen  
**Location:** `mechanic_app_new/lib/screens/my_assignments/my_assignments_screen.dart`  
**Status:** Needs wrapping text in Expanded widget

### 3. Token Management
**Problem:** Token not being persisted or sent in requests  
**Location:** `mechanic_app_new/lib/core/network/dio_client.dart`  
**Status:** Interceptor implemented, needs verification

---

## 🚀 Deployment

### Backend
- **Platform:** Render.com
- **URL:** https://auto-garage-system-backend.onrender.com
- **Database:** PostgreSQL on Render
- **Environment Variables:** Configured via Render dashboard

### Frontend
- **Admin:** Deployed on Render
- **Mechanic App:** Can be deployed as web app or built for mobile
- **Customer:** Static HTML

### CORS Configuration
Backend CORS configured to allow:
- Frontend URLs
- Localhost for development
- Specific origins from environment variables

---

## 📊 Data Flow

### Booking Creation Flow
```
Customer → Admin Dashboard → Backend API → PostgreSQL
                                    ↓
                              WebSocket Notification
                                    ↓
                              Mechanic App (Real-time)
```

### Mechanic Assignment Flow
```
Mechanic App → Backend API → PostgreSQL
                    ↓
              Update Booking Status
                    ↓
              WebSocket Notification
                    ↓
              Admin Dashboard (Real-time)
```

---

## 🧪 Testing

### Backend Tests
- `backend/test/auth_routes_test.dart`
- `backend/test/booking_repository_test.dart`
- `backend/test/jwt_service_test.dart`
- `backend/test/server_test.dart`

### Frontend Tests
- `admin_frontend/test/widget_test.dart`
- `mechanic_app_new/test/widget_test.dart`

---

## 📝 Development Notes

### Backend Architecture Pattern
- **Clean Architecture:** Domain-driven design
- **Layers:** Domain → Application → Infrastructure → Presentation
- **Dependency Injection:** Manual DI (not using DI framework)

### Frontend Architecture Pattern
- **Clean Architecture:** Data → Domain → Presentation
- **State Management:** Riverpod (StateNotifierProvider, FutureProvider)
- **HTTP:** Dio with interceptors for token management
- **Error Handling:** Custom exceptions and failures

### WebSocket Implementation
- Real-time booking updates
- Mechanic notifications
- Admin dashboard live updates

---

## 🔧 Configuration Files

### Environment Variables
- `backend/.env` (not committed)
- `backend/.env.example` (template)
- `mechanic_app_new/lib/core/env.dart` (Flutter env config)

### Key Environment Variables
- `CORS_ORIGIN` - Main frontend URL
- `CUSTOMER_CORS_ORIGIN` - Customer frontend URL
- `MECHANIC_CORS_ORIGIN` - Mechanic app URL
- Database connection strings (configured on Render)

---

## 📚 Documentation

- `README.md` - Project overview
- `DEPLOYMENT.md` - Deployment instructions
- `AUDIT_REPORT.md` - Security audit
- `PROJECT_DOCUMENTATION.md` - Detailed technical docs
- `graphify-out/GRAPH_REPORT.md` - Code analysis (knowledge graph)

---

## 🎨 UI/UX Notes

### Localization
- Arabic (primary)
- English (secondary)
- RTL support for Arabic

### Theme
- Material Design 3
- Custom app theme
- Responsive design

---

## 🔍 Code Analysis

### Knowledge Graph Stats
- **Total Files:** 438
- **Code Files:** 342
- **Doc Files:** 51
- **Image Files:** 45
- **Graph Nodes:** 9,788
- **Graph Edges:** 60,708
- **Communities:** 421

### Key Dependencies
- **Backend:** shelf, postgres, jaguar_jwt, web_socket_channel
- **Frontend:** flutter, riverpod, dio, shared_preferences

---

## 📞 Contact & Support

For questions or issues, refer to:
- Project documentation in `PROJECT_DOCUMENTATION.md`
- Deployment guide in `DEPLOYMENT.md`
- Audit report in `AUDIT_REPORT.md`

---

**Last Updated:** May 17, 2026  
**Version:** 1.0.0
