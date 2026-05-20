import 'package:postgres/postgres.dart';
import '../../domain/entities/maintenance_contract.dart';
import '../../domain/repositories/maintenance_contract_repository.dart';
import '../database/database_connection.dart';

class MaintenanceContractRepositoryImpl implements MaintenanceContractRepository {
  final DatabaseConnection _db;

  MaintenanceContractRepositoryImpl(this._db);

  @override
  Future<MaintenanceContract> create(MaintenanceContract contract) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''
          INSERT INTO maintenance_contracts (asset_id, contract_number, start_date, end_date, provider, cost, terms, status, created_at)
          VALUES (@assetId, @contractNumber, @startDate, @endDate, @provider, @cost, @terms, @status, @createdAt)
          RETURNING id, created_at'''),
        parameters: {
          'assetId': contract.assetId,
          'contractNumber': contract.contractNumber,
          'startDate': contract.startDate,
          'endDate': contract.endDate,
          'provider': contract.provider,
          'cost': contract.cost,
          'terms': contract.terms,
          'status': contract.status,
          'createdAt': contract.createdAt,
        },
      );
      final row = result.first;
      return contract.copyWith(
        id: row[0] as int,
        createdAt: row[1] as DateTime,
      );
    });
  }

  @override
  Future<MaintenanceContract?> findById(int id) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''SELECT id, asset_id, contract_number, start_date, end_date, provider, cost, terms, status, created_at, updated_at
           FROM maintenance_contracts WHERE id = @id'''),
        parameters: {'id': id},
      );
      if (result.isEmpty) return null;
      return _mapRowToContract(result.first);
    });
  }

  @override
  Future<List<MaintenanceContract>> findByAssetId(int assetId) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''SELECT id, asset_id, contract_number, start_date, end_date, provider, cost, terms, status, created_at, updated_at
           FROM maintenance_contracts WHERE asset_id = @assetId ORDER BY start_date DESC'''),
        parameters: {'assetId': assetId},
      );
      return result.map(_mapRowToContract).toList();
    });
  }

  @override
  Future<List<MaintenanceContract>> findByCustomerId(String customerId) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''SELECT id, asset_id, contract_number, start_date, end_date, provider, cost, terms, status, created_at, updated_at
           FROM maintenance_contracts WHERE customer_id = @customerId ORDER BY start_date DESC'''),
        parameters: {'customerId': customerId},
      );
      return result.map(_mapRowToContract).toList();
    });
  }

  @override
  Future<List<MaintenanceContract>> findByVehicleId(String vehicleId) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''SELECT id, asset_id, contract_number, start_date, end_date, provider, cost, terms, status, created_at, updated_at
           FROM maintenance_contracts WHERE vehicle_id = @vehicleId ORDER BY start_date DESC'''),
        parameters: {'vehicleId': vehicleId},
      );
      return result.map(_mapRowToContract).toList();
    });
  }

  @override
  Future<List<MaintenanceContract>> findDueContracts() async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, asset_id, contract_number, start_date, end_date, provider, cost, terms, status, created_at, updated_at
           FROM maintenance_contracts 
           WHERE next_service_due <= CURRENT_DATE AND end_date >= CURRENT_DATE
           ORDER BY next_service_due ASC''',
      );
      return result.map(_mapRowToContract).toList();
    });
  }

  @override
  Future<List<MaintenanceContract>> findByStatus(String status) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''SELECT id, asset_id, contract_number, start_date, end_date, provider, cost, terms, status, created_at, updated_at
           FROM maintenance_contracts WHERE status = @status ORDER BY start_date DESC'''),
        parameters: {'status': status},
      );
      return result.map(_mapRowToContract).toList();
    });
  }

  @override
  Future<List<MaintenanceContract>> findAll() async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, asset_id, contract_number, start_date, end_date, provider, cost, terms, status, created_at, updated_at
           FROM maintenance_contracts ORDER BY start_date DESC''',
      );
      return result.map(_mapRowToContract).toList();
    });
  }

  @override
  Future<MaintenanceContract> update(MaintenanceContract contract) async {
    return await _db.runInTransaction((session) async {
      await session.execute(
        Sql.named('''UPDATE maintenance_contracts SET
           asset_id = @assetId,
           contract_number = @contractNumber,
           start_date = @startDate,
           end_date = @endDate,
           provider = @provider,
           cost = @cost,
           terms = @terms,
           status = @status,
           updated_at = NOW()
           WHERE id = @id'''),
        parameters: {
          'id': contract.id,
          'assetId': contract.assetId,
          'contractNumber': contract.contractNumber,
          'startDate': contract.startDate,
          'endDate': contract.endDate,
          'provider': contract.provider,
          'cost': contract.cost,
          'terms': contract.terms,
          'status': contract.status,
        },
      );
      return contract.copyWith(updatedAt: DateTime.now());
    });
  }

  @override
  Future<void> delete(int id) async {
    return await _db.runInTransaction((session) async {
      await session.execute(Sql.named('DELETE FROM maintenance_contracts WHERE id = @id'), parameters: {'id': id});
    });
  }

  MaintenanceContract _mapRowToContract(List<dynamic> row) {
    return MaintenanceContract(
      id: row[0] as int,
      assetId: row[1] as int,
      contractNumber: row[2] as String,
      startDate: row[3] as DateTime,
      endDate: row[4] as DateTime,
      provider: row[5] as String?,
      cost: row[6] != null ? (row[6] as num).toDouble() : null,
      terms: row[7] as String?,
      status: row[8] as String,
      createdAt: row[9] as DateTime,
      updatedAt: row[10] as DateTime?,
    );
  }
}
