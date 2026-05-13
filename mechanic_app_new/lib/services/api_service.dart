import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/backend_constants.dart';

class ApiService {
  final String _baseUrl = BackendConstants.backendUrl;
  String? _token;
  
  void setToken(String? token) {
    _token = token;
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
  
  // Auth operations
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      print('Attempting login via Render backend for username: $username');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      print('Login response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login response: $data');
        
        // Store token
        _token = data['token'];
        
        return data;
      }
      
      print('Login failed: ${response.body}');
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  
  Future<bool> register(String username, String fullName, String passwordHash, String role) async {
    try {
      print('Attempting register via Render backend for username: $username');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'full_name': fullName,
          'password': passwordHash,
          'role': role,
        }),
      );
      
      print('Register response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('User registered successfully');
        return true;
      }
      
      print('Register failed: ${response.body}');
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }
  
  // Booking operations
  Future<List<Map<String, dynamic>>> fetchAvailableBookings() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/mechanics/available-bookings'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }
  
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/bookings/$bookingId/status'),
        headers: _headers,
        body: jsonEncode({
          'status': status,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating booking status: $e');
      return false;
    }
  }
  
  Future<bool> assignBooking(String bookingId, String mechanicUserId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/mechanics/assign'),
        headers: _headers,
        body: jsonEncode({
          'bookingId': bookingId,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error assigning booking: $e');
      return false;
    }
  }
  
  // Assignment operations
  Future<List<Map<String, dynamic>>> fetchMyAssignments(String mechanicUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/mechanics/my-assignments'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      
      return [];
    } catch (e) {
      print('Error fetching assignments: $e');
      return [];
    }
  }
  
  Future<bool> updateAssignmentStatus(String assignmentId, String status, String? notes) async {
    try {
      final body = {
        'status': status,
      };
      
      if (notes != null) {
        body['notes'] = notes;
      }
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/mechanics/assignments/$assignmentId/status'),
        headers: _headers,
        body: jsonEncode(body),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating assignment status: $e');
      return false;
    }
  }
  
  // Part suggestion operations
  Future<bool> createPartSuggestion(String bookingId, String mechanicUserId, String type, String description, double? priceSYP) async {
    try {
      final body = {
        'type': type,
        'description': description,
      };
      
      if (priceSYP != null) {
        body['priceSYP'] = priceSYP.toString();
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/mechanics/bookings/$bookingId/part-suggestions'),
        headers: _headers,
        body: jsonEncode(body),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error creating part suggestion: $e');
      return false;
    }
  }
  
  Future<List<Map<String, dynamic>>> fetchPartSuggestions(String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/mechanics/bookings/$bookingId/part-suggestions'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      
      return [];
    } catch (e) {
      print('Error fetching part suggestions: $e');
      return [];
    }
  }
  
  // Repair operations
  Future<bool> addRepair(String bookingId, String mechanicUserId, String description, String status, double? cost) async {
    try {
      final body = {
        'booking_id': bookingId,
        'mechanic_user_id': mechanicUserId,
        'description': description,
        'status': status,
      };
      
      if (cost != null) {
        body['cost'] = cost.toString();
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/repairs'),
        headers: _headers,
        body: jsonEncode(body),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding repair: $e');
      return false;
    }
  }
}
