import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/errors/failures.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository) {
    // Ensure UserRepository implements AuthRepository
    if (_authRepository is! UserRepository) {
      throw ArgumentError('AuthRepository must be a UserRepository');
    }
  }

  Future<User> login(String username, String password) async {
    try {
      return await _authRepository.authenticate(username, password);
    } catch (e) {
      throw ServerFailure('Authentication failed: $e');
    }
  }

  Future<String> generateToken(User user) async {
    try {
      return await _authRepository.generateToken(user);
    } catch (e) {
      throw ServerFailure('Failed to generate token: $e');
    }
  }

  Future<User?> verifyToken(String token) async {
    try {
      return await _authRepository.verifyToken(token);
    } catch (e) {
      throw ServerFailure('Failed to verify token: $e');
    }
  }
}
