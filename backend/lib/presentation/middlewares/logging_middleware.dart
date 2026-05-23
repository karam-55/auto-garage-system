import 'package:shelf/shelf.dart';
import 'package:logger/logger.dart';

Middleware createLoggingMiddleware() {
  final logger = Logger();

  return (Handler innerHandler) {
    return (Request request) async {
      final startTime = DateTime.now();
      logger.i('${request.method} ${request.url.path}');

      final response = await innerHandler(request);

      final duration = DateTime.now().difference(startTime);
      logger.i('${request.method} ${request.url.path} - ${response.statusCode} (${duration.inMilliseconds}ms)');

      return response;
    };
  };
}
