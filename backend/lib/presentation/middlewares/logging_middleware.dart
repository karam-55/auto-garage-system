import 'package:shelf/shelf.dart';
import 'package:logger/logger.dart';

class LoggingMiddleware {
  static final Logger _logger = Logger();

  static Middleware logRequests() {
    return (Handler innerHandler) {
      return (Request request) async {
        final startTime = DateTime.now();
        _logger.i('${request.method} ${request.url.path}');

        final response = await innerHandler(request);

        final duration = DateTime.now().difference(startTime);
        _logger.i('${request.method} ${request.url.path} - ${response.statusCode} (${duration.inMilliseconds}ms)');

        return response;
      };
    };
  }
}
