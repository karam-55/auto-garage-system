import '../../domain/entities/salary_payment.dart';
import '../../domain/repositories/salary_payment_repository.dart';
import '../../application/services/journal_service.dart';
import '../../domain/entities/journal_entry.dart';
import '../../application/services/accounting_settings_service.dart';

class PaySalaryUseCase {
  final SalaryPaymentRepository _salaryRepository;
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  PaySalaryUseCase(
    this._salaryRepository,
    this._journalService,
    this._accountingSettingsService,
  );

  Future<void> execute(int salaryPaymentId, DateTime paymentDate, int paidByUserId) async {
    final salary = await _salaryRepository.findPaymentById(salaryPaymentId);
    if (salary == null) {
      throw Exception('Salary record not found');
    }
    if (salary.isPaid) {
      throw Exception('Salary already paid');
    }

    // Get salary expense account ID from accounting settings
    final settings = await _accountingSettingsService.getSettings();
    final salaryExpenseAccountId = settings.depreciationExpenseAccountId; // Using depreciation expense as salary expense
    final cashAccountId = settings.cashAccountId;

    // Create journal entry
    final entry = await _journalService.createJournalEntry(
      date: paymentDate,
      reference: 'SAL-${salary.userId.substring(0, 6)}-${salary.monthYear.month}',
      description: 'صرف راتب شهر ${salary.monthYear.month}/${salary.monthYear.year}',
      lines: [
        JournalLineInput(
          accountId: salaryExpenseAccountId,
          debit: salary.netSalary,
          credit: 0,
          description: 'الراتب الصافي',
        ),
        JournalLineInput(
          accountId: cashAccountId,
          debit: 0,
          credit: salary.netSalary,
          description: 'دفع نقدي',
        ),
      ],
      sourceType: 'salary',
      sourceId: salaryPaymentId.toString(),
      createdBy: paidByUserId,
    );

    // Update salary payment
    await _salaryRepository.markAsPaid(salaryPaymentId, paymentDate, entry.id);
  }
}
