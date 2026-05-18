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
CREATE TYPE IF NOT EXISTS account_type_enum AS ENUM ('asset', 'liability', 'equity', 'revenue', 'expense', 'cogs');
CREATE TABLE IF NOT EXISTS accounts (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    parent_id INT REFERENCES accounts(id) ON DELETE CASCADE,
    account_type account_type_enum NOT NULL,
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

-- Enable UUID extension (for older PostgreSQL versions compatibility)
-- Note: gen_random_uuid() is available in PostgreSQL 13+, which is the standard on modern platforms like Render
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(255) NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('OWNER', 'MANAGER', 'RECEPTIONIST', 'MECHANIC')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Vehicles table
CREATE TABLE IF NOT EXISTS vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    license_plate VARCHAR(20),
    vin VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Services table
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

-- Bookings table
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

-- Booking Services junction table
CREATE TABLE IF NOT EXISTS booking_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    price_syp DECIMAL(12, 2) NOT NULL,
    notes TEXT,
    UNIQUE(booking_id, service_id)
);

-- Mechanic Assignments table
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

-- Part Suggestions table
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

-- Company Settings table
CREATE TABLE IF NOT EXISTS company_settings (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL DEFAULT 'Garage Go',
    company_logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Insert default company settings if not exists
INSERT INTO company_settings (company_name, created_at, updated_at)
SELECT 'Garage Go', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM company_settings);

-- Inventory Items table
CREATE TABLE IF NOT EXISTS inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    unit VARCHAR(50),
    low_stock_threshold INTEGER DEFAULT 5,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Inventory Variants table
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

-- Inventory Transactions table
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

-- Booking Invoice Data table
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

-- Alerts table
CREATE TABLE IF NOT EXISTS alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50) NOT NULL CHECK (type IN ('LOW_STOCK', 'SYSTEM', 'BOOKING')),
    related_id UUID,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_vehicles_customer_id ON vehicles(customer_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_license_plate ON vehicles(license_plate);
CREATE INDEX IF NOT EXISTS idx_bookings_customer_id ON bookings(customer_id);
CREATE INDEX IF NOT EXISTS idx_bookings_vehicle_id ON bookings(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_public_token ON bookings(public_token);
CREATE INDEX IF NOT EXISTS idx_services_is_active ON services(is_active);
CREATE INDEX IF NOT EXISTS idx_booking_services_booking_id ON booking_services(booking_id);
CREATE INDEX IF NOT EXISTS idx_mechanic_assignments_booking_id ON mechanic_assignments(booking_id);
CREATE INDEX IF NOT EXISTS idx_mechanic_assignments_mechanic_user_id ON mechanic_assignments(mechanic_user_id);
CREATE INDEX IF NOT EXISTS idx_mechanic_assignments_status ON mechanic_assignments(status);
CREATE INDEX IF NOT EXISTS idx_part_suggestions_booking_id ON part_suggestions(booking_id);
CREATE INDEX IF NOT EXISTS idx_part_suggestions_status ON part_suggestions(status);

-- Inventory indexes
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
ALTER TABLE inventory_variants ADD COLUMN IF NOT EXISTS cost_price DECIMAL(12, 2) DEFAULT 0;
ALTER TABLE inventory_variants ADD COLUMN IF NOT EXISTS selling_price DECIMAL(12, 2) DEFAULT 0;
ALTER TABLE company_settings ADD COLUMN IF NOT EXISTS accounting_settings JSONB DEFAULT '{}'::jsonb;
ALTER TABLE booking_invoice_data ADD COLUMN IF NOT EXISTS journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL;

-- Add salary-related columns to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS base_salary DECIMAL(15,2) DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS hire_date DATE;

-- Add journal_entry_id to purchase_invoices and expenses
ALTER TABLE purchase_invoices ADD COLUMN IF NOT EXISTS journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL;
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL;

-- Add foreign key constraint to purchase_invoice_items after inventory_variants is created
ALTER TABLE purchase_invoice_items ADD CONSTRAINT fk_purchase_invoice_items_inventory_variant 
FOREIGN KEY (inventory_variant_id) REFERENCES inventory_variants(id) ON DELETE SET NULL;
