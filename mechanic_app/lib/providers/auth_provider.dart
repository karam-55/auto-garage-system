import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/services/storage_service.dart';
import '../core/constants/api_constants.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService;
  
  String? _userName;
  String? _userId;
  String? _userRole;
  bool _isLoading = false;
  String? _errorMessage;
  
  AuthProvider() : _storageService = StorageService();
  
  String? get userName => _userName;
  String? get userId => _userId;
  String? get userRole => _userRole;
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
        _userId = await _storageService.getUserId();
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
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        
        _userName = userData['fullName'] as String;
        _userId = userData['id'] as String;
        _userRole = userData['role'] as String;
        
        await _storageService.saveToken(token);
        await _storageService.saveUserInfo(_userId!, _userName!);
        
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
    _userId = null;
    _userRole = null;
    notifyListeners();
  }
}
