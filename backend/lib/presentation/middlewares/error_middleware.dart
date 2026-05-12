import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';

class ErrorMiddleware {
  static Middleware handleErrors() {
    return (Handler innerHandler) {
      return (Request request) async {
        try {
          return await innerHandler(request);
        } on ServerFailure catch (e) {
          return Response(
            e.statusCode ?? 500,
            body: jsonEncode({'error': e.message}),
            headers: {'Content-Type': 'application/json'},
          );
        } on DatabaseFailure catch (e) {
          return Response(
            500,
            body: jsonEncode({'error': 'Database error: ${e.message}'}),
            headers: {'Content-Type': 'application/json'},
          );
        } on AuthenticationFailure catch (e) {
          return Response(
            e.statusCode ?? 401,
            body: jsonEncode({'error': e.message}),
            headers: {'Content-Type': 'application/json'},
          );
        } on AuthorizationFailure catch (e) {
          return Response(
            e.statusCode ?? 403,
            body: jsonEncode({'error': e.message}),
            headers: {'Content-Type': 'application/json'},
          );
        } on ValidationFailure catch (e) {
          return Response(
            e.statusCode ?? 400,
            body: jsonEncode({'error': e.message}),
            headers: {'Content-Type': 'application/json'},
          );
        } on NotFoundFailure catch (e) {
            return Response(
            e.statusCode ?? 404,
            body: jsonEncode({'error': e.message}),
            headers: {'Content-Type': 'application/json'},
          );
        } on ConflictFailure catch (e) {
          return Response(
            e.statusCode ?? 409,
            body: jsonEncode({'error': e.message}),
            headers: {'Content-Type': 'application/json'},
          );
        } on ValidationException catch (e) {
          return Response(
            e.statusCode ?? 400,
            body: jsonEncode({'error': e.message}),
            headers: {'Content-Type': 'application/json'},
          );
        } on AuthenticationException catch (e) {
          return Response(
            e.statusCode ?? 401,
            body: jsonEncode({'error': e.message}),
            headers: {'Content-Type': 'application/json'},
          );
        } on AuthorizationException catch (e) {
          return Response(
            e.statusCode ?? 403,
            body: jsonEncode({'error': e.message}),
            headers: {'Content-Type': 'application/json'},
          );
        } on DatabaseException catch (e) {
          return Response(
            500,
            body: jsonEncode({'error': 'Database error: ${e.message}'}),
            headers: {'Content-Type': 'application/json'},
          );
        } catch (e) {
          return Response(
            500,
            body: jsonEncode({'error': 'Internal server error'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      };
    };
  }
}
