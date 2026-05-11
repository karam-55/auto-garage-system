import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/service.dart';
import '../../../domain/repositories/service_repository.dart';
import '../../../core/errors/exceptions.dart';
import '../database/database_connection.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  ServiceRepositoryImpl(this._db);

  @override
  Future<Service> create(Service service) async {
    try {
      final result = await _db.connection.query('''
        INSERT INTO services (id, name, description, price_syp, estimated_duration_minutes, is_active, created_at)
        VALUES (@id, @name, @description, @priceSyp, @estimatedDurationMinutes, @isActive, @createdAt)
        RETURNING *
      ''', substitutionValues: {
        'id': service.id.isEmpty ? _uuid.v4() : service.id,
        'name': service.name,
        'description': service.description,
        'priceSyp': service.priceSYP,
        'estimatedDurationMinutes': service.estimatedDurationMinutes,
        'isActive': service.isActive,
        'createdAt': service.createdAt,
      });

      return _mapRowToService(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create service: $e');
    }
  }

  @override
  Future<Service?> findById(String id) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM services WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (result.isEmpty) return null;
      return _mapRowToService(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find service by id: $e');
    }
  }

  @override
  Future<List<Service>> findAll({bool activeOnly = true}) async {
    try {
      String query = 'SELECT * FROM services';
      if (activeOnly) {
        query += ' WHERE is_active = true';
      }
      query += ' ORDER BY created_at DESC';

      final result = await _db.connection.query(query);
      return result.map(_mapRowToService).toList();
    } catch (e) {
      throw DatabaseException('Failed to find all services: $e');
    }
  }

  @override
  Future<Service> update(Service service) async {
    try {
      final result = await _db.connection.query('''
        UPDATE services 
        SET name = @name, description = @description, price_syp = @priceSyp, 
            estimated_duration_minutes = @estimatedDurationMinutes, is_active = @isActive, updated_at = @updatedAt
        WHERE id = @id
        RETURNING *
      ''', substitutionValues: {
        'id': service.id,
        'name': service.name,
        'description': service.description,
        'priceSyp': service.priceSYP,
        'estimatedDurationMinutes': service.estimatedDurationMinutes,
        'isActive': service.isActive,
        'updatedAt': DateTime.now().toUtc(),
      });

      return _mapRowToService(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update service: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.connection.query(
        'DELETE FROM services WHERE id = @id',
        substitutionValues: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete service: $e');
    }
  }

  Service _mapRowToService(PostgreSQLResultRow row) {
    return Service(
      id: row['id'].toString(),
      name: row['name'],
      description: row['description'],
      priceSYP: row['price_syp'],
      estimatedDurationMinutes: row['estimated_duration_minutes'],
      createdAt: row['created_at'],
      updatedAt: row['updated_at'],
      isActive: row['is_active'],
    );
  }
}
