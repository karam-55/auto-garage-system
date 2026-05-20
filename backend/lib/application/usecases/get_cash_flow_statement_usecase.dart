import '../../domain/repositories/journal_repository.dart';

class GetCashFlowStatementUseCase {
  final JournalRepository _journalRepository;

  GetCashFlowStatementUseCase(this._journalRepository);

  Future<Map<String, dynamic>> execute(DateTime startDate, DateTime endDate) async {
    return await _journalRepository.getCashFlowStatement(startDate, endDate);
  }
}
