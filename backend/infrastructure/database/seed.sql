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
('6100', 'تكلفة البضاعة المباعة', 'Cost of Goods Sold', NULL, 'cogs', true, NOW());

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
);

-- Default Users
-- Note: Passwords should be hashed with bcrypt in production
-- admin123 for owner
-- acc123 for accountant
-- manager123 for manager
-- mech123 for mechanic
-- recep123 for receptionist

INSERT INTO users (username, password_hash, full_name, phone, role, is_active, created_at, updated_at) VALUES
('admin', '\$2a\$10\$xLrNqK7qNqNqNqNqNqNqNu', 'المدير العام', '+966500000001', 'OWNER', true, NOW(), NOW()),
('accountant', '\$2a\$10\$xLrNqK7qNqNqNqNqNqNqNu', 'المحاسب', '+966500000002', 'ACCOUNTANT', true, NOW(), NOW()),
('manager', '\$2a\$10\$xLrNqK7qNqNqNqNqNqNqNu', 'مدير العمليات', '+966500000003', 'MANAGER', true, NOW(), NOW()),
('mechanic', '\$2a\$10\$xLrNqK7qNqNqNqNqNqNqNu', 'فني ميكانيكي', '+966500000004', 'MECHANIC', true, NOW(), NOW()),
('receptionist', '\$2a\$10\$xLrNqK7qNqNqNqNqNqNqNu', 'موظف استقبال', '+966500000005', 'RECEPTIONIST', true, NOW(), NOW());

-- Default Service Categories
INSERT INTO service_categories (name_ar, name_en, base_price, duration_minutes, is_active, created_at) VALUES
('تغيير زيت', 'Oil Change', 150.00, 30, true, NOW()),
('فحص مكابح', 'Brake Inspection', 100.00, 45, true, NOW()),
('تغيير إطارات', 'Tire Change', 200.00, 60, true, NOW()),
('فحص بطارية', 'Battery Check', 50.00, 20, true, NOW()),
('صيانة دورية', 'Regular Maintenance', 300.00, 120, true, NOW());

-- Default Spare Parts Categories
INSERT INTO spare_parts_categories (name_ar, name_en, created_at) VALUES
('زيت المحرك', 'Engine Oil', NOW()),
('إطارات', 'Tires', NOW()),
('مكابح', 'Brakes', NOW()),
('بطاريات', 'Batteries', NOW()),
('فلتر', 'Filters', NOW());

-- Note: The above password hashes are placeholders. 
-- In production, you must hash the actual passwords using bcrypt.
-- Example hashing command (using Dart's bcrypt package):
-- final hashedPassword = bcrypt.hashPassword(password, bcrypt.gensalt());
