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
        try {
          await _pool.execute(statement.trim());
        } catch (e) {
          // Ignore errors for columns/constraints that already exist
          final errorStr = e.toString();
          if (errorStr.contains('already exists') || 
              errorStr.contains('duplicate_column') ||
              errorStr.contains('duplicate_constraint')) {
            _logger.w('Skipping existing column/constraint: $e');
          } else {
            rethrow;
          }
        }
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
    // Inline schema for production compatibility
    // Note: Supabase uses pgcrypto with gen_random_uuid() instead of uuid-ossp
    return r'''
-- ========================================
-- Core System Tables (must be created first)
-- ========================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(255) NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('OWNER', 'MANAGER', 'MANAGER_SALES', 'MANAGER_WAREHOUSE', 'RECEPTIONIST', 'MECHANIC', 'ACCOUNTANT', 'HR_MANAGER')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ========================================
-- Accounting System Tables
-- ========================================

-- 1.1.1 Fiscal Periods
CREATE TABLE IF NOT EXISTS fiscal_periods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_closed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 1.1.2 Chart of Accounts
-- Note: account_type_enum is created in migrations
CREATE TABLE IF NOT EXISTS accounts (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    parent_id INT REFERENCES accounts(id) ON DELETE CASCADE,
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('asset', 'liability', 'equity', 'revenue', 'expense', 'cogs')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 1.1.3 Journal Entries
CREATE TABLE IF NOT EXISTS journal_entries (
    id SERIAL PRIMARY KEY,
    entry_date DATE NOT NULL,
    reference VARCHAR(50),
    description TEXT,
    is_reversing BOOLEAN DEFAULT FALSE,
    reversing_date DATE,
    is_reversed BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    fiscal_period_id INT REFERENCES fiscal_periods(id)
);

-- 1.1.4 Journal Lines (debit/credit lines)
CREATE TABLE IF NOT EXISTS journal_lines (
    id SERIAL PRIMARY KEY,
    entry_id INT REFERENCES journal_entries(id) ON DELETE CASCADE,
    account_id INT REFERENCES accounts(id),
    debit DECIMAL(15,2) DEFAULT 0,
    credit DECIMAL(15,2) DEFAULT 0,
    description TEXT,
    source_type VARCHAR(50),
    source_id VARCHAR(100)
);

-- 1.1.5 Bank Accounts and Cash
CREATE TABLE IF NOT EXISTS bank_accounts (
    id SERIAL PRIMARY KEY,
    account_name VARCHAR(255) NOT NULL,
    account_number VARCHAR(100),
    bank_name VARCHAR(255),
    initial_balance DECIMAL(15,2) DEFAULT 0,
    current_balance DECIMAL(15,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    account_id INT REFERENCES accounts(id)
);

-- 1.1.6 Bank Reconciliations
CREATE TABLE IF NOT EXISTS bank_reconciliations (
    id SERIAL PRIMARY KEY,
    bank_account_id INT REFERENCES bank_accounts(id),
    statement_date DATE NOT NULL,
    statement_balance DECIMAL(15,2) NOT NULL,
    reconciled_balance DECIMAL(15,2),
    is_done BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS reconciliation_lines (
    id SERIAL PRIMARY KEY,
    reconciliation_id INT REFERENCES bank_reconciliations(id),
    journal_line_id INT REFERENCES journal_lines(id),
    is_matched BOOLEAN DEFAULT TRUE
);

-- 1.1.7 Vendors
CREATE TABLE IF NOT EXISTS vendors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    tax_number VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 1.1.8 Purchase Invoices
CREATE TABLE IF NOT EXISTS purchase_invoices (
    id SERIAL PRIMARY KEY,
    vendor_id INT REFERENCES vendors(id),
    invoice_number VARCHAR(50) NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE,
    total_amount DECIMAL(15,2) NOT NULL,
    paid_amount DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'unpaid',
    journal_entry_id INT REFERENCES journal_entries(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS purchase_invoice_items (
    id SERIAL PRIMARY KEY,
    invoice_id INT REFERENCES purchase_invoices(id),
    inventory_variant_id UUID,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL
);

-- 1.1.9 Operating Expenses
CREATE TABLE IF NOT EXISTS expenses (
    id SERIAL PRIMARY KEY,
    expense_date DATE NOT NULL,
    account_id INT REFERENCES accounts(id),
    amount DECIMAL(15,2) NOT NULL,
    description TEXT,
    payment_method VARCHAR(50),
    attachment_url TEXT,
    journal_entry_id INT REFERENCES journal_entries(id) ON DELETE SET NULL,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 1.1.10 Payroll Settings and Salary Payments
CREATE TABLE IF NOT EXISTS payroll_settings (
    id SERIAL PRIMARY KEY,
    monthly_work_days INT DEFAULT 30,
    salary_payment_day INT DEFAULT 28
);
CREATE TABLE IF NOT EXISTS salary_payments (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    month_year DATE NOT NULL,
    base_salary DECIMAL(15,2),
    working_days INT,
    bonuses DECIMAL(15,2) DEFAULT 0,
    deductions DECIMAL(15,2) DEFAULT 0,
    net_salary DECIMAL(15,2),
    payment_date DATE,
    is_paid BOOLEAN DEFAULT FALSE,
    journal_entry_id INT REFERENCES journal_entries(id)
);

-- ========================================
-- Core System Tables
-- ========================================

CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    license_plate VARCHAR(20),
    vin VARCHAR(50),
    public_car_id VARCHAR(255) UNIQUE NOT NULL DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_syp DECIMAL(12, 2) NOT NULL,
    estimated_duration_minutes INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'IN_PROGRESS', 'WAITING_PARTS', 'READY', 'DELIVERED', 'CANCELLED')),
    public_token VARCHAR(255) UNIQUE NOT NULL,
    notes TEXT,
    estimated_completion_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS booking_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    price_syp DECIMAL(12, 2) NOT NULL,
    notes TEXT,
    UNIQUE(booking_id, service_id)
);

CREATE TABLE IF NOT EXISTS mechanic_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    mechanic_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'ASSIGNED' CHECK (status IN ('ASSIGNED', 'IN_PROGRESS', 'WAITING_PARTS', 'READY', 'DELIVERED')),
    notes TEXT,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(booking_id)
);

CREATE TABLE IF NOT EXISTS part_suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    mechanic_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('ORIGINAL', 'COMMERCIAL', 'USED')),
    description TEXT NOT NULL,
    price_syp DECIMAL(12, 2),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING_CUSTOMER_APPROVAL' CHECK (status IN ('PENDING_CUSTOMER_APPROVAL', 'APPROVED', 'REJECTED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS company_settings (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL DEFAULT 'Garage Go',
    company_logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

INSERT INTO company_settings (company_name, created_at, updated_at)
SELECT 'Garage Go', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM company_settings);

CREATE TABLE IF NOT EXISTS inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    unit VARCHAR(50),
    low_stock_threshold INTEGER DEFAULT 5,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS inventory_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    variant_type VARCHAR(50) NOT NULL CHECK (variant_type IN ('ORIGINAL', 'COMMERCIAL', 'USED')),
    quantity INTEGER DEFAULT 0,
    cost_price DECIMAL(12, 2) DEFAULT 0,
    selling_price DECIMAL(12, 2) DEFAULT 0,
    supplier VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS inventory_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
    variant_id UUID NOT NULL REFERENCES inventory_variants(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    mechanic_id UUID REFERENCES users(id) ON DELETE SET NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('CONSUME', 'ADD', 'RETURN')),
    quantity INTEGER NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS booking_invoice_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE UNIQUE,
    services_snapshot JSONB,
    parts_snapshot JSONB,
    total_price DECIMAL(12, 2) DEFAULT 0,
    invoice_created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    public_token VARCHAR(255),
    qr_code_url TEXT,
    journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50) NOT NULL CHECK (type IN ('LOW_STOCK', 'SYSTEM', 'BOOKING')),
    related_id UUID,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_vehicles_customer_id ON vehicles(customer_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_license_plate ON vehicles(license_plate);
CREATE INDEX IF NOT EXISTS idx_vehicles_public_car_id ON vehicles(public_car_id);
CREATE INDEX IF NOT EXISTS idx_bookings_customer_id ON bookings(customer_id);
CREATE INDEX IF NOT EXISTS idx_bookings_vehicle_id ON bookings(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings(created_at);

CREATE INDEX IF NOT EXISTS idx_booking_services_booking_id ON booking_services(booking_id);
CREATE INDEX IF NOT EXISTS idx_booking_services_service_id ON booking_services(service_id);

CREATE INDEX IF NOT EXISTS idx_mechanic_assignments_booking_id ON mechanic_assignments(booking_id);
CREATE INDEX IF NOT EXISTS idx_mechanic_assignments_mechanic_user_id ON mechanic_assignments(mechanic_user_id);
CREATE INDEX IF NOT EXISTS idx_mechanic_assignments_status ON mechanic_assignments(status);

CREATE INDEX IF NOT EXISTS idx_part_suggestions_booking_id ON part_suggestions(booking_id);
CREATE INDEX IF NOT EXISTS idx_part_suggestions_mechanic_user_id ON part_suggestions(mechanic_user_id);
CREATE INDEX IF NOT EXISTS idx_part_suggestions_status ON part_suggestions(status);

CREATE INDEX IF NOT EXISTS idx_inventory_items_category ON inventory_items(category);
CREATE INDEX IF NOT EXISTS idx_inventory_variants_item_id ON inventory_variants(item_id);
CREATE INDEX IF NOT EXISTS idx_inventory_variants_variant_type ON inventory_variants(variant_type);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_item_id ON inventory_transactions(item_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_variant_id ON inventory_transactions(variant_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_booking_id ON inventory_transactions(booking_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_mechanic_id ON inventory_transactions(mechanic_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_type ON inventory_transactions(type);
CREATE INDEX IF NOT EXISTS idx_booking_invoice_data_booking_id ON booking_invoice_data(booking_id);
CREATE INDEX IF NOT EXISTS idx_alerts_type ON alerts(type);
CREATE INDEX IF NOT EXISTS idx_alerts_is_read ON alerts(is_read);

-- Add missing columns to existing tables
ALTER TABLE inventory_variants ADD COLUMN cost_price DECIMAL(12, 2) DEFAULT 0;
ALTER TABLE inventory_variants ADD COLUMN selling_price DECIMAL(12, 2) DEFAULT 0;
ALTER TABLE company_settings ADD COLUMN accounting_settings JSONB DEFAULT '{}'::jsonb;
ALTER TABLE booking_invoice_data ADD COLUMN journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL;

-- Add salary-related columns to users table
ALTER TABLE users ADD COLUMN base_salary DECIMAL(15,2) DEFAULT 0;
ALTER TABLE users ADD COLUMN hire_date DATE;

-- Add journal_entry_id to purchase_invoices and expenses
ALTER TABLE purchase_invoices ADD COLUMN journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL;
ALTER TABLE expenses ADD COLUMN journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL;

-- Add foreign key constraint to purchase_invoice_items after inventory_variants is created
ALTER TABLE purchase_invoice_items ADD CONSTRAINT fk_purchase_invoice_items_inventory_variant 
FOREIGN KEY (inventory_variant_id) REFERENCES inventory_variants(id) ON DELETE SET NULL;
''';
  }
}
