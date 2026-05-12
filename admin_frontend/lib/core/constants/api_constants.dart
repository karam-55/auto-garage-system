class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://auto-garage-system-backend.onrender.com',
  );
  
  static const String apiVersion = '/api';
  
  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  
  // Customer endpoints
  static const String customers = '$apiVersion/customers';
  static String customer(String id) => '$apiVersion/customers/$id';
  
  // Vehicle endpoints
  static const String vehicles = '$apiVersion/vehicles';
  static String vehicle(String id) => '$apiVersion/vehicles/$id';
  
  // Service endpoints
  static const String services = '$apiVersion/services';
  static String service(String id) => '$apiVersion/services/$id';
  
  // Booking endpoints
  static const String bookings = '$apiVersion/bookings';
  static String booking(String id) => '$apiVersion/bookings/$id';
  
  // Employee endpoints
  static const String employees = '$apiVersion/users';
  static const String users = '$apiVersion/users';
  static String employee(String id) => '$apiVersion/users/$id';
  
  // Dashboard endpoints
  static const String dashboardStats = '$apiVersion/dashboard/stats';
  static const String dashboardRevenue = '$apiVersion/dashboard/revenue';
  
  // Mechanic endpoints
  static const String mechanicBookings = '$apiVersion/mechanics/available-bookings';
  static const String mechanicAssign = '$apiVersion/mechanics/assign';
  
  // Public endpoints
  static String publicBooking(String token) => '/public/bookings/$token';
}
