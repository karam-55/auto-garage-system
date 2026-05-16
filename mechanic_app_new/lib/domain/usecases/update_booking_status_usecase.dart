import '../repositories/booking_repository.dart';
import '../../core/error/failures.dart';

class UpdateBookingStatusUseCase {
  final BookingRepository _bookingRepository;

  UpdateBookingStatusUseCase(this._bookingRepository);

  Future<bool> call(String bookingId, String status) async {
    try {
      return await _bookingRepository.updateBookingStatus(bookingId, status);
    } on ServerFailure catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkFailure catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to update booking status: $e');
    }
  }
}
