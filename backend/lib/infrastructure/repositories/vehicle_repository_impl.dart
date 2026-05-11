import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../core/errors/exceptions.dart';
import '../database/database_connection.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  VehicleRepositoryImpl(this._db);

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    try {
      final result = await _db.connection.query('''
        INSERT INTO vehicles (id, customer_id, make, model, year, license_plate, vin, created_at)
        VALUES (@id, @customerId, @make, @model, @year, @licensePlate, @vin, @createdAt)
        RETURNING *
      ''', substitutionValues: {
        'id': vehicle.id.isEmpty ? _uuid.v4() : vehicle.id,
        'customerId': vehicle.customerId,
        'make': vehicle.make,
        'model': vehicle.model,
        'year': vehicle.year,
        'licensePlate': vehicle.licensePlate,
        'vin': vehicle.vin,
        'createdAt': vehicle.createdAt,
      });

      return _mapRowToVehicle(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create vehicle: $e');
    }
  }

  @override
  Future<Vehicle?> findById(String id) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM vehicles WHERE id = @id',
        substitutionValues: {'id': id},
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
      final result = await _db.connection.query(
        'SELECT * FROM vehicles WHERE customer_id = @customerId ORDER BY created_at DESC',
        substitutionValues: {'customerId': customerId},
      );
      return result.map(_mapRowToVehicle).toList();
    } catch (e) {
      throw DatabaseException('Failed to find vehicles by customer id: $e');
    }
  }

  @override
  Future<List<Vehicle>> findAll() async {
    try {
      final result = await _db.connection.query('SELECT * FROM vehicles ORDER BY created_at DESC');
      return result.map(_mapRowToVehicle).toList();
    } catch (e) {
      throw DatabaseException('Failed to find all vehicles: $e');
    }
  }

  @override
  Future<Vehicle> update(Vehicle vehicle) async {
    try {
      final result = await _db.connection.query('''
        UPDATE vehicles 
        SET customer_id = @customerId, make = @make, model = @model, year = @year, 
            license_plate = @licensePlate, vin = @vin, updated_at = @updatedAt
        WHERE id = @id
        RETURNING *
      ''', substitutionValues: {
        'id': vehicle.id,
        'customerId': vehicle.customerId,
        'make': vehicle.make,
        'model': vehicle.model,
        'year': vehicle.year,
        'licensePlate': vehicle.licensePlate,
        'vin': vehicle.vin,
        'updatedAt': DateTime.now().toUtc(),
      });

      return _mapRowToVehicle(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update vehicle: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.connection.query(
        'DELETE FROM vehicles WHERE id = @id',
        substitutionValues: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete vehicle: $e');
    }
  }

  Vehicle _mapRowToVehicle(PostgreSQLResultRow row) {
    return Vehicle(
      id: row['id'].toString(),
      customerId: row['customer_id'].toString(),
      make: row['make'],
      model: row['model'],
      year: row['year'],
      licensePlate: row['license_plate'],
      vin: row['vin'],
      createdAt: row['created_at'],
      updatedAt: row['updated_at'],
    );
  }
}
