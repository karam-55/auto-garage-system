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

  Pool get pool => _pool;

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
      settings: PoolSettings(
        maxConnectionCount: 20,
        sslMode: SslMode.disable,
      ),
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
      // Run migrations first for existing databases
      await _runMigrations();

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

  Future<void> _runMigrations() async {
    try {
      // Add new ERP roles to users table
      await _pool.execute('''
        ALTER TABLE users
        DROP CONSTRAINT IF EXISTS users_role_check
      ''');

      await _pool.execute('''
        ALTER TABLE users
        ADD CONSTRAINT users_role_check
        CHECK (role IN ('OWNER', 'MANAGER', 'MANAGER_SALES', 'MANAGER_WAREHOUSE', 'RECEPTIONIST', 'MECHANIC', 'ACCOUNTANT', 'HR_MANAGER'))
      ''');

      // Add public_car_id column if it doesn't exist
      await _pool.execute('''
        ALTER TABLE vehicles 
        ADD COLUMN IF NOT EXISTS public_car_id VARCHAR(255) UNIQUE NOT NULL DEFAULT ''
      ''');

      // Generate public_car_id for existing vehicles that don't have one
      await _pool.execute('''
        UPDATE vehicles 
        SET public_car_id = 'CAR-' || md5(random()::text) 
        WHERE public_car_id = ''
      ''');

      // Add index if it doesn't exist
      await _pool.execute('''
        CREATE INDEX IF NOT EXISTS idx_vehicles_public_car_id ON vehicles(public_car_id)
      ''');

      // Create company_settings table if it doesn't exist
      await _pool.execute('''
        CREATE TABLE IF NOT EXISTS company_settings (
          id SERIAL PRIMARY KEY,
          company_name VARCHAR(255) NOT NULL DEFAULT 'Garage Go',
          company_logo_url TEXT,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP WITH TIME ZONE
        )
      ''');

      // Insert default company settings if not exists
      await _pool.execute('''
        INSERT INTO company_settings (company_name, created_at, updated_at)
        SELECT 'Garage Go', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        WHERE NOT EXISTS (SELECT 1 FROM company_settings)
      ''');

      // Add invoice_generated column to bookings table
      await _pool.execute('''
        ALTER TABLE bookings 
        ADD COLUMN IF NOT EXISTS invoice_generated BOOLEAN DEFAULT false
      ''');

      // Add public_token and qr_code_url columns to booking_invoice_data for existing tables
      await _pool.execute('''
        ALTER TABLE booking_invoice_data 
        ADD COLUMN IF NOT EXISTS public_token VARCHAR(255)
      ''');

      await _pool.execute('''
        ALTER TABLE booking_invoice_data 
        ADD COLUMN IF NOT EXISTS qr_code_url TEXT
      ''');

      // Note: Inventory tables (inventory_items, inventory_variants, inventory_transactions,
      // booking_invoice_data, alerts) are now defined in schema.sql and are created
      // during schema execution. Dynamic creation has been removed for better maintainability.

      _logger.i('Migrations executed successfully');
    } catch (e) {
      _logger.e('Failed to execute migrations: $e');
      // Don't rethrow - migrations are optional
    }
  }

  Future<String> _readSchemaFile() async {
    final schemaFile = File('lib/infrastructure/database/schema.sql');
    if (await schemaFile.exists()) {
      return await schemaFile.readAsString();
    } else {
      throw Exception('Schema file not found: lib/infrastructure/database/schema.sql');
    }
  }
}
