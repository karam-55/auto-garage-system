import '../../domain/repositories/journal_repository.dart';

class GetRetainedEarningsUseCase {
  final JournalRepository _journalRepository;

  GetRetainedEarningsUseCase(this._journalRepository);

  Future<double> execute(DateTime asOfDate) async {
    return await _journalRepository.getRetainedEarnings(asOfDate);
  }
}
