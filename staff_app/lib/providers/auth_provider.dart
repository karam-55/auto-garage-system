import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/api_constants.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  AuthProvider()
      : _apiService = ApiService(),
        _storageService = StorageService();
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      if (isLoggedIn) {
        final userId = await _storageService.getUserId();
        final userRole = await _storageService.getUserRole();
        final userName = await _storageService.getUserName();
        
        if (userId != null && userRole != null && userName != null) {
          _currentUser = User(
            id: userId,
            fullName: userName,
            username: userName,
            role: userRole,
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
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
        final data = _parseResponse(response);
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        
        final user = User.fromJson(userData);
        _currentUser = user;
        
        await _storageService.saveToken(token);
        await _storageService.saveUserInfo(user.id, user.role, user.fullName);
        
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
    _currentUser = null;
    notifyListeners();
  }
  
  dynamic _parseResponse(http.Response response) {
    if (response.body.isEmpty) return {};
    return json.decode(response.body);
  }
}
