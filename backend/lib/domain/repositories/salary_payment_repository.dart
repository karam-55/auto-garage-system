import '../entities/salary_payment.dart';

abstract class SalaryPaymentRepository {
  Future<SalaryPayment> createPayment(SalaryPayment payment);
  Future<SalaryPayment?> findPaymentById(int id);
  Future<List<SalaryPayment>> findAllPayments();
  Future<List<SalaryPayment>> findByUserId(String userId);
  Future<List<SalaryPayment>> findByMonthYear(DateTime monthYear);
  Future<SalaryPayment> updatePayment(SalaryPayment payment);
  Future<void> deletePayment(int id);
  Future<SalaryPayment?> markAsPaid(int id, DateTime paymentDate, int journalEntryId);
  
  // Transactional operations
  Future<SalaryPayment> payWithJournal(
    int salaryPaymentId,
    DateTime paymentDate,
    String createdBy,
  );
}

