import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';

class ApiService {
  final http.Client _client;
  String? _token;
  String? _refreshToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client() {
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // Set token for authentication
  void setToken(String? token) {
    _token = token;
  }

  // Set refresh token
  void setRefreshToken(String? refreshToken) {
    _refreshToken = refreshToken;
  }

  // Clear token
  void clearToken() {
    _token = null;
  }

  // Clear refresh token
  void clearRefreshToken() {
    _refreshToken = null;
  }

  // Refresh access token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;
    
    try {
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

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
      );
      return await _handleResponse(response, endpoint: endpoint, method: 'GET');
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم: $e');
    }
  }

  // Get current user
  Future<Map<String, dynamic>> getUser() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/me'),
        headers: _getHeaders(),
      );
      return await _handleResponse(response, endpoint: '/api/auth/me', method: 'GET');
    } catch (e) {
      throw Exception('فشل جلب المستخدم: $e');
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      return await _handleResponse(response, endpoint: endpoint, method: 'POST', data: data);
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم: $e');
    }
  }
  
  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      
      return await _handleResponse(response, endpoint: endpoint, method: 'PUT', data: data);
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم: $e');
    }
  }

  // Generic PATCH request
  Future<Map<String, dynamic>> patch(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      
      return await _handleResponse(response, endpoint: endpoint, method: 'PATCH', data: body);
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم: $e');
    }
  }
  
  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
      );
      
      return await _handleResponse(response, endpoint: endpoint, method: 'DELETE');
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم: $e');
    }
  }
  
  // Get headers
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }
  
  // Handle response
  Future<dynamic> _handleResponse(http.Response response, {String? endpoint, String? method, Map<String, dynamic>? data}) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('فشل في تحليل الاستجابة: $e');
      }
    } else if (response.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        // Retry the original request
        if (method == 'GET' && endpoint != null) {
          final retryResponse = await _client.get(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _getHeaders(),
          );
          return await _handleResponse(retryResponse, endpoint: endpoint, method: method, data: data);
        } else if (method == 'POST' && endpoint != null && data != null) {
          final retryResponse = await _client.post(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _getHeaders(),
            body: jsonEncode(data),
          );
          return await _handleResponse(retryResponse, endpoint: endpoint, method: method, data: data);
        } else if (method == 'PUT' && endpoint != null && data != null) {
          final retryResponse = await _client.put(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _getHeaders(),
            body: jsonEncode(data),
          );
          return await _handleResponse(retryResponse, endpoint: endpoint, method: method, data: data);
        } else if (method == 'PATCH' && endpoint != null) {
          final retryResponse = await _client.patch(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _getHeaders(),
            body: data != null ? jsonEncode(data) : null,
          );
          return await _handleResponse(retryResponse, endpoint: endpoint, method: method, data: data);
        } else if (method == 'DELETE' && endpoint != null) {
          final retryResponse = await _client.delete(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _getHeaders(),
          );
          return await _handleResponse(retryResponse, endpoint: endpoint, method: method, data: data);
        }
      }
      throw Exception('غير مصرح: يرجى تسجيل الدخول مرة أخرى');
    } else if (response.statusCode == 403) {
      throw Exception('ممنوع: ليس لديك الصلاحية');
    } else if (response.statusCode == 404) {
      throw Exception('غير موجود');
    } else if (response.statusCode == 429) {
      throw Exception('طلبات كثيرة: يرجى الانتظار قليلاً');
    } else if (response.statusCode == 500) {
      throw Exception('خطأ في الخادم: يرجى المحاولة لاحقاً');
    } else {
      throw Exception('خطأ غير معروف: ${response.statusCode}');
    }
  }
  
  void dispose() {
    _client.close();
  }
}
