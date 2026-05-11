import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  final String baseUrl;
  
  ApiService({this.baseUrl = ApiConstants.baseUrl});
  
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return http.get(url, headers: headers);
  }
  
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }
  
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return http.put(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }
  
  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return http.patch(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }
  
  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    return http.delete(url, headers: headers);
  }
}
