import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/form_data.dart';
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
        final formData = await FormData.fromRequest(request);
        
        // Get the file field
        final fileField = formData.files['logo'];
        if (fileField == null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'No file uploaded'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Validate file type (only images)
        final contentType = fileField.contentType?.toLowerCase() ?? '';
        if (!contentType.startsWith('image/')) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Only image files are allowed'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Validate file size (max 2MB)
        final maxSize = 2 * 1024 * 1024; // 2MB
        if (fileField.length > maxSize) {
          return Response.badRequest(
            body: jsonEncode({'error': 'File size must be less than 2MB'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Create uploads directory if it doesn't exist
        final uploadDir = Directory('uploads/logos');
        if (!await uploadDir.exists()) {
          await uploadDir.create(recursive: true);
        }

        // Generate unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = contentType.split('/').last;
        final filename = 'logo_$timestamp.$extension';
        final filePath = '${uploadDir.path}/$filename';

        // Save file
        final file = File(filePath);
        await file.writeAsBytes(fileField.content);

        // Generate public URL
        final logoUrl = '/uploads/logos/$filename';

        // Update company settings with new logo URL
        final currentSettings = await _repository.getSettings();
        if (currentSettings == null) {
          return Response.notFound(
            jsonEncode({'error': 'Company settings not found'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final updatedSettings = currentSettings.copyWith(
          companyLogoUrl: logoUrl,
        );

        await _repository.updateSettings(updatedSettings);

        return Response.ok(
          jsonEncode({
            'logoUrl': logoUrl,
            'settings': updatedSettings.toJson(),
          }),
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
