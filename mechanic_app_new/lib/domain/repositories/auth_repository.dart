import '../entities/user.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<bool> logout();
  Future<User?> getLoggedInUser();
  Future<bool> refreshAccessToken();
}
