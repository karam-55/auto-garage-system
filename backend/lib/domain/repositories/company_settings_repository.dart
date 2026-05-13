import '../entities/company_settings.dart';

abstract class CompanySettingsRepository {
  Future<CompanySettings?> getSettings();
  Future<CompanySettings> updateSettings(CompanySettings settings);
}
