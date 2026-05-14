import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_user;
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  app_user.User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  String? _refreshToken;
  
  app_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  
  AuthProvider() {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final fullName = prefs.getString('full_name');
    final username = prefs.getString('username');
    final role = prefs.getString('role');
    final token = prefs.getString('token');
    final refreshToken = prefs.getString('refresh_token');
    
    if (userId != null && fullName != null && token != null) {
      _currentUser = app_user.User(
        id: userId,
        fullName: fullName,
        username: username ?? '',
        role: role ?? '',
      );
      _token = token;
      _refreshToken = refreshToken;
      _apiService.setToken(token);
      _apiService.setRefreshToken(refreshToken);
      notifyListeners();
    }
  }
  
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      print('Attempting login for username: $username');
      
      // Login via Render backend
      final response = await _apiService.login(username, password);
      
      if (response == null) {
        _errorMessage = 'المستخدم غير موجود أو حدث خطأ في الاتصال بقاعدة البيانات. تأكد من اسم المستخدم.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      print('Login successful');
      
      // Store tokens
      _token = response['token'];
      _refreshToken = response['refreshToken'];
      _apiService.setToken(_token);
      _apiService.setRefreshToken(_refreshToken);
      
      // Save user info
      final userData = response['user'];
      _currentUser = app_user.User(
        id: userData['id'],
        fullName: userData['fullName'],
        username: userData['username'],
        role: userData['role'],
      );
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userData['id']);
      await prefs.setString('full_name', userData['fullName']);
      await prefs.setString('username', userData['username']);
      await prefs.setString('role', userData['role']);
      await prefs.setString('token', _token!);
      await prefs.setString('refresh_token', _refreshToken!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Login exception: $e');
      _errorMessage = 'خطأ في الاتصال: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> register(String username, String fullName, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      print('Registering user: $username, role: $role');
      
      // Register via Render backend (password is sent as plain text, backend handles bcrypt)
      final success = await _apiService.register(username, fullName, password, role);
      
      if (!success) {
        _errorMessage = 'فشل إنشاء المستخدم - قد يكون الاسم مستخدم بالفعل أو الدور غير صحيح';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'خطأ في إنشاء المستخدم: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _currentUser = null;
    _token = null;
    _refreshToken = null;
    _apiService.setToken(null);
    _apiService.setRefreshToken(null);
    notifyListeners();
  }
  
  String? get userId => _currentUser?.id;
}
