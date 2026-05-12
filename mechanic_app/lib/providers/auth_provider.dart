import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../core/constants/supabase_constants.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  String? _userName;
  String? _userId;
  String? _userRole;
  bool _isLoading = false;
  String? _errorMessage;
  
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
      final session = _supabase.auth.currentSession;
      if (session != null) {
        final user = await _supabase
            .from('users')
            .select('id, full_name, role')
            .eq('id', session.user.id)
            .single();
        
        _userId = user['id'] as String;
        _userName = user['full_name'] as String;
        _userRole = user['role'] as String;
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
      // First, get the user by username
      final users = await _supabase
          .from('users')
          .select('id, password_hash, full_name, role, is_active')
          .eq('username', username)
          .limit(1);
      
      if (users.isEmpty) {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final user = users.first;
      
      // Check if user is active
      if (user['is_active'] == false) {
        _errorMessage = 'User account is inactive';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Verify password (simple hash for demo - in production use proper bcrypt)
      final passwordBytes = utf8.encode(password);
      final passwordHash = sha256.convert(passwordBytes).toString();
      
      if (passwordHash != user['password_hash']) {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Create a session using Supabase Auth
      // We'll use the user ID as the email for auth
      await _supabase.auth.signInWithPassword(
        email: '${username}@mechanic.local',
        password: password,
      );
      
      _userId = user['id'] as String;
      _userName = user['full_name'] as String;
      _userRole = user['role'] as String;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _userId = null;
    _userName = null;
    _userRole = null;
    notifyListeners();
  }
}
