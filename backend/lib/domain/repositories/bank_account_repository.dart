import '../entities/bank_account.dart';
import '../entities/bank_reconciliation.dart';

abstract class BankAccountRepository {
  Future<BankAccount> create(BankAccount account);
  Future<BankAccount?> findById(int id);
  Future<List<BankAccount>> findAll();
  Future<List<BankAccount>> findActive();
  Future<BankAccount> update(BankAccount account);
  Future<void> delete(int id);
  
  Future<BankReconciliation> createReconciliation(BankReconciliation reconciliation);
  Future<BankReconciliation?> findReconciliationById(int id);
  Future<List<BankReconciliation>> findReconciliationsByBankAccountId(int bankAccountId);
  Future<BankReconciliation> updateReconciliation(BankReconciliation reconciliation);
  Future<void> deleteReconciliation(int id);
}
