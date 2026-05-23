import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthService {
  final http.Client _client;
  String? _token;
  String? _refreshToken;
  int _failedAttempts = 0;
  DateTime? _lastFailedAttempt;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    // Check rate limit
    if (_failedAttempts >= 5 && _lastFailedAttempt != null) {
      final timeSinceLastFail = DateTime.now().difference(_lastFailedAttempt!);
      if (timeSinceLastFail < const Duration(minutes: 15)) {
        throw Exception('محاولات كثيرة فاشلة. يرجى المحاولة بعد 15 دقيقة');
      } else {
        _failedAttempts = 0;
      }
    }
    
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _refreshToken = data['refreshToken'];
        _failedAttempts = 0; // Reset on successful login
        
        // Save tokens to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['token']);
        await prefs.setString('refresh_token', data['refreshToken']);
        
        return data;
      } else {
        _failedAttempts++;
        _lastFailedAttempt = DateTime.now();
        throw Exception('فشل تسجيل الدخول');
      }
    } catch (e) {
      _failedAttempts++;
      _lastFailedAttempt = DateTime.now();
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Load tokens from SharedPreferences
  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // Try auto login using refresh token
  Future<bool> tryAutoLogin() async {
    await loadTokens();
    
    if (_refreshToken == null) return false;
    
    final success = await refreshAccessToken();
    return success;
  }

  // Refresh access token
  Future<bool> refreshAccessToken() async {
    try {
      if (_refreshToken == null) return false;
      
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/refresh'),
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
        await prefs.setString('access_token', data['token']);
        await prefs.setString('refresh_token', data['refreshToken']);
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
    String fullName,
    String username,
    String password,
    String role,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'username': username,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return data;
      } else {
        throw Exception('فشل التسجيل');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // Get token
  String? get token => _token;

  // Get refresh token
  String? get refreshToken => _refreshToken;

  // Set token
  void setToken(String? token) {
    _token = token;
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    
    // Clear tokens from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
  }

  // Check if authenticated
  bool get isAuthenticated => _token != null;

  void dispose() {
    _client.close();
  }
}
