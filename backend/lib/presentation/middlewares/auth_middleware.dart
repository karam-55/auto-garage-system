import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class AuthMiddleware {
  final UserRepository _userRepository;

  AuthMiddleware(this._userRepository);

  Middleware authenticate() {
    return (Handler innerHandler) {
      return (Request request) async {
        final authHeader = request.headers['Authorization'];
        
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.unauthorized(jsonEncode({'error': 'Missing or invalid authorization header'}));
        }

        final token = authHeader.substring(7);
        final user = await _userRepository.verifyToken(token);

        if (user == null) {
          return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
        }

        if (!user.isActive) {
          return Response.forbidden(jsonEncode({'error': 'User account is inactive'}));
        }

        // Add user to request context
        return innerHandler(request.change(context: {'user': user}));
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

    return roleHierarchy[userRole]! >= roleHierarchy[requiredRole]!;
  }
}
