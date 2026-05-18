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

class MaintenanceContractRepositoryImpl implements MaintenanceContractRepository {
  final DatabaseConnection _db;

  MaintenanceContractRepositoryImpl(this._db);

  @override
  Future<MaintenanceContract> create(MaintenanceContract contract) async {
    final result = await _db.pool.execute('''
      INSERT INTO maintenance_contracts (customer_id, vehicle_id, contract_number, start_date, end_date,
                                       service_interval_km, service_interval_days, last_service_km, next_service_due, notes, created_by)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'customer_id': contract.customerId,
      'vehicle_id': contract.vehicleId,
      'contract_number': contract.contractNumber,
      'start_date': contract.startDate,
      'end_date': contract.endDate,
      'service_interval_km': contract.serviceIntervalKm,
      'service_interval_days': contract.serviceIntervalDays,
      'last_service_km': contract.lastServiceKm,
      'next_service_due': contract.nextServiceDue,
      'notes': contract.notes,
      'created_by': contract.createdBy,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return contract.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<MaintenanceContract?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM maintenance_contracts WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToContract(row);
  }

  @override
  Future<List<MaintenanceContract>> findByCustomerId(String customerId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM maintenance_contracts WHERE customer_id = \$1 ORDER BY start_date DESC
    ''', parameters: {'customer_id': customerId});

    return result.map((row) => _mapRowToContract(row)).toList();
  }

  @override
  Future<List<MaintenanceContract>> findByVehicleId(String vehicleId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM maintenance_contracts WHERE vehicle_id = \$1 ORDER BY start_date DESC
    ''', parameters: {'vehicle_id': vehicleId});

    return result.map((row) => _mapRowToContract(row)).toList();
  }

  @override
  Future<List<MaintenanceContract>> findDueContracts() async {
    final result = await _db.pool.execute('''
      SELECT * FROM maintenance_contracts 
      WHERE next_service_due <= CURRENT_DATE AND end_date >= CURRENT_DATE
      ORDER BY next_service_due ASC
    ''');

    return result.map((row) => _mapRowToContract(row)).toList();
  }

  @override
  Future<MaintenanceContract> update(MaintenanceContract contract) async {
    await _db.pool.execute('''
      UPDATE maintenance_contracts
      SET customer_id = \$1, vehicle_id = \$2, contract_number = \$3, start_date = \$4, end_date = \$5,
          service_interval_km = \$6, service_interval_days = \$7, last_service_km = \$8,
          next_service_due = \$9, notes = \$10, updated_at = NOW()
      WHERE id = \$11
    ''', parameters: {
      'customer_id': contract.customerId,
      'vehicle_id': contract.vehicleId,
      'contract_number': contract.contractNumber,
      'start_date': contract.startDate,
      'end_date': contract.endDate,
      'service_interval_km': contract.serviceIntervalKm,
      'service_interval_days': contract.serviceIntervalDays,
      'last_service_km': contract.lastServiceKm,
      'next_service_due': contract.nextServiceDue,
      'notes': contract.notes,
      'id': contract.id,
    });

    return contract.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM maintenance_contracts WHERE id = \$1
    ''', parameters: {'id': id});
  }

  MaintenanceContract _mapRowToContract(List<dynamic> row) {
    return MaintenanceContract(
      id: row[0] as int,
      customerId: row[1] as String,
      vehicleId: row[2] as String,
      contractNumber: row[3] as String?,
      startDate: row[4] as DateTime,
      endDate: row[5] as DateTime,
      serviceIntervalKm: row[6] as int?,
      serviceIntervalDays: row[7] as int?,
      lastServiceKm: row[8] as int?,
      nextServiceDue: row[9] as DateTime?,
      notes: row[10] as String?,
      createdBy: row[11] as String?,
      createdAt: row[12] as DateTime,
      updatedAt: row[13] as DateTime,
    );
  }
}
