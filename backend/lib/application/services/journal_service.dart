import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_line.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/account_repository.dart';

class JournalService {
  final JournalRepository _journalRepository;
  final AccountRepository _accountRepository;

  JournalService(this._journalRepository, this._accountRepository);

  Future<JournalEntry> createJournalEntry({
    required DateTime date,
    required String reference,
    required String description,
    required List<JournalLineInput> lines,
    required String sourceType,
    required String sourceId,
    bool isReversing = false,
    DateTime? reversingDate,
    String? createdBy,
    int? fiscalPeriodId,
  }) async {
    // Validate that total debits = total credits
    double totalDebits = 0;
    double totalCredits = 0;
    for (final line in lines) {
      totalDebits += line.debit;
      totalCredits += line.credit;
      // Validate account exists
      final account = await _accountRepository.findById(line.accountId);
      if (account == null) {
        throw Exception('Account ${line.accountId} not found');
      }
    }
    if ((totalDebits - totalCredits).abs() > 0.01) {
      throw Exception('Debits ($totalDebits) do not equal credits ($totalCredits)');
    }

    final entry = JournalEntry(
      id: 0,
      entryDate: date,
      reference: reference,
      description: description,
      isReversing: isReversing,
      reversingDate: reversingDate,
      isReversed: false,
      createdBy: createdBy,
      createdAt: DateTime.now().toUtc(),
      fiscalPeriodId: fiscalPeriodId,
    );

    final journalEntry = await _journalRepository.createEntry(entry);

    // Create journal lines
    for (final line in lines) {
      final journalLine = JournalLine(
        id: 0,
        entryId: journalEntry.id,
        accountId: line.accountId,
        debit: line.debit,
        credit: line.credit,
        description: line.description,
        sourceType: sourceType,
        sourceId: sourceId,
      );
      await _journalRepository.createLine(journalLine);
    }

    return journalEntry;
  }
}

class JournalLineInput {
  final int accountId;
  final double debit;
  final double credit;
  final String? description;

  JournalLineInput({
    required this.accountId,
    required this.debit,
    required this.credit,
    this.description,
  });
}
