import 'package:postgres/postgres.dart';
import '../../domain/entities/salary_payment.dart';
import '../../domain/repositories/salary_payment_repository.dart';

class SalaryPaymentRepositoryImpl implements SalaryPaymentRepository {
  final Pool _pool;

  SalaryPaymentRepositoryImpl(this._pool);

  @override
  Future<SalaryPayment> createPayment(SalaryPayment payment) async {
    final result = await _pool.query(
      '''INSERT INTO salary_payments (user_id, month_year, base_salary, working_days, bonuses, deductions, net_salary, payment_date, is_paid, journal_entry_id)
         VALUES (@userId, @monthYear, @baseSalary, @workingDays, @bonuses, @deductions, @netSalary, @paymentDate, @isPaid, @journalEntryId)
         RETURNING id''',
      substitutionValues: {
        'userId': payment.userId,
        'monthYear': payment.monthYear,
        'baseSalary': payment.baseSalary,
        'workingDays': payment.workingDays,
        'bonuses': payment.bonuses,
        'deductions': payment.deductions,
        'netSalary': payment.netSalary,
        'paymentDate': payment.paymentDate,
        'isPaid': payment.isPaid,
        'journalEntryId': payment.journalEntryId,
      },
    );
    final row = result.first;
    return payment.copyWith(id: row[0] as int);
  }

  @override
  Future<SalaryPayment?> findPaymentById(int id) async {
    final result = await _pool.query(
      '''SELECT id, user_id, month_year, base_salary, working_days, bonuses, deductions, net_salary, payment_date, is_paid, journal_entry_id 
      FROM salary_payments WHERE id = @id''',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToSalaryPayment(result.first);
  }

  @override
  Future<List<SalaryPayment>> findAllPayments() async {
    final result = await _pool.query(
      '''SELECT id, user_id, month_year, base_salary, working_days, bonuses, deductions, net_salary, payment_date, is_paid, journal_entry_id 
      FROM salary_payments ORDER BY month_year DESC''',
    );
    return result.map(_mapRowToSalaryPayment).toList();
  }

  @override
  Future<List<SalaryPayment>> findByUserId(String userId) async {
    final result = await _pool.query(
      '''SELECT id, user_id, month_year, base_salary, working_days, bonuses, deductions, net_salary, payment_date, is_paid, journal_entry_id 
      FROM salary_payments WHERE user_id = @userId ORDER BY month_year DESC''',
      substitutionValues: {'userId': userId},
    );
    return result.map(_mapRowToSalaryPayment).toList();
  }

  @override
  Future<List<SalaryPayment>> findByMonthYear(DateTime monthYear) async {
    final result = await _pool.query(
      '''SELECT id, user_id, month_year, base_salary, working_days, bonuses, deductions, net_salary, payment_date, is_paid, journal_entry_id 
      FROM salary_payments WHERE month_year = @monthYear ORDER BY month_year DESC''',
      substitutionValues: {'monthYear': monthYear},
    );
    return result.map(_mapRowToSalaryPayment).toList();
  }

  @override
  Future<SalaryPayment> updatePayment(SalaryPayment payment) async {
    await _pool.query(
      '''UPDATE salary_payments SET
         user_id = @userId,
         month_year = @monthYear,
         base_salary = @baseSalary,
         working_days = @workingDays,
         bonuses = @bonuses,
         deductions = @deductions,
         net_salary = @netSalary,
         payment_date = @paymentDate,
         is_paid = @isPaid,
         journal_entry_id = @journalEntryId
         WHERE id = @id''',
      substitutionValues: {
        'id': payment.id,
        'userId': payment.userId,
        'monthYear': payment.monthYear,
        'baseSalary': payment.baseSalary,
        'workingDays': payment.workingDays,
        'bonuses': payment.bonuses,
        'deductions': payment.deductions,
        'netSalary': payment.netSalary,
        'paymentDate': payment.paymentDate,
        'isPaid': payment.isPaid,
        'journalEntryId': payment.journalEntryId,
      },
    );
    return payment;
  }

  @override
  Future<void> deletePayment(int id) async {
    await _pool.query('DELETE FROM salary_payments WHERE id = @id', substitutionValues: {'id': id});
  }

  @override
  Future<SalaryPayment?> markAsPaid(int id, DateTime paymentDate, int journalEntryId) async {
    await _pool.query(
      '''UPDATE salary_payments SET
         payment_date = @paymentDate,
         is_paid = true,
         journal_entry_id = @journalEntryId
         WHERE id = @id''',
      substitutionValues: {
        'id': id,
        'paymentDate': paymentDate,
        'journalEntryId': journalEntryId,
      },
    );
    return findPaymentById(id);
  }

  SalaryPayment _mapRowToSalaryPayment(Row row) {
    return SalaryPayment(
      id: row[0] as int,
      userId: row[1] as String,
      monthYear: row[2] as DateTime,
      baseSalary: (row[3] as num).toDouble(),
      workingDays: row[4] as int,
      bonuses: (row[5] as num?)?.toDouble() ?? 0,
      deductions: (row[6] as num?)?.toDouble() ?? 0,
      netSalary: (row[7] as num).toDouble(),
      paymentDate: row[8] as DateTime?,
      isPaid: row[9] as bool,
      journalEntryId: row[10] as int?,
    );
  }
}
