import '../../domain/entities/bank_reconciliation.dart';
import '../../domain/repositories/bank_account_repository.dart';

class ReconcileBankAccountUseCase {
  final BankAccountRepository _bankAccountRepository;

  ReconcileBankAccountUseCase(this._bankAccountRepository);

  Future<BankReconciliation> execute(
    int bankAccountId,
    DateTime statementDate,
    double statementBalance,
    List<int> matchedJournalLineIds,
    String createdBy,
  ) async {
    return await _bankAccountRepository.reconcileWithAdjustment(
      bankAccountId,
      statementDate,
      statementBalance,
      matchedJournalLineIds,
      createdBy,
    );
  }
}
