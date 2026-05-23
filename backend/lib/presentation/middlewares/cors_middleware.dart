import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:dotenv/dotenv.dart';

Middleware createCorsMiddleware() {
  final env = DotEnv()..load();
  
  // Use separate CORS origins from Render environment variables
  final corsOrigin = env['CORS_ORIGIN'] ?? 'http://localhost:3000';
  final customerCorsOrigin = env['CUSTOMER_CORS_ORIGIN'] ?? 'http://localhost:3000';
  final mechanicCorsOrigin = env['MECHANIC_CORS_ORIGIN'] ?? 'http://localhost:8081';
  
  // Combine all origins into a comma-separated list
  final allowedOrigins = '$corsOrigin,$customerCorsOrigin,$mechanicCorsOrigin';
  
  return corsHeaders(
    headers: {
      ACCESS_CONTROL_ALLOW_ORIGIN: allowedOrigins,
      ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
      ACCESS_CONTROL_ALLOW_HEADERS: 'Content-Type, Authorization',
      ACCESS_CONTROL_ALLOW_CREDENTIALS: 'true',
    },
  );
}
