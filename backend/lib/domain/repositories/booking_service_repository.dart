import '../entities/booking_service.dart';
import '../../core/errors/failures.dart';

abstract class BookingServiceRepository {
  Future<BookingService> create(BookingService bookingService);
  Future<BookingService?> findById(String id);
  Future<List<BookingService>> findByBookingId(String bookingId);
  Future<void> delete(String id);
  Future<void> deleteByBookingId(String bookingId);
}
