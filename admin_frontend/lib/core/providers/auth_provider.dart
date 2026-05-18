import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class User {
  final String id;
  final String fullName;
  final String username;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.username,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'role': role,
    };
  }
}

// Auth State
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;

  AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isLoading: true)) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        state = AuthState(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = AuthState(
          user: null,
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  Future<void> setUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    state = AuthState(
      user: user,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    state = AuthState(
      user: null,
      isAuthenticated: false,
      isLoading: false,
    );
  }

  void refresh() {
    _loadUser();
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers
final userProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).user?.role;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
