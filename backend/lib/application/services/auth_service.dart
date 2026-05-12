import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/errors/failures.dart';

class AuthService {
  final UserRepository _userRepository;

  AuthService(this._userRepository);

  Future<User> login(String username, String password) async {
    try {
      return await _userRepository.authenticate(username, password);
    } catch (e) {
      throw ServerFailure('Authentication failed: $e');
    }
  }

  Future<String> generateToken(User user) async {
    try {
      return await _userRepository.generateToken(user);
    } catch (e) {
      throw ServerFailure('Token generation failed: $e');
    }
  }

  Future<User?> verifyToken(String token) async {
    try {
      return await _userRepository.verifyToken(token);
    } catch (e) {
      throw ServerFailure('Failed to verify token: $e');
    }
  }
}
