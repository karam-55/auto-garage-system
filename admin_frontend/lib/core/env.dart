class Env {
  // Base URL for API
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://auto-garage-system-backend.onrender.com',
  );

  // WebSocket URL
  static String get wsUrl {
    if (baseUrl.startsWith('https://')) {
      return baseUrl.replaceFirst('https://', 'wss://');
    } else if (baseUrl.startsWith('http://')) {
      return baseUrl.replaceFirst('http://', 'ws://');
    }
    return baseUrl;
  }

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
