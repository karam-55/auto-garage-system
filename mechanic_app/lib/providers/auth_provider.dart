import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_constants.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  
  String? _userName;
  bool _isLoading = false;
  String? _errorMessage;
  
  AuthProvider()
      : _apiService = ApiService(),
        _storageService = StorageService();
  
  String? get userName => _userName;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userName != null;
  
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      if (isLoggedIn) {
        _userName = await _storageService.getUserName();
      }
      _isLoading = false;
      notifyListeners();
      return _userName != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        body: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        
        _userName = userData['fullName'] as String;
        
        await _storageService.saveToken(token);
        await _storageService.saveUserInfo(userData['id'] as String, _userName!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login failed: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    await _storageService.clearAll();
    _userName = null;
    notifyListeners();
  }
}
