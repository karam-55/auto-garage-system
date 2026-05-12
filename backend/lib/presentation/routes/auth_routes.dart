import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/user_repository.dart';
import '../../infrastructure/repositories/user_repository_impl.dart';
import '../middlewares/json_middleware.dart';
import '../middlewares/auth_middleware.dart';
import '../../application/services/auth_service.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';

class AuthRoutes {
  final UserRepository _userRepository;
  final AuthMiddleware _authMiddleware;
  final AuthService _authService;
  final Map<String, List<DateTime>> _rateLimitStore = {};
  final Map<String, int> _attemptCount = {};

  AuthRoutes(
    this._userRepository,
    this._authMiddleware,
    this._authService,
  );

  UserRepositoryImpl get _userRepositoryImpl => _userRepository as UserRepositoryImpl;

  AuthMiddleware get authMiddleware => _authMiddleware;

  bool _isRateLimited(String ip) {
    final now = DateTime.now();
    final attempts = _rateLimitStore[ip] ?? [];
    attempts.removeWhere((t) => now.difference(t).inMinutes > 15);
    _rateLimitStore[ip] = attempts;
    return attempts.length >= 5;
  }

  void _recordAttempt(String ip) {
    _rateLimitStore.putIfAbsent(ip, () => []).add(DateTime.now());
  }

  String _getClientIp(Request request) {
    final forwarded = request.headers['X-Forwarded-For'];
    if (forwarded != null && forwarded.isNotEmpty) {
      return forwarded.split(',').first.trim();
    }
    final connInfo = request.context['shelf.io.connection_info'] as HttpConnectionInfo?;
    return connInfo?.remoteAddress.address ?? 'unknown';
  }

  Router get router {
    final router = Router();

    // POST /api/auth/login
    router.post('/api/auth/login', _login);

    // POST /api/auth/refresh
    router.post('/api/auth/refresh', _refreshToken);

    // POST /api/auth/register (protected: only OWNER can create users)
    router.post('/api/auth/register', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_register)));

    // GET /api/users (protected: MANAGER or higher)
    router.get('/api/users', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_getAllUsers)));

    // DELETE /api/users/:id (protected: only OWNER)
    router.delete('/api/users/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_deleteUser)));

    return router;
  }

  Future<Response> _login(Request request) async {
    final clientIp = _getClientIp(request);
    if (_isRateLimited(clientIp)) {
      return Response(429, body: jsonEncode({'error': 'Too many login attempts. Please try again later.'}));
    }

    try {
      final body = await JsonMiddleware.parseJsonBody(request);
      if (body == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
      }

      final username = (body['username'] as String?)?.trim();
      final password = body['password'] as String?;

      if (username == null || username.isEmpty || password == null || password.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Username and password are required'}));
      }

      _recordAttempt(clientIp);

      final user = await _authService.login(username, password);
      final token = await _authService.generateToken(user);
      
      // Generate refresh token
      final refreshToken = _userRepositoryImpl.generateRefreshToken(userId: user.id);

      return Response.ok(
        jsonEncode({
          'token': token,
          'refreshToken': refreshToken,
          'user': {
            'id': user.id,
            'fullName': user.fullName,
            'username': user.username,
            'role': user.role.value,
          },
        }),
      );
    } catch (e) {
      return Response(401, body: jsonEncode({'error': 'Invalid username or password'}));
    }
  }

  Future<Response> _refreshToken(Request request) async {
    try {
      final body = await JsonMiddleware.parseJsonBody(request);
      if (body == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
      }

      final refreshToken = body['refreshToken'] as String?;
      if (refreshToken == null || refreshToken.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'Refresh token is required'}));
      }

      // Verify refresh token
      final payload = _userRepositoryImpl.verifyRefreshToken(refreshToken);
      
      if (payload == null) {
        return Response(401, body: jsonEncode({'error': 'Invalid or expired refresh token'}));
      }

      final userId = payload['sub'] as String?;
      if (userId == null) {
        return Response(401, body: jsonEncode({'error': 'Invalid refresh token'}));
      }

      // Get user
      final user = await _userRepository.findById(userId);
      if (user == null || !user.isActive) {
        return Response(401, body: jsonEncode({'error': 'User not found or inactive'}));
      }

      // Generate new access token
      final newToken = await _authService.generateToken(user);
      final newRefreshToken = _userRepositoryImpl.generateRefreshToken(userId: user.id);

      return Response.ok(
        jsonEncode({
          'token': newToken,
          'refreshToken': newRefreshToken,
        }),
      );
    } catch (e) {
      return Response(401, body: jsonEncode({'error': 'Failed to refresh token: $e'}));
    }
  }

  Future<Response> _getAllUsers(Request request) async {
    try {
      final users = await _userRepository.findAll();
      return Response.ok(
        jsonEncode(users.map((u) => u.toJson()).toList()),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get users: $e'}),
      );
    }
  }

  Future<Response> _deleteUser(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      await _userRepository.delete(id);
      return Response.ok(jsonEncode({'message': 'User deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete user: $e'}),
      );
    }
  }

  Future<Response> _register(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final fullName = (body['fullName'] as String?)?.trim();
    final username = (body['username'] as String?)?.trim();
    final password = body['password'] as String?;
    final role = (body['role'] as String?)?.trim();

    if (fullName == null || fullName.isEmpty ||
        username == null || username.isEmpty ||
        password == null || password.isEmpty ||
        role == null || role.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'All fields are required and cannot be empty'}));
    }

    if (password.length < 12) {
      return Response.badRequest(body: jsonEncode({'error': 'Password must be at least 12 characters'}));
    }

    // Check password complexity
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUpperCase || !hasLowerCase || !hasNumber || !hasSpecialChar) {
      return Response.badRequest(body: jsonEncode({'error': 'Password must contain uppercase, lowercase, number, and special character'}));
    }

    try {
      // Hash password
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      final user = User(
        id: const Uuid().v4(),
        fullName: fullName,
        username: username,
        passwordHash: passwordHash,
        role: Role.fromString(role),
        createdAt: DateTime.now().toUtc(),
      );

      final createdUser = await _userRepository.create(user);

      return Response.ok(
        jsonEncode({
          'id': createdUser.id,
          'fullName': createdUser.fullName,
          'username': createdUser.username,
          'role': createdUser.role.value,
        }),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Registration failed: $e'}),
      );
    }
  }
}
