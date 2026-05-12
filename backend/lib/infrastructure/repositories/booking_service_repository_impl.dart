import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/repositories/booking_service_repository.dart';
import '../../core/errors/exceptions.dart';
import '../database/database_connection.dart';

class BookingServiceRepositoryImpl implements BookingServiceRepository {
  final DatabaseConnection _db;
  final Uuid _uuid = const Uuid();

  BookingServiceRepositoryImpl(this._db);

  @override
  Future<BookingService> create(BookingService bookingService) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('''
          INSERT INTO booking_services (id, booking_id, service_id, price_syp, notes)
          VALUES (@id, @bookingId, @serviceId, @priceSyp, @notes)
          RETURNING *
        '''),
        parameters: {
          'id': bookingService.id.isEmpty ? _uuid.v4() : bookingService.id,
          'bookingId': bookingService.bookingId,
          'serviceId': bookingService.serviceId,
          'priceSyp': bookingService.priceSYP,
          'notes': bookingService.notes,
        },
      );

      return _mapRowToBookingService(result.first);
    } catch (e) {
      throw DatabaseException('Failed to create booking service: $e');
    }
  }

  @override
  Future<BookingService?> findById(String id) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('SELECT * FROM booking_services WHERE id = @id'),
        parameters: {'id': id},
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
      final result = await _db.connection.execute(
        Sql.named('SELECT * FROM booking_services WHERE booking_id = @bookingId'),
        parameters: {'bookingId': bookingId},
      );
      return result.map(_mapRowToBookingService).toList();
    } catch (e) {
      throw DatabaseException('Failed to find booking services by booking id: $e');
    }
  }

  @override
  Future<List<BookingService>> findByBookingIds(List<String> bookingIds) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('SELECT * FROM booking_services WHERE booking_id = ANY(@bookingIds)'),
        parameters: {'bookingIds': bookingIds},
      );
      return result.map(_mapRowToBookingService).toList();
    } catch (e) {
      throw DatabaseException('Failed to find booking services by booking ids: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _db.connection.execute(
        Sql.named('DELETE FROM booking_services WHERE id = @id'),
        parameters: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete booking service: $e');
    }
  }

  @override
  Future<void> deleteByBookingId(String bookingId) async {
    try {
      await _db.connection.execute(
        Sql.named('DELETE FROM booking_services WHERE booking_id = @bookingId'),
        parameters: {'bookingId': bookingId},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete booking services by booking id: $e');
    }
  }

  BookingService _mapRowToBookingService(ResultRow row) {
    final data = row.toColumnMap();
    return BookingService(
      id: data['id'].toString(),
      bookingId: data['booking_id'].toString(),
      serviceId: data['service_id'].toString(),
      priceSYP: (data['price_syp'] as num).toDouble(),
      notes: data['notes'] as String?,
    );
  }
}
