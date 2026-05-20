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
-- WARNING: These are bcrypt hashes for TESTING ONLY.
-- In PRODUCTION, you MUST generate new secure hashes using bcrypt.
-- To generate new hashes, use: dart -c "import 'package:bcrypt/bcrypt.dart'; void main() { print(BCrypt.hashpw('your_password', BCrypt.gensalt())); }"
--
-- Default passwords (for testing):
-- admin123 for owner
-- accountant123 for accountant
-- manager123 for manager
-- mechanic123 for mechanic
-- receptionist123 for receptionist

INSERT INTO users (username, password_hash, full_name, phone, role, is_active, created_at, updated_at) VALUES
('admin', '\$2a\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'المدير العام', '+966500000001', 'OWNER', true, NOW(), NOW()),
('accountant', '\$2a\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'المحاسب', '+966500000002', 'ACCOUNTANT', true, NOW(), NOW()),
('manager', '\$2a\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'مدير العمليات', '+966500000003', 'MANAGER', true, NOW(), NOW()),
('mechanic', '\$2a\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'فني ميكانيكي', '+966500000004', 'MECHANIC', true, NOW(), NOW()),
('receptionist', '\$2a\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'موظف استقبال', '+966500000005', 'RECEPTIONIST', true, NOW(), NOW());

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

-- Vendors (الموردين)
INSERT INTO vendors (name, phone, address, tax_number) VALUES
('مورد أ للقطع الأصلية', '0911123456', 'دمشق، جوبر', '123456789'),
('مورد ب للقطع التجارية', '0922345678', 'ريف دمشق، عدرا', '987654321'),
('مورد ج للزيوت', '0933456789', 'حمص، المحطة', '456789123');

-- Sample Expenses (المصاريف)
INSERT INTO expenses (expense_date, account_id, amount, description, payment_method, created_by) VALUES
('2024-05-15', 5200, 300000, 'إيجار الكراج لشهر مايو', 'cash', NULL),
('2024-05-18', 5300, 85000, 'فاتورة كهرباء', 'cash', NULL),
('2024-05-20', 5300, 45000, 'فاتورة ماء', 'cash', NULL);

-- Bank Accounts (الحسابات البنكية)
INSERT INTO bank_accounts (account_name, account_number, bank_name, initial_balance, current_balance, account_id, is_active) VALUES
('الحساب الرئيسي', '1234567890', 'بنك سوريا', 5000000, 5000000, 1110, true),
('حساب الرواتب', '0987654321', 'بنك سوريا', 2000000, 2000000, 1110, true);

-- Payroll Settings (إعدادات الرواتب)
INSERT INTO payroll_settings (monthly_work_days, salary_payment_day) VALUES
(22, 1);

-- Fiscal Periods (الفترات المالية)
INSERT INTO fiscal_periods (name, start_date, end_date, is_closed) VALUES
('2024', '2024-01-01', '2024-12-31', false),
('Q1 2024', '2024-01-01', '2024-03-31', false),
('Q2 2024', '2024-04-01', '2024-06-30', false),
('Q3 2024', '2024-07-01', '2024-09-30', false),
('Q4 2024', '2024-10-01', '2024-12-31', false);

-- Note: The above password hashes are placeholders. 
-- In production, you must hash the actual passwords using bcrypt.
-- Example hashing command (using Dart's bcrypt package):
-- final hashedPassword = bcrypt.hashPassword(password, bcrypt.gensalt());
