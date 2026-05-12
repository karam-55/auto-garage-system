import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
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
import '../lib/presentation/routes/auth_routes.dart';
import '../lib/presentation/routes/customer_routes.dart';
import '../lib/presentation/routes/vehicle_routes.dart';
import '../lib/presentation/routes/service_routes.dart';
import '../lib/presentation/routes/booking_routes.dart';
import '../lib/presentation/routes/mechanic_routes.dart';
import '../lib/presentation/routes/dashboard_routes.dart';
import '../lib/presentation/middlewares/error_middleware.dart';
import '../lib/presentation/middlewares/logging_middleware.dart';
import '../lib/presentation/middlewares/json_middleware.dart';
import '../lib/domain/entities/user.dart';
import '../lib/domain/entities/role.dart';
import 'dart:io';

void main(List<String> args) async {
  // Load environment variables
  final env = DotEnv()..load();

  // Initialize database
  final db = DatabaseConnection.instance;
  try {
    await db.initialize();
    print('Database connected successfully');
    
    // Execute schema (in production, you might want to use migrations)
    await db.executeSchema();
    print('Database schema executed successfully');
    
    // Create default admin user if not exists
    await _createDefaultAdminUser(db);
    
    // Create default receptionist user if not exists
    await _createDefaultReceptionistUser(db);
  } catch (e) {
    print('Failed to initialize database: $e');
    rethrow;
  }

  // Initialize repositories
  final userRepository = UserRepositoryImpl(db);
  final customerRepository = CustomerRepositoryImpl(db);
  final vehicleRepository = VehicleRepositoryImpl(db);
  final serviceRepository = ServiceRepositoryImpl(db);
  final bookingRepository = BookingRepositoryImpl(db);
  final bookingServiceRepository = BookingServiceRepositoryImpl(db);
  final mechanicAssignmentRepository = MechanicAssignmentRepositoryImpl(db);
  final partSuggestionRepository = PartSuggestionRepositoryImpl(db);

  // Initialize routes
  final authRoutes = AuthRoutes(userRepository);
  final customerRoutes = CustomerRoutes(customerRepository, authRoutes.authMiddleware);
  final vehicleRoutes = VehicleRoutes(vehicleRepository, authRoutes.authMiddleware);
  final serviceRoutes = ServiceRoutes(serviceRepository, authRoutes.authMiddleware);
  final bookingRoutes = BookingRoutes(
    bookingRepository,
    bookingServiceRepository,
    authRoutes.authMiddleware,
  );
  final mechanicRoutes = MechanicRoutes(
    mechanicAssignmentRepository,
    partSuggestionRepository,
    bookingRepository,
    authRoutes.authMiddleware,
  );
  final dashboardRoutes = DashboardRoutes(
    bookingRepository,
    customerRepository,
    vehicleRepository,
    bookingServiceRepository,
    authRoutes.authMiddleware,
  );

  // Combine all routes
  final handler = Cascade()
      .add(authRoutes.router)
      .add(customerRoutes.router)
      .add(vehicleRoutes.router)
      .add(serviceRoutes.router)
      .add(bookingRoutes.router)
      .add(mechanicRoutes.router)
      .add(dashboardRoutes.router)
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
  print('  GET    /public/bookings/<publicToken>');
}

Future<void> _createDefaultAdminUser(DatabaseConnection db) async {
  try {
    final userRepository = UserRepositoryImpl(db);
    
    // Try to create default admin user
    // If it already exists, it will fail silently
    final passwordHash = BCrypt.hashpw('admin123', BCrypt.gensalt());
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
      print('Username: admin');
      print('Password: admin123');
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

Future<void> _createDefaultReceptionistUser(DatabaseConnection db) async {
  try {
    final userRepository = UserRepositoryImpl(db);
    
    // Try to create default receptionist user
    // If it already exists, it will fail silently
    final passwordHash = BCrypt.hashpw('receptionist123', BCrypt.gensalt());
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
      print('Username: receptionist');
      print('Password: receptionist123');
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
  return (Handler innerHandler) {
    return (Request request) async {
      // Handle preflight OPTIONS request
      if (request.method == 'OPTIONS') {
        return Response.ok(
          null,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Max-Age': '86400',
          },
        );
      }

      final response = await innerHandler(request);
      return response.change(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          ...response.headers,
        },
      );
    };
  };
}
