import '../entities/mechanic_assignment.dart';
import '../repositories/booking_repository.dart';
import '../../core/error/failures.dart';

class AssignBookingUseCase {
  final BookingRepository _bookingRepository;

  AssignBookingUseCase(this._bookingRepository);

  Future<MechanicAssignment> call(String bookingId, String mechanicUserId) async {
    try {
      return await _bookingRepository.assignBooking(bookingId, mechanicUserId);
    } on ServerFailure catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkFailure catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to assign booking: $e');
    }
  }
}
