import '../../domain/repositories/salary_payment_repository.dart';

class PaySalaryUseCase {
  final SalaryPaymentRepository _salaryRepository;

  PaySalaryUseCase(this._salaryRepository);

  Future<void> execute(int salaryPaymentId, DateTime paymentDate, int paidByUserId) async {
    await _salaryRepository.payWithJournal(salaryPaymentId, paymentDate, paidByUserId.toString());
  }
}
