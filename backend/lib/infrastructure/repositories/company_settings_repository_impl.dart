import 'package:postgres/postgres.dart';
import '../../domain/entities/company_settings.dart';
import '../../domain/repositories/company_settings_repository.dart';
import '../../core/errors/exceptions.dart';
import '../database/database_connection.dart';

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
      final row = result.first.toColumnMap();
      return _mapRowToCompanySettings(row);
    } catch (e) {
      throw DatabaseException('Failed to get company settings: $e');
    }
  }

  @override
  Future<CompanySettings> createSettings(CompanySettings settings) async {
    try {
      final result = await _db.execute(
        Sql.named('''
          INSERT INTO company_settings (company_name, company_logo_url)
          VALUES (@companyName, @companyLogoUrl)
          RETURNING *
        '''),
        parameters: {
          'companyName': settings.companyName,
          'companyLogoUrl': settings.companyLogoUrl,
        },
      );

      final row = result.first.toColumnMap();
      return _mapRowToCompanySettings(row);
    } catch (e) {
      throw DatabaseException('Failed to create company settings: $e');
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

      final row = result.first.toColumnMap();
      return _mapRowToCompanySettings(row);
    } catch (e) {
      throw DatabaseException('Failed to update company settings: $e');
    }
  }

  CompanySettings _mapRowToCompanySettings(Map<String, dynamic> row) {
    return CompanySettings(
      id: row['id'] as int,
      companyName: row['company_name'] as String,
      companyLogoUrl: row['company_logo_url'] as String?,
      createdAt: row['created_at'] as DateTime,
      updatedAt: row['updated_at'] as DateTime?,
    );
  }
}
