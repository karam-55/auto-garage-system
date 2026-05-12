import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  final _client = http.Client();
  
  Future<http.Response> get(String endpoint) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return response;
  }
  
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );
    return response;
  }
  
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _client.put(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );
    return response;
  }
  
  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );
    return response;
  }
  
  Future<http.Response> delete(String endpoint) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return response;
  }
}
