import 'package:postgres/postgres.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/entities/bank_reconciliation.dart';
import '../../domain/repositories/bank_account_repository.dart';

class BankAccountRepositoryImpl implements BankAccountRepository {
  final Pool _pool;

  BankAccountRepositoryImpl(this._pool);

  @override
  Future<BankAccount> create(BankAccount account) async {
    final result = await _pool.query(
      '''INSERT INTO bank_accounts (account_name, account_number, bank_name, initial_balance, current_balance, is_active, account_id)
         VALUES (@accountName, @accountNumber, @bankName, @initialBalance, @currentBalance, @isActive, @accountId)
         RETURNING id''',
      substitutionValues: {
        'accountName': account.accountName,
        'accountNumber': account.accountNumber,
        'bankName': account.bankName,
        'initialBalance': account.initialBalance,
        'currentBalance': account.currentBalance,
        'isActive': account.isActive,
        'accountId': account.accountId,
      },
    );
    final row = result.first;
    return account.copyWith(id: row[0] as int);
  }

  @override
  Future<BankAccount?> findById(int id) async {
    final result = await _pool.query(
      'SELECT id, account_name, account_number, bank_name, initial_balance, current_balance, is_active, account_id FROM bank_accounts WHERE id = @id',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToBankAccount(result.first);
  }

  @override
  Future<List<BankAccount>> findAll() async {
    final result = await _pool.query(
      'SELECT id, account_name, account_number, bank_name, initial_balance, current_balance, is_active, account_id FROM bank_accounts ORDER BY account_name',
    );
    return result.map(_mapRowToBankAccount).toList();
  }

  @override
  Future<List<BankAccount>> findActive() async {
    final result = await _pool.query(
      'SELECT id, account_name, account_number, bank_name, initial_balance, current_balance, is_active, account_id FROM bank_accounts WHERE is_active = true ORDER BY account_name',
    );
    return result.map(_mapRowToBankAccount).toList();
  }

  @override
  Future<BankAccount> update(BankAccount account) async {
    await _pool.query(
      '''UPDATE bank_accounts SET
         account_name = @accountName,
         account_number = @accountNumber,
         bank_name = @bankName,
         initial_balance = @initialBalance,
         current_balance = @currentBalance,
         is_active = @isActive,
         account_id = @accountId
         WHERE id = @id''',
      substitutionValues: {
        'id': account.id,
        'accountName': account.accountName,
        'accountNumber': account.accountNumber,
        'bankName': account.bankName,
        'initialBalance': account.initialBalance,
        'currentBalance': account.currentBalance,
        'isActive': account.isActive,
        'accountId': account.accountId,
      },
    );
    return account;
  }

  @override
  Future<void> delete(int id) async {
    await _pool.query('DELETE FROM bank_accounts WHERE id = @id', substitutionValues: {'id': id});
  }

  @override
  Future<BankReconciliation> createReconciliation(BankReconciliation reconciliation) async {
    final result = await _pool.query(
      '''INSERT INTO bank_reconciliations (bank_account_id, statement_date, statement_balance, reconciled_balance, is_done)
         VALUES (@bankAccountId, @statementDate, @statementBalance, @reconciledBalance, @isDone)
         RETURNING id, created_at''',
      substitutionValues: {
        'bankAccountId': reconciliation.bankAccountId,
        'statementDate': reconciliation.statementDate,
        'statementBalance': reconciliation.statementBalance,
        'reconciledBalance': reconciliation.reconciledBalance,
        'isDone': reconciliation.isDone,
      },
    );
    final row = result.first;
    return reconciliation.copyWith(
      id: row[0] as int,
      createdAt: row[1] as DateTime,
    );
  }

  @override
  Future<BankReconciliation?> findReconciliationById(int id) async {
    final result = await _pool.query(
      'SELECT id, bank_account_id, statement_date, statement_balance, reconciled_balance, is_done, created_at FROM bank_reconciliations WHERE id = @id',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToBankReconciliation(result.first);
  }

  @override
  Future<List<BankReconciliation>> findReconciliationsByBankAccountId(int bankAccountId) async {
    final result = await _pool.query(
      'SELECT id, bank_account_id, statement_date, statement_balance, reconciled_balance, is_done, created_at FROM bank_reconciliations WHERE bank_account_id = @bankAccountId ORDER BY statement_date DESC',
      substitutionValues: {'bankAccountId': bankAccountId},
    );
    return result.map(_mapRowToBankReconciliation).toList();
  }

  @override
  Future<BankReconciliation> updateReconciliation(BankReconciliation reconciliation) async {
    await _pool.query(
      '''UPDATE bank_reconciliations SET
         bank_account_id = @bankAccountId,
         statement_date = @statementDate,
         statement_balance = @statementBalance,
         reconciled_balance = @reconciledBalance,
         is_done = @isDone
         WHERE id = @id''',
      substitutionValues: {
        'id': reconciliation.id,
        'bankAccountId': reconciliation.bankAccountId,
        'statementDate': reconciliation.statementDate,
        'statementBalance': reconciliation.statementBalance,
        'reconciledBalance': reconciliation.reconciledBalance,
        'isDone': reconciliation.isDone,
      },
    );
    return reconciliation;
  }

  @override
  Future<void> deleteReconciliation(int id) async {
    await _pool.query('DELETE FROM bank_reconciliations WHERE id = @id', substitutionValues: {'id': id});
  }

  BankAccount _mapRowToBankAccount(Row row) {
    return BankAccount(
      id: row[0] as int,
      accountName: row[1] as String,
      accountNumber: row[2] as String?,
      bankName: row[3] as String?,
      initialBalance: (row[4] as num).toDouble(),
      currentBalance: (row[5] as num).toDouble(),
      isActive: row[6] as bool,
      accountId: row[7] as int?,
    );
  }

  BankReconciliation _mapRowToBankReconciliation(Row row) {
    return BankReconciliation(
      id: row[0] as int,
      bankAccountId: row[1] as int,
      statementDate: row[2] as DateTime,
      statementBalance: (row[3] as num).toDouble(),
      reconciledBalance: row[4] != null ? (row[4] as num).toDouble() : null,
      isDone: row[5] as bool,
      createdAt: row[6] as DateTime,
    );
  }
}
