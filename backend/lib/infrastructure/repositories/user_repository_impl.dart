import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../database/database_connection.dart';

class UserRepositoryImpl implements UserRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  UserRepositoryImpl(this._db);

  @override
  Future<User> create(User user) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('''
          INSERT INTO users (id, full_name, username, password_hash, role, is_active, created_at, updated_at)
          VALUES (@id, @fullName, @username, @passwordHash, @role, @isActive, @createdAt, @updatedAt)
          RETURNING *
        '''),
        parameters: {
          'id': user.id.isEmpty ? _uuid.v4() : user.id,
          'fullName': user.fullName,
          'username': user.username,
          'passwordHash': user.passwordHash,
          'role': user.role.value,
          'isActive': user.isActive,
          'createdAt': user.createdAt,
          'updatedAt': user.updatedAt,
        },
      );

      return _mapRowToUser(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create user: $e');
    }
  }

  @override
  Future<User?> findById(String id) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('SELECT * FROM users WHERE id = @id'),
        parameters: {'id': id},
      );

      if (result.isEmpty) return null;
      return _mapRowToUser(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find user by id: $e');
    }
  }

  @override
  Future<User?> findByUsername(String username) async {
    try {
      print('Finding user by username: $username');
      final result = await _db.connection.execute(
        Sql.named('SELECT * FROM users WHERE username = @username AND is_active = true'),
        parameters: {'username': username},
      );

      if (result.isEmpty) {
        print('User not found: $username');
        return null;
      }

      final user = _mapRowToUser(result.first);
      print('User found: ${user.username}');
      return user;
    } catch (e) {
      print('Error finding user by username: $e');
      throw DatabaseException('Failed to find user by username: $e');
    }
  }

  @override
  Future<List<User>> findAll() async {
    try {
      final result = await _db.connection.execute('SELECT * FROM users ORDER BY created_at DESC');
      return result.map(_mapRowToUser).toList();
    } catch (e) {
      throw DatabaseException('Failed to find all users: $e');
    }
  }

  @override
  Future<User> update(User user) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('''
          UPDATE users 
          SET full_name = @fullName, username = @username, role = @role, is_active = @isActive, updated_at = @updatedAt
          WHERE id = @id
          RETURNING *
        '''),
        parameters: {
          'id': user.id,
          'fullName': user.fullName,
          'username': user.username,
          'role': user.role.value,
          'isActive': user.isActive,
          'updatedAt': DateTime.now().toUtc(),
        },
      );

      return _mapRowToUser(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update user: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.connection.execute(
        Sql.named('DELETE FROM users WHERE id = @id'),
        parameters: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete user: $e');
    }
  }

  @override
  Future<List<User>> findByRole(String role) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('SELECT * FROM users WHERE role = @role ORDER BY created_at DESC'),
        parameters: {'role': role},
      );
      return result.map(_mapRowToUser).toList();
    } catch (e) {
      throw DatabaseException('Failed to find users by role: $e');
    }
  }

  @override
  Future<User> authenticate(String username, String password) async {
    try {
      final user = await findByUsername(username);
      if (user == null) {
        throw AuthenticationException('Invalid username or password', statusCode: 401);
      }

      if (!user.isActive) {
        throw AuthenticationException('User account is inactive', statusCode: 401);
      }

      if (user.passwordHash == null || user.passwordHash!.isEmpty) {
        throw AuthenticationException('User has no password set', statusCode: 401);
      }

      final isValid = BCrypt.checkpw(password, user.passwordHash!);
      if (!isValid) {
        throw AuthenticationException('Invalid username or password', statusCode: 401);
      }

      return user;
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }
      throw AuthenticationException('Authentication failed: $e', statusCode: 500);
    }
  }

  @override
  Future<String> generateToken(User user) async {
    // Simple JWT generation (in production, use a proper JWT library)
    // For now, we'll use a simple token with user info
    final payload = {
      'sub': user.id,
      'username': user.username,
      'role': user.role.value,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000,
    };

    // This is a simplified token generation - in production use dart_jsonwebtoken or similar
    return _generateSimpleJWT(payload);
  }

  String _generateSimpleJWT(Map<String, dynamic> payload) {
    // Simplified JWT generation - replace with proper library in production
    final header = {'alg': 'HS256', 'typ': 'JWT'};
    final encodedHeader = _base64UrlEncode(header);
    final encodedPayload = _base64UrlEncode(payload);
    final signature = _base64UrlEncode('${encodedHeader}.$encodedPayload');
    return '$encodedHeader.$encodedPayload.$signature';
  }

  String _base64UrlEncode(dynamic data) {
    final bytes = data.toString().codeUnits;
    return String.fromCharCodes(bytes)
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
  }

  @override
  Future<User?> verifyToken(String token) async {
    try {
      // Simplified token verification - replace with proper JWT library in production
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payloadStr = parts[1];
      final decoded = _base64UrlDecode(payloadStr);
      final payload = _parsePayload(decoded);

      if (payload == null) return null;

      final userId = payload['sub'] as String?;
      if (userId == null) return null;

      return await findById(userId);
    } catch (e) {
      return null;
    }
  }

  String _base64UrlDecode(String str) {
    String normalized = str.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    return normalized;
  }

  Map<String, dynamic>? _parsePayload(String str) {
    // Simplified parsing - replace with proper JSON decoder in production
    try {
      final pairs = str.split(',');
      final Map<String, dynamic> result = {};
      for (final pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim().replaceAll('{', '').replaceAll('"', '');
          final value = parts[1].trim().replaceAll('}', '').replaceAll('"', '');
          result[key] = value;
        }
      }
      return result;
    } catch (e) {
      return null;
    }
  }

  User _mapRowToUser(ResultRow row) {
    final data = row.toColumnMap();
    return User(
      id: data['id'].toString(),
      fullName: data['full_name'] as String,
      username: data['username'] as String,
      passwordHash: data['password_hash'] as String?,
      role: Role.fromString(data['role'] as String),
      createdAt: data['created_at'] as DateTime,
      updatedAt: data['updated_at'] as DateTime?,
      isActive: data['is_active'] as bool,
    );
  }
}
