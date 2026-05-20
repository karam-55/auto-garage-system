import '../../domain/entities/mechanic_assignment.dart';
import '../../domain/entities/mechanic_assignment_status.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/mechanic_assignment_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../core/errors/failures.dart';
import 'package:uuid/uuid.dart';

class AssignMechanicUseCase {
  final MechanicAssignmentRepository _mechanicAssignmentRepository;
  final BookingRepository _bookingRepository;

  AssignMechanicUseCase(
    this._mechanicAssignmentRepository,
    this._bookingRepository,
  );

  Future<MechanicAssignment> execute(String bookingId, String mechanicUserId) async {
    try {
      // Check if booking already has a mechanic
      final existingAssignment = await _mechanicAssignmentRepository.findByBookingId(bookingId);
      if (existingAssignment != null) {
        throw ConflictFailure('Booking already assigned to a mechanic');
      }

      // Check if booking exists
      final booking = await _bookingRepository.findById(bookingId);
      if (booking == null) {
        throw NotFoundFailure('Booking not found');
      }

      // Create assignment
      final assignment = MechanicAssignment(
        id: const Uuid().v4(),
        bookingId: bookingId,
        mechanicUserId: mechanicUserId,
        status: MechanicAssignmentStatus.ASSIGNED,
        assignedAt: DateTime.now().toUtc(),
      );

      final createdAssignment = await _mechanicAssignmentRepository.create(assignment);

      // Update booking status to IN_PROGRESS
      final updatedBooking = booking.copyWith(
        status: BookingStatus.IN_PROGRESS,
      );
      await _bookingRepository.update(updatedBooking);

      return createdAssignment;
    } catch (e) {
      throw ServerFailure('Failed to assign mechanic: $e');
    }
  }
}
