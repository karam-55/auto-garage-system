import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../core/errors/failures.dart';

class UpdateBookingStatusUseCase {
  final BookingRepository _bookingRepository;

  UpdateBookingStatusUseCase(this._bookingRepository);

  Future<Booking> execute(String bookingId, BookingStatus newStatus) async {
    try {
      final booking = await _bookingRepository.findById(bookingId);
      if (booking == null) {
        throw NotFoundFailure('Booking not found');
      }

      final updatedBooking = booking.copyWith(
        status: newStatus,
        updatedAt: DateTime.now().toUtc(),
      );

      return await _bookingRepository.update(updatedBooking);
    } catch (e) {
      throw ServerFailure('Failed to update booking status: $e');
    }
  }
}
