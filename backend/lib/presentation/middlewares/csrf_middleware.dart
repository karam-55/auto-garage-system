import 'dart:convert' as convert;
import 'package:shelf/shelf.dart';
import 'package:crypto/crypto.dart';

class CsrfMiddleware {
  Middleware create() {
    return (Handler innerHandler) {
      return (Request request) async {
        // Skip for GET requests
        if (request.method == 'GET') {
          return innerHandler(request);
        }

        // Skip for public endpoints (no authentication required)
        if (request.url.path.startsWith('/public/')) {
          return innerHandler(request);
        }
        
        // Check CSRF token for state-changing operations
        final token = request.headers['x-csrf-token'];
        final sessionToken = _getSessionToken(request);
        
        if (token == null || token != sessionToken) {
          return Response(403, body: convert.jsonEncode({'error': 'Invalid CSRF token'}));
        }
        
        return innerHandler(request);
      };
    };
  }
  
  String generateToken() {
    final bytes = DateTime.now().millisecondsSinceEpoch.toString().codeUnits;
    return sha256.convert(bytes).toString();
  }
  
  String? _getSessionToken(Request request) {
    // Implement session token retrieval
    // This is a placeholder - implement based on your auth system
    return request.headers['authorization'];
  }
}
