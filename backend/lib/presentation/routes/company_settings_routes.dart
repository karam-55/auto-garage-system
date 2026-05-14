import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
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
        final parts = await request.multipartFormData;
        
        // Find the logo file
        String? logoUrl;
        await for (final part in parts) {
          if (part.name == 'logo') {
            // Read file content
            final content = await part.part.readBytes();
            
            // Generate a unique filename
            final filename = 'logo_${DateTime.now().millisecondsSinceEpoch}_${part.filename}';
            
            // For now, we'll just return a mock URL since we don't have file storage
            // In production, you would upload to a cloud storage service (AWS S3, Cloudinary, etc.)
            logoUrl = '/uploads/$filename';
            
            break;
          }
        }
        
        if (logoUrl == null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'No logo file provided'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        
        return Response.ok(
          jsonEncode({'logoUrl': logoUrl}),
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
