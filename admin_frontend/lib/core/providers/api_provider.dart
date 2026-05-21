import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// API Service Provider - Singleton instance for the entire app
final apiServiceProvider = Provider<ApiService>((ref) {
  // Use the singleton instance from ApiService factory
  return ApiService.instance;
});

// Keep the instance alive during the app lifecycle
final apiServiceKeepAliveProvider = Provider<ApiService>((ref) {
  final apiService = ApiService.instance;
  ref.onDispose(() {
    // Dispose logic if needed
  });
  return apiService;
});
