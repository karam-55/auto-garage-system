import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/company_settings.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/company_settings_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../middlewares/auth_middleware.dart';
import '../../application/services/accounting_settings_service.dart';

class CompanySettingsRoutes {
  final CompanySettingsRepository _repository;
  final AuthMiddleware _authMiddleware;
  final AccountRepository _accountRepository;
  final AccountingSettingsService _accountingSettingsService;

  CompanySettingsRoutes(this._repository, this._authMiddleware, this._accountRepository, this._accountingSettingsService);

  Router get router {
    final router = Router();

    // GET /api/company/settings - Get company settings
    router.get('/api/company/settings', _getSettings);

    // PATCH /api/company/settings - Update company settings
    router.patch('/api/company/settings', _updateSettings);

    // POST /api/company/upload-logo - Upload company logo
    router.post('/api/company/upload-logo', _uploadLogo);

    // GET /api/accounting-settings - Get accounting settings
    router.get('/api/accounting-settings', 
      _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_getAccountingSettings)));

    // PUT /api/accounting-settings - Update accounting settings
    router.put('/api/accounting-settings',
      _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_updateAccountingSettings)));

    return router;
  }

  Future<Response> _getSettings(Request request) async {
    try {
      final settings = await _repository.getSettings();
      
      if (settings == null) {
        return Response.ok(
          jsonEncode({
            'companyName': 'Garage Go',
            'companyLogoUrl': null,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      return Response.ok(
        jsonEncode(settings.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get company settings'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _updateSettings(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      // Get current settings first
      final currentSettings = await _repository.getSettings();
      
      CompanySettings result;
      if (currentSettings == null) {
        // Create default settings if not exists
        final defaultSettings = CompanySettings(
          id: 0,
          companyName: data['companyName'] as String? ?? 'Garage Go',
          companyLogoUrl: data['companyLogoUrl'] as String?,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        result = await _repository.createSettings(defaultSettings);
      } else {
        // Update existing settings
        final updatedSettings = currentSettings.copyWith(
          companyName: data['companyName'] as String? ?? currentSettings.companyName,
          companyLogoUrl: data['companyLogoUrl'] as String?,
        );
        
        result = await _repository.updateSettings(updatedSettings);
      }
      
      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update company settings: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _uploadLogo(Request request) async {
    try {
      // For now, return a simple response since multipart parsing is complex
      return Response.badRequest(
        body: jsonEncode({'error': 'Multipart upload not implemented yet'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to upload logo: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getAccountingSettings(Request request) async {
    try {
      final settings = await _accountingSettingsService.getSettings();
      return Response.ok(
        jsonEncode(settings.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get accounting settings: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _updateAccountingSettings(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      final newSettings = AccountingSettings.fromJson(data);
      await _accountingSettingsService.saveSettings(newSettings);
      
      return Response.ok(
        jsonEncode({'message': 'Accounting settings updated successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update accounting settings: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
