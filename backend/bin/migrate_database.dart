import 'package:postgres/postgres.dart';
import 'package:supabase/supabase.dart';
import 'dart:io';

/// Migration script to transfer data from Supabase to Render PostgreSQL
/// 
/// Usage:
/// 1. Set environment variables for both databases
/// 2. Run: dart run bin/migrate_database.dart

void main(List<String> args) async {
  print('Starting database migration from Supabase to Render...');
  
  // Source: Supabase (remove /rest/v1/ from the end)
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? 'https://epiqlptgiqskizfgmagj.supabase.co';
  final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwaXFscHRnaXFza2l6ZmdtYWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTY2ODgsImV4cCI6MjA5NDE5MjY4OH0.9__a_Y3mMvpH456Go4MF9TKmObytZO0bOF761wagGuY';
  
  // Destination: Render PostgreSQL
  final renderDbUrl = Platform.environment['RENDER_DATABASE_URL'] ?? 'postgresql://garage_user:xOqMzT1nTPbHlTWLkpfgRC3Q8bMuoAf8@dpg-d824opgjs32c73dm9fs0-a/auto_garage_9ebq';
  
  print('Supabase URL: $supabaseUrl');
  print('Render DB URL: $renderDbUrl');
  
  if (supabaseKey.contains('YOUR_')) {
    print('ERROR: Please set SUPABASE_ANON_KEY environment variable');
    return;
  }
  
  try {
    // Initialize Supabase client
    final supabase = SupabaseClient(supabaseUrl, supabaseKey);
    
    // Connect to Render PostgreSQL
    final renderDb = await Connection.open(
      Endpoint(
        host: 'dpg-d824opgjs32c73dm9fs0-a',
        port: 5432,
        database: 'auto_garage_9ebq',
        username: 'garage_user',
        password: 'xOqMzT1nTPbHlTWLkpfgRC3Q8bMuoAf8',
      ),
      settings: ConnectionSettings(sslMode: SslMode.require),
    );
    
    print('Connected to Render PostgreSQL');
    
    // Migrate tables
    await migrateUsers(supabase, renderDb);
    await migrateCustomers(supabase, renderDb);
    await migrateVehicles(supabase, renderDb);
    await migrateBookings(supabase, renderDb);
    await migrateMechanicAssignments(supabase, renderDb);
    await migratePartSuggestions(supabase, renderDb);
    await migrateRepairs(supabase, renderDb);
    
    await renderDb.close();
    print('Migration completed successfully!');
  } catch (e) {
    print('Migration failed: $e');
  }
}

Future<void> migrateUsers(SupabaseClient supabase, Connection renderDb) async {
  print('\nMigrating users...');
  
  // Fetch from Supabase
  final response = await supabase.from('users').select('*');
  final users = response as List;
  
  print('Found ${users.length} users');
  
  // Create table if not exists
  await renderDb.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id UUID PRIMARY KEY,
      full_name VARCHAR(255) NOT NULL,
      username VARCHAR(100) UNIQUE NOT NULL,
      password_hash VARCHAR(255) NOT NULL,
      role VARCHAR(50) NOT NULL,
      is_active BOOLEAN DEFAULT true,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE
    )
  ''');
  
  // Insert into Render
  for (var user in users) {
    await renderDb.execute('''
      INSERT INTO users (id, full_name, username, password_hash, role, is_active, created_at, updated_at)
      VALUES (@id, @fullName, @username, @passwordHash, @role, @isActive, @createdAt, @updatedAt)
      ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        username = EXCLUDED.username,
        password_hash = EXCLUDED.password_hash,
        role = EXCLUDED.role,
        is_active = EXCLUDED.is_active,
        updated_at = EXCLUDED.updated_at
    ''', parameters: {
      'id': user['id'],
      'fullName': user['full_name'],
      'username': user['username'],
      'passwordHash': user['password_hash'],
      'role': user['role'],
      'isActive': user['is_active'] ?? true,
      'createdAt': user['created_at'],
      'updatedAt': user['updated_at'],
    });
  }
  
  print('Users migrated successfully');
}

Future<void> migrateCustomers(SupabaseClient supabase, Connection renderDb) async {
  print('\nMigrating customers...');
  
  final response = await supabase.from('customers').select('*');
  final customers = response as List;
  
  print('Found ${customers.length} customers');
  
  await renderDb.execute('''
    CREATE TABLE IF NOT EXISTS customers (
      id UUID PRIMARY KEY,
      full_name VARCHAR(255) NOT NULL,
      phone VARCHAR(20) NOT NULL,
      address TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE
    )
  ''');
  
  for (var customer in customers) {
    await renderDb.execute('''
      INSERT INTO customers (id, full_name, phone, address, created_at, updated_at)
      VALUES (@id, @fullName, @phone, @address, @createdAt, @updatedAt)
      ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        phone = EXCLUDED.phone,
        address = EXCLUDED.address,
        updated_at = EXCLUDED.updated_at
    ''', parameters: {
      'id': customer['id'],
      'fullName': customer['full_name'],
      'phone': customer['phone'],
      'address': customer['address'],
      'createdAt': customer['created_at'],
      'updatedAt': customer['updated_at'],
    });
  }
  
  print('Customers migrated successfully');
}

Future<void> migrateVehicles(SupabaseClient supabase, Connection renderDb) async {
  print('\nMigrating vehicles...');
  
  final response = await supabase.from('vehicles').select('*');
  final vehicles = response as List;
  
  print('Found ${vehicles.length} vehicles');
  
  await renderDb.execute('''
    CREATE TABLE IF NOT EXISTS vehicles (
      id UUID PRIMARY KEY,
      customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
      make VARCHAR(100) NOT NULL,
      model VARCHAR(100) NOT NULL,
      year INTEGER NOT NULL,
      license_plate VARCHAR(20),
      vin VARCHAR(50),
      public_car_id VARCHAR(255) UNIQUE NOT NULL DEFAULT '',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE
    )
  ''');
  
  for (var vehicle in vehicles) {
    await renderDb.execute('''
      INSERT INTO vehicles (id, customer_id, make, model, year, license_plate, vin, public_car_id, created_at, updated_at)
      VALUES (@id, @customerId, @make, @model, @year, @licensePlate, @vin, @publicCarId, @createdAt, @updatedAt)
      ON CONFLICT (id) DO UPDATE SET
        customer_id = EXCLUDED.customer_id,
        make = EXCLUDED.make,
        model = EXCLUDED.model,
        year = EXCLUDED.year,
        license_plate = EXCLUDED.license_plate,
        vin = EXCLUDED.vin,
        public_car_id = EXCLUDED.public_car_id,
        updated_at = EXCLUDED.updated_at
    ''', parameters: {
      'id': vehicle['id'],
      'customerId': vehicle['customer_id'],
      'make': vehicle['make'],
      'model': vehicle['model'],
      'year': vehicle['year'],
      'licensePlate': vehicle['license_plate'],
      'vin': vehicle['vin'],
      'publicCarId': vehicle['public_car_id'],
      'createdAt': vehicle['created_at'],
      'updatedAt': vehicle['updated_at'],
    });
  }
  
  print('Vehicles migrated successfully');
}

Future<void> migrateBookings(SupabaseClient supabase, Connection renderDb) async {
  print('\nMigrating bookings...');
  
  final response = await supabase.from('bookings').select('*');
  final bookings = response as List;
  
  print('Found ${bookings.length} bookings');
  
  await renderDb.execute('''
    CREATE TABLE IF NOT EXISTS bookings (
      id UUID PRIMARY KEY,
      customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
      vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
      status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
      public_token VARCHAR(255) UNIQUE NOT NULL,
      notes TEXT,
      estimated_completion_date TIMESTAMP WITH TIME ZONE,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE
    )
  ''');
  
  for (var booking in bookings) {
    await renderDb.execute('''
      INSERT INTO bookings (id, customer_id, vehicle_id, status, public_token, notes, estimated_completion_date, created_at, updated_at)
      VALUES (@id, @customerId, @vehicleId, @status, @publicToken, @notes, @estimatedCompletionDate, @createdAt, @updatedAt)
      ON CONFLICT (id) DO UPDATE SET
        customer_id = EXCLUDED.customer_id,
        vehicle_id = EXCLUDED.vehicle_id,
        status = EXCLUDED.status,
        public_token = EXCLUDED.public_token,
        notes = EXCLUDED.notes,
        estimated_completion_date = EXCLUDED.estimated_completion_date,
        updated_at = EXCLUDED.updated_at
    ''', parameters: {
      'id': booking['id'],
      'customerId': booking['customer_id'],
      'vehicleId': booking['vehicle_id'],
      'status': booking['status'],
      'publicToken': booking['public_token'],
      'notes': booking['notes'],
      'estimatedCompletionDate': booking['estimated_completion_date'],
      'createdAt': booking['created_at'],
      'updatedAt': booking['updated_at'],
    });
  }
  
  print('Bookings migrated successfully');
}

Future<void> migrateMechanicAssignments(SupabaseClient supabase, Connection renderDb) async {
  print('\nMigrating mechanic_assignments...');
  
  final response = await supabase.from('mechanic_assignments').select('*');
  final assignments = response as List;
  
  print('Found ${assignments.length} assignments');
  
  await renderDb.execute('''
    CREATE TABLE IF NOT EXISTS mechanic_assignments (
      id UUID PRIMARY KEY,
      booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
      mechanic_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      status VARCHAR(50) NOT NULL DEFAULT 'ASSIGNED',
      notes TEXT,
      assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE,
      UNIQUE(booking_id)
    )
  ''');
  
  for (var assignment in assignments) {
    await renderDb.execute('''
      INSERT INTO mechanic_assignments (id, booking_id, mechanic_user_id, status, notes, assigned_at, updated_at)
      VALUES (@id, @bookingId, @mechanicUserId, @status, @notes, @assignedAt, @updatedAt)
      ON CONFLICT (id) DO UPDATE SET
        booking_id = EXCLUDED.booking_id,
        mechanic_user_id = EXCLUDED.mechanic_user_id,
        status = EXCLUDED.status,
        notes = EXCLUDED.notes,
        assigned_at = EXCLUDED.assigned_at,
        updated_at = EXCLUDED.updated_at
    ''', parameters: {
      'id': assignment['id'],
      'bookingId': assignment['booking_id'],
      'mechanicUserId': assignment['mechanic_user_id'],
      'status': assignment['status'],
      'notes': assignment['notes'],
      'assignedAt': assignment['assigned_at'],
      'updatedAt': assignment['updated_at'],
    });
  }
  
  print('Mechanic assignments migrated successfully');
}

Future<void> migratePartSuggestions(SupabaseClient supabase, Connection renderDb) async {
  print('\nMigrating part_suggestions...');
  
  final response = await supabase.from('part_suggestions').select('*');
  final suggestions = response as List;
  
  print('Found ${suggestions.length} part suggestions');
  
  await renderDb.execute('''
    CREATE TABLE IF NOT EXISTS part_suggestions (
      id UUID PRIMARY KEY,
      booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
      mechanic_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      type VARCHAR(50) NOT NULL,
      description TEXT NOT NULL,
      price_syp DECIMAL(12, 2),
      status VARCHAR(50) NOT NULL DEFAULT 'PENDING_CUSTOMER_APPROVAL',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE
    )
  ''');
  
  for (var suggestion in suggestions) {
    await renderDb.execute('''
      INSERT INTO part_suggestions (id, booking_id, mechanic_user_id, type, description, price_syp, status, created_at, updated_at)
      VALUES (@id, @bookingId, @mechanicUserId, @type, @description, @priceSyp, @status, @createdAt, @updatedAt)
      ON CONFLICT (id) DO UPDATE SET
        booking_id = EXCLUDED.booking_id,
        mechanic_user_id = EXCLUDED.mechanic_user_id,
        type = EXCLUDED.type,
        description = EXCLUDED.description,
        price_syp = EXCLUDED.price_syp,
        status = EXCLUDED.status,
        updated_at = EXCLUDED.updated_at
    ''', parameters: {
      'id': suggestion['id'],
      'bookingId': suggestion['booking_id'],
      'mechanicUserId': suggestion['mechanic_user_id'],
      'type': suggestion['type'],
      'description': suggestion['description'],
      'priceSyp': suggestion['price_syp'],
      'status': suggestion['status'],
      'createdAt': suggestion['created_at'],
      'updatedAt': suggestion['updated_at'],
    });
  }
  
  print('Part suggestions migrated successfully');
}

Future<void> migrateRepairs(SupabaseClient supabase, Connection renderDb) async {
  print('\nMigrating repairs...');
  
  final response = await supabase.from('repairs').select('*');
  final repairs = response as List;
  
  print('Found ${repairs.length} repairs');
  
  await renderDb.execute('''
    CREATE TABLE IF NOT EXISTS repairs (
      id UUID PRIMARY KEY,
      booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
      mechanic_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      description TEXT NOT NULL,
      status VARCHAR(50) NOT NULL,
      cost DECIMAL(12, 2),
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE
    )
  ''');
  
  for (var repair in repairs) {
    await renderDb.execute('''
      INSERT INTO repairs (id, booking_id, mechanic_user_id, description, status, cost, created_at, updated_at)
      VALUES (@id, @bookingId, @mechanicUserId, @description, @status, @cost, @createdAt, @updatedAt)
      ON CONFLICT (id) DO UPDATE SET
        booking_id = EXCLUDED.booking_id,
        mechanic_user_id = EXCLUDED.mechanic_user_id,
        description = EXCLUDED.description,
        status = EXCLUDED.status,
        cost = EXCLUDED.cost,
        updated_at = EXCLUDED.updated_at
    ''', parameters: {
      'id': repair['id'],
      'bookingId': repair['booking_id'],
      'mechanicUserId': repair['mechanic_user_id'],
      'description': repair['description'],
      'status': repair['status'],
      'cost': repair['cost'],
      'createdAt': repair['created_at'],
      'updatedAt': repair['updated_at'],
    });
  }
  
  print('Repairs migrated successfully');
}
