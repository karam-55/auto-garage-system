import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:dotenv/dotenv.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import 'package:backend/infrastructure/database/database_connection.dart';
import 'package:backend/infrastructure/repositories/user_repository_impl.dart';
import 'package:backend/infrastructure/repositories/customer_repository_impl.dart';
import 'package:backend/infrastructure/repositories/vehicle_repository_impl.dart';
import 'package:backend/infrastructure/repositories/service_repository_impl.dart';
import 'package:backend/infrastructure/repositories/booking_repository_impl.dart';
import 'package:backend/infrastructure/repositories/booking_service_repository_impl.dart';
import 'package:backend/infrastructure/repositories/mechanic_assignment_repository_impl.dart';
import 'package:backend/infrastructure/repositories/part_suggestion_repository_impl.dart';
import 'package:backend/infrastructure/repositories/company_settings_repository_impl.dart';
import 'package:backend/infrastructure/repositories/inventory_item_repository_impl.dart';
import 'package:backend/infrastructure/repositories/inventory_variant_repository_impl.dart';
import 'package:backend/infrastructure/repositories/inventory_transaction_repository_impl.dart';
import 'package:backend/infrastructure/repositories/booking_invoice_data_repository_impl.dart';
import 'package:backend/infrastructure/repositories/alert_repository_impl.dart';
import 'package:backend/presentation/routes/auth_routes.dart';
import 'package:backend/presentation/routes/customer_routes.dart';
import 'package:backend/presentation/routes/vehicle_routes.dart';
import 'package:backend/presentation/routes/service_routes.dart';
import 'package:backend/presentation/routes/booking_routes.dart';
import 'package:backend/presentation/routes/mechanic_routes.dart';
import 'package:backend/presentation/routes/dashboard_routes.dart';
import 'package:backend/presentation/routes/public_routes.dart';
import 'package:backend/presentation/routes/company_settings_routes.dart';
import 'package:backend/presentation/routes/inventory_routes.dart';
import 'package:backend/presentation/routes/invoice_routes.dart';
import 'package:backend/presentation/middlewares/auth_middleware.dart';
import 'package:backend/presentation/middlewares/error_middleware.dart';
import 'package:backend/presentation/middlewares/json_middleware.dart';
import 'package:backend/presentation/middlewares/logging_middleware.dart';
import 'package:backend/presentation/websocket/booking_websocket.dart';
import 'package:backend/application/services/auth_service.dart';
import 'package:backend/domain/entities/user.dart';
import 'package:backend/domain/entities/role.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

void main(List<String> args) async {
  // Load environment variables
  final env = DotEnv()..load();

  // JWT Secret from environment (mandatory)
  final jwtSecret = Platform.environment['JWT_SECRET'] ?? env['JWT_SECRET'];
  if (jwtSecret == null || jwtSecret.isEmpty) {
    logger.e('❌ FATAL: JWT_SECRET environment variable is not set. Server cannot start securely.');
    exit(1);
  }

  // Initialize database
  final db = DatabaseConnection.instance;
  try {
    await db.initialize();
    logger.i('Database connected successfully');
    
    // Execute schema (in production, you might want to use migrations)
    await db.executeSchema();
    logger.i('Database schema executed successfully');
    
    // Create default admin user if not exists
    await _createDefaultAdminUser(db, jwtSecret);
    
    // Create default receptionist user if not exists
    await _createDefaultReceptionistUser(db, jwtSecret);
  } catch (e) {
    logger.e('Failed to initialize database: $e');
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
  final inventoryItemRepository = InventoryItemRepositoryImpl(db);
  final inventoryVariantRepository = InventoryVariantRepositoryImpl(db);
  final inventoryTransactionRepository = InventoryTransactionRepositoryImpl(db);
  final bookingInvoiceDataRepository = BookingInvoiceDataRepositoryImpl(db);
  final alertRepository = AlertRepositoryImpl(db);

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
    bookingInvoiceDataRepository,
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
  final companySettingsRoutes = CompanySettingsRoutes(companySettingsRepository, authMiddleware);
  final webSocket = BookingWebSocket(alertRepository);
  final inventoryRoutes = InventoryRoutes(
    inventoryItemRepository,
    inventoryVariantRepository,
    inventoryTransactionRepository,
    bookingInvoiceDataRepository,
    alertRepository,
    authMiddleware,
    webSocket,
  );
  final invoiceRoutes = InvoiceRoutes(bookingInvoiceDataRepository, authMiddleware);

  // Create static file handler for uploads directory
  final uploadsDir = Directory('uploads');
  if (!await uploadsDir.exists()) {
    await uploadsDir.create(recursive: true);
  }
  final staticHandler = createStaticHandler(uploadsDir.path, defaultDocument: null);

  // Combine all routes
  final handler = Cascade()
      .add(staticHandler)
      .add(companySettingsRoutes.router.call)
      .add(authRoutes.router.call)
      .add(customerRoutes.router.call)
      .add(vehicleRoutes.router.call)
      .add(serviceRoutes.router.call)
      .add(bookingRoutes.router.call)
      .add(mechanicRoutes.router.call)
      .add(dashboardRoutes.router.call)
      .add(inventoryRoutes.router.call)
      .add(invoiceRoutes.router.call)
      .add(publicRoutes.router.call)
      .add(webSocket.handler)
      .add((Request request) {
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
  logger.i('Server listening on http://${server.address.host}:${server.port}');
  logger.i('API Documentation:');
  logger.i('  POST   /api/auth/login');
  logger.i('  POST   /api/auth/register');
  logger.i('  GET    /api/users');
  logger.i('  DELETE /api/users/:id');
  logger.i('  GET    /api/customers');
  logger.i('  POST   /api/customers');
  logger.i('  GET    /api/vehicles');
  logger.i('  POST   /api/vehicles');
  logger.i('  GET    /api/services');
  logger.i('  POST   /api/services');
  logger.i('  GET    /api/bookings');
  logger.i('  POST   /api/bookings');
  logger.i('  GET    /api/mechanics/available-bookings');
  logger.i('  POST   /api/mechanics/assign');
  logger.i('  GET    /api/dashboard/stats');
  logger.i('  GET    /api/dashboard/revenue');
  logger.i('  GET    /public/bookings/<publicToken>');
  logger.i('  GET    /api/company/settings');
  logger.i('  PATCH  /api/company/settings');
  logger.i('  POST   /api/company/upload-logo');
  logger.i('  GET    /api/inventory/items');
  logger.i('  POST   /api/inventory/items');
  logger.i('  GET    /api/inventory/variants');
  logger.i('  POST   /api/inventory/consume');
  logger.i('  GET    /api/bookings/:id/invoice');
  logger.i('  GET    /api/bookings/:id/invoice/pdf');
}

Future<void> _createDefaultAdminUser(DatabaseConnection db, String jwtSecret) async {
  final env = DotEnv()..load();
  final adminPassword = Platform.environment['DEFAULT_ADMIN_PASSWORD'] ?? env['DEFAULT_ADMIN_PASSWORD'];
  if (adminPassword == null || adminPassword.isEmpty) {
    logger.w('DEFAULT_ADMIN_PASSWORD not set. Skipping default admin creation.');
    logger.w('Set DEFAULT_ADMIN_PASSWORD to create an admin user on startup.');
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
      logger.i('Default admin user created successfully');
      logger.w('⚠️  Please change the password after first login!');
    } catch (e) {
      // User might already exist, that's okay
      logger.i('Admin user already exists or creation failed: $e');
    }
  } catch (e) {
    logger.e('Failed to create default admin user: $e');
    // Don't rethrow - this is not critical for the server to start
  }
}

Future<void> _createDefaultReceptionistUser(DatabaseConnection db, String jwtSecret) async {
  final env = DotEnv()..load();
  final receptionistPassword = Platform.environment['DEFAULT_RECEPTIONIST_PASSWORD'] ?? env['DEFAULT_RECEPTIONIST_PASSWORD'];
  if (receptionistPassword == null || receptionistPassword.isEmpty) {
    logger.w('DEFAULT_RECEPTIONIST_PASSWORD not set. Skipping default receptionist creation.');
    logger.w('Set DEFAULT_RECEPTIONIST_PASSWORD to create a receptionist user on startup.');
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
      logger.i('Default receptionist user created successfully');
      logger.w('⚠️  Please change the password after first login!');
    } catch (e) {
      // User might already exist, that's okay
      logger.i('Receptionist user already exists or creation failed: $e');
    }
  } catch (e) {
    logger.e('Failed to create default receptionist user: $e');
    // Don't rethrow - this is not critical for the server to start
  }
}

Middleware _corsMiddleware() {
  final env = DotEnv()..load();
  final allowedOrigin = Platform.environment['CORS_ORIGIN'] ?? env['CORS_ORIGIN'];
  final customerOrigin = Platform.environment['CUSTOMER_CORS_ORIGIN'] ?? env['CUSTOMER_CORS_ORIGIN'];
  final mechanicOrigin = Platform.environment['MECHANIC_CORS_ORIGIN'] ?? env['MECHANIC_CORS_ORIGIN'];

  if (allowedOrigin == null || allowedOrigin.isEmpty) {
    logger.e('❌ FATAL: CORS_ORIGIN environment variable is not set. Server cannot start securely.');
    logger.e('Set CORS_ORIGIN to your frontend domain (e.g., https://your-frontend.com)');
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

  logger.i('✅ CORS configured for: ${allowedOrigins.join(", ")}');

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
