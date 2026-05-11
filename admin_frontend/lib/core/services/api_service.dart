import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  
  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
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
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  
  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return {};
      case 400:
        throw Exception('طلب غير صالح');
      case 401:
        throw Exception('غير مصرح');
      case 403:
        throw Exception('ممنوع الوصول');
      case 404:
        throw Exception('غير موجود');
      case 500:
        throw Exception('خطأ في الخادم');
      default:
        throw Exception('خطأ غير متوقع: ${response.statusCode}');
    }
  }
  
  void dispose() {
    _client.close();
  }
}
