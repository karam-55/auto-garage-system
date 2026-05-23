import 'dart:convert' as convert;
import 'package:shelf/shelf.dart';

class RateLimitMiddleware {
  final Map<String, _RateLimitEntry> _entries = {};
  final int maxRequests;
  final Duration window;

  RateLimitMiddleware({
    this.maxRequests = 100,
    this.window = const Duration(minutes: 1),
  });

  Middleware create() {
    return (Handler innerHandler) {
      return (Request request) async {
        final key = _getKey(request);
        final entry = _entries[key];

        if (entry == null) {
          _entries[key] = _RateLimitEntry(1, DateTime.now());
          return innerHandler(request);
        }

        final now = DateTime.now();
        final timeSinceFirst = now.difference(entry.firstRequestTime);

        if (timeSinceFirst > window) {
          _entries[key] = _RateLimitEntry(1, now);
          return innerHandler(request);
        }

        if (entry.requestCount >= maxRequests) {
          return Response(429, body: convert.jsonEncode({'error': 'Too many requests'}));
        }

        entry.requestCount++;
        return innerHandler(request);
      };
    };
  }

  String _getKey(Request request) {
    return '${request.requestedUri.host}:${request.method}';
  }
}

class _RateLimitEntry {
  int requestCount;
  DateTime firstRequestTime;

  _RateLimitEntry(this.requestCount, this.firstRequestTime);
}

Middleware createRateLimitMiddleware({
  int maxRequests = 100,
  Duration window = const Duration(minutes: 1),
}) {
  return RateLimitMiddleware(
    maxRequests: maxRequests,
    window: window,
  ).create();
}
