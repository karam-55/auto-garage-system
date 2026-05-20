import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<Expense> create(Expense expense);
  Future<Expense?> findById(int id);
  Future<List<Expense>> findAll();
  Future<List<Expense>> findByDateRange(DateTime startDate, DateTime endDate);
  Future<List<Expense>> findByAccountId(int accountId);
  Future<Expense> update(Expense expense);
  Future<void> delete(int id);
  
  // Transactional operations
  Future<Expense> createWithJournal(
    Expense expense,
    String createdBy,
  );
}
