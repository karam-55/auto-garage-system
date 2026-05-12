import 'package:test/test.dart';
import '../lib/core/utils/jwt_service.dart';

void main() {
  const testSecret = 'test-secret-key-1234567890';
  late JwtService jwt;

  setUp(() {
    jwt = JwtService(testSecret);
  });

  group('JwtService', () {
    test('generates a valid token with 3 parts', () {
      final token = jwt.generateToken(
        userId: 'user-123',
        username: 'testuser',
        role: 'MANAGER',
      );
      expect(token.split('.').length, equals(3));
    });

    test('verifies a valid token and returns payload', () {
      final token = jwt.generateToken(
        userId: 'user-123',
        username: 'testuser',
        role: 'MANAGER',
      );
      final payload = jwt.verifyToken(token);
      expect(payload, isNotNull);
      expect(payload!['sub'], equals('user-123'));
      expect(payload['username'], equals('testuser'));
      expect(payload['role'], equals('MANAGER'));
      expect(payload.containsKey('iat'), isTrue);
      expect(payload.containsKey('exp'), isTrue);
    });

    test('rejects a tampered token', () {
      final token = jwt.generateToken(
        userId: 'user-123',
        username: 'testuser',
        role: 'MANAGER',
      );
      final tampered = '${token.substring(0, token.length - 5)}xxxxx';
      expect(jwt.verifyToken(tampered), isNull);
    });

    test('rejects a token with wrong number of parts', () {
      expect(jwt.verifyToken('header.payload'), isNull);
      expect(jwt.verifyToken('a.b.c.d'), isNull);
    });

    test('rejects an expired token', () {
      final token = jwt.generateToken(
        userId: 'user-123',
        username: 'testuser',
        role: 'MANAGER',
        expiresInSeconds: -1,
      );
      expect(jwt.verifyToken(token), isNull);
    });

    test('rejects a token signed with a different secret', () {
      final otherJwt = JwtService('different-secret');
      final token = otherJwt.generateToken(
        userId: 'user-123',
        username: 'testuser',
        role: 'MANAGER',
      );
      expect(jwt.verifyToken(token), isNull);
    });
  });
}
