import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../../core/errors/exceptions.dart';
import '../database/database_connection.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  ServiceRepositoryImpl(this._db);

  @override
  Future<Service> create(Service service) async {
    try {
      final result = await _db.execute(
        Sql.named('''
          INSERT INTO services (id, name, description, price_syp, estimated_duration_minutes, is_active, created_at)
          VALUES (@id, @name, @description, @priceSyp, @estimatedDurationMinutes, @isActive, @createdAt)
          RETURNING *
        '''),
        parameters: {
          'id': service.id.isEmpty ? _uuid.v4() : service.id,
          'name': service.name,
          'description': service.description,
          'priceSyp': service.priceSYP,
          'estimatedDurationMinutes': service.estimatedDurationMinutes,
          'isActive': service.isActive,
          'createdAt': service.createdAt,
        },
      );

      return _mapRowToService(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create service: $e');
    }
  }

  @override
  Future<Service?> findById(String id) async {
    try {
      final result = await _db.execute(
        Sql.named('SELECT * FROM services WHERE id = @id'),
        parameters: {'id': id},
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

      final result = await _db.execute(query);
      return result.map(_mapRowToService).toList();
    } catch (e) {
      throw DatabaseException('Failed to find all services: $e');
    }
  }

  @override
  Future<Service> update(Service service) async {
    try {
      final result = await _db.execute(
        Sql.named('''
          UPDATE services 
          SET name = @name, description = @description, price_syp = @priceSyp, 
              estimated_duration_minutes = @estimatedDurationMinutes, is_active = @isActive, updated_at = @updatedAt
          WHERE id = @id
          RETURNING *
        '''),
        parameters: {
          'id': service.id,
          'name': service.name,
          'description': service.description,
          'priceSyp': service.priceSYP,
          'estimatedDurationMinutes': service.estimatedDurationMinutes,
          'isActive': service.isActive,
          'updatedAt': DateTime.now().toUtc(),
        },
      );

      return _mapRowToService(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update service: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.execute(
        Sql.named('DELETE FROM services WHERE id = @id'),
        parameters: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete service: $e');
    }
  }

  Service _mapRowToService(ResultRow row) {
    final data = row.toColumnMap();
    return Service(
      id: data['id'].toString(),
      name: data['name'] as String,
      description: data['description'] as String?,
      priceSYP: (data['price_syp'] as num).toDouble(),
      estimatedDurationMinutes: data['estimated_duration_minutes'] as int?,
      createdAt: data['created_at'] as DateTime,
      updatedAt: data['updated_at'] as DateTime?,
      isActive: data['is_active'] as bool,
    );
  }
}
