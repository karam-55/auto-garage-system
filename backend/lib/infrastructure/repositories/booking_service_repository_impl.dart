import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/booking_service.dart';
import '../../../domain/repositories/booking_service_repository.dart';
import '../../../core/errors/exceptions.dart';
import '../database/database_connection.dart';

class BookingServiceRepositoryImpl implements BookingServiceRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  BookingServiceRepositoryImpl(this._db);

  @override
  Future<BookingService> create(BookingService bookingService) async {
    try {
      final result = await _db.connection.query('''
        INSERT INTO booking_services (id, booking_id, service_id, price_syp, notes)
        VALUES (@id, @bookingId, @serviceId, @priceSyp, @notes)
        RETURNING *
      ''', substitutionValues: {
        'id': bookingService.id.isEmpty ? _uuid.v4() : bookingService.id,
        'bookingId': bookingService.bookingId,
        'serviceId': bookingService.serviceId,
        'priceSyp': bookingService.priceSYP,
        'notes': bookingService.notes,
      });

      return _mapRowToBookingService(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create booking service: $e');
    }
  }

  @override
  Future<BookingService?> findById(String id) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM booking_services WHERE id = @id',
        substitutionValues: {'id': id},
      );

      if (result.isEmpty) return null;
      return _mapRowToBookingService(result.first);
    } catch (e) {
      throw DatabaseException('Failed to find booking service by id: $e');
    }
  }

  @override
  Future<List<BookingService>> findByBookingId(String bookingId) async {
    try {
      final result = await _db.connection.query(
        'SELECT * FROM booking_services WHERE booking_id = @bookingId',
        substitutionValues: {'bookingId': bookingId},
      );
      return result.map(_mapRowToBookingService).toList();
    } catch (e) {
      throw DatabaseException('Failed to find booking services by booking id: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.connection.query(
        'DELETE FROM booking_services WHERE id = @id',
        substitutionValues: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete booking service: $e');
    }
  }

  @override
  Future<void> deleteByBookingId(String bookingId) async {
    try {
      await _db.connection.query(
        'DELETE FROM booking_services WHERE booking_id = @bookingId',
        substitutionValues: {'bookingId': bookingId},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete booking services by booking id: $e');
    }
  }

  BookingService _mapRowToBookingService(PostgreSQLResultRow row) {
    return BookingService(
      id: row['id'].toString(),
      bookingId: row['booking_id'].toString(),
      serviceId: row['service_id'].toString(),
      priceSYP: row['price_syp'],
      notes: row['notes'],
    );
  }
}
