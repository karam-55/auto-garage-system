import '../../domain/entities/payroll_settings.dart';
import '../../domain/repositories/payroll_settings_repository.dart';
import '../../infrastructure/database/database_connection.dart';

class PayrollSettingsRepositoryImpl implements PayrollSettingsRepository {
  final DatabaseConnection _db;

  PayrollSettingsRepositoryImpl(this._db);

  @override
  Future<PayrollSettings?> getSettings() async {
    final result = await _db.query(
      'SELECT id, monthly_work_days, salary_payment_day FROM payroll_settings LIMIT 1',
    );

    if (result.isEmpty) {
      // Create default settings
      await _db.execute(
        'INSERT INTO payroll_settings (monthly_work_days, salary_payment_day) VALUES (30, 28)',
      );
      final defaultResult = await _db.query(
        'SELECT id, monthly_work_days, salary_payment_day FROM payroll_settings LIMIT 1',
      );
      return PayrollSettings(
        id: defaultResult.first[0] as int,
        monthlyWorkDays: defaultResult.first[1] as int,
        salaryPaymentDay: defaultResult.first[2] as int,
      );
    }

    final row = result.first;
    return PayrollSettings(
      id: row[0] as int,
      monthlyWorkDays: row[1] as int,
      salaryPaymentDay: row[2] as int,
    );
  }

  @override
  Future<PayrollSettings> updateSettings(PayrollSettings settings) async {
    await _db.execute(
      'UPDATE payroll_settings SET monthly_work_days = \$1, salary_payment_day = \$2 WHERE id = \$3',
      [settings.monthlyWorkDays, settings.salaryPaymentDay, settings.id],
    );
    return settings;
  }
}
