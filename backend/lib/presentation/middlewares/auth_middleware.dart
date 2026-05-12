import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class AuthMiddleware {
  final UserRepository _userRepository;

  AuthMiddleware(this._userRepository);

  // Get Authorization header (case-insensitive)
  String? _getAuthorizationHeader(Request request) {
    // Try common variations
    for (final key in request.headers.keys) {
      if (key.toLowerCase() == 'authorization') {
        return request.headers[key];
      }
    }
    return null;
  }

  Middleware authenticate() {
    return (Handler innerHandler) {
      return (Request request) async {
        final authHeader = _getAuthorizationHeader(request);

        if (authHeader == null) {
          return Response.unauthorized(jsonEncode({'error': 'Missing authorization header'}));
        }

        // Check for Bearer prefix (case-insensitive)
        if (!authHeader.toLowerCase().startsWith('bearer ')) {
          return Response.unauthorized(jsonEncode({'error': 'Invalid authorization header format. Expected: Bearer <token>'}));
        }

        // Extract token (substring after 'Bearer ')
        final token = authHeader.substring(7);

        try {
          final user = await _userRepository.verifyToken(token);

          if (user == null) {
            return Response.unauthorized(jsonEncode({'error': 'Invalid or expired token'}));
          }

          if (!user.isActive) {
            return Response.forbidden(jsonEncode({'error': 'User account is inactive'}));
          }

          // Add user to request context
          return innerHandler(request.change(context: {'user': user}));
        } catch (e) {
          return Response.internalServerError(
            body: jsonEncode({'error': 'Authentication error'}),
          );
        }
      };
    };
  }

  Middleware requireRole(Role requiredRole) {
    return (Handler innerHandler) {
      return (Request request) async {
        final user = request.context['user'];

        if (user == null) {
          return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
        }

        // Cast user to User type
        final typedUser = user as User;

        // Check if user has the required role or higher privilege
        final userRole = typedUser.role;
        if (!_hasRequiredRole(userRole, requiredRole)) {
          return Response.forbidden(jsonEncode({'error': 'Insufficient permissions'}));
        }

        return innerHandler(request);
      };
    };
  }

  bool _hasRequiredRole(Role userRole, Role requiredRole) {
    // Define role hierarchy
    final roleHierarchy = {
      Role.OWNER: 4,
      Role.MANAGER: 3,
      Role.RECEPTIONIST: 2,
      Role.MECHANIC: 1,
    };

    final userLevel = roleHierarchy[userRole] ?? 0;
    final requiredLevel = roleHierarchy[requiredRole] ?? 0;
    
    return userLevel >= requiredLevel;
  }
}
