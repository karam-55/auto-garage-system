import '../entities/booking.dart';
import '../entities/booking_service.dart';
import '../../core/utils/pagination_result.dart';

abstract class BookingRepository {
  Future<Booking> create(Booking booking);
  Future<Booking> createWithServices(Booking booking, List<BookingService> services);
  Future<Booking?> findById(String id);
  Future<Booking?> findByPublicToken(String publicToken);
  Future<List<Booking>> findByCustomerId(String customerId, {int? limit, int? offset});
  Future<List<Booking>> findByVehicleId(String vehicleId, {int? limit, int? offset});
  Future<List<Booking>> findAll({int? limit, int? offset});
  Future<PaginationResult<Booking>> findAllPaginated({
    String? status,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    int page = 1,
    int limit = 20,
  });
  Future<List<Booking>> findByStatus(String status, {int? limit, int? offset});
  Future<List<Booking>> findByDateRange(DateTime from, DateTime to, {int? limit, int? offset});
  Future<List<Booking>> findAvailableForMechanic({int? limit, int? offset});
  Future<Booking> update(Booking booking);
  Future<void> delete(String id);
}
