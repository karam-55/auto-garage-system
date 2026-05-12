import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logger/logger.dart';
import 'dart:io';

class DatabaseConnection {
  static DatabaseConnection? _instance;
  late Pool _pool;
  final Logger _logger = Logger();

  DatabaseConnection._internal();

  static DatabaseConnection get instance {
    _instance ??= DatabaseConnection._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    // In production, read from environment variables directly
    // In development, try to load from .env file
    final env = DotEnv()..load();
    
    final databaseUrl = Platform.environment['DATABASE_URL'] ?? env['DATABASE_URL'];
    if (databaseUrl == null) {
      throw Exception('DATABASE_URL environment variable is not set');
    }

    // Parse DATABASE_URL safely
    final uri = Uri.parse(databaseUrl);
    final host = uri.host;
    final port = uri.port != 0 ? uri.port : 5432;
    final databaseName = uri.path.isNotEmpty ? uri.path.substring(1) : '';
    final userInfoParts = uri.userInfo.split(':');
    final username = userInfoParts.isNotEmpty ? userInfoParts[0] : '';
    final password = userInfoParts.length > 1 ? userInfoParts[1] : '';

    _pool = Pool.withEndpoints(
      [
        Endpoint(
          host: host,
          port: port,
          database: databaseName,
          username: username,
          password: password,
        ),
      ],
      settings: PoolSettings(maxConnectionCount: 20),
    );

    _logger.i('Database pool initialized (max 20 connections)');
  }

  /// Execute a single SQL query using a pooled connection.
  Future<Result> execute(dynamic sql, {Map<String, dynamic>? parameters}) async {
    if (sql is Sql) {
      return await _pool.execute(sql, parameters: parameters);
    }
    return await _pool.execute(sql.toString());
  }

  /// Run a block of code inside a database transaction.
  /// If any operation fails, the entire transaction is rolled back.
  Future<T> runInTransaction<T>(Future<T> Function(Session session) operation) async {
    return await _pool.run(operation);
  }

  Future<void> close() async {
    await _pool.close();
    _logger.i('Database pool closed');
  }

  Future<void> executeSchema() async {
    try {
      final schema = await _readSchemaFile();
      final statements = schema.split(';').where((s) => s.trim().isNotEmpty);

      for (final statement in statements) {
        await _pool.execute(statement.trim());
      }

      _logger.i('Database schema executed successfully');
    } catch (e) {
      _logger.e('Failed to execute schema: $e');
      rethrow;
    }
  }

  Future<String> _readSchemaFile() async {
    final file = File('lib/infrastructure/database/schema.sql');
    if (!await file.exists()) {
      throw Exception('Schema file not found at lib/infrastructure/database/schema.sql');
    }
    return await file.readAsString();
  }
}
