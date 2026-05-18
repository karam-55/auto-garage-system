import '../../domain/repositories/company_settings_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/entities/account.dart';

class AccountingSettings {
  final int revenueServiceAccountId;
  final int revenuePartsAccountId;
  final int cogsPartsAccountId;
  final int inventoryAccountId;
  final int cashAccountId;
  final int receivableAccountId;
  final int payableAccountId;
  final int wipAccountId;
  final int depreciationExpenseAccountId;
  final int accumulatedDepreciationAccountId;
  final int salesTaxAccountId;

  AccountingSettings({
    required this.revenueServiceAccountId,
    required this.revenuePartsAccountId,
    required this.cogsPartsAccountId,
    required this.inventoryAccountId,
    required this.cashAccountId,
    required this.receivableAccountId,
    required this.payableAccountId,
    required this.wipAccountId,
    required this.depreciationExpenseAccountId,
    required this.accumulatedDepreciationAccountId,
    required this.salesTaxAccountId,
  });

  Map<String, dynamic> toJson() {
    return {
      'revenue_service_account_id': revenueServiceAccountId,
      'revenue_parts_account_id': revenuePartsAccountId,
      'cogs_parts_account_id': cogsPartsAccountId,
      'inventory_account_id': inventoryAccountId,
      'cash_account_id': cashAccountId,
      'receivable_account_id': receivableAccountId,
      'payable_account_id': payableAccountId,
      'wip_account_id': wipAccountId,
      'depreciation_expense_account_id': depreciationExpenseAccountId,
      'accumulated_depreciation_account_id': accumulatedDepreciationAccountId,
      'sales_tax_account_id': salesTaxAccountId,
    };
  }

  factory AccountingSettings.fromJson(Map<String, dynamic> json) {
    return AccountingSettings(
      revenueServiceAccountId: json['revenue_service_account_id'] as int,
      revenuePartsAccountId: json['revenue_parts_account_id'] as int,
      cogsPartsAccountId: json['cogs_parts_account_id'] as int,
      inventoryAccountId: json['inventory_account_id'] as int,
      cashAccountId: json['cash_account_id'] as int,
      receivableAccountId: json['receivable_account_id'] as int,
      payableAccountId: json['payable_account_id'] as int,
      wipAccountId: json['wip_account_id'] as int,
      depreciationExpenseAccountId: json['depreciation_expense_account_id'] as int,
      accumulatedDepreciationAccountId: json['accumulated_depreciation_account_id'] as int,
      salesTaxAccountId: json['sales_tax_account_id'] as int,
    );
  }
}

class AccountingSettingsService {
  final CompanySettingsRepository _settingsRepository;
  final AccountRepository _accountRepository;

  AccountingSettingsService(this._settingsRepository, this._accountRepository);

  Future<AccountingSettings> getSettings() async {
    final settings = await _settingsRepository.getSettings();
    final json = settings?.accountingSettings ?? {};
    
    // If settings are empty, initialize with default accounts
    if (json.isEmpty) {
      final defaultSettings = await _initializeDefaultSettings();
      await saveSettings(defaultSettings);
      return defaultSettings;
    }

    return AccountingSettings.fromJson(json);
  }

  Future<void> saveSettings(AccountingSettings settings) async {
    final currentSettings = await _settingsRepository.getSettings();
    final updatedSettings = currentSettings!.copyWith(
      accountingSettings: settings.toJson(),
    );
    await _settingsRepository.updateSettings(updatedSettings);
  }

  Future<AccountingSettings> _initializeDefaultSettings() async {
    final defaultAccounts = await _getDefaultAccountIds();
    return AccountingSettings(
      revenueServiceAccountId: defaultAccounts['revenue_service']!,
      revenuePartsAccountId: defaultAccounts['revenue_parts']!,
      cogsPartsAccountId: defaultAccounts['cogs_parts']!,
      inventoryAccountId: defaultAccounts['inventory']!,
      cashAccountId: defaultAccounts['cash']!,
      receivableAccountId: defaultAccounts['receivable']!,
      payableAccountId: defaultAccounts['payable']!,
      wipAccountId: defaultAccounts['wip']!,
      depreciationExpenseAccountId: defaultAccounts['depreciation_expense']!,
      accumulatedDepreciationAccountId: defaultAccounts['accumulated_depreciation']!,
      salesTaxAccountId: defaultAccounts['sales_tax']!,
    );
  }

  Future<Map<String, int>> _getDefaultAccountIds() async {
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
      if (account.code == '1400') accountMap['wip'] = account.id;
      if (account.code == '6100') accountMap['depreciation_expense'] = account.id;
      if (account.code == '1501') accountMap['accumulated_depreciation'] = account.id;
      if (account.code == '2200') accountMap['sales_tax'] = account.id;
    }
    
    // If any account is missing, throw an error
    if (accountMap.length < 11) {
      throw Exception('Default accounts not found. Please run accounting seeder first.');
    }
    
    return accountMap;
  }

  Future<Account?> findAccountByCode(String code) async {
    return await _accountRepository.findByCode(code);
  }
}
