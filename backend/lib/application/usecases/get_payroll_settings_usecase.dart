import '../../domain/entities/payroll_settings.dart';
import '../../domain/repositories/payroll_settings_repository.dart';

class GetPayrollSettingsUseCase {
  final PayrollSettingsRepository _settingsRepository;

  GetPayrollSettingsUseCase(this._settingsRepository);

  Future<PayrollSettings> execute() async {
    final settings = await _settingsRepository.getSettings();
    if (settings == null) {
      throw Exception('Payroll settings not found');
    }
    return settings;
  }
}
