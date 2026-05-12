class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://auto-garage-system-backend.onrender.com',
  );
  static const String publicBooking = '/public/bookings/';
}
