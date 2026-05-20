import '../../domain/repositories/journal_repository.dart';

class GetTradingAccountUseCase {
  final JournalRepository _journalRepository;

  GetTradingAccountUseCase(this._journalRepository);

  Future<Map<String, dynamic>> execute(DateTime fromDate, DateTime toDate) async {
    return await _journalRepository.getTradingAccount(fromDate, toDate);
  }
}
