import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/jwt_service.dart';
import '../database/database_connection.dart';

class UserRepositoryImpl implements UserRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();
  final String _jwtSecret;

  UserRepositoryImpl(this._db, {required String jwtSecret}) : _jwtSecret = jwtSecret;

  @override
  Future<User> create(User user) async {
    try {
      final result = await _db.execute(
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
      final result = await _db.execute(
        Sql.named('SELECT * FROM users WHERE id = @id'),
        parameters: {'id': id},
      );

      if (result.isEmpty) {
        return null;
      }

      final user = _mapRowToUser(result.first);
      return user;
    } catch (e) {
      throw DatabaseException('Failed to find user by id: $e');
    }
  }

  @override
  Future<User?> findByUsername(String username) async {
    try {
      final result = await _db.execute(
        Sql.named('SELECT * FROM users WHERE username = @username AND is_active = true'),
        parameters: {'username': username},
      );

      if (result.isEmpty) {
        return null;
      }

      final user = _mapRowToUser(result.first);
      return user;
    } catch (e) {
      throw DatabaseException('Failed to find user by username: $e');
    }
  }

  @override
  Future<List<User>> findAll() async {
    try {
      final result = await _db.execute('SELECT * FROM users ORDER BY created_at DESC');
      return result.map(_mapRowToUser).toList();
    } catch (e) {
      throw DatabaseException('Failed to find all users: $e');
    }
  }

  @override
  Future<User> update(User user) async {
    try {
      final result = await _db.execute(
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
      await _db.execute(
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
      final result = await _db.execute(
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
    final jwt = JwtService(_jwtSecret);
    return jwt.generateToken(
      userId: user.id,
      username: user.username,
      role: user.role.value,
    );
  }

  @override
  Future<User?> verifyToken(String token) async {
    try {
      final jwt = JwtService(_jwtSecret);
      final payload = jwt.verifyToken(token);
      if (payload == null) return null;

      final userId = payload['sub'] as String?;
      if (userId == null) return null;

      final user = await findById(userId);
      return user;
    } catch (e) {
      return null;
    }
  }

  String generateRefreshToken({required String userId}) {
    final jwt = JwtService(_jwtSecret);
    return jwt.generateRefreshToken(userId: userId);
  }

  Map<String, dynamic>? verifyRefreshToken(String token) {
    final jwt = JwtService(_jwtSecret);
    return jwt.verifyToken(token);
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
