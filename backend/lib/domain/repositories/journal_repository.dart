import '../entities/journal_entry.dart';
import '../entities/journal_line.dart';

abstract class JournalRepository {
  Future<JournalEntry> createEntry(JournalEntry entry);
  Future<JournalEntry?> findEntryById(int id);
  Future<List<JournalEntry>> findAllEntries();
  Future<List<JournalEntry>> findByDateRange(DateTime startDate, DateTime endDate);
  Future<List<JournalEntry>> findByFiscalPeriod(int fiscalPeriodId);
  Future<JournalEntry> updateEntry(JournalEntry entry);
  Future<void> deleteEntry(int id);
  
  Future<JournalLine> createLine(JournalLine line);
  Future<List<JournalLine>> findLinesByEntryId(int entryId);
  Future<JournalLine> updateLine(JournalLine line);
  Future<void> deleteLine(int id);
}
