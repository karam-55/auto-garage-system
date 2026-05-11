import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/booking_service_repository.dart';
import '../../core/errors/failures.dart';

class CreateBookingUseCase {
  final BookingRepository _bookingRepository;
  final BookingServiceRepository _bookingServiceRepository;

  CreateBookingUseCase(
    this._bookingRepository,
    this._bookingServiceRepository,
  );

  Future<Booking> execute(Booking booking, List<BookingService> services) async {
    try {
      // Create booking
      final createdBooking = await _bookingRepository.create(booking);

      // Create booking services
      for (final service in services) {
        final bookingService = BookingService(
          id: '',
          bookingId: createdBooking.id,
          serviceId: service.serviceId,
          priceSYP: service.priceSYP,
          notes: service.notes,
        );
        await _bookingServiceRepository.create(bookingService);
      }

      return createdBooking;
    } catch (e) {
      throw ServerFailure('Failed to create booking: $e');
    }
  }
}
