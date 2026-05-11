import 'package:shelf/shelf.dart';
import '../../core/errors/failures.dart';

class ErrorMiddleware {
  static Middleware handleErrors() {
    return (Handler innerHandler) {
      return (Request request) async {
        try {
          return await innerHandler(request);
        } on ServerFailure catch (e) {
          return Response(
            e.statusCode ?? 500,
            body: '{"error": "${e.message}"}',
            headers: {'Content-Type': 'application/json'},
          );
        } on DatabaseFailure catch (e) {
          return Response(
            500,
            body: '{"error": "Database error: ${e.message}"}',
            headers: {'Content-Type': 'application/json'},
          );
        } on AuthenticationFailure catch (e) {
          return Response(
            e.statusCode ?? 401,
            body: '{"error": "${e.message}"}',
            headers: {'Content-Type': 'application/json'},
          );
        } on AuthorizationFailure catch (e) {
          return Response(
            e.statusCode ?? 403,
            body: '{"error": "${e.message}"}',
            headers: {'Content-Type': 'application/json'},
          );
        } on ValidationFailure catch (e) {
          return Response(
            e.statusCode ?? 400,
            body: '{"error": "${e.message}"}',
            headers: {'Content-Type': 'application/json'},
          );
        } on NotFoundFailure catch (e) {
          return Response(
            e.statusCode ?? 404,
            body: '{"error": "${e.message}"}',
            headers: {'Content-Type': 'application/json'},
          );
        } on ConflictFailure catch (e) {
          return Response(
            e.statusCode ?? 409,
            body: '{"error": "${e.message}"}',
            headers: {'Content-Type': 'application/json'},
          );
        } catch (e) {
          return Response(
            500,
            body: '{"error": "Internal server error"}',
            headers: {'Content-Type': 'application/json'},
          );
        }
      };
    };
  }
}
