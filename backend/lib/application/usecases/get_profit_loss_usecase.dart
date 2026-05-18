import '../../domain/entities/account.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_line.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/account_repository.dart';

class ProfitLossLine {
  final Account account;
  final double amount;

  ProfitLossLine({
    required this.account,
    required this.amount,
  });
}

class ProfitLossReport {
  final List<ProfitLossLine> revenues;
  final List<ProfitLossLine> expenses;
  final double totalRevenue;
  final double totalExpense;
  final double netProfit;

  ProfitLossReport({
    required this.revenues,
    required this.expenses,
    required this.totalRevenue,
    required this.totalExpense,
    required this.netProfit,
  });
}

class GetProfitLossUseCase {
  final JournalRepository _journalRepository;
  final AccountRepository _accountRepository;

  GetProfitLossUseCase(this._journalRepository, this._accountRepository);

  Future<ProfitLossReport> execute({
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
    final List<ProfitLossLine> revenues = [];
    final List<ProfitLossLine> expenses = [];
    double totalRevenue = 0;
    double totalExpense = 0;

    for (final accountId in accountLines.keys) {
      final account = await _accountRepository.findById(accountId);
      if (account == null) continue;

      double balance = 0;
      for (final line in accountLines[accountId]!) {
        // For revenue accounts: credit increases balance, debit decreases
        // For expense accounts: debit increases balance, credit decreases
        if (account.accountType == AccountType.revenue) {
          balance += line.credit - line.debit;
        } else if (account.accountType == AccountType.expense || account.accountType == AccountType.cogs) {
          balance += line.debit - line.credit;
        }
      }

      if (balance != 0) {
        final line = ProfitLossLine(account: account, amount: balance);
        if (account.accountType == AccountType.revenue) {
          revenues.add(line);
          totalRevenue += balance;
        } else if (account.accountType == AccountType.expense || account.accountType == AccountType.cogs) {
          expenses.add(line);
          totalExpense += balance;
        }
      }
    }

    final netProfit = totalRevenue - totalExpense;

    return ProfitLossReport(
      revenues: revenues,
      expenses: expenses,
      totalRevenue: totalRevenue,
      totalExpense: totalExpense,
      netProfit: netProfit,
    );
  }
}
