import '../../infrastructure/database/database_connection.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseConnection _db;

  ExpenseRepositoryImpl(this._db);

  @override
  Future<Expense> create(Expense expense) async {
    final result = await _db.query(
      '''INSERT INTO expenses (expense_date, account_id, amount, description, payment_method, attachment_url, created_by)
         VALUES (@expenseDate, @accountId, @amount, @description, @paymentMethod, @attachmentUrl, @createdBy)
         RETURNING id, created_at''',
      substitutionValues: {
        'expenseDate': expense.expenseDate,
        'accountId': expense.accountId,
        'amount': expense.amount,
        'description': expense.description,
        'paymentMethod': expense.paymentMethod,
        'attachmentUrl': expense.attachmentUrl,
        'createdBy': expense.createdBy,
      },
    );
    final row = result.first;
    return expense.copyWith(
      id: row[0] as int,
      createdAt: row[1] as DateTime,
    );
  }

  @override
  Future<Expense?> findById(int id) async {
    final result = await _db.query(
      'SELECT id, expense_date, account_id, amount, description, payment_method, attachment_url, created_by, created_at FROM expenses WHERE id = @id',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToExpense(result.first);
  }

  @override
  Future<List<Expense>> findAll() async {
    final result = await _db.query(
      'SELECT id, expense_date, account_id, amount, description, payment_method, attachment_url, created_by, created_at FROM expenses ORDER BY expense_date DESC',
    );
    return result.map(_mapRowToExpense).toList();
  }

  @override
  Future<List<Expense>> findByDateRange(DateTime startDate, DateTime endDate) async {
    final result = await _db.query(
      '''SELECT id, expense_date, account_id, amount, description, payment_method, attachment_url, created_by, created_at 
      FROM expenses WHERE expense_date >= @startDate AND expense_date <= @endDate 
      ORDER BY expense_date DESC''',
      substitutionValues: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return result.map(_mapRowToExpense).toList();
  }

  @override
  Future<List<Expense>> findByAccountId(int accountId) async {
    final result = await _db.query(
      'SELECT id, expense_date, account_id, amount, description, payment_method, attachment_url, created_by, created_at FROM expenses WHERE account_id = @accountId ORDER BY expense_date DESC',
      substitutionValues: {'accountId': accountId},
    );
    return result.map(_mapRowToExpense).toList();
  }

  @override
  Future<Expense> update(Expense expense) async {
    await _db.query(
      '''UPDATE expenses SET
         expense_date = @expenseDate,
         account_id = @accountId,
         amount = @amount,
         description = @description,
         payment_method = @paymentMethod,
         attachment_url = @attachmentUrl
         WHERE id = @id''',
      substitutionValues: {
        'id': expense.id,
        'expenseDate': expense.expenseDate,
        'accountId': expense.accountId,
        'amount': expense.amount,
        'description': expense.description,
        'paymentMethod': expense.paymentMethod,
        'attachmentUrl': expense.attachmentUrl,
      },
    );
    return expense;
  }

  @override
  Future<void> delete(int id) async {
    await _db.query('DELETE FROM expenses WHERE id = @id', substitutionValues: {'id': id});
  }

  Expense _mapRowToExpense(dynamic row) {
    return Expense(
      id: row[0] as int,
      expenseDate: row[1] as DateTime,
      accountId: row[2] as int,
      amount: (row[3] as num).toDouble(),
      description: row[4] as String?,
      paymentMethod: row[5] as String?,
      attachmentUrl: row[6] as String?,
      createdBy: row[7] as String?,
      createdAt: row[8] as DateTime,
    );
  }
}
