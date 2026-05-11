abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException(super.message, {super.statusCode});
}

class DatabaseException extends AppException {
  DatabaseException(super.message);
}

class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.statusCode});
}

class AuthorizationException extends AppException {
  AuthorizationException(super.message, {super.statusCode = 403});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.statusCode = 400});
}

class NotFoundException extends AppException {
  NotFoundException(super.message, {super.statusCode = 404});
}

class ConflictException extends AppException {
  ConflictException(super.message, {super.statusCode = 409});
}
