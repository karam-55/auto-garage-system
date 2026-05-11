import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../middlewares/json_middleware.dart';
import '../../application/services/auth_service.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';

class AuthRoutes {
  final UserRepository _userRepository;
  final AuthService _authService;
  final AuthMiddleware _authMiddleware;

  AuthRoutes(this._userRepository) 
      : _authService = AuthService(_userRepository),
        _authMiddleware = AuthMiddleware(_userRepository);

  Router get router {
    final router = Router();

    // POST /api/auth/login
    router.post('/api/auth/login', _login);

    // POST /api/auth/register (only for initial setup)
    router.post('/api/auth/register', _register);

    return router;
  }

  Future<Response> _login(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final username = body['username'] as String?;
    final password = body['password'] as String?;

    if (username == null || password == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Username and password are required'}));
    }

    try {
      final user = await _authService.login(username, password);
      final token = await _authService.generateToken(user);

      return Response.ok(
        jsonEncode({
          'token': token,
          'user': {
            'id': user.id,
            'fullName': user.fullName,
            'username': user.username,
            'role': user.role.value,
          },
        }),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Login failed: $e'}),
      );
    }
  }

  Future<Response> _register(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final fullName = body['fullName'] as String?;
    final username = body['username'] as String?;
    final password = body['password'] as String?;
    final role = body['role'] as String?;

    if (fullName == null || username == null || password == null || role == null) {
      return Response.badRequest(body: jsonEncode({'error': 'All fields are required'}));
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
