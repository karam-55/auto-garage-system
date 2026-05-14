import '../entities/booking.dart';
import '../../core/utils/pagination_result.dart';

abstract class BookingRepository {
  Future<Booking> create(Booking booking);
  Future<Booking?> findById(String id);
  Future<Booking?> findByPublicToken(String publicToken);
  Future<List<Booking>> findByCustomerId(String customerId);
  Future<List<Booking>> findByVehicleId(String vehicleId);
  Future<List<Booking>> findAll();
  Future<PaginationResult<Booking>> findAllPaginated({
    String? status,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    int page = 1,
    int limit = 20,
  });
  Future<List<Booking>> findByStatus(String status);
  Future<List<Booking>> findByDateRange(DateTime from, DateTime to);
  Future<List<Booking>> findAvailableForMechanic();
  Future<Booking> update(Booking booking);
  Future<void> delete(String id);
}
