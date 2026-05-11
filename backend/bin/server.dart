import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:dotenv/dotenv.dart';

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
import '../lib/core/utils/app_constants.dart';

void main(List<String> args) async {
  // Load environment variables
  final env = DotEnv(includeEnvFile: true)..load();

  // Initialize database
  final db = DatabaseConnection.instance;
  try {
    await db.initialize();
    print('Database connected successfully');
    
    // Execute schema (in production, you might want to use migrations)
    await db.executeSchema();
    print('Database schema executed successfully');
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
  final customerRoutes = CustomerRoutes(customerRepository, authRoutes._authMiddleware);
  final vehicleRoutes = VehicleRoutes(vehicleRepository, authRoutes._authMiddleware);
  final serviceRoutes = ServiceRoutes(serviceRepository, authRoutes._authMiddleware);
  final bookingRoutes = BookingRoutes(
    bookingRepository,
    bookingServiceRepository,
    authRoutes._authMiddleware,
  );
  final mechanicRoutes = MechanicRoutes(
    mechanicAssignmentRepository,
    partSuggestionRepository,
    bookingRepository,
    authRoutes._authMiddleware,
  );
  final dashboardRoutes = DashboardRoutes(
    bookingRepository,
    customerRepository,
    vehicleRepository,
    bookingServiceRepository,
    authRoutes._authMiddleware,
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
  final port = int.parse(env[AppConstants.portEnv] ?? AppConstants.defaultPort.toString());

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

Middleware _corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
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
