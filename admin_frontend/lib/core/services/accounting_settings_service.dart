import '../models/accounting_settings.dart';
import 'api_service.dart';

class AccountingSettingsService {
  final ApiService _apiService;

  AccountingSettingsService(this._apiService);

  Future<AccountingSettings> getSettings() async {
    final response = await _apiService.get('/api/accounting-settings');
    return AccountingSettings.fromJson(response);
  }

  Future<void> updateSettings(AccountingSettings settings) async {
    await _apiService.put(
      '/api/accounting-settings',
      settings.toJson(),
    );
  }
}
