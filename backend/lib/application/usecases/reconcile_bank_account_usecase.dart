import '../../domain/entities/bank_reconciliation.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../application/services/journal_service.dart';
import '../../application/services/accounting_settings_service.dart';

class ReconcileBankAccountUseCase {
  final BankAccountRepository _bankAccountRepository;
  final JournalRepository _journalRepository;
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  ReconcileBankAccountUseCase(
    this._bankAccountRepository,
    this._journalRepository,
    this._journalService,
    this._accountingSettingsService,
  );

  Future<BankReconciliation> execute(
    int bankAccountId,
    DateTime statementDate,
    double statementBalance,
    List<int> matchedJournalLineIds,
    String createdBy,
  ) async {
    // Get journal lines for the bank account during the period
    final journalLines = await _journalRepository.findLinesByAccountIdAndDateRange(
      bankAccountId,
      statementDate.subtract(const Duration(days: 30)),
      statementDate,
    );

    // Calculate system balance
    double systemBalance = 0;
    for (final line in journalLines) {
      systemBalance += line.debit - line.credit;
    }

    // Calculate difference
    final difference = statementBalance - systemBalance;

    // Create reconciliation record
    final reconciliation = BankReconciliation(
      id: 0,
      bankAccountId: bankAccountId,
      statementDate: statementDate,
      statementBalance: statementBalance,
      reconciledBalance: systemBalance,
      isDone: true,
      createdAt: DateTime.now(),
    );

    final createdReconciliation = await _bankAccountRepository.createReconciliation(reconciliation);

    // If there's a difference, create an adjustment journal entry
    if (difference.abs() > 0.01) {
      final settings = await _accountingSettingsService.getSettings();
      
      final adjustmentEntry = await _journalService.createJournalEntry(
        date: statementDate,
        reference: 'BANK-ADJ-${createdReconciliation.id}',
        description: 'تعديل تسوية بنكية - فرق ${difference.abs().toStringAsFixed(2)}',
        lines: [
          JournalLineInput(
            accountId: bankAccountId,
            debit: difference > 0 ? difference : 0,
            credit: difference < 0 ? difference.abs() : 0,
            description: 'فرق التسوية',
          ),
          JournalLineInput(
            accountId: settings.depreciationExpenseAccountId, // Using depreciation expense as adjustment account
            debit: difference < 0 ? difference.abs() : 0,
            credit: difference > 0 ? difference : 0,
            description: 'فرق التسوية',
          ),
        ],
        sourceType: 'bank_reconciliation',
        sourceId: createdReconciliation.id.toString(),
        createdBy: createdBy,
      );
    }

    return createdReconciliation;
  }
}
