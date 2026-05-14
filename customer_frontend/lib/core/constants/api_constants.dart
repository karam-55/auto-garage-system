class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://auto-garage-system-backend.onrender.com',
  );
  
  static String get wsUrl {
    final url = baseUrl.replaceAll('https://', 'wss://').replaceAll('http://', 'ws://');
    return url;
  }
  
  static const String publicBooking = '/public/bookings/';
}
