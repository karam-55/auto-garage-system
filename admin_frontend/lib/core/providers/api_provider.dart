import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// API Service Provider - Singleton instance for the entire app
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
