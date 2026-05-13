class Env {
  // Base URL for API
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // API Endpoints
  static const String apiBase = '$baseUrl/api';
  static const String publicBase = '$baseUrl/public';

  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Debug mode
  static const bool isDebugMode = environment == 'development';
}
