import '../database/database_connection.dart';
import '../repositories/account_repository_impl.dart';
import '../../domain/entities/account.dart';

class AccountingSeeder {
  final DatabaseConnection _db;
  late final AccountRepositoryImpl _accountRepository;

  AccountingSeeder(this._db) {
    _accountRepository = AccountRepositoryImpl(_db);
  }

  Future<void> seedDefaultAccounts() async {
    final existingAccounts = await _accountRepository.findAll();
    
    // Check if default accounts already exist
    final hasDefaultAccounts = existingAccounts.any((acc) => 
      acc.code.startsWith('4') || acc.code.startsWith('5') || acc.code.startsWith('6')
    );

    if (hasDefaultAccounts) {
      print('Default accounting accounts already exist, skipping seeding.');
      return;
    }

    print('Seeding default accounting accounts...');

    // Create default chart of accounts
    final accounts = [
      // Assets (1xxx)
      Account(
        id: 0,
        code: '1000',
        nameAr: 'الأصول',
        nameEn: 'Assets',
        parentId: null,
        accountType: AccountType.asset,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      Account(
        id: 0,
        code: '1100',
        nameAr: 'الصندوق والبنك',
        nameEn: 'Cash and Bank',
        parentId: null, // Will be updated after parent creation
        accountType: AccountType.asset,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      Account(
        id: 0,
        code: '1101',
        nameAr: 'الصندوق',
        nameEn: 'Cash',
        parentId: null, // Will be updated after parent creation
        accountType: AccountType.asset,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      Account(
        id: 0,
        code: '1200',
        nameAr: 'العملاء (ذمم مدينة)',
        nameEn: 'Accounts Receivable',
        parentId: null,
        accountType: AccountType.asset,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      Account(
        id: 0,
        code: '1300',
        nameAr: 'المخزون',
        nameEn: 'Inventory',
        parentId: null,
        accountType: AccountType.asset,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      
      // Liabilities (2xxx)
      Account(
        id: 0,
        code: '2000',
        nameAr: 'الخصوم',
        nameEn: 'Liabilities',
        parentId: null,
        accountType: AccountType.liability,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      Account(
        id: 0,
        code: '2100',
        nameAr: 'الموردين (ذمم دائنة)',
        nameEn: 'Accounts Payable',
        parentId: null,
        accountType: AccountType.liability,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      
      // Equity (3xxx)
      Account(
        id: 0,
        code: '3000',
        nameAr: 'حقوق الملكية',
        nameEn: 'Equity',
        parentId: null,
        accountType: AccountType.equity,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      
      // Revenue (4xxx)
      Account(
        id: 0,
        code: '4000',
        nameAr: 'الإيرادات',
        nameEn: 'Revenue',
        parentId: null,
        accountType: AccountType.revenue,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      Account(
        id: 0,
        code: '4100',
        nameAr: 'إيرادات الخدمات',
        nameEn: 'Service Revenue',
        parentId: null,
        accountType: AccountType.revenue,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      Account(
        id: 0,
        code: '4200',
        nameAr: 'إيرادات قطع الغيار',
        nameEn: 'Parts Revenue',
        parentId: null,
        accountType: AccountType.revenue,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      
      // COGS (5xxx)
      Account(
        id: 0,
        code: '5000',
        nameAr: 'تكلفة البضاعة المباعة',
        nameEn: 'Cost of Goods Sold',
        parentId: null,
        accountType: AccountType.cogs,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      Account(
        id: 0,
        code: '5100',
        nameAr: 'تكلفة قطع الغيار',
        nameEn: 'Parts COGS',
        parentId: null,
        accountType: AccountType.cogs,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      
      // Expenses (6xxx)
      Account(
        id: 0,
        code: '6000',
        nameAr: 'المصروفات',
        nameEn: 'Expenses',
        parentId: null,
        accountType: AccountType.expense,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      Account(
        id: 0,
        code: '6100',
        nameAr: 'مصروفات الرواتب',
        nameEn: 'Salary Expenses',
        parentId: null,
        accountType: AccountType.expense,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
      Account(
        id: 0,
        code: '6200',
        nameAr: 'مصروفات أخرى',
        nameEn: 'Other Expenses',
        parentId: null,
        accountType: AccountType.expense,
        isActive: true,
        createdAt: DateTime.now().toUtc(),
      ),
    ];

    // First create parent accounts
    final createdAccounts = <String, Account>{};
    for (final account in accounts) {
      if (account.parentId == null) {
        final created = await _accountRepository.create(account);
        createdAccounts[created.code] = created;
      }
    }

    // Then create child accounts with proper parent IDs
    for (final account in accounts) {
      if (account.parentId == null && account.code.length > 4) {
        // Find parent by code prefix (e.g., 1101's parent is 1100)
        final parentCode = account.code.substring(0, 4);
        final parent = createdAccounts[parentCode];
        if (parent != null) {
          final childAccount = account.copyWith(parentId: parent.id);
          await _accountRepository.create(childAccount);
        }
      }
    }

    print('Default accounting accounts seeded successfully.');
  }

  Future<Map<String, int>> getDefaultAccountIds() async {
    final accounts = await _accountRepository.findAll();
    final accountMap = <String, int>{};
    
    for (final account in accounts) {
      if (account.code == '4100') accountMap['revenue_service'] = account.id;
      if (account.code == '4200') accountMap['revenue_parts'] = account.id;
      if (account.code == '5100') accountMap['cogs_parts'] = account.id;
      if (account.code == '1300') accountMap['inventory'] = account.id;
      if (account.code == '1101') accountMap['cash'] = account.id;
      if (account.code == '1200') accountMap['receivable'] = account.id;
      if (account.code == '2100') accountMap['payable'] = account.id;
    }
    
    return accountMap;
  }
}
