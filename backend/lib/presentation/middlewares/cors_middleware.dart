import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:dotenv/dotenv.dart';

Middleware createCorsMiddleware() {
  final env = DotEnv()..load();
  
  // Read CORS origins from environment variables
  final corsOrigin = env['CORS_ORIGIN'] ?? 'http://localhost:3000';
  final customerCorsOrigin = env['CUSTOMER_CORS_ORIGIN'] ?? 'http://localhost:3000';
  final mechanicCorsOrigin = env['MECHANIC_CORS_ORIGIN'] ?? 'http://localhost:8081';
  
  // Collect all allowed origins
  final allowedOrigins = [
    corsOrigin,
    customerCorsOrigin,
    mechanicCorsOrigin,
    // Add production Cloudflare Pages origins as fallback
    'https://auto-garage-staff-frontend.pages.dev',
    'https://auto-garage-customer-frontend.pages.dev',
  ];
  
  return (Handler innerHandler) {
    return (Request request) async {
      // Extract Origin header from request
      final requestOrigin = request.headers['Origin'];
      
      // Determine the allowed origin for this request
      String? allowedOrigin;
      
      if (requestOrigin != null) {
        // Check if the origin matches one of the allowed origins
        if (allowedOrigins.contains(requestOrigin)) {
          allowedOrigin = requestOrigin;
        } else if (mechanicCorsOrigin == '*' && requestOrigin.isNotEmpty) {
          // If mechanic origin is set to *, allow any origin
          allowedOrigin = '*';
        }
      }
      
      // Allow localhost during development
      if (allowedOrigin == null && 
          (requestOrigin == 'http://localhost' || 
           requestOrigin?.startsWith('http://localhost:') == true ||
           requestOrigin == null)) {
        allowedOrigin = '*';
      }
      
      // Create response with appropriate CORS headers
      final response = await innerHandler(request);
      
      // Add CORS headers
      final headers = {
        ACCESS_CONTROL_ALLOW_ORIGIN: allowedOrigin ?? '*',
        ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
        ACCESS_CONTROL_ALLOW_HEADERS: 'Content-Type, Authorization',
        ACCESS_CONTROL_ALLOW_CREDENTIALS: allowedOrigin != '*' ? 'true' : 'false',
      };
      
      // Add headers to response
      return response.change(headers: headers);
    };
  };
}
