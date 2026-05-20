import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_service.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository _bookingRepository;

  CreateBookingUseCase(this._bookingRepository);

  Future<Booking> execute(Booking booking, List<BookingService> services) async {
    try {
      return await _bookingRepository.createWithServices(booking, services);
    } catch (e) {
      throw ServerFailure('Failed to create booking: $e');
    }
  }
}
