import 'package:postgres/postgres.dart';
import '../../domain/entities/fixed_asset.dart';
import '../../domain/repositories/fixed_asset_repository.dart';
import '../database/database_connection.dart';

class FixedAssetRepositoryImpl implements FixedAssetRepository {
  final DatabaseConnection _db;

  FixedAssetRepositoryImpl(this._db);

  @override
  Future<FixedAsset> create(FixedAsset asset) async {
    final result = await _db.pool.execute('''
      INSERT INTO fixed_assets (name, acquisition_date, acquisition_cost, salvage_value, 
                                 useful_life_years, depreciation_method, current_net_book_value, location, status)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'name': asset.name,
      'acquisition_date': asset.acquisitionDate,
      'acquisition_cost': asset.acquisitionCost,
      'salvage_value': asset.salvageValue,
      'useful_life_years': asset.usefulLifeYears,
      'depreciation_method': asset.depreciationMethod,
      'current_net_book_value': asset.currentNetBookValue,
      'location': asset.location,
      'status': asset.status,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return asset.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<FixedAsset?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM fixed_assets WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToAsset(row);
  }

  @override
  Future<List<FixedAsset>> findAll() async {
    final result = await _db.pool.execute('''
      SELECT * FROM fixed_assets ORDER BY acquisition_date DESC
    ''');

    return result.map((row) => _mapRowToAsset(row)).toList();
  }

  @override
  Future<List<FixedAsset>> findByCategory(String category) async {
    final result = await _db.pool.execute('''
      SELECT * FROM fixed_assets WHERE category = \$1 ORDER BY acquisition_date DESC
    ''', parameters: {'category': category});

    return result.map((row) => _mapRowToAsset(row)).toList();
  }

  @override
  Future<List<FixedAsset>> findByStatus(String status) async {
    final result = await _db.pool.execute('''
      SELECT * FROM fixed_assets WHERE status = \$1 ORDER BY acquisition_date DESC
    ''', parameters: {'status': status});

    return result.map((row) => _mapRowToAsset(row)).toList();
  }

  @override
  Future<FixedAsset> update(FixedAsset asset) async {
    await _db.pool.execute('''
      UPDATE fixed_assets
      SET name = \$1, acquisition_date = \$2, acquisition_cost = \$3, salvage_value = \$4,
          useful_life_years = \$5, depreciation_method = \$6, current_net_book_value = \$7,
          location = \$8, status = \$9, updated_at = NOW()
      WHERE id = \$10
    ''', parameters: {
      'name': asset.name,
      'acquisition_date': asset.acquisitionDate,
      'acquisition_cost': asset.acquisitionCost,
      'salvage_value': asset.salvageValue,
      'useful_life_years': asset.usefulLifeYears,
      'depreciation_method': asset.depreciationMethod,
      'current_net_book_value': asset.currentNetBookValue,
      'location': asset.location,
      'status': asset.status,
      'id': asset.id,
    });

    return asset.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM fixed_assets WHERE id = \$1
    ''', parameters: {'id': id});
  }

  @override
  Future<void> runDepreciationWithJournal(
    List<FixedAsset> assets,
    String createdBy,
  ) async {
    await _db.runInTransaction((session) async {
      // Calculate total depreciation for all assets
      double totalDepreciation = 0;
      final assetEntries = <Map<String, dynamic>>[];

      for (final asset in assets) {
        // Skip if asset is fully depreciated
        if (asset.currentNetBookValue != null && asset.currentNetBookValue! <= asset.salvageValue) {
          continue;
        }

        // Calculate monthly depreciation
        double monthlyDepreciation;
        if (asset.depreciationMethod == 'straight_line') {
          monthlyDepreciation = (asset.acquisitionCost - asset.salvageValue) / (asset.usefulLifeYears * 12);
        } else if (asset.depreciationMethod == 'declining_balance') {
          monthlyDepreciation = (asset.currentNetBookValue ?? asset.acquisitionCost) * 2 / (asset.usefulLifeYears * 12);
        } else {
          monthlyDepreciation = (asset.acquisitionCost - asset.salvageValue) / (asset.usefulLifeYears * 12);
        }

        // Update asset's net book value
        final newNetBookValue = (asset.currentNetBookValue ?? asset.acquisitionCost) - monthlyDepreciation;
        await session.execute(
          Sql.named('''
            UPDATE fixed_assets
            SET current_net_book_value = @newNetBookValue,
                updated_at = @updatedAt
            WHERE id = @id
          '''),
          parameters: {
            'newNetBookValue': newNetBookValue,
            'updatedAt': DateTime.now().toUtc(),
            'id': asset.id,
          },
        );

        totalDepreciation += monthlyDepreciation;
        assetEntries.add({
          'assetId': asset.id,
          'depreciation': monthlyDepreciation,
        });
      }

      if (totalDepreciation > 0) {
        // Create journal entry
        final journalEntryResult = await session.execute(
          Sql.named('''
            INSERT INTO journal_entries (entry_date, reference, description, created_by, created_at)
            VALUES (@entryDate, @reference, @description, @createdBy, @createdAt)
            RETURNING id
          '''),
          parameters: {
            'entryDate': DateTime.now(),
            'reference': 'DEPR-${DateTime.now().millisecondsSinceEpoch}',
            'description': 'إهلاك شهري للأصول الثابتة',
            'createdBy': createdBy,
            'createdAt': DateTime.now().toUtc(),
          },
        );
        final journalEntryId = journalEntryResult.first[0] as int;

        // Create journal lines for each asset
        for (final entry in assetEntries) {
          await session.execute(
            Sql.named('''
              INSERT INTO journal_lines (entry_id, account_id, debit, credit, description, source_id)
              VALUES (@entryId, @accountId, @debit, @credit, @description, @sourceId)
            '''),
            parameters: {
              'entryId': journalEntryId,
              'accountId': 1, // Would need to get from settings
              'debit': entry['depreciation'],
              'credit': 0,
              'description': 'إهلاك الأصل ${entry['assetId']}',
              'sourceId': entry['assetId'].toString(),
            },
          );
        }
      }
    });
  }

  FixedAsset _mapRowToAsset(List<dynamic> row) {
    return FixedAsset(
      id: row[0] as int,
      name: row[1] as String,
      acquisitionDate: row[2] as DateTime,
      acquisitionCost: row[3] as double,
      salvageValue: row[4] as double,
      usefulLifeYears: row[5] as int,
      depreciationMethod: row[6] as String,
      currentNetBookValue: row[7] as double?,
      location: row[8] as String?,
      status: row[9] as String,
      createdAt: row[10] as DateTime,
      updatedAt: row[11] as DateTime,
    );
  }
}
