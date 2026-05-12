import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../core/errors/exceptions.dart';

class JsonMiddleware {
  static Middleware jsonContent() {
    return (Handler innerHandler) {
      return (Request request) async {
        // Set JSON response headers
        final response = await innerHandler(request);
        
        return response.change(
          headers: {
            ...response.headers,
            'Content-Type': 'application/json',
          },
        );
      };
    };
  }

  static Future<Map<String, dynamic>?> parseJsonBody(Request request) async {
    final body = await request.readAsString();
    if (body.isEmpty) return null;
    
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw ValidationException('Request body must be a JSON object');
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ValidationException('Invalid JSON body: $e');
    }
  }
}
