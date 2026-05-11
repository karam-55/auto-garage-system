import '../entities/booking.dart';
import '../../core/errors/failures.dart';

abstract class BookingRepository {
  Future<Booking> create(Booking booking);
  Future<Booking?> findById(String id);
  Future<Booking?> findByPublicToken(String publicToken);
  Future<List<Booking>> findByCustomerId(String customerId);
  Future<List<Booking>> findByVehicleId(String vehicleId);
  Future<List<Booking>> findAll();
  Future<List<Booking>> findByStatus(String status);
  Future<Booking> update(Booking booking);
  Future<void> delete(String id);
}
