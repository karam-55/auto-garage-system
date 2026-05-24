-- ========================================
-- Chart of Accounts Seed Data
-- Auto Garage Management System
-- ========================================

-- Clear existing accounts (optional - comment out if you want to keep existing data)
-- TRUNCATE TABLE accounts CASCADE;

-- ========================================
-- STEP 1: Insert all accounts WITHOUT parent_id first
-- ========================================
INSERT INTO accounts (code, name_ar, name_en, parent_id, account_type) VALUES
-- Level 1: Main Account Categories
('1', 'الأصول', 'Assets', NULL, 'asset'),
('2', 'الخصوم', 'Liabilities', NULL, 'liability'),
('3', 'حقوق الملكية', 'Equity', NULL, 'equity'),
('4', 'الإيرادات', 'Revenue', NULL, 'revenue'),
('5', 'المصروفات', 'Expenses', NULL, 'expense'),
('6', 'حسابات معاكسة', 'Contra Accounts', NULL, 'expense'),

-- Level 2: Sub-categories
('11', 'الأصول المتداولة', 'Current Assets', NULL, 'asset'),
('12', 'الأصول الثابتة', 'Fixed Assets', NULL, 'asset'),
('21', 'الخصوم المتداولة', 'Current Liabilities', NULL, 'liability'),
('22', 'الخصوم طويلة الأجل', 'Long-term Liabilities', NULL, 'liability'),
('41', 'إيرادات الخدمات', 'Service Revenue', NULL, 'revenue'),
('42', 'إيرادات أخرى', 'Other Revenue', NULL, 'revenue'),
('51', 'تكلفة البضاعة المباعة', 'Cost of Goods Sold', NULL, 'cogs'),
('52', 'المصروفات التشغيلية', 'Operating Expenses', NULL, 'expense'),
('53', 'مصروفات أخرى', 'Other Expenses', NULL, 'expense'),

-- Level 3: Detailed Accounts
-- Current Assets
('111', 'الصندوق', 'Cash', NULL, 'asset'),
('112', 'البنك', 'Bank', NULL, 'asset'),
('113', 'العملاء', 'Accounts Receivable', NULL, 'asset'),
('114', 'مخزون قطع الغيار', 'Spare Parts Inventory', NULL, 'asset'),
('115', 'مخزون الزيوت والسوائل', 'Oils and Fluids Inventory', NULL, 'asset'),
('116', 'مخزون الإطارات', 'Tires Inventory', NULL, 'asset'),
('117', 'العمل قيد التنفيذ', 'Work in Progress', NULL, 'asset'),
('118', 'الإيرادات المستحقة', 'Accrued Revenue', NULL, 'asset'),

-- Fixed Assets
('121', 'الأرض والمباني', 'Land and Buildings', NULL, 'asset'),
('122', 'المعدات والآلات', 'Equipment and Machinery', NULL, 'asset'),
('123', 'الأوناش والرافعات', 'Cranes and Forklifts', NULL, 'asset'),
('124', 'أجهزة الكمبيوتر', 'Computer Equipment', NULL, 'asset'),
('125', 'الأثاث والمكاتب', 'Furniture and Office Equipment', NULL, 'asset'),
('126', 'السيارات', 'Vehicles', NULL, 'asset'),
('127', 'مجمع الإهلاك', 'Accumulated Depreciation', NULL, 'asset'),

-- Current Liabilities
('211', 'الموردين', 'Accounts Payable', NULL, 'liability'),
('212', 'الرواتب المستحقة', 'Accrued Salaries', NULL, 'liability'),
('213', 'الضرائب المستحقة', 'Accrued Taxes', NULL, 'liability'),
('214', 'الإيجار المستحق', 'Accrued Rent', NULL, 'liability'),
('215', 'الكهرباء والماء', 'Utilities Payable', NULL, 'liability'),
('216', 'التأمينات الاجتماعية', 'Social Security Payable', NULL, 'liability'),

-- Long-term Liabilities
('221', 'القروض البنكي', 'Bank Loan', NULL, 'liability'),
('222', 'القروض الأخرى', 'Other Loans', NULL, 'liability'),

-- Equity
('31', 'رأس المال', 'Capital', NULL, 'equity'),
('32', 'الأرباح المحتجزة', 'Retained Earnings', NULL, 'equity'),
('33', 'أرباح العام الحالي', 'Current Year Earnings', NULL, 'equity'),
('34', 'الخسائر المتراكمة', 'Accumulated Losses', NULL, 'equity'),

-- Service Revenue
('411', 'إيرادات الصيانة العامة', 'General Maintenance Revenue', NULL, 'revenue'),
('412', 'إيرادات تغيير الزيوت', 'Oil Change Revenue', NULL, 'revenue'),
('413', 'إيرادات الإطارات', 'Tire Services Revenue', NULL, 'revenue'),
('414', 'إيرادات غسيل السيارات', 'Car Wash Revenue', NULL, 'revenue'),
('415', 'إيرادات التبريد والتكييف', 'AC Services Revenue', NULL, 'revenue'),
('416', 'إيرادات كهرباء السيارات', 'Auto Electrical Revenue', NULL, 'revenue'),
('417', 'إيرادات الميكانيكا', 'Mechanical Services Revenue', NULL, 'revenue'),
('418', 'إيرادات قطع الغيار', 'Spare Parts Sales Revenue', NULL, 'revenue'),
('419', 'إيرادات الزيوت والسوائل', 'Oils and Fluids Sales Revenue', NULL, 'revenue'),

-- Other Revenue
('421', 'إيرادات التخزين', 'Storage Revenue', NULL, 'revenue'),
('422', 'إيرادات السحب', 'Towing Revenue', NULL, 'revenue'),
('423', 'إيرادات الفحص الفني', 'Technical Inspection Revenue', NULL, 'revenue'),
('424', 'إيرادات أخرى متنوعة', 'Miscellaneous Revenue', NULL, 'revenue'),

-- Cost of Goods Sold
('511', 'تكلفة قطع الغيار المباعة', 'Cost of Spare Parts Sold', NULL, 'cogs'),
('512', 'تكلفة الزيوت والسوائل المباعة', 'Cost of Oils and Fluids Sold', NULL, 'cogs'),
('513', 'تكلفة الإطارات المباعة', 'Cost of Tires Sold', NULL, 'cogs'),

-- Operating Expenses
('521', 'الرواتب والأجور', 'Salaries and Wages', NULL, 'expense'),
('522', 'إيجار المرآب', 'Garage Rent', NULL, 'expense'),
('523', 'الكهرباء والماء', 'Electricity and Water', NULL, 'expense'),
('524', 'التأمينات', 'Insurance', NULL, 'expense'),
('525', 'الصيانة والترميم', 'Maintenance and Repairs', NULL, 'expense'),
('526', 'الإعلان والتسويق', 'Advertising and Marketing', NULL, 'expense'),
('527', 'النقل والشحن', 'Transportation and Shipping', NULL, 'expense'),
('528', 'الهاتف والإنترنت', 'Telephone and Internet', NULL, 'expense'),
('529', 'المستلزمات المكتبية', 'Office Supplies', NULL, 'expense'),
('52A', 'الإهلاك', 'Depreciation', NULL, 'expense'),
('52B', 'الضرائب والرسوم', 'Taxes and Fees', NULL, 'expense'),
('52C', 'التأمينات الاجتماعية', 'Social Security Contributions', NULL, 'expense'),

-- Other Expenses
('531', 'مصروفات متنوعة', 'Miscellaneous Expenses', NULL, 'expense'),
('532', 'مصروفات البنك', 'Bank Charges', NULL, 'expense'),
('533', 'خسائر بيع الأصول', 'Loss on Sale of Assets', NULL, 'expense'),
('534', 'الديون المعدومة', 'Bad Debts', NULL, 'expense'),

-- Contra Accounts
('61', 'مردودات المبيعات', 'Sales Returns', NULL, 'expense'),
('62', 'الخصومات المسموح بها', 'Sales Discounts', NULL, 'expense'),
('63', 'مردودات المشتريات', 'Purchase Returns', NULL, 'revenue'),
('64', 'الخصومات المكتسبة', 'Purchase Discounts', NULL, 'revenue')
ON CONFLICT (code) DO NOTHING;

-- ========================================
-- STEP 2: Update parent_id for Level 2 accounts
-- ========================================
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '1') WHERE code = '11';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '1') WHERE code = '12';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '2') WHERE code = '21';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '2') WHERE code = '22';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '4') WHERE code = '41';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '4') WHERE code = '42';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '5') WHERE code = '51';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '5') WHERE code = '52';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '5') WHERE code = '53';

-- ========================================
-- STEP 3: Update parent_id for Level 3 accounts
-- ========================================
-- Current Assets
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '11') WHERE code = '111';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '11') WHERE code = '112';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '11') WHERE code = '113';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '11') WHERE code = '114';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '11') WHERE code = '115';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '11') WHERE code = '116';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '11') WHERE code = '117';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '11') WHERE code = '118';

-- Fixed Assets
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '12') WHERE code = '121';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '12') WHERE code = '122';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '12') WHERE code = '123';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '12') WHERE code = '124';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '12') WHERE code = '125';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '12') WHERE code = '126';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '12') WHERE code = '127';

-- Current Liabilities
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '21') WHERE code = '211';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '21') WHERE code = '212';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '21') WHERE code = '213';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '21') WHERE code = '214';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '21') WHERE code = '215';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '21') WHERE code = '216';

-- Long-term Liabilities
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '22') WHERE code = '221';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '22') WHERE code = '222';

-- Equity
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '3') WHERE code = '31';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '3') WHERE code = '32';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '3') WHERE code = '33';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '3') WHERE code = '34';

-- Service Revenue
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '41') WHERE code = '411';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '41') WHERE code = '412';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '41') WHERE code = '413';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '41') WHERE code = '414';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '41') WHERE code = '415';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '41') WHERE code = '416';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '41') WHERE code = '417';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '41') WHERE code = '418';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '41') WHERE code = '419';

-- Other Revenue
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '42') WHERE code = '421';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '42') WHERE code = '422';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '42') WHERE code = '423';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '42') WHERE code = '424';

-- Cost of Goods Sold
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '51') WHERE code = '511';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '51') WHERE code = '512';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '51') WHERE code = '513';

-- Operating Expenses
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '521';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '522';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '523';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '524';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '525';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '526';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '527';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '528';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '529';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '52A';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '52B';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '52') WHERE code = '52C';

-- Other Expenses
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '53') WHERE code = '531';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '53') WHERE code = '532';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '53') WHERE code = '533';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '53') WHERE code = '534';

-- Contra Accounts
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '6') WHERE code = '61';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '6') WHERE code = '62';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '6') WHERE code = '63';
UPDATE accounts SET parent_id = (SELECT id FROM accounts WHERE code = '6') WHERE code = '64';

-- Insert fiscal period for current year
INSERT INTO fiscal_periods (name, start_date, end_date, is_closed) VALUES
('2026', '2026-01-01', '2026-12-31', FALSE)
ON CONFLICT DO NOTHING;

-- Display summary
SELECT 
    account_type,
    COUNT(*) as account_count,
    STRING_AGG(code, ', ' ORDER BY code) as account_codes
FROM accounts 
GROUP BY account_type 
ORDER BY account_type;
