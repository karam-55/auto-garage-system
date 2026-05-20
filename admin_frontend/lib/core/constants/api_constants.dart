import '../env.dart';

class ApiConstants {
  static String get baseUrl => Env.baseUrl;
  static String get wsUrl => Env.wsUrl;
  
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
  
  // HR endpoints
  static const String hrContracts = '$apiVersion/hr/contracts';
  static const String hrLeaveRequests = '$apiVersion/hr/leave-requests';
  static const String hrPerformanceReviews = '$apiVersion/hr/performance-reviews';
  static String hrLeaveRequestApprove(String id) => '$apiVersion/hr/leave-requests/$id/approve';
  static String hrLeaveRequestReject(String id) => '$apiVersion/hr/leave-requests/$id/reject';
  
  // CRM endpoints
  static const String crmLeads = '$apiVersion/crm/leads';
  static const String crmActivities = '$apiVersion/crm/activities';
  static String crmLeadConvert(String id) => '$apiVersion/crm/leads/$id/convert';
  
  // Public endpoints
  static String publicBooking(String token) => '/public/bookings/$token';
}
