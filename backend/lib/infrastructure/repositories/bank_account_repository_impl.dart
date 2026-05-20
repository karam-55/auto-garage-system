import 'package:postgres/postgres.dart';
import '../../infrastructure/database/database_connection.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/entities/bank_reconciliation.dart';
import '../../domain/repositories/bank_account_repository.dart';

class BankAccountRepositoryImpl implements BankAccountRepository {
  final DatabaseConnection _db;

  BankAccountRepositoryImpl(this._db);

  @override
  Future<BankAccount> create(BankAccount account) async {
    final result = await _db.query(
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
    final result = await _db.query(
      'SELECT id, account_name, account_number, bank_name, initial_balance, current_balance, is_active, account_id FROM bank_accounts WHERE id = @id',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToBankAccount(result.first);
  }

  @override
  Future<List<BankAccount>> findAll() async {
    final result = await _db.query(
      'SELECT id, account_name, account_number, bank_name, initial_balance, current_balance, is_active, account_id FROM bank_accounts ORDER BY account_name',
    );
    return result.map(_mapRowToBankAccount).toList();
  }

  @override
  Future<List<BankAccount>> findActive() async {
    final result = await _db.query(
      'SELECT id, account_name, account_number, bank_name, initial_balance, current_balance, is_active, account_id FROM bank_accounts WHERE is_active = true ORDER BY account_name',
    );
    return result.map(_mapRowToBankAccount).toList();
  }

  @override
  Future<BankAccount> update(BankAccount account) async {
    await _db.query(
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
    await _db.query('DELETE FROM bank_accounts WHERE id = @id', substitutionValues: {'id': id});
  }

  @override
  Future<BankReconciliation> createReconciliation(BankReconciliation reconciliation) async {
    final result = await _db.query(
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
    final result = await _db.query(
      'SELECT id, bank_account_id, statement_date, statement_balance, reconciled_balance, is_done, created_at FROM bank_reconciliations WHERE id = @id',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToBankReconciliation(result.first);
  }

  @override
  Future<List<BankReconciliation>> findReconciliationsByBankAccountId(int bankAccountId) async {
    final result = await _db.query(
      'SELECT id, bank_account_id, statement_date, statement_balance, reconciled_balance, is_done, created_at FROM bank_reconciliations WHERE bank_account_id = @bankAccountId ORDER BY statement_date DESC',
      substitutionValues: {'bankAccountId': bankAccountId},
    );
    return result.map(_mapRowToBankReconciliation).toList();
  }

  @override
  Future<BankReconciliation> updateReconciliation(BankReconciliation reconciliation) async {
    await _db.query(
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
    await _db.query('DELETE FROM bank_reconciliations WHERE id = @id', substitutionValues: {'id': id});
  }

  @override
  Future<BankReconciliation> reconcileWithAdjustment(
    int bankAccountId,
    DateTime statementDate,
    double statementBalance,
    List<int> matchedJournalLineIds,
    String createdBy,
  ) async {
    return await _db.runInTransaction((session) async {
      // Calculate system balance
      final journalLinesResult = await session.execute(
        '''SELECT debit, credit FROM journal_lines WHERE account_id = @accountId''',
        parameters: {'accountId': bankAccountId},
      );
      double systemBalance = 0;
      for (final line in journalLinesResult) {
        systemBalance += (line[0] as double) - (line[1] as double);
      }

      // Calculate difference
      final difference = statementBalance - systemBalance;

      // Create reconciliation record
      final reconciliationResult = await session.execute(
        Sql.named('''
          INSERT INTO bank_reconciliations (bank_account_id, statement_date, statement_balance, reconciled_balance, is_done, created_at)
          VALUES (@bankAccountId, @statementDate, @statementBalance, @reconciledBalance, @isDone, @createdAt)
          RETURNING id
        '''),
        parameters: {
          'bankAccountId': bankAccountId,
          'statementDate': statementDate,
          'statementBalance': statementBalance,
          'reconciledBalance': systemBalance,
          'isDone': true,
          'createdAt': DateTime.now().toUtc(),
        },
      );
      final reconciliationId = reconciliationResult.first[0] as int;

      // Create adjustment journal entry if there's a difference
      if (difference.abs() > 0.01) {
        final journalEntryResult = await session.execute(
          Sql.named('''
            INSERT INTO journal_entries (entry_date, reference, description, created_by, created_at)
            VALUES (@entryDate, @reference, @description, @createdBy, @createdAt)
            RETURNING id
          '''),
          parameters: {
            'entryDate': statementDate,
            'reference': 'RECON-$reconciliationId',
            'description': 'فرق التسوية',
            'createdBy': createdBy,
            'createdAt': DateTime.now().toUtc(),
          },
        );
        final journalEntryId = journalEntryResult.first[0] as int;

        // Create journal line for adjustment
        await session.execute(
          Sql.named('''
            INSERT INTO journal_lines (entry_id, account_id, debit, credit, description)
            VALUES (@entryId, @accountId, @debit, @credit, @description)
          '''),
          parameters: {
            'entryId': journalEntryId,
            'accountId': bankAccountId,
            'debit': difference > 0 ? difference : 0,
            'credit': difference < 0 ? -difference : 0,
            'description': 'فرق التسوية',
          },
        );
      }

      return BankReconciliation(
        id: reconciliationId,
        bankAccountId: bankAccountId,
        statementDate: statementDate,
        statementBalance: statementBalance,
        reconciledBalance: systemBalance,
        isDone: true,
        createdAt: DateTime.now().toUtc(),
      );
    });
  }

  BankAccount _mapRowToBankAccount(dynamic row) {
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

  BankReconciliation _mapRowToBankReconciliation(dynamic row) {
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
