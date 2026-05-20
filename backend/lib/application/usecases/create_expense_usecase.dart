import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class CreateExpenseUseCase {
  final ExpenseRepository _expenseRepository;

  CreateExpenseUseCase(this._expenseRepository);

  Future<Expense> execute(Expense expense, String createdBy) async {
    return await _expenseRepository.createWithJournal(expense, createdBy);
  }
}
