import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/mechanic_assignment.dart';
import '../../domain/entities/mechanic_assignment_status.dart';
import '../../domain/repositories/mechanic_assignment_repository.dart';
import '../../core/errors/exceptions.dart';
import '../database/database_connection.dart';

class MechanicAssignmentRepositoryImpl implements MechanicAssignmentRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  MechanicAssignmentRepositoryImpl(this._db);

  @override
  Future<MechanicAssignment> create(MechanicAssignment assignment) async {
    try {
      final result = await _db.execute(
        Sql.named('''
          INSERT INTO mechanic_assignments (id, booking_id, mechanic_user_id, status, notes, assigned_at)
          VALUES (@id, @bookingId, @mechanicUserId, @status, @notes, @assignedAt)
          RETURNING *
        '''),
        parameters: {
          'id': assignment.id.isEmpty ? _uuid.v4() : assignment.id,
          'bookingId': assignment.bookingId,
          'mechanicUserId': assignment.mechanicUserId,
          'status': assignment.status.value,
          'notes': assignment.notes,
          'assignedAt': assignment.assignedAt,
        },
      );

      return _mapRowToMechanicAssignment(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create mechanic assignment: $e');
    }
  }

  @override
  Future<MechanicAssignment?> findById(String id) async {
    try {
      final result = await _db.execute(
        Sql.named('SELECT * FROM mechanic_assignments WHERE id = @id'),
        parameters: {'id': id},
      );

      if (result.isEmpty) return null;
      return _mapRowToMechanicAssignment(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find mechanic assignment by id: $e');
    }
  }

  @override
  Future<MechanicAssignment?> findByBookingId(String bookingId) async {
    try {
      final result = await _db.execute(
        Sql.named('SELECT * FROM mechanic_assignments WHERE booking_id = @bookingId'),
        parameters: {'bookingId': bookingId},
      );

      if (result.isEmpty) return null;
      return _mapRowToMechanicAssignment(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find mechanic assignment by booking id: $e');
    }
  }

  @override
  Future<List<MechanicAssignment>> findByMechanicUserId(String mechanicUserId) async {
    try {
      final result = await _db.execute(
        Sql.named('SELECT * FROM mechanic_assignments WHERE mechanic_user_id = @mechanicUserId ORDER BY assigned_at DESC'),
        parameters: {'mechanicUserId': mechanicUserId},
      );
      return result.map(_mapRowToMechanicAssignment).toList();
    } catch (e) {
      throw DatabaseException('Failed to find mechanic assignments by mechanic user id: $e');
    }
  }

  @override
  Future<MechanicAssignment> update(MechanicAssignment assignment) async {
    try {
      final result = await _db.execute(
        Sql.named('''
          UPDATE mechanic_assignments 
          SET status = @status, notes = @notes, updated_at = @updatedAt
          WHERE id = @id
          RETURNING *
        '''),
        parameters: {
          'id': assignment.id,
          'status': assignment.status.value,
          'notes': assignment.notes,
          'updatedAt': DateTime.now().toUtc(),
        },
      );

      return _mapRowToMechanicAssignment(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update mechanic assignment: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.execute(
        Sql.named('DELETE FROM mechanic_assignments WHERE id = @id'),
        parameters: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete mechanic assignment: $e');
    }
  }

  MechanicAssignment _mapRowToMechanicAssignment(ResultRow row) {
    final data = row.toColumnMap();
    return MechanicAssignment(
      id: data['id'].toString(),
      bookingId: data['booking_id'].toString(),
      mechanicUserId: data['mechanic_user_id'].toString(),
      status: MechanicAssignmentStatus.fromString(data['status'] is String ? data['status'] as String : data['status']?.toString() ?? 'ASSIGNED'),
      notes: data['notes'] is String ? data['notes'] as String? : null,
      assignedAt: data['assigned_at'] is DateTime ? data['assigned_at'] as DateTime : DateTime.parse(data['assigned_at'] as String),
      updatedAt: data['updated_at'] != null ? (data['updated_at'] is DateTime ? data['updated_at'] as DateTime : DateTime.parse(data['updated_at'] as String)) : null,
    );
  }
}
