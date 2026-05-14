import 'dart:convert';
import 'package:crypto/crypto.dart';

/// JWT token service for generating and verifying tokens.
class JwtService {
  final String _secret;

  JwtService(this._secret);

  String generateToken({
    required String userId,
    required String username,
    required String role,
    int expiresInSeconds = 86400,
  }) {
    final header = _base64UrlEncode({'alg': 'HS256', 'typ': 'JWT'});
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payload = _base64UrlEncode({
      'sub': userId,
      'username': username,
      'role': role,
      'iat': now,
      'exp': now + expiresInSeconds,
      'type': 'access',
    });
    final signature = _sign('$header.$payload');
    return '$header.$payload.$signature';
  }

  String generateRefreshToken({
    required String userId,
    int expiresInSeconds = 604800, // 7 days
  }) {
    final header = _base64UrlEncode({'alg': 'HS256', 'typ': 'JWT'});
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payload = _base64UrlEncode({
      'sub': userId,
      'iat': now,
      'exp': now + expiresInSeconds,
      'type': 'refresh',
    });
    final signature = _sign('$header.$payload');
    return '$header.$payload.$signature';
  }

  Map<String, dynamic>? verifyToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final expectedSignature = _sign('${parts[0]}.${parts[1]}');
      if (!_constantTimeEquals(parts[2], expectedSignature)) {
        return null;
      }

      final decoded = _base64UrlDecode(parts[1]);
      final payload = jsonDecode(decoded) as Map<String, dynamic>;

      final exp = payload['exp'] as int?;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (exp != null && now > exp) return null;

      return payload;
    } catch (e) {
      return null;
    }
  }

  String _sign(String input) {
    final hmac = Hmac(sha256, utf8.encode(_secret));
    final digest = hmac.convert(utf8.encode(input));
    return base64UrlEncode(digest.bytes);
  }

  String _base64UrlEncode(Map<String, dynamic> data) {
    final bytes = utf8.encode(jsonEncode(data));
    return base64Url.encode(bytes);
  }

  String _base64UrlDecode(String str) {
    String normalized = str.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    final bytes = base64.decode(normalized);
    return utf8.decode(bytes);
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
