import '../../domain/repositories/journal_repository.dart';

class GetBreakEvenAnalysisUseCase {
  final JournalRepository _journalRepository;

  GetBreakEvenAnalysisUseCase(this._journalRepository);

  Future<Map<String, dynamic>> execute(DateTime fromDate, DateTime toDate) async {
    return await _journalRepository.getBreakEvenAnalysis(fromDate, toDate);
  }
}
