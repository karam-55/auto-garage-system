import '../../domain/entities/salary_payment.dart';
import '../../domain/repositories/salary_payment_repository.dart';

class MonthlyPayrollReport {
  final DateTime monthYear;
  final List<SalaryPayment> payments;
  final double totalBaseSalary;
  final double totalBonuses;
  final double totalDeductions;
  final double totalNetSalary;
  final int totalPaid;
  final int totalPending;

  MonthlyPayrollReport({
    required this.monthYear,
    required this.payments,
    required this.totalBaseSalary,
    required this.totalBonuses,
    required this.totalDeductions,
    required this.totalNetSalary,
    required this.totalPaid,
    required this.totalPending,
  });
}

class GetMonthlyPayrollReportUseCase {
  final SalaryPaymentRepository _salaryRepository;

  GetMonthlyPayrollReportUseCase(this._salaryRepository);

  Future<MonthlyPayrollReport> execute(DateTime monthYear) async {
    final payments = await _salaryRepository.findByMonthYear(monthYear);

    double totalBaseSalary = 0;
    double totalBonuses = 0;
    double totalDeductions = 0;
    double totalNetSalary = 0;
    int totalPaid = 0;
    int totalPending = 0;

    for (final payment in payments) {
      totalBaseSalary += payment.baseSalary;
      totalBonuses += payment.bonuses;
      totalDeductions += payment.deductions;
      totalNetSalary += payment.netSalary;
      if (payment.isPaid) {
        totalPaid++;
      } else {
        totalPending++;
      }
    }

    return MonthlyPayrollReport(
      monthYear: monthYear,
      payments: payments,
      totalBaseSalary: totalBaseSalary,
      totalBonuses: totalBonuses,
      totalDeductions: totalDeductions,
      totalNetSalary: totalNetSalary,
      totalPaid: totalPaid,
      totalPending: totalPending,
    );
  }
}
