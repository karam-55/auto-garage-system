import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/company_settings.dart';
import '../../domain/repositories/company_settings_repository.dart';
import '../../core/errors/failures.dart';

class CompanySettingsRoutes {
  final CompanySettingsRepository _repository;

  CompanySettingsRoutes(this._repository);

  Router get router {
    final router = Router();

    // GET /api/company/settings - Get company settings
    router.get('/api/company/settings', (Request request) async {
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
    });

    // PATCH /api/company/settings - Update company settings
    router.patch('/api/company/settings', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload) as Map<String, dynamic>;
        
        // Get current settings first
        final currentSettings = await _repository.getSettings();
        
        if (currentSettings == null) {
          return Response.notFound(
            jsonEncode({'error': 'Company settings not found'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        
        // Update settings
        final updatedSettings = currentSettings.copyWith(
          companyName: data['companyName'] as String? ?? currentSettings.companyName,
          companyLogoUrl: data['companyLogoUrl'] as String?,
        );
        
        final result = await _repository.updateSettings(updatedSettings);
        
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
    });

    // POST /api/company/upload-logo - Upload company logo
    router.post('/api/company/upload-logo', (Request request) async {
      try {
        // Parse multipart form data
        final contentType = request.headers['content-type'];
        if (contentType == null || !contentType.contains('multipart/form-data')) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Invalid content type'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Read the body as bytes
        final bodyBytes = await request.read();
        
        // For now, return a simple response since multipart parsing is complex
        // This endpoint may need a different approach based on the shelf_multipart version
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
    });

    return router;
  }
}
