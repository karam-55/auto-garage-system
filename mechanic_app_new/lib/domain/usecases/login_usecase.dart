import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<User> call(String username, String password) async {
    try {
      return await _authRepository.login(username, password);
    } on ServerFailure catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkFailure catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Login failed: $e');
    }
  }
}
