import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  final http.Client _client;
  String? _token;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Set token for authentication
  void setToken(String? token) {
    _token = token;
  }

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم: $e');
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
      return _handleResponse(response);
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
      
      return _handleResponse(response);
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
      
      return _handleResponse(response);
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
      
      return _handleResponse(response);
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
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('فشل في تحليل الاستجابة: $e');
      }
    } else if (response.statusCode == 401) {
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
