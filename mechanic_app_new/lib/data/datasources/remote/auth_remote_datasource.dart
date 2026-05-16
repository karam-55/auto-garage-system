import '../../models/user_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/exceptions.dart';

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
        return UserModel.fromJson(response.data['user']);
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
