abstract class Failure {
  final String message;
  final int? statusCode;

  Failure(this.message, {this.statusCode});
}

class ServerFailure extends Failure {
  ServerFailure(super.message, {super.statusCode});
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}

class AuthenticationFailure extends Failure {
  AuthenticationFailure(super.message, {super.statusCode});
}

class AuthorizationFailure extends Failure {
  AuthorizationFailure(super.message, {super.statusCode = 403});
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message, {super.statusCode = 400});
}

class NotFoundFailure extends Failure {
  NotFoundFailure(super.message, {super.statusCode = 404});
}

class ConflictFailure extends Failure {
  ConflictFailure(super.message, {super.statusCode = 409});
}
