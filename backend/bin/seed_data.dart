import 'package:postgres/postgres.dart';
import 'dart:io';

Future<void> main() async {
  final databaseUrl = Platform.environment['DATABASE_URL'];
  if (databaseUrl == null) {
    print('ERROR: DATABASE_URL environment variable is not set');
    exit(1);
  }

  final uri = Uri.parse(databaseUrl);
  final host = uri.host;
  final port = uri.port != 0 ? uri.port : 5432;
  final databaseName = uri.path.isNotEmpty ? uri.path.substring(1) : '';
  final userInfoParts = uri.userInfo.split(':');
  final username = userInfoParts.isNotEmpty ? userInfoParts[0] : '';
  final password = userInfoParts.length > 1 ? userInfoParts[1] : '';

  print('Connecting to database...');
  print('Host: $host');
  print('Port: $port');
  print('Database: $databaseName');
  print('Username: $username');

  final pool = Pool.withEndpoints(
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
    ),
  );

  try {
    print('Connected to database successfully!');
    
    // Read the SQL file
    final sqlFile = File('lib/infrastructure/database/sample_data.sql');
    final sqlContent = await sqlFile.readAsString();
    
    print('Executing sample data script...');
    
    // Split by semicolons and execute each statement
    final statements = sqlContent.split(';').where((s) => s.trim().isNotEmpty);
    
    int executed = 0;
    int failed = 0;
    
    for (final statement in statements) {
      final trimmedStatement = statement.trim();
      if (trimmedStatement.isEmpty) continue;
      
      try {
        await pool.execute(trimmedStatement);
        executed++;
        if (executed % 10 == 0) {
          print('Executed $executed statements...');
        }
      } catch (e) {
        failed++;
        print('Failed to execute statement: $e');
        print('Statement: ${trimmedStatement.substring(0, 100)}...');
      }
    }
    
    print('\n========================================');
    print('Sample Data Script Execution Complete');
    print('========================================');
    print('Total statements executed: $executed');
    print('Failed statements: $failed');
    print('\nSample data includes:');
    print('- 5 Users (employees)');
    print('- 10 Customers');
    print('- 10 Vehicles');
    print('- 15 Services');
    print('- 20 Inventory Items');
    print('- 18 Inventory Variants');
    print('- 16 Accounts (Chart of Accounts)');
    print('- Accounting Settings configured');
    print('- 3 Vendors');
    print('- 1 Fiscal Period');
    print('- 2 Bank Accounts');
    print('- Payroll Settings');
    print('\nNote: Journal entries, booking services, and other auto-generated data');
    print('will be created automatically when you add data through the web interface.');
    
  } catch (e) {
    print('Error: $e');
    exit(1);
  } finally {
    await pool.close();
    print('Database connection closed.');
  }
}
