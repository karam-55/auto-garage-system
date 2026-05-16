import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/backend_constants.dart';
import '../core/logger.dart';

class ApiService {
  final String _baseUrl = BackendConstants.backendUrl;
  String? _token;
  String? _refreshToken;
  
  ApiService() {
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _refreshToken = prefs.getString('refresh_token');
  }
  
  void setToken(String? token) {
    _token = token;
  }

  void setRefreshToken(String? refreshToken) {
    _refreshToken = refreshToken;
  }

  String? get token => _token;
  String? get refreshToken => _refreshToken;

  Future<bool> refreshAccessToken() async {
    return await _refreshAccessToken();
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refreshToken': _refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _refreshToken = data['refreshToken'];
        
        // Save new tokens to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('refresh_token', data['refreshToken']);
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
  
  // Auth operations
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      logger.info('Attempting login via Render backend for username: $username');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      logger.info('Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.info('Login response: $data');

        // Store token
        _token = data['token'];

        return data;
      }

      logger.warning('Login failed: ${response.body}');
      return null;
    } catch (e) {
      logger.severe('Login error: $e');
      return null;
    }
  }
  
  Future<bool> register(String username, String fullName, String passwordHash, String role) async {
    try {
      logger.info('Attempting register via Render backend for username: $username');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/mechanic-register'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'fullName': fullName,
          'password': passwordHash,
          'role': role,
        }),
      );

      logger.info('Register response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        logger.info('User registered successfully');
        return true;
      }

      logger.warning('Register failed: ${response.body}');
      return false;
    } catch (e) {
      logger.severe('Register error: $e');
      return false;
    }
  }
  
  // Booking operations
  Future<List<Map<String, dynamic>>> fetchAvailableBookings() async {
    try {
      logger.info('Fetching available bookings from: $_baseUrl/api/mechanics/available-bookings');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/mechanics/available-bookings'),
        headers: _headers,
      );

      logger.info('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.info('Available bookings data: $data');
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          logger.warning('Expected list but got: ${data.runtimeType}');
          return [];
        }
      } else if (response.statusCode == 401) {
        logger.warning('Unauthorized, attempting token refresh');
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return fetchAvailableBookings();
        }
        return [];
      } else {
        logger.warning('Failed to fetch bookings: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e, stack) {
      logger.severe('Error fetching bookings: $e', e, stack);
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
      logger.severe('Error updating booking status: $e');
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
      logger.severe('Error assigning booking: $e');
      return false;
    }
  }
  
  // Assignment operations
  Future<List<Map<String, dynamic>>> fetchMyAssignments(String mechanicUserId) async {
    try {
      logger.info('Fetching my assignments from: $_baseUrl/api/mechanics/my-assignments');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/mechanics/my-assignments'),
        headers: _headers,
      );

      logger.info('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.info('My assignments data: $data');
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          logger.warning('Expected list but got: ${data.runtimeType}');
          return [];
        }
      } else if (response.statusCode == 401) {
        logger.warning('Unauthorized, attempting token refresh');
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return fetchMyAssignments(mechanicUserId);
        }
        return [];
      } else {
        logger.warning('Failed to fetch assignments: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e, stack) {
      logger.severe('Error fetching assignments: $e', e, stack);
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
      logger.severe('Error updating assignment status: $e');
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
      logger.severe('Error creating part suggestion: $e');
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
      logger.severe('Error fetching part suggestions: $e');
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
      logger.severe('Error adding repair: $e');
      return false;
    }
  }
  
  // Inventory operations
  Future<List<dynamic>> fetchInventory() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/inventory/variants'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<dynamic>.from(data);
      }
      
      return [];
    } catch (e) {
      logger.severe('Error fetching inventory: $e');
      return [];
    }
  }
  
  Future<bool> consumePart(String variantId, int quantity, String bookingId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/inventory/consume'),
        headers: _headers,
        body: jsonEncode({
          'variantId': variantId,
          'quantity': quantity,
          'bookingId': bookingId,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      logger.severe('Error consuming part: $e');
      return false;
    }
  }
  
  Future<Map<String, dynamic>?> fetchInvoice(String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/bookings/$bookingId/invoice'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return null;
    } catch (e) {
      logger.severe('Error fetching invoice: $e');
      return null;
    }
  }
}
