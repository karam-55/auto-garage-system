import '../../domain/entities/account.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_line.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/account_repository.dart';

class BalanceSheetLine {
  final Account account;
  final double balance;

  BalanceSheetLine({
    required this.account,
    required this.balance,
  });
}

class BalanceSheetReport {
  final List<BalanceSheetLine> assets;
  final List<BalanceSheetLine> liabilities;
  final double totalAssets;
  final double totalLiabilities;
  final double equity;

  BalanceSheetReport({
    required this.assets,
    required this.liabilities,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.equity,
  });
}

class GetBalanceSheetUseCase {
  final JournalRepository _journalRepository;
  final AccountRepository _accountRepository;

  GetBalanceSheetUseCase(this._journalRepository, this._accountRepository);

  Future<BalanceSheetReport> execute({
    DateTime? asOfDate,
    int? fiscalPeriodId,
  }) async {
    // Get journal entries
    final entries = await _journalRepository.findAllEntries();
    
    // Filter by date or fiscal period
    List<JournalEntry> filteredEntries = entries;
    if (asOfDate != null) {
      filteredEntries = entries.where((e) => e.entryDate.isBefore(asOfDate!) || e.entryDate.isAtSameMomentAs(asOfDate!)).toList();
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
    final List<BalanceSheetLine> assets = [];
    final List<BalanceSheetLine> liabilities = [];
    double totalAssets = 0;
    double totalLiabilities = 0;

    for (final accountId in accountLines.keys) {
      final account = await _accountRepository.findById(accountId);
      if (account == null) continue;

      double balance = 0;
      for (final line in accountLines[accountId]!) {
        // For asset accounts: debit increases balance, credit decreases
        // For liability accounts: credit increases balance, debit decreases
        // For equity accounts: credit increases balance, debit decreases
        if (account.accountType == AccountType.asset) {
          balance += line.debit - line.credit;
        } else if (account.accountType == AccountType.liability || account.accountType == AccountType.equity) {
          balance += line.credit - line.debit;
        }
      }

      if (balance != 0) {
        final line = BalanceSheetLine(account: account, balance: balance);
        if (account.accountType == AccountType.asset) {
          assets.add(line);
          totalAssets += balance;
        } else if (account.accountType == AccountType.liability) {
          liabilities.add(line);
          totalLiabilities += balance;
        }
      }
    }

    // Calculate equity
    final equity = totalAssets - totalLiabilities;

    return BalanceSheetReport(
      assets: assets,
      liabilities: liabilities,
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      equity: equity,
    );
  }
}
