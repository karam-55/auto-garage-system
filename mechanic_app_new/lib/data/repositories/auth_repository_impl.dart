import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/local/cache_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final CacheDataSource _cacheDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._cacheDataSource);

  @override
  Future<User> login(String username, String password) async {
    try {
      final userModel = await _remoteDataSource.login(username, password);
      final user = userModel.toEntity();
      
      // Save user to cache
      await _cacheDataSource.saveString('user_id', user.id);
      await _cacheDataSource.saveString('full_name', user.fullName);
      await _cacheDataSource.saveString('username', user.username);
      await _cacheDataSource.saveString('role', user.role);
      
      return user;
    } on UnauthorizedException {
      throw UnauthorizedFailure('Invalid username or password');
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Login failed: $e');
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('refresh_token');
      await _cacheDataSource.clear();
      return true;
    } catch (e) {
      throw CacheFailure('Logout failed: $e');
    }
  }

  @override
  Future<User?> getLoggedInUser() async {
    try {
      final userId = await _cacheDataSource.getString('user_id');
      if (userId == null) return null;

      final fullName = await _cacheDataSource.getString('full_name') ?? '';
      final username = await _cacheDataSource.getString('username') ?? '';
      final role = await _cacheDataSource.getString('role') ?? '';

      return User(
        id: userId,
        fullName: fullName,
        username: username,
        role: role,
      );
    } catch (e) {
      throw CacheFailure('Failed to get logged in user: $e');
    }
  }

  @override
  Future<bool> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) return false;

      // This should be implemented in the remote datasource
      // For now, return false
      return false;
    } catch (e) {
      throw ServerFailure('Token refresh failed: $e');
    }
  }
}
