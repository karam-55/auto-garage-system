class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );
  
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  
  static const String customers = '/api/customers';
  static const String customerById = '/api/customers/';
  
  static const String vehicles = '/api/vehicles';
  static const String vehicleById = '/api/vehicles/';
  static const String vehiclesByCustomer = '/api/vehicles/customer/';
  
  static const String services = '/api/services';
  static const String serviceById = '/api/services/';
  
  static const String bookings = '/api/bookings';
  static const String bookingById = '/api/bookings/';
  static const String bookingsByCustomer = '/api/bookings/customer/';
  static const String bookingsByStatus = '/api/bookings/status/';
  static const String updateBookingStatus = '/api/bookings/';
  
  static const String dashboardStats = '/api/dashboard/stats';
  static const String dashboardRevenue = '/api/dashboard/revenue';
  
  static const String users = '/api/users';
  static const String userById = '/api/users/';
  
  static const String availableBookings = '/api/mechanics/available-bookings';
  static const String assignMechanic = '/api/mechanics/assign';
  
  static const String publicBooking = '/public/bookings/';
}
