import '../../models/user_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _dioClient.post(
        '/api/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        
        final data = response.data;
        final token = data['token'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        final userData = data['user'];
        
        if (token == null || token.isEmpty) {
          throw ServerException('No token received from server');
        }
        
        await prefs.setString('token', token);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await prefs.setString('refresh_token', refreshToken);
        }
        
        if (userData == null) {
          throw ServerException('No user data received from server');
        }
        
        return UserModel.fromJson(userData);
      } else {
        throw ServerException('Login failed');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
