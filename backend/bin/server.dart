import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:dotenv/dotenv.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';

import '../lib/infrastructure/database/database_connection.dart';
import '../lib/infrastructure/repositories/user_repository_impl.dart';
import '../lib/infrastructure/repositories/customer_repository_impl.dart';
import '../lib/infrastructure/repositories/vehicle_repository_impl.dart';
import '../lib/infrastructure/repositories/service_repository_impl.dart';
import '../lib/infrastructure/repositories/booking_repository_impl.dart';
import '../lib/infrastructure/repositories/booking_service_repository_impl.dart';
import '../lib/infrastructure/repositories/mechanic_assignment_repository_impl.dart';
import '../lib/infrastructure/repositories/part_suggestion_repository_impl.dart';
import '../lib/infrastructure/repositories/company_settings_repository_impl.dart';
import '../lib/presentation/routes/auth_routes.dart';
import '../lib/presentation/routes/customer_routes.dart';
import '../lib/presentation/routes/vehicle_routes.dart';
import '../lib/presentation/routes/service_routes.dart';
import '../lib/presentation/routes/booking_routes.dart';
import '../lib/presentation/routes/mechanic_routes.dart';
import '../lib/presentation/routes/dashboard_routes.dart';
import '../lib/presentation/routes/public_routes.dart';
import '../lib/presentation/routes/company_settings_routes.dart';
import '../lib/presentation/middlewares/auth_middleware.dart';
import '../lib/presentation/middlewares/error_middleware.dart';
import '../lib/presentation/middlewares/json_middleware.dart';
import '../lib/presentation/middlewares/logging_middleware.dart';
import '../lib/application/services/auth_service.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/entities/role.dart';

void main(List<String> args) async {
  // Load environment variables
  final env = DotEnv()..load();

  // JWT Secret from environment (mandatory)
  final jwtSecret = Platform.environment['JWT_SECRET'] ?? env['JWT_SECRET'];
  if (jwtSecret == null || jwtSecret.isEmpty) {
    print('❌ FATAL: JWT_SECRET environment variable is not set. Server cannot start securely.');
    exit(1);
  }

  // Initialize database
  final db = DatabaseConnection.instance;
  try {
    await db.initialize();
    print('Database connected successfully');
    
    // Execute schema (in production, you might want to use migrations)
    await db.executeSchema();
    print('Database schema executed successfully');
    
    // Create default admin user if not exists
    await _createDefaultAdminUser(db, jwtSecret);
    
    // Create default receptionist user if not exists
    await _createDefaultReceptionistUser(db, jwtSecret);
  } catch (e) {
    print('Failed to initialize database: $e');
    rethrow;
  }

  // Initialize repositories
  final userRepository = UserRepositoryImpl(db, jwtSecret: jwtSecret);
  final customerRepository = CustomerRepositoryImpl(db);
  final vehicleRepository = VehicleRepositoryImpl(db);
  final serviceRepository = ServiceRepositoryImpl(db);
  final bookingRepository = BookingRepositoryImpl(db);
  final bookingServiceRepository = BookingServiceRepositoryImpl(db);
  final mechanicAssignmentRepository = MechanicAssignmentRepositoryImpl(db);
  final partSuggestionRepository = PartSuggestionRepositoryImpl(db);
  final companySettingsRepository = CompanySettingsRepositoryImpl(db);

  // Initialize routes
  final authMiddleware = AuthMiddleware(userRepository);
  final authService = AuthService(userRepository);
  final authRoutes = AuthRoutes(userRepository, authMiddleware, authService);
  final customerRoutes = CustomerRoutes(customerRepository, authMiddleware);
  final vehicleRoutes = VehicleRoutes(vehicleRepository, authMiddleware);
  final serviceRoutes = ServiceRoutes(serviceRepository, authMiddleware);
  final bookingRoutes = BookingRoutes(
    bookingRepository,
    bookingServiceRepository,
    authMiddleware,
    db,
    vehicleRepository,
  );
  final mechanicRoutes = MechanicRoutes(
    mechanicAssignmentRepository,
    partSuggestionRepository,
    bookingRepository,
    authMiddleware,
  );
  final dashboardRoutes = DashboardRoutes(
    bookingRepository,
    customerRepository,
    vehicleRepository,
    bookingServiceRepository,
    authRoutes.authMiddleware,
  );
  final publicRoutes = PublicRoutes(db);
  final companySettingsRoutes = CompanySettingsRoutes(companySettingsRepository);

  // Create static file handler for uploads directory
  final uploadsDir = Directory('uploads');
  if (!await uploadsDir.exists()) {
    await uploadsDir.create(recursive: true);
  }
  final staticHandler = createStaticHandler(uploadsDir.path, defaultDocument: null);

  // Combine all routes
  final handler = Cascade()
      .add(staticHandler)
      .add(authRoutes.router)
      .add(customerRoutes.router)
      .add(vehicleRoutes.router)
      .add(serviceRoutes.router)
      .add(bookingRoutes.router)
      .add(mechanicRoutes.router)
      .add(dashboardRoutes.router)
      .add(publicRoutes.router)
      .add(companySettingsRoutes.router)
      .add((Request request) {
        if (request.url.path == 'health') {
          return Response.ok(
            jsonEncode({'status': 'ok', 'timestamp': DateTime.now().toIso8601String()}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.notFound('Not Found');
      })
      .handler;

  // Configure middleware pipeline
  final pipeline = Pipeline()
      .addMiddleware(ErrorMiddleware.handleErrors())
      .addMiddleware(LoggingMiddleware.logRequests())
      .addMiddleware(JsonMiddleware.jsonContent())
      .addMiddleware(_corsMiddleware())
      .addHandler(handler);

  // Start server
  final ip = InternetAddress.anyIPv4;
  final port = int.parse(env['PORT'] ?? '8080');

  final server = await serve(pipeline, ip, port);
  print('Server listening on http://${server.address.host}:${server.port}');
  print('API Documentation:');
  print('  POST   /api/auth/login');
  print('  POST   /api/auth/register');
  print('  GET    /api/users');
  print('  DELETE /api/users/:id');
  print('  GET    /api/customers');
  print('  POST   /api/customers');
  print('  GET    /api/vehicles');
  print('  POST   /api/vehicles');
  print('  GET    /api/services');
  print('  POST   /api/services');
  print('  GET    /api/bookings');
  print('  POST   /api/bookings');
  print('  GET    /api/mechanics/available-bookings');
  print('  POST   /api/mechanics/assign');
  print('  GET    /api/dashboard/stats');
  print('  GET    /api/dashboard/revenue');
  print('  GET    /public/bookings/<publicToken>');
  print('  GET    /api/company/settings');
  print('  PATCH  /api/company/settings');
  print('  POST   /api/company/upload-logo');
}

Future<void> _createDefaultAdminUser(DatabaseConnection db, String jwtSecret) async {
  final env = DotEnv()..load();
  final adminPassword = Platform.environment['DEFAULT_ADMIN_PASSWORD'] ?? env['DEFAULT_ADMIN_PASSWORD'];
  if (adminPassword == null || adminPassword.isEmpty) {
    print('DEFAULT_ADMIN_PASSWORD not set. Skipping default admin creation.');
    print('Set DEFAULT_ADMIN_PASSWORD to create an admin user on startup.');
    return;
  }

  try {
    final userRepository = UserRepositoryImpl(db, jwtSecret: jwtSecret);
    final passwordHash = BCrypt.hashpw(adminPassword, BCrypt.gensalt());
    final adminUser = User(
      id: const Uuid().v4(),
      fullName: 'System Admin',
      username: 'admin',
      passwordHash: passwordHash,
      role: Role.OWNER,
      createdAt: DateTime.now().toUtc(),
    );

    try {
      await userRepository.create(adminUser);
      print('Default admin user created successfully');
      print('⚠️  Please change the password after first login!');
    } catch (e) {
      // User might already exist, that's okay
      print('Admin user already exists or creation failed: $e');
    }
  } catch (e) {
    print('Failed to create default admin user: $e');
    // Don't rethrow - this is not critical for the server to start
  }
}

Future<void> _createDefaultReceptionistUser(DatabaseConnection db, String jwtSecret) async {
  final env = DotEnv()..load();
  final receptionistPassword = Platform.environment['DEFAULT_RECEPTIONIST_PASSWORD'] ?? env['DEFAULT_RECEPTIONIST_PASSWORD'];
  if (receptionistPassword == null || receptionistPassword.isEmpty) {
    print('DEFAULT_RECEPTIONIST_PASSWORD not set. Skipping default receptionist creation.');
    print('Set DEFAULT_RECEPTIONIST_PASSWORD to create a receptionist user on startup.');
    return;
  }

  try {
    final userRepository = UserRepositoryImpl(db, jwtSecret: jwtSecret);
    final passwordHash = BCrypt.hashpw(receptionistPassword, BCrypt.gensalt());
    final receptionistUser = User(
      id: const Uuid().v4(),
      fullName: 'Default Receptionist',
      username: 'receptionist',
      passwordHash: passwordHash,
      role: Role.RECEPTIONIST,
      createdAt: DateTime.now().toUtc(),
    );

    try {
      await userRepository.create(receptionistUser);
      print('Default receptionist user created successfully');
      print('⚠️  Please change the password after first login!');
    } catch (e) {
      // User might already exist, that's okay
      print('Receptionist user already exists or creation failed: $e');
    }
  } catch (e) {
    print('Failed to create default receptionist user: $e');
    // Don't rethrow - this is not critical for the server to start
  }
}

Middleware _corsMiddleware() {
  final env = DotEnv()..load();
  final allowedOrigin = Platform.environment['CORS_ORIGIN'] ?? env['CORS_ORIGIN'];
  final customerOrigin = Platform.environment['CUSTOMER_CORS_ORIGIN'] ?? env['CUSTOMER_CORS_ORIGIN'];
  final mechanicOrigin = Platform.environment['MECHANIC_CORS_ORIGIN'] ?? env['MECHANIC_CORS_ORIGIN'];

  if (allowedOrigin == null || allowedOrigin.isEmpty) {
    print('❌ FATAL: CORS_ORIGIN environment variable is not set. Server cannot start securely.');
    print('Set CORS_ORIGIN to your frontend domain (e.g., https://your-frontend.com)');
    exit(1);
  }

  // Allow multiple origins
  final allowedOrigins = <String>[allowedOrigin];
  if (customerOrigin != null && customerOrigin.isNotEmpty) {
    allowedOrigins.add(customerOrigin);
  }
  if (mechanicOrigin != null && mechanicOrigin.isNotEmpty) {
    allowedOrigins.add(mechanicOrigin);
  }

  print('✅ CORS configured for: ${allowedOrigins.join(", ")}');

  return (Handler innerHandler) {
    return (Request request) async {
      // Determine the allowed origin based on request origin
      final requestOrigin = request.headers['Origin'];
      final effectiveOrigin = allowedOrigins.contains(requestOrigin) 
          ? requestOrigin ?? allowedOrigin ?? ''
          : allowedOrigin ?? '';

      // Handle preflight OPTIONS request
      if (request.method == 'OPTIONS') {
        return Response.ok(
          null,
          headers: {
            'Access-Control-Allow-Origin': effectiveOrigin,
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Max-Age': '86400',
          },
        );
      }

      final response = await innerHandler(request);
      return response.change(
        headers: {
          'Access-Control-Allow-Origin': effectiveOrigin,
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          ...response.headers,
        },
      );
    };
  };
}
