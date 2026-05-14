import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/entities/booking_status.dart';
import '../../core/errors/failures.dart';
import '../../infrastructure/database/database_connection.dart';
import '../../domain/repositories/booking_invoice_data_repository.dart';

class CreateBookingUseCase {
  final DatabaseConnection _db;

  CreateBookingUseCase(this._db);

  Future<Booking> execute(Booking booking, List<BookingService> services) async {
    try {
      return await _db.runInTransaction((session) async {
        // Create booking within transaction
        final publicToken = booking.publicToken.isEmpty
            ? const Uuid().v4().replaceAll('-', '')
            : booking.publicToken;
        final bookingId = booking.id.isEmpty ? const Uuid().v4() : booking.id;

        final bookingResult = await session.execute(
          Sql.named('''
            INSERT INTO bookings (id, customer_id, vehicle_id, status, public_token, notes, estimated_completion_date, created_at)
            VALUES (@id, @customerId, @vehicleId, @status, @publicToken, @notes, @estimatedCompletionDate, @createdAt)
            RETURNING *
          '''),
          parameters: {
            'id': bookingId,
            'customerId': booking.customerId,
            'vehicleId': booking.vehicleId,
            'status': booking.status.value,
            'publicToken': publicToken,
            'notes': booking.notes,
            'estimatedCompletionDate': booking.estimatedCompletionDate,
            'createdAt': booking.createdAt,
          },
        );

        final createdBooking = _mapRowToBooking(bookingResult.first);

        // Create booking services within same transaction
        for (final service in services) {
          await session.execute(
            Sql.named('''
              INSERT INTO booking_services (id, booking_id, service_id, price_syp, notes)
              VALUES (@id, @bookingId, @serviceId, @priceSyp, @notes)
            '''),
            parameters: {
              'id': const Uuid().v4(),
              'bookingId': createdBooking.id,
              'serviceId': service.serviceId,
              'priceSyp': service.priceSYP,
              'notes': service.notes,
            },
          );
        }

        return createdBooking;
      });
    } catch (e) {
      throw ServerFailure('Failed to create booking: $e');
    }
  }

  Booking _mapRowToBooking(ResultRow row) {
    final data = row.toColumnMap();
    print('DEBUG _mapRowToBooking data: $data');
    print('DEBUG status type: ${data['status'].runtimeType}');
    print('DEBUG publicToken type: ${data['public_token'].runtimeType}');
    print('DEBUG notes type: ${data['notes'].runtimeType}');
    
    return Booking(
      id: data['id'].toString(),
      customerId: data['customer_id'].toString(),
      vehicleId: data['vehicle_id'].toString(),
      status: BookingStatus.fromString(data['status'] is String ? data['status'] as String : data['status']?.toString() ?? 'PENDING'),
      publicToken: data['public_token'] is String ? data['public_token'] as String : data['public_token']?.toString() ?? '',
      notes: data['notes'] is String ? data['notes'] as String? : null,
      createdAt: data['created_at'] is DateTime ? data['created_at'] as DateTime : DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null ? (data['updated_at'] is DateTime ? data['updated_at'] as DateTime : DateTime.parse(data['updated_at'] as String)) : null,
      estimatedCompletionDate: data['estimated_completion_date'] != null ? (data['estimated_completion_date'] is DateTime ? data['estimated_completion_date'] as DateTime : DateTime.parse(data['estimated_completion_date'] as String)) : null,
    );
  }
}
