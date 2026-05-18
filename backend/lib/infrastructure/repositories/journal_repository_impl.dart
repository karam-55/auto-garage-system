import 'package:postgres/postgres.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_line.dart';
import '../../domain/repositories/journal_repository.dart';
import '../database/database_connection.dart';

class JournalRepositoryImpl implements JournalRepository {
  final DatabaseConnection _db;

  JournalRepositoryImpl(this._db);

  @override
  Future<JournalEntry> createEntry(JournalEntry entry) async {
    final result = await _db.execute(
      Sql.named('''INSERT INTO journal_entries
         (entry_date, reference, description, is_reversing, reversing_date, is_reversed, created_by, fiscal_period_id)
         VALUES (@entryDate, @reference, @description, @isReversing, @reversingDate, @isReversed, @createdBy, @fiscalPeriodId)
         RETURNING id, created_at'''),
      parameters: {
        'entryDate': entry.entryDate,
        'reference': entry.reference,
        'description': entry.description,
        'isReversing': entry.isReversing,
        'reversingDate': entry.reversingDate,
        'isReversed': entry.isReversed,
        'createdBy': entry.createdBy,
        'fiscalPeriodId': entry.fiscalPeriodId,
      },
    );
    final row = result.first;
    return entry.copyWith(
      id: row[0] as int,
      createdAt: row[1] as DateTime,
    );
  }

  @override
  Future<JournalEntry?> findEntryById(int id) async {
    final result = await _db.execute(
      Sql.named('''SELECT id, entry_date, reference, description, is_reversing, reversing_date, is_reversed,
             created_by, created_at, approved_by, approved_at, fiscal_period_id
      FROM journal_entries WHERE id = @id'''),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToJournalEntry(result.first);
  }

  @override
  Future<List<JournalEntry>> findAllEntries() async {
    final result = await _db.execute(
      Sql.named('''SELECT id, entry_date, reference, description, is_reversing, reversing_date, is_reversed,
             created_by, created_at, approved_by, approved_at, fiscal_period_id
      FROM journal_entries ORDER BY entry_date DESC, id DESC'''),
    );
    return result.map(_mapRowToJournalEntry).toList();
  }

  @override
  Future<List<JournalEntry>> findByDateRange(DateTime startDate, DateTime endDate) async {
    final result = await _db.execute(
      Sql.named('''SELECT id, entry_date, reference, description, is_reversing, reversing_date, is_reversed,
             created_by, created_at, approved_by, approved_at, fiscal_period_id
      FROM journal_entries WHERE entry_date >= @startDate AND entry_date <= @endDate
      ORDER BY entry_date DESC, id DESC'''),
      parameters: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return result.map(_mapRowToJournalEntry).toList();
  }

  @override
  Future<List<JournalEntry>> findByFiscalPeriod(int fiscalPeriodId) async {
    final result = await _db.execute(
      Sql.named('''SELECT id, entry_date, reference, description, is_reversing, reversing_date, is_reversed,
             created_by, created_at, approved_by, approved_at, fiscal_period_id
      FROM journal_entries WHERE fiscal_period_id = @fiscalPeriodId
      ORDER BY entry_date DESC, id DESC'''),
      parameters: {'fiscalPeriodId': fiscalPeriodId},
    );
    return result.map(_mapRowToJournalEntry).toList();
  }

  @override
  Future<JournalEntry> updateEntry(JournalEntry entry) async {
    await _db.execute(
      Sql.named('''UPDATE journal_entries SET
         entry_date = @entryDate,
         reference = @reference,
         description = @description,
         is_reversing = @isReversing,
         reversing_date = @reversingDate,
         is_reversed = @isReversed,
         approved_by = @approvedBy,
         approved_at = @approvedAt,
         fiscal_period_id = @fiscalPeriodId
         WHERE id = @id'''),
      parameters: {
        'id': entry.id,
        'entryDate': entry.entryDate,
        'reference': entry.reference,
        'description': entry.description,
        'isReversing': entry.isReversing,
        'reversingDate': entry.reversingDate,
        'isReversed': entry.isReversed,
        'approvedBy': entry.approvedBy,
        'approvedAt': entry.approvedAt,
        'fiscalPeriodId': entry.fiscalPeriodId,
      },
    );
    return entry;
  }

  @override
  Future<void> deleteEntry(int id) async {
    await _db.execute(
      Sql.named('DELETE FROM journal_entries WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<JournalLine> createLine(JournalLine line) async {
    final result = await _db.execute(
      Sql.named('''INSERT INTO journal_lines
         (entry_id, account_id, debit, credit, description, source_type, source_id)
         VALUES (@entryId, @accountId, @debit, @credit, @description, @sourceType, @sourceId)
         RETURNING id'''),
      parameters: {
        'entryId': line.entryId,
        'accountId': line.accountId,
        'debit': line.debit,
        'credit': line.credit,
        'description': line.description,
        'sourceType': line.sourceType,
        'sourceId': line.sourceId,
      },
    );
    final row = result.first;
    return line.copyWith(id: row[0] as int);
  }

  @override
  Future<List<JournalLine>> findLinesByEntryId(int entryId) async {
    final result = await _db.execute(
      Sql.named('SELECT id, entry_id, account_id, debit, credit, description, source_type, source_id FROM journal_lines WHERE entry_id = @entryId'),
      parameters: {'entryId': entryId},
    );
    return result.map(_mapRowToJournalLine).toList();
  }

  @override
  Future<JournalLine> updateLine(JournalLine line) async {
    await _db.execute(
      Sql.named('''UPDATE journal_lines SET
         account_id = @accountId,
         debit = @debit,
         credit = @credit,
         description = @description,
         source_type = @sourceType,
         source_id = @sourceId
         WHERE id = @id'''),
      parameters: {
        'id': line.id,
        'accountId': line.accountId,
        'debit': line.debit,
        'credit': line.credit,
        'description': line.description,
        'sourceType': line.sourceType,
        'sourceId': line.sourceId,
      },
    );
    return line;
  }

  @override
  Future<void> deleteLine(int id) async {
    await _db.execute(
      Sql.named('DELETE FROM journal_lines WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  JournalEntry _mapRowToJournalEntry(ResultRow row) {
    return JournalEntry(
      id: row[0] as int,
      entryDate: row[1] as DateTime,
      reference: row[2] as String?,
      description: row[3] as String?,
      isReversing: row[4] as bool,
      reversingDate: row[5] as DateTime?,
      isReversed: row[6] as bool,
      createdBy: row[7] as String?,
      createdAt: row[8] as DateTime,
      approvedBy: row[9] as String?,
      approvedAt: row[10] as DateTime?,
      fiscalPeriodId: row[11] as int?,
    );
  }

  JournalLine _mapRowToJournalLine(ResultRow row) {
    return JournalLine(
      id: row[0] as int,
      entryId: row[1] as int,
      accountId: row[2] as int,
      debit: (row[3] as num).toDouble(),
      credit: (row[4] as num).toDouble(),
      description: row[5] as String?,
      sourceType: row[6] as String?,
      sourceId: row[7] as String?,
    );
  }
}
