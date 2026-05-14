import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/pagination_result.dart';
import '../database/database_connection.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  VehicleRepositoryImpl(this._db);

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    try {
      // Check if public_car_id column exists
      final columnExists = await _checkPublicCarIdColumnExists();
      
      final publicCarId = (columnExists && (vehicle.publicCarId?.isNotEmpty ?? false)) 
          ? vehicle.publicCarId 
          : (columnExists ? _generatePublicCarId() : null);

      final sql = columnExists
          ? Sql.named('''
              INSERT INTO vehicles (id, customer_id, make, model, year, license_plate, vin, public_car_id, created_at)
              VALUES (@id, @customerId, @make, @model, @year, @licensePlate, @vin, @publicCarId, @createdAt)
              RETURNING *
            ''')
          : Sql.named('''
              INSERT INTO vehicles (id, customer_id, make, model, year, license_plate, vin, created_at)
              VALUES (@id, @customerId, @make, @model, @year, @licensePlate, @vin, @createdAt)
              RETURNING *
            ''');

      final parameters = columnExists
          ? {
              'id': vehicle.id.isEmpty ? _uuid.v4() : vehicle.id,
              'customerId': vehicle.customerId,
              'make': vehicle.make,
              'model': vehicle.model,
              'year': vehicle.year,
              'licensePlate': vehicle.licensePlate,
              'vin': vehicle.vin,
              'publicCarId': publicCarId,
              'createdAt': vehicle.createdAt,
            }
          : {
              'id': vehicle.id.isEmpty ? _uuid.v4() : vehicle.id,
              'customerId': vehicle.customerId,
              'make': vehicle.make,
              'model': vehicle.model,
              'year': vehicle.year,
              'licensePlate': vehicle.licensePlate,
              'vin': vehicle.vin,
              'createdAt': vehicle.createdAt,
            };

      final result = await _db.execute(sql, parameters: parameters);
      return _mapRowToVehicle(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create vehicle: $e');
    }
  }

  Future<bool> _checkPublicCarIdColumnExists() async {
    try {
      final result = await _db.execute('''
        SELECT EXISTS (
          SELECT FROM information_schema.columns 
          WHERE table_name = 'vehicles' 
          AND column_name = 'public_car_id'
        )
      ''');
      return result.first[0] as bool;
    } catch (e) {
      return false;
    }
  }

  String _generatePublicCarId() {
    // Generate a secure random token for public access
    final random = _uuid.v4();
    return 'CAR-$random';
  }

  @override
  Future<Vehicle?> findById(String id) async {
    try {
      final result = await _db.execute(
        Sql.named('SELECT * FROM vehicles WHERE id = @id'),
        parameters: {'id': id},
      );

      if (result.isEmpty) return null;
      return _mapRowToVehicle(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find vehicle by id: $e');
    }
  }

  @override
  Future<List<Vehicle>> findByCustomerId(String customerId) async {
    try {
      final result = await _db.execute(
        Sql.named('SELECT * FROM vehicles WHERE customer_id = @customerId ORDER BY created_at DESC'),
        parameters: {'customerId': customerId},
      );
      return result.map(_mapRowToVehicle).toList();
    } catch (e) {
      throw DatabaseException('Failed to find vehicles by customer id: $e');
    }
  }

  @override
  Future<List<Vehicle>> findAll() async {
    try {
      final result = await _db.execute('SELECT * FROM vehicles ORDER BY created_at DESC');
      return result.map(_mapRowToVehicle).toList();
    } catch (e) {
      throw DatabaseException('Failed to find all vehicles: $e');
    }
  }

  @override
  Future<PaginationResult<Vehicle>> findAllPaginated({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final offset = (page - 1) * limit;
      List<Vehicle> vehicles;
      int totalCount;

      if (search != null && search.isNotEmpty) {
        final searchPattern = '%$search%';
        // Get total count
        final countResult = await _db.execute(
          Sql.named('''
            SELECT COUNT(*) as count FROM vehicles
            WHERE license_plate ILIKE @search OR make ILIKE @search OR model ILIKE @search
          '''),
          parameters: {'search': searchPattern},
        );
        totalCount = countResult.first[0] as int;

        // Get paginated data
        final dataResult = await _db.execute(
          Sql.named('''
            SELECT * FROM vehicles
            WHERE license_plate ILIKE @search OR make ILIKE @search OR model ILIKE @search
            ORDER BY created_at DESC
            LIMIT @limit OFFSET @offset
          '''),
          parameters: {
            'search': searchPattern,
            'limit': limit,
            'offset': offset,
          },
        );
        vehicles = dataResult.map(_mapRowToVehicle).toList();
      } else {
        // Get total count
        final countResult = await _db.execute('SELECT COUNT(*) as count FROM vehicles');
        totalCount = countResult.first[0] as int;

        // Get paginated data
        final dataResult = await _db.execute(
          Sql.named('''
            SELECT * FROM vehicles
            ORDER BY created_at DESC
            LIMIT @limit OFFSET @offset
          '''),
          parameters: {
            'limit': limit,
            'offset': offset,
          },
        );
        vehicles = dataResult.map(_mapRowToVehicle).toList();
      }

      return PaginationResult(
        data: vehicles,
        totalCount: totalCount,
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw DatabaseException('Failed to get paginated vehicles: $e');
    }
  }

  @override
  Future<Vehicle> update(Vehicle vehicle) async {
    try {
      final result = await _db.execute(
        Sql.named('''
          UPDATE vehicles 
          SET customer_id = @customerId, make = @make, model = @model, year = @year, 
              license_plate = @licensePlate, vin = @vin, updated_at = @updatedAt
          WHERE id = @id
          RETURNING *
        '''),
        parameters: {
          'id': vehicle.id,
          'customerId': vehicle.customerId,
          'make': vehicle.make,
          'model': vehicle.model,
          'year': vehicle.year,
          'licensePlate': vehicle.licensePlate,
          'vin': vehicle.vin,
          'updatedAt': DateTime.now().toUtc(),
        },
      );

      return _mapRowToVehicle(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update vehicle: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.execute(
        Sql.named('DELETE FROM vehicles WHERE id = @id'),
        parameters: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete vehicle: $e');
    }
  }

  Vehicle _mapRowToVehicle(ResultRow row) {
    final data = row.toColumnMap();
    return Vehicle(
      id: data['id'].toString(),
      customerId: data['customer_id'].toString(),
      make: data['make'] as String,
      model: data['model'] as String,
      year: data['year'] as int,
      licensePlate: data['license_plate'] as String?,
      vin: data['vin'] as String?,
      publicCarId: data['public_car_id'] as String?,
      createdAt: data['created_at'] as DateTime,
      updatedAt: data['updated_at'] as DateTime?,
    );
  }
}
