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
        print('AuthMiddleware: Checking authorization...');
        
        final authHeader = _getAuthorizationHeader(request);
        print('AuthMiddleware: Authorization header: ${authHeader != null ? "Present" : "Missing"}');
        
        if (authHeader == null) {
          print('AuthMiddleware: Missing Authorization header');
          return Response.unauthorized(jsonEncode({'error': 'Missing authorization header'}));
        }

        // Check for Bearer prefix (case-insensitive)
        if (!authHeader.toLowerCase().startsWith('bearer ')) {
          print('AuthMiddleware: Invalid Authorization header format: $authHeader');
          return Response.unauthorized(jsonEncode({'error': 'Invalid authorization header format. Expected: Bearer <token>'}));
        }

        // Extract token (split after 'Bearer ')
        final parts = authHeader.split(' ');
        if (parts.length < 2) {
          print('AuthMiddleware: Malformed Authorization header: $authHeader');
          return Response.unauthorized(jsonEncode({'error': 'Malformed authorization header'}));
        }

        final token = parts[1];
        print('AuthMiddleware: Token extracted (length: ${token.length})');
        
        try {
          final user = await _userRepository.verifyToken(token);
          
          if (user == null) {
            print('AuthMiddleware: Invalid token or user not found');
            return Response.unauthorized(jsonEncode({'error': 'Invalid or expired token'}));
          }

          if (!user.isActive) {
            print('AuthMiddleware: User account is inactive: ${user.username}');
            return Response.forbidden(jsonEncode({'error': 'User account is inactive'}));
          }

          print('AuthMiddleware: User authenticated successfully: ${user.username}');

          // Add user to request context
          return innerHandler(request.change(context: {'user': user}));
        } catch (e) {
          print('AuthMiddleware: Error during token verification: $e');
          return Response.internalServerError(
            body: jsonEncode({'error': 'Authentication error: $e'}),
          );
        }
      };
    };
  }

  Middleware requireRole(Role requiredRole) {
    return (Handler innerHandler) {
      return (Request request) async {
        print('AuthMiddleware: Checking role requirement: ${requiredRole.value}');
        
        final user = request.context['user'];
        
        if (user == null) {
          print('AuthMiddleware: No user in context');
          return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
        }

        // Cast user to User type
        final typedUser = user as User;
        print('AuthMiddleware: User role: ${typedUser.role.value}, Required: ${requiredRole.value}');

        // Check if user has the required role or higher privilege
        final userRole = typedUser.role;
        if (!_hasRequiredRole(userRole, requiredRole)) {
          print('AuthMiddleware: Insufficient permissions');
          return Response.forbidden(jsonEncode({'error': 'Insufficient permissions'}));
        }

        print('AuthMiddleware: Role check passed');
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
