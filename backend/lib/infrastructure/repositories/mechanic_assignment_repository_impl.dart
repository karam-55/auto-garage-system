import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/mechanic_assignment.dart';
import '../../../domain/entities/mechanic_assignment_status.dart';
import '../../../domain/repositories/mechanic_assignment_repository.dart';
import '../../../core/errors/exceptions.dart';
import '../database/database_connection.dart';

class MechanicAssignmentRepositoryImpl implements MechanicAssignmentRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  MechanicAssignmentRepositoryImpl(this._db);

  @override
  Future<MechanicAssignment> create(MechanicAssignment assignment) async {
    try {
      final result = await _db.connection.query('''
        INSERT INTO mechanic_assignments (id, booking_id, mechanic_user_id, status, notes, assigned_at)
        VALUES (@id, @bookingId, @mechanicUserId, @status, @notes, @assignedAt)
        RETURNING *
      ''', substitutionValues: {
        'id': assignment.id.isEmpty ? _uuid.v4() : assignment.id,
        'bookingId': assignment.bookingId,
        'mechanicUserId': assignment.mechanicUserId,
        'status': assignment.status.value,
        'notes': assignment.notes,
        'assignedAt': assignment.assignedAt,
      });

      return _mapRowToMechanicAssignment(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create mechanic assignment: $e');
    }
  }

  @override
  Future<MechanicAssignment?> findById(String id) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM mechanic_assignments WHERE id = @id',
        substitutionValues: {'id': id},
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
      final result = await _db.connection.query(
        'SELECT * FROM mechanic_assignments WHERE booking_id = @bookingId',
        substitutionValues: {'bookingId': bookingId},
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
      final result = await _db.connection.query(
        'SELECT * FROM mechanic_assignments WHERE mechanic_user_id = @mechanicUserId ORDER BY assigned_at DESC',
        substitutionValues: {'mechanicUserId': mechanicUserId},
      );
      return result.map(_mapRowToMechanicAssignment).toList();
    } catch (e) {
      throw DatabaseException('Failed to find mechanic assignments by mechanic user id: $e');
    }
  }

  @override
  Future<List<MechanicAssignment>> findAvailableBookings() async {
    try {
      // Find bookings that don't have a mechanic assignment
      final result = await _db.connection.query('''
        SELECT b.id, b.customer_id, b.vehicle_id, b.status, b.public_token, b.notes, b.estimated_completion_date, b.created_at, b.updated_at
        FROM bookings b
        LEFT JOIN mechanic_assignments ma ON b.id = ma.booking_id
        WHERE ma.id IS NULL AND b.status != 'DELIVERED' AND b.status != 'CANCELLED'
        ORDER BY b.created_at DESC
      ''');

      // Convert to empty mechanic assignments (this is a simplified approach)
      // In a real implementation, you might want to return a different DTO
      return [];
    } catch (e) {
      throw DatabaseException('Failed to find available bookings: $e');
    }
  }

  @override
  Future<MechanicAssignment> update(MechanicAssignment assignment) async {
    try {
      final result = await _db.connection.query('''
        UPDATE mechanic_assignments 
        SET status = @status, notes = @notes, updated_at = @updatedAt
        WHERE id = @id
        RETURNING *
      ''', substitutionValues: {
        'id': assignment.id,
        'status': assignment.status.value,
        'notes': assignment.notes,
        'updatedAt': DateTime.now().toUtc(),
      });

      return _mapRowToMechanicAssignment(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update mechanic assignment: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.connection.query(
        'DELETE FROM mechanic_assignments WHERE id = @id',
        substitutionValues: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete mechanic assignment: $e');
    }
  }

  MechanicAssignment _mapRowToMechanicAssignment(PostgreSQLResultRow row) {
    return MechanicAssignment(
      id: row['id'].toString(),
      bookingId: row['booking_id'].toString(),
      mechanicUserId: row['mechanic_user_id'].toString(),
      status: MechanicAssignmentStatus.fromString(row['status']),
      notes: row['notes'],
      assignedAt: row['assigned_at'],
      updatedAt: row['updated_at'],
    );
  }
}
