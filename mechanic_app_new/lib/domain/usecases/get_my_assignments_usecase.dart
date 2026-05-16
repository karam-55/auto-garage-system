import '../entities/mechanic_assignment.dart';
import '../repositories/booking_repository.dart';
import '../../core/error/failures.dart';

class GetMyAssignmentsUseCase {
  final BookingRepository _bookingRepository;

  GetMyAssignmentsUseCase(this._bookingRepository);

  Future<List<MechanicAssignment>> call(String mechanicUserId) async {
    try {
      return await _bookingRepository.getMyAssignments(mechanicUserId);
    } on ServerFailure catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkFailure catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get my assignments: $e');
    }
  }
}
