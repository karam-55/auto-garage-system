import '../../domain/entities/payroll_settings.dart';

abstract class PayrollSettingsRepository {
  Future<PayrollSettings?> getSettings();
  Future<PayrollSettings> updateSettings(PayrollSettings settings);
}
