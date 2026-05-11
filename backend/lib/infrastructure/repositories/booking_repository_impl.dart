import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../core/errors/exceptions.dart';
import '../database/database_connection.dart';

class BookingRepositoryImpl implements BookingRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  BookingRepositoryImpl(this._db);

  @override
  Future<Booking> create(Booking booking) async {
    try {
      final result = await _db.connection.query('''
        INSERT INTO bookings (id, customer_id, vehicle_id, status, public_token, notes, estimated_completion_date, created_at)
        VALUES (@id, @customerId, @vehicleId, @status, @publicToken, @notes, @estimatedCompletionDate, @createdAt)
        RETURNING *
      ''', substitutionValues: {
        'id': booking.id.isEmpty ? _uuid.v4() : booking.id,
        'customerId': booking.customerId,
        'vehicleId': booking.vehicleId,
        'status': booking.status.value,
        'publicToken': booking.publicToken.isEmpty ? _generatePublicToken() : booking.publicToken,
        'notes': booking.notes,
        'estimatedCompletionDate': booking.estimatedCompletionDate,
        'createdAt': booking.createdAt,
      });

      return _mapRowToBooking(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create booking: $e');
    }
  }

  @override
  Future<Booking?> findById(String id) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM bookings WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (result.isEmpty) return null;
      return _mapRowToBooking(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find booking by id: $e');
    }
  }

  @override
  Future<Booking?> findByPublicToken(String publicToken) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM bookings WHERE public_token = @publicToken',
        substitutionValues: {'publicToken': publicToken},
      );

      if (result.isEmpty) return null;
      return _mapRowToBooking(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find booking by public token: $e');
    }
  }

  @override
  Future<List<Booking>> findByCustomerId(String customerId) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM bookings WHERE customer_id = @customerId ORDER BY created_at DESC',
        substitutionValues: {'customerId': customerId},
      );
      return result.map(_mapRowToBooking).toList();
    } catch (e) {
      throw DatabaseException('Failed to find bookings by customer id: $e');
    }
  }

  @override
  Future<List<Booking>> findByVehicleId(String vehicleId) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM bookings WHERE vehicle_id = @vehicleId ORDER BY created_at DESC',
        substitutionValues: {'vehicleId': vehicleId},
      );
      return result.map(_mapRowToBooking).toList();
    } catch (e) {
      throw DatabaseException('Failed to find bookings by vehicle id: $e');
    }
  }

  @override
  Future<List<Booking>> findAll() async {
    try {
      final result = await _db.connection.query('SELECT * FROM bookings ORDER BY created_at DESC');
      return result.map(_mapRowToBooking).toList();
    } catch (e) {
      throw DatabaseException('Failed to find all bookings: $e');
    }
  }

  @override
  Future<List<Booking>> findByStatus(String status) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM bookings WHERE status = @status ORDER BY created_at DESC',
        substitutionValues: {'status': status},
      );
      return result.map(_mapRowToBooking).toList();
    } catch (e) {
      throw DatabaseException('Failed to find bookings by status: $e');
    }
  }

  @override
  Future<Booking> update(Booking booking) async {
    try {
      final result = await _db.connection.query('''
        UPDATE bookings 
        SET customer_id = @customerId, vehicle_id = @vehicleId, status = @status, 
            notes = @notes, estimated_completion_date = @estimatedCompletionDate, updated_at = @updatedAt
        WHERE id = @id
        RETURNING *
      ''', substitutionValues: {
        'id': booking.id,
        'customerId': booking.customerId,
        'vehicleId': booking.vehicleId,
        'status': booking.status.value,
        'notes': booking.notes,
        'estimatedCompletionDate': booking.estimatedCompletionDate,
        'updatedAt': DateTime.now().toUtc(),
      });

      return _mapRowToBooking(result.first);
    } catch (e) {
      throw DatabaseException('Failed to update booking: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.connection.query(
        'DELETE FROM bookings WHERE id = @id',
        substitutionValues: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete booking: $e');
    }
  }

  String _generatePublicToken() {
    return _uuid.v4().replaceAll('-', '');
  }

  Booking _mapRowToBooking(ResultRow row) {
    return Booking(
      id: row['id'] as String,
      customerId: row['customer_id'] as String,
      vehicleId: row['vehicle_id'] as String,
      status: BookingStatus.fromString(row['status'] as String),
      publicToken: row['public_token'] as String,
      notes: row['notes'] as String?,
      createdAt: row['created_at'] as DateTime,
      updatedAt: row['updated_at'] as DateTime?,
      estimatedCompletionDate: row['estimated_completion_date'] as DateTime?,
    );
  }
}
