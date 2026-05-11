import 'dart:convert';
import 'package:shelf/shelf.dart';

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
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
