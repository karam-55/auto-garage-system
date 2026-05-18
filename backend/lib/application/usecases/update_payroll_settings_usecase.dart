import '../../domain/entities/payroll_settings.dart';
import '../../domain/repositories/payroll_settings_repository.dart';

class UpdatePayrollSettingsUseCase {
  final PayrollSettingsRepository _settingsRepository;

  UpdatePayrollSettingsUseCase(this._settingsRepository);

  Future<PayrollSettings> execute(PayrollSettings settings) async {
    return await _settingsRepository.updateSettings(settings);
  }
}
