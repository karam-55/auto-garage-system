import '../entities/journal_entry.dart';
import '../entities/journal_line.dart';

abstract class JournalRepository {
  Future<JournalEntry> createEntry(JournalEntry entry);
  Future<JournalLine> createLine(JournalLine line);
  Future<List<JournalEntry>> findAllEntries({int? limit, int? offset});
  Future<JournalEntry?> findEntryById(int id);
  Future<List<JournalLine>> findLinesByEntryId(int entryId);
  Future<List<JournalLine>> findAllLines({int? limit, int? offset});
  Future<JournalEntry> updateEntry(JournalEntry entry);
  Future<void> deleteEntry(int id);
  Future<void> deleteLine(int id);
  Future<List<JournalEntry>> findByDateRange(DateTime startDate, DateTime endDate);
  Future<List<JournalEntry>> findByFiscalPeriod(int fiscalPeriodId);

  // Accounting report methods
  Future<Map<String, dynamic>> getTradingAccount(DateTime fromDate, DateTime toDate);
  Future<double> getRetainedEarnings(DateTime asOfDate);
  Future<Map<String, dynamic>> getCashFlowStatement(DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getBreakEvenAnalysis(DateTime fromDate, DateTime toDate);
}
