import '../../domain/entities/account.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_line.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/account_repository.dart';

class GeneralLedgerEntry {
  final DateTime date;
  final String reference;
  final String description;
  final Account account;
  final double debit;
  final double credit;
  final String? lineDescription;

  GeneralLedgerEntry({
    required this.date,
    required this.reference,
    required this.description,
    required this.account,
    required this.debit,
    required this.credit,
    this.lineDescription,
  });
}

class GetGeneralLedgerUseCase {
  final JournalRepository _journalRepository;
  final AccountRepository _accountRepository;

  GetGeneralLedgerUseCase(this._journalRepository, this._accountRepository);

  Future<List<GeneralLedgerEntry>> execute({
    DateTime? fromDate,
    DateTime? toDate,
    int? accountId,
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
    final List<GeneralLedgerEntry> ledgerEntries = [];
    for (final entry in filteredEntries) {
      final lines = await _journalRepository.findLinesByEntryId(entry.id);
      for (final line in lines) {
        // Filter by account if specified
        if (accountId != null && line.accountId != accountId) {
          continue;
        }

        final account = await _accountRepository.findById(line.accountId);
        if (account == null) continue;

        ledgerEntries.add(GeneralLedgerEntry(
          date: entry.entryDate,
          reference: entry.reference ?? '',
          description: entry.description ?? '',
          account: account,
          debit: line.debit,
          credit: line.credit,
          lineDescription: line.description,
        ));
      }
    }

    // Sort by date
    ledgerEntries.sort((a, b) => a.date.compareTo(b.date));

    return ledgerEntries;
  }
}
