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
    final env = DotEnv()..load([allowOptional: true]);
    
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
        sslMode: SslMode.require,
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

  /// Execute a query and return results (for SELECT queries)
  Future<Result> query(String sql, {Map<String, dynamic>? substitutionValues}) async {
    if (substitutionValues != null && substitutionValues.isNotEmpty) {
      return await _pool.execute(Sql.named(sql), parameters: substitutionValues);
    }
    return await _pool.execute(sql);
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

  Future<void> executeSeed() async {
    try {
      _logger.i('Reading seed.sql file...');
      final seedSql = await _readSeedFile();
      _logger.i('Seed SQL length: ${seedSql.length} characters');
      
      if (seedSql.isEmpty) {
        _logger.w('Seed SQL is empty, skipping seed data execution');
        return;
      }
      
      final statements = seedSql.split(';').where((s) => s.trim().isNotEmpty && !s.trim().startsWith('--'));
      _logger.i('Found ${statements.length} SQL statements');

      int executed = 0;
      int failed = 0;

      for (final statement in statements) {
        try {
          await _pool.execute(statement.trim());
          executed++;
        } catch (e) {
          failed++;
          // Ignore duplicate key errors
          final errorStr = e.toString();
          if (errorStr.contains('duplicate key') || 
              errorStr.contains('unique constraint') ||
              errorStr.contains('already exists')) {
            _logger.w('Skipping duplicate data: $e');
          } else {
            _logger.e('Failed to execute seed statement: $e');
          }
        }
      }

      _logger.i('Seed data executed: $executed statements, $failed failed');
    } catch (e) {
      _logger.e('Failed to execute seed data: $e');
      // Don't rethrow - seed data is optional
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

      // Add CHECK constraint to journal_lines
      await _pool.execute('''
        ALTER TABLE journal_lines
        DROP CONSTRAINT IF EXISTS check_debit_or_credit
      ''');

      await _pool.execute('''
        ALTER TABLE journal_lines
        ADD CONSTRAINT check_debit_or_credit CHECK (debit = 0 OR credit = 0)
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

      // Add payment-related columns to booking_invoice_data for existing tables
      await _pool.execute('''
        ALTER TABLE booking_invoice_data 
        ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50) DEFAULT 'cash' CHECK (payment_method IN ('cash', 'electronic'))
      ''');

      await _pool.execute('''
        ALTER TABLE booking_invoice_data 
        ADD COLUMN IF NOT EXISTS payment_status VARCHAR(50) DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'partial', 'paid'))
      ''');

      await _pool.execute('''
        ALTER TABLE booking_invoice_data 
        ADD COLUMN IF NOT EXISTS amount_paid DECIMAL(12, 2) DEFAULT 0
      ''');

      await _pool.execute('''
        ALTER TABLE booking_invoice_data 
        ADD COLUMN IF NOT EXISTS amount_remaining DECIMAL(12, 2) DEFAULT 0
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

  Future<String> _readSeedFile() async {
    // Inline seed SQL for production compatibility
    return r'''
-- Seed Data for Garage Go Accounting System
-- This file contains default accounts, company settings, and users for production

-- Default Chart of Accounts
INSERT INTO accounts (code, name_ar, name_en, parent_id, account_type, is_active, created_at) VALUES
-- Assets
('1100', 'الصندوق', 'Cash', NULL, 'asset', true, NOW()),
('1101', 'الصندوق الرئيسي', 'Main Cash', NULL, 'asset', true, NOW()),
('1110', 'البنك', 'Bank', NULL, 'asset', true, NOW()),
('1200', 'المخزون', 'Inventory', NULL, 'asset', true, NOW()),
('1201', 'العملاء', 'Accounts Receivable', NULL, 'asset', true, NOW()),
('1210', 'السيارات', 'Vehicles', NULL, 'asset', true, NOW()),
('1220', 'القطع الغيار', 'Spare Parts', NULL, 'asset', true, NOW()),
('1300', 'المخزون (ERP)', 'ERP Inventory', NULL, 'asset', true, NOW()),
('1400', 'تحت التشغيل', 'Work In Progress', NULL, 'asset', true, NOW()),
('1500', 'الأصول الثابتة', 'Fixed Assets', NULL, 'asset', true, NOW()),
('1501', 'مجمع الإهلاك', 'Accumulated Depreciation', NULL, 'asset', true, NOW()),
-- Liabilities
('2100', 'الموردين', 'Accounts Payable', NULL, 'liability', true, NOW()),
('2101', 'الرواتب المستحقة', 'Salaries Payable', NULL, 'liability', true, NOW()),
('2200', 'الضريبة المستحقة', 'Tax Payable', NULL, 'liability', true, NOW()),
('2201', 'ضريبة المبيعات', 'Sales Tax Payable', NULL, 'liability', true, NOW()),
-- Equity
('3100', 'رأس المال', 'Capital', NULL, 'equity', true, NOW()),
('3200', 'الأرباح المحتجزة', 'Retained Earnings', NULL, 'equity', true, NOW()),
-- Revenue
('4100', 'إيرادات خدمات', 'Service Revenue', NULL, 'revenue', true, NOW()),
('4200', 'إيرادات قطع', 'Spare Parts Revenue', NULL, 'revenue', true, NOW()),
-- Expenses
('5100', 'مصروف الرواتب', 'Salaries Expense', NULL, 'expense', true, NOW()),
('5200', 'مصروف الإيجار', 'Rent Expense', NULL, 'expense', true, NOW()),
('5300', 'مصروف الكهرباء', 'Utilities Expense', NULL, 'expense', true, NOW()),
('5400', 'مصروف الصيانة', 'Maintenance Expense', NULL, 'expense', true, NOW()),
('5500', 'مصروف الإعلانات', 'Advertising Expense', NULL, 'expense', true, NOW()),
('6000', 'مصروف الإهلاك', 'Depreciation Expense', NULL, 'expense', true, NOW()),
-- COGS
('6100', 'تكلفة البضاعة المباعة', 'Cost of Goods Sold', NULL, 'cogs', true, NOW())
ON CONFLICT (code) DO NOTHING;

-- Default Company Settings
INSERT INTO company_settings (company_name, company_name_en, company_logo_url, address, phone, tax_number, fiscal_year_start, currency_code, created_at, updated_at)
VALUES (
    'كراج الذهاب',
    'Garage Go',
    NULL,
    'الرياض، المملكة العربية السعودية',
    '+966500000000',
    '3000000000',
    '2024-01-01',
    'SAR',
    NOW(),
    NOW()
)
ON CONFLICT DO NOTHING;

-- Vendors (الموردين)
INSERT INTO vendors (name, phone, address, tax_number) VALUES
('مورد أ للقطع الأصلية', '0911123456', 'دمشق، جوبر', '123456789'),
('مورد ب للقطع التجارية', '0922345678', 'ريف دمشق، عدرا', '987654321'),
('مورد ج للزيوت', '0933456789', 'حمص، المحطة', '456789123')
ON CONFLICT DO NOTHING;

-- Sample Expenses (المصاريف)
INSERT INTO expenses (expense_date, account_id, amount, description, payment_method, created_by) VALUES
('2024-05-15', 5200, 300000, 'إيجار الكراج لشهر مايو', 'cash', NULL),
('2024-05-18', 5300, 85000, 'فاتورة كهرباء', 'cash', NULL),
('2024-05-20', 5300, 45000, 'فاتورة ماء', 'cash', NULL)
ON CONFLICT DO NOTHING;

-- Bank Accounts (الحسابات البنكية)
INSERT INTO bank_accounts (account_name, account_number, bank_name, initial_balance, current_balance, account_id, is_active) VALUES
('الحساب الرئيسي', '1234567890', 'بنك سوريا', 5000000, 5000000, 1110, true),
('حساب الرواتب', '0987654321', 'بنك سوريا', 2000000, 2000000, 1110, true)
ON CONFLICT DO NOTHING;

-- Payroll Settings (إعدادات الرواتب)
INSERT INTO payroll_settings (monthly_work_days, salary_payment_day) VALUES
(22, 1)
ON CONFLICT DO NOTHING;

-- Fiscal Periods (الفترات المالية)
INSERT INTO fiscal_periods (name, start_date, end_date, is_closed) VALUES
('2024', '2024-01-01', '2024-12-31', false),
('Q1 2024', '2024-01-01', '2024-03-31', false),
('Q2 2024', '2024-04-01', '2024-06-30', false),
('Q3 2024', '2024-07-01', '2024-09-30', false),
('Q4 2024', '2024-10-01', '2024-12-31', false)
ON CONFLICT DO NOTHING;
''';
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
    source_id VARCHAR(100),
    CONSTRAINT check_debit_or_credit CHECK (debit = 0 OR credit = 0)
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
ALTER TABLE company_settings ADD COLUMN accounting_settings JSONB DEFAULT '{}'::jsonb;

-- Add salary-related columns to users table
ALTER TABLE users ADD COLUMN base_salary DECIMAL(15,2) DEFAULT 0;
ALTER TABLE users ADD COLUMN hire_date DATE;

-- Add foreign key constraint to purchase_invoice_items after inventory_variants is created
ALTER TABLE purchase_invoice_items ADD CONSTRAINT fk_purchase_invoice_items_inventory_variant 
FOREIGN KEY (inventory_variant_id) REFERENCES inventory_variants(id) ON DELETE SET NULL;

-- ========================================
-- ERP Tables
-- ========================================

-- Fixed Assets table
CREATE TABLE IF NOT EXISTS fixed_assets (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    acquisition_date DATE NOT NULL,
    acquisition_cost DECIMAL(15,2) NOT NULL,
    salvage_value DECIMAL(15,2) DEFAULT 0,
    useful_life_years INTEGER NOT NULL,
    depreciation_method VARCHAR(50) NOT NULL DEFAULT 'straight_line',
    current_net_book_value DECIMAL(15,2),
    location VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Depreciation Entries table
CREATE TABLE IF NOT EXISTS depreciation_entries (
    id SERIAL PRIMARY KEY,
    asset_id INTEGER NOT NULL REFERENCES fixed_assets(id) ON DELETE CASCADE,
    period DATE NOT NULL,
    depreciation_amount DECIMAL(15,2) NOT NULL,
    journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Maintenance Contracts table
CREATE TABLE IF NOT EXISTS maintenance_contracts (
    id SERIAL PRIMARY KEY,
    asset_id INTEGER REFERENCES fixed_assets(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
    contract_number VARCHAR(50),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    provider VARCHAR(255),
    cost DECIMAL(15,2),
    terms TEXT,
    status VARCHAR(50) DEFAULT 'active',
    service_interval_km INTEGER,
    service_interval_days INTEGER,
    last_service_km INTEGER,
    next_service_due DATE,
    notes TEXT,
    created_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Quotations table
CREATE TABLE IF NOT EXISTS quotations (
    id SERIAL PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    quotation_number VARCHAR(50) NOT NULL UNIQUE,
    quotation_date DATE NOT NULL,
    valid_until DATE,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'accepted', 'rejected', 'expired', 'converted_to_order')),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Quotation Items table
CREATE TABLE IF NOT EXISTS quotation_items (
    id SERIAL PRIMARY KEY,
    quotation_id INTEGER NOT NULL REFERENCES quotations(id) ON DELETE CASCADE,
    service_id UUID REFERENCES services(id) ON DELETE SET NULL,
    description TEXT,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    total_price DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Sales Orders table
CREATE TABLE IF NOT EXISTS sales_orders (
    id SERIAL PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    order_date DATE NOT NULL,
    quotation_id INTEGER REFERENCES quotations(id) ON DELETE SET NULL,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Sales Order Items table
CREATE TABLE IF NOT EXISTS sales_order_items (
    id SERIAL PRIMARY KEY,
    sales_order_id INTEGER NOT NULL REFERENCES sales_orders(id) ON DELETE CASCADE,
    service_id UUID REFERENCES services(id) ON DELETE SET NULL,
    description TEXT,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    total_price DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Purchase Orders table
CREATE TABLE IF NOT EXISTS purchase_orders (
    id SERIAL PRIMARY KEY,
    vendor_id INTEGER REFERENCES vendors(id) ON DELETE SET NULL,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    notes TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'received', 'cancelled')),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Purchase Order Items table
CREATE TABLE IF NOT EXISTS purchase_order_items (
    id SERIAL PRIMARY KEY,
    purchase_order_id INTEGER NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    item_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Warehouses table
CREATE TABLE IF NOT EXISTS warehouses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    manager_id UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Bill of Materials (BOM) table
CREATE TABLE IF NOT EXISTS bill_of_materials (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- BOM Items table
CREATE TABLE IF NOT EXISTS bom_items (
    id SERIAL PRIMARY KEY,
    bom_id INTEGER NOT NULL REFERENCES bill_of_materials(id) ON DELETE CASCADE,
    inventory_item_id UUID NOT NULL REFERENCES inventory_items(id),
    quantity DECIMAL(15,2) NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Manufacturing Orders table
CREATE TABLE IF NOT EXISTS manufacturing_orders (
    id SERIAL PRIMARY KEY,
    bom_id INTEGER REFERENCES bill_of_materials(id) ON DELETE SET NULL,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    order_date DATE NOT NULL,
    quantity DECIMAL(15,2) NOT NULL DEFAULT 1,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    start_date DATE,
    expected_completion_date DATE,
    actual_completion_date DATE,
    notes TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Employee Contracts table
CREATE TABLE IF NOT EXISTS employee_contracts (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    contract_number VARCHAR(50) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE,
    contract_type VARCHAR(50) NOT NULL DEFAULT 'full_time' CHECK (contract_type IN ('full_time', 'part_time', 'contract')),
    base_salary DECIMAL(15,2) NOT NULL,
    position VARCHAR(255),
    department VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'terminated', 'expired')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Leave Requests table
CREATE TABLE IF NOT EXISTS leave_requests (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    leave_type VARCHAR(50) NOT NULL CHECK (leave_type IN ('annual', 'sick', 'unpaid', 'other')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INTEGER NOT NULL,
    reason TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Performance Reviews table
CREATE TABLE IF NOT EXISTS performance_reviews (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users(id),
    review_period VARCHAR(50) NOT NULL,
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    strengths TEXT,
    areas_for_improvement TEXT,
    goals TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'reviewed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- CRM Leads table
CREATE TABLE IF NOT EXISTS crm_leads (
    id SERIAL PRIMARY KEY,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    source VARCHAR(50),
    status VARCHAR(50) NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'qualified', 'converted', 'lost')),
    estimated_value DECIMAL(15,2),
    closing_date DATE,
    assigned_to UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- CRM Activities table
CREATE TABLE IF NOT EXISTS crm_activities (
    id SERIAL PRIMARY KEY,
    lead_id INTEGER REFERENCES crm_leads(id) ON DELETE SET NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    activity_type VARCHAR(50) NOT NULL CHECK (activity_type IN ('call', 'email', 'meeting', 'visit', 'other')),
    activity_date DATE NOT NULL,
    summary TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for ERP tables
CREATE INDEX IF NOT EXISTS idx_fixed_assets_status ON fixed_assets(status);
CREATE INDEX IF NOT EXISTS idx_fixed_assets_acquisition_date ON fixed_assets(acquisition_date);
CREATE INDEX IF NOT EXISTS idx_depreciation_entries_asset_id ON depreciation_entries(asset_id);
CREATE INDEX IF NOT EXISTS idx_depreciation_entries_period ON depreciation_entries(period);
CREATE INDEX IF NOT EXISTS idx_maintenance_contracts_customer_id ON maintenance_contracts(customer_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_contracts_vehicle_id ON maintenance_contracts(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_contracts_next_service_due ON maintenance_contracts(next_service_due);
CREATE INDEX IF NOT EXISTS idx_quotations_customer_id ON quotations(customer_id);
CREATE INDEX IF NOT EXISTS idx_quotations_status ON quotations(status);
CREATE INDEX IF NOT EXISTS idx_quotations_date ON quotations(quotation_date);
CREATE INDEX IF NOT EXISTS idx_sales_orders_customer_id ON sales_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_orders_status ON sales_orders(status);
CREATE INDEX IF NOT EXISTS idx_sales_orders_date ON sales_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_vendor_id ON purchase_orders(vendor_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_status ON purchase_orders(status);
CREATE INDEX IF NOT EXISTS idx_employee_contracts_user_id ON employee_contracts(user_id);
CREATE INDEX IF NOT EXISTS idx_employee_contracts_status ON employee_contracts(status);
CREATE INDEX IF NOT EXISTS idx_leave_requests_user_id ON leave_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_status ON leave_requests(status);
CREATE INDEX IF NOT EXISTS idx_performance_reviews_user_id ON performance_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_warehouses_manager_id ON warehouses(manager_id);
CREATE INDEX IF NOT EXISTS idx_bill_of_materials_created_by ON bill_of_materials(created_by);
CREATE INDEX IF NOT EXISTS idx_bom_items_bom_id ON bom_items(bom_id);
CREATE INDEX IF NOT EXISTS idx_bom_items_inventory_item_id ON bom_items(inventory_item_id);
CREATE INDEX IF NOT EXISTS idx_manufacturing_orders_bom_id ON manufacturing_orders(bom_id);
CREATE INDEX IF NOT EXISTS idx_manufacturing_orders_status ON manufacturing_orders(status);
CREATE INDEX IF NOT EXISTS idx_manufacturing_orders_created_by ON manufacturing_orders(created_by);
CREATE INDEX IF NOT EXISTS idx_crm_leads_customer_id ON crm_leads(customer_id);
CREATE INDEX IF NOT EXISTS idx_crm_leads_assigned_to ON crm_leads(assigned_to);
CREATE INDEX IF NOT EXISTS idx_crm_leads_status ON crm_leads(status);
CREATE INDEX IF NOT EXISTS idx_crm_activities_lead_id ON crm_activities(lead_id);
CREATE INDEX IF NOT EXISTS idx_crm_activities_customer_id ON crm_activities(customer_id);
CREATE INDEX IF NOT EXISTS idx_crm_activities_created_by ON crm_activities(created_by);
CREATE INDEX IF NOT EXISTS idx_crm_activities_activity_date ON crm_activities(activity_date);
''';
  }
}
