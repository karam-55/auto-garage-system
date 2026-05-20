import 'dart:convert';
import 'package:shelf/shelf.dart';

/// Middleware موحد لمعالجة الأخطاء في جميع الـ handlers
class ErrorHandler {
  /// تطبيق Middleware على handler معين
  static Middleware apply() {
    return (Handler innerHandler) {
      return (Request request) async {
        try {
          final response = await innerHandler(request);
          return response;
        } catch (e, stackTrace) {
          print('Error: $e');
          print('StackTrace: $stackTrace');
          
          // إرجاع استجابة موحدة للأخطاء
          return Response.internalServerError(
            body: jsonEncode({
              'success': false,
              'error': e.toString(),
              'code': 'INTERNAL_SERVER_ERROR',
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      };
    };
  }

  /// إنشاء استجابة خطأ موحدة
  static Response errorResponse({
    required String message,
    String code = 'ERROR',
    int statusCode = 400,
  }) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': false,
        'error': message,
        'code': code,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// إنشاء استجابة نجاح موحدة
  static Response successResponse({
    required dynamic data,
    int statusCode = 200,
  }) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': true,
        'data': data,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
