import '../../domain/entities/expense.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../application/services/journal_service.dart';

class CreateExpenseUseCase {
  final ExpenseRepository _expenseRepository;
  final JournalService _journalService;

  CreateExpenseUseCase(
    this._expenseRepository,
    this._journalService,
  );

  Future<Expense> execute(Expense expense, String createdBy) async {
    // Create expense
    final createdExpense = await _expenseRepository.create(expense);

    // Create journal entry
    // TODO: Get cash account ID from accounting settings
    final cashAccountId = 3; // Default cash account

    final journalEntry = await _journalService.createJournalEntry(
      date: expense.expenseDate,
      reference: 'EXP-${createdExpense.id}',
      description: expense.description ?? 'مصروف تشغيلي',
      lines: [
        JournalLineInput(
          accountId: expense.accountId,
          debit: expense.amount,
          credit: 0,
          description: expense.description ?? 'مصروف',
        ),
        JournalLineInput(
          accountId: cashAccountId,
          debit: 0,
          credit: expense.amount,
          description: expense.paymentMethod ?? 'نقدي',
        ),
      ],
      sourceType: 'expense',
      sourceId: createdExpense.id.toString(),
      createdBy: createdBy,
    );

    // Update expense with journal entry ID
    final updatedExpense = createdExpense.copyWith(journalEntryId: journalEntry.id);
    await _expenseRepository.update(updatedExpense);

    return updatedExpense;
  }
}
