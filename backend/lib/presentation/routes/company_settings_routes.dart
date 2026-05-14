import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/company_settings.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/company_settings_repository.dart';
import '../../core/errors/failures.dart';
import '../middlewares/auth_middleware.dart';

class CompanySettingsRoutes {
  final CompanySettingsRepository _repository;
  final AuthMiddleware _authMiddleware;

  CompanySettingsRoutes(this._repository, this._authMiddleware);

  Router get router {
    final router = Router();

    // GET /api/company/settings - Get company settings
    router.get('/api/company/settings', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getSettings)));

    // PATCH /api/company/settings - Update company settings
    router.patch('/api/company/settings', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_updateSettings)));

    // POST /api/company/upload-logo - Upload company logo
    router.post('/api/company/upload-logo', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_uploadLogo)));

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
}
