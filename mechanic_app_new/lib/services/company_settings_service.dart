import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/backend_constants.dart';

class CompanySettings {
  final String companyName;
  final String? companyLogoUrl;

  CompanySettings({
    required this.companyName,
    this.companyLogoUrl,
  });

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      companyName: json['companyName'] ?? 'تطبيق الميكانيكي',
      companyLogoUrl: json['companyLogoUrl'],
    );
  }
}

class CompanySettingsService {
  static const String _companyNameKey = 'company_name';
  static const String _companyLogoUrlKey = 'company_logo_url';

  Future<CompanySettings> getCompanySettings() async {
    // Try to load from SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    final cachedName = prefs.getString(_companyNameKey);
    final cachedLogoUrl = prefs.getString(_companyLogoUrlKey);

    if (cachedName != null) {
      return CompanySettings(
        companyName: cachedName,
        companyLogoUrl: cachedLogoUrl,
      );
    }

    // If not cached, fetch from API
    try {
      final response = await http.get(
        Uri.parse('${BackendConstants.backendUrl}/api/company/settings'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final settings = CompanySettings.fromJson(data);

        // Cache the settings
        await prefs.setString(_companyNameKey, settings.companyName);
        if (settings.companyLogoUrl != null) {
          await prefs.setString(_companyLogoUrlKey, settings.companyLogoUrl!);
        }

        return settings;
      }
    } catch (e) {
      // Return default settings on error
      return CompanySettings(companyName: 'تطبيق الميكانيكي');
    }

    return CompanySettings(companyName: 'تطبيق الميكانيكي');
  }

  Future<void> refreshCompanySettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      final response = await http.get(
        Uri.parse('${BackendConstants.backendUrl}/api/company/settings'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final settings = CompanySettings.fromJson(data);

        // Update cache
        await prefs.setString(_companyNameKey, settings.companyName);
        if (settings.companyLogoUrl != null) {
          await prefs.setString(_companyLogoUrlKey, settings.companyLogoUrl!);
        } else {
          await prefs.remove(_companyLogoUrlKey);
        }
      }
    } catch (e) {
      // Ignore error, keep cached values
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_companyNameKey);
    await prefs.remove(_companyLogoUrlKey);
  }
}
