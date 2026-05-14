import 'package:postgres/postgres.dart';
import 'package:backend/domain/entities/company_settings.dart';
import 'package:backend/domain/repositories/company_settings_repository.dart';
import 'package:backend/core/errors/exceptions.dart';
import 'package:backend/infrastructure/database/database_connection.dart';

class CompanySettingsRepositoryImpl implements CompanySettingsRepository {
  final DatabaseConnection _db;

  CompanySettingsRepositoryImpl(this._db);

  @override
  Future<CompanySettings?> getSettings() async {
    try {
      final result = await _db.execute(
        'SELECT * FROM company_settings ORDER BY created_at DESC LIMIT 1',
      );

      if (result.isEmpty) return null;
      return _mapRowToCompanySettings(result.first);
    } catch (e) {
      throw DatabaseException('Failed to get company settings: $e');
    }
  }

  @override
  Future<CompanySettings> updateSettings(CompanySettings settings) async {
    try {
      final result = await _db.execute(
        Sql.named('''
          UPDATE company_settings
          SET company_name = @companyName,
              company_logo_url = @companyLogoUrl,
              updated_at = CURRENT_TIMESTAMP
          WHERE id = @id
          RETURNING *
        '''),
        parameters: {
          'id': settings.id,
          'companyName': settings.companyName,
          'companyLogoUrl': settings.companyLogoUrl,
        },
      );

      return _mapRowToCompanySettings(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update company settings: $e');
    }
  }

  CompanySettings _mapRowToCompanySettings(ResultRow row) {
    return CompanySettings(
      id: row['id'].toString(),
      companyName: row['company_name'].toString(),
      companyLogoUrl: row['company_logo_url']?.toString(),
      createdAt: DateTime.parse(row['created_at'].toString()),
      updatedAt: row['updated_at'] != null ? DateTime.parse(row['updated_at'].toString()) : null,
    );
  }
}
