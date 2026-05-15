class Env {
  // Base URL for API
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://auto-garage-system-backend.onrender.com',
  );

  // WebSocket URL
  static String get wsUrl {
    String url = baseUrl;
    if (url.startsWith('https://')) {
      url = url.replaceFirst('https://', 'wss://');
    } else if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'ws://');
    }
    // Fix double 'wsss' issue
    if (url.contains('wsss://')) {
      url = url.replaceFirst('wsss://', 'wss://');
    }
    return url;
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
