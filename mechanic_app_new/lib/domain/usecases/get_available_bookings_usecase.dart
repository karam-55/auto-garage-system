import '../entities/booking.dart';
import '../repositories/booking_repository.dart';
import '../../core/error/failures.dart';

class GetAvailableBookingsUseCase {
  final BookingRepository _bookingRepository;

  GetAvailableBookingsUseCase(this._bookingRepository);

  Future<List<Booking>> call() async {
    try {
      return await _bookingRepository.getAvailableBookings();
    } on ServerFailure catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkFailure catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get available bookings: $e');
    }
  }
}
