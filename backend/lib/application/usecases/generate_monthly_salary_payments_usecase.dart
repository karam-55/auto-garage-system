import '../../domain/entities/salary_payment.dart';
import '../../domain/repositories/salary_payment_repository.dart';
import '../../domain/repositories/payroll_settings_repository.dart';
import '../../domain/entities/payroll_settings.dart';

class GenerateMonthlySalaryPaymentsUseCase {
  final SalaryPaymentRepository _salaryRepository;
  final PayrollSettingsRepository _settingsRepository;

  GenerateMonthlySalaryPaymentsUseCase(this._salaryRepository, this._settingsRepository);

  Future<List<SalaryPayment>> execute(DateTime monthYear, List<Map<String, dynamic>> employees) async {
    final settings = await _settingsRepository.getSettings();
    if (settings == null) {
      throw Exception('Payroll settings not found');
    }

    final existingPayments = await _salaryRepository.findByMonthYear(monthYear);
    final existingUserIds = existingPayments.map((p) => p.userId).toSet();

    final newPayments = <SalaryPayment>[];

    for (final employee in employees) {
      final userId = employee['id'] as String;
      final baseSalary = (employee['base_salary'] as num?)?.toDouble() ?? 0;

      if (baseSalary <= 0) continue;
      if (existingUserIds.contains(userId)) continue;

      final dailyRate = baseSalary / settings.monthlyWorkDays;
      final workingDays = settings.monthlyWorkDays;
      final netSalary = baseSalary;

      final payment = SalaryPayment(
        id: 0,
        userId: userId,
        monthYear: monthYear,
        baseSalary: baseSalary,
        workingDays: workingDays,
        bonuses: 0,
        deductions: 0,
        netSalary: netSalary,
        paymentDate: null,
        isPaid: false,
        journalEntryId: null,
      );

      final created = await _salaryRepository.createPayment(payment);
      newPayments.add(created);
    }

    return newPayments;
  }
}
