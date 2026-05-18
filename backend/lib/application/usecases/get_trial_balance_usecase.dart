import '../../domain/entities/account.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_line.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/account_repository.dart';

class TrialBalanceLine {
  final Account account;
  final double totalDebit;
  final double totalCredit;

  TrialBalanceLine({
    required this.account,
    required this.totalDebit,
    required this.totalCredit,
  });
}

class GetTrialBalanceUseCase {
  final JournalRepository _journalRepository;
  final AccountRepository _accountRepository;

  GetTrialBalanceUseCase(this._journalRepository, this._accountRepository);

  Future<List<TrialBalanceLine>> execute({
    DateTime? fromDate,
    DateTime? toDate,
    int? fiscalPeriodId,
  }) async {
    // Get journal entries
    final entries = await _journalRepository.findAllEntries();
    
    // Filter by date range or fiscal period
    List<JournalEntry> filteredEntries = entries;
    if (fromDate != null && toDate != null) {
      filteredEntries = await _journalRepository.findByDateRange(fromDate, toDate);
    } else if (fiscalPeriodId != null) {
      filteredEntries = await _journalRepository.findByFiscalPeriod(fiscalPeriodId);
    }

    // Get all lines from filtered entries
    final Map<int, List<JournalLine>> accountLines = {};
    for (final entry in filteredEntries) {
      final lines = await _journalRepository.findLinesByEntryId(entry.id);
      for (final line in lines) {
        if (!accountLines.containsKey(line.accountId)) {
          accountLines[line.accountId] = [];
        }
        accountLines[line.accountId]!.add(line);
      }
    }

    // Calculate totals per account
    final List<TrialBalanceLine> trialBalance = [];
    for (final accountId in accountLines.keys) {
      final account = await _accountRepository.findById(accountId);
      if (account == null) continue;

      double totalDebit = 0;
      double totalCredit = 0;
      for (final line in accountLines[accountId]!) {
        totalDebit += line.debit;
        totalCredit += line.credit;
      }

      trialBalance.add(TrialBalanceLine(
        account: account,
        totalDebit: totalDebit,
        totalCredit: totalCredit,
      ));
    }

    return trialBalance;
  }
}
