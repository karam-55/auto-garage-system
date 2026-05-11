import '../entities/user.dart';
import '../../core/errors/failures.dart';

abstract class UserRepository {
  Future<User> create(User user);
  Future<User?> findById(String id);
  Future<User?> findByUsername(String username);
  Future<List<User>> findAll();
  Future<User> update(User user);
  Future<void> delete(String id);
  Future<List<User>> findByRole(String role);
  Future<String> generateToken(User user);
  Future<User?> verifyToken(String token);
  Future<User> authenticate(String username, String password);
}
