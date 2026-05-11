import '../entities/mechanic_assignment.dart';
import '../../core/errors/failures.dart';

abstract class MechanicAssignmentRepository {
  Future<MechanicAssignment> create(MechanicAssignment assignment);
  Future<MechanicAssignment?> findById(String id);
  Future<MechanicAssignment?> findByBookingId(String bookingId);
  Future<List<MechanicAssignment>> findByMechanicUserId(String mechanicUserId);
  Future<List<MechanicAssignment>> findAvailableBookings();
  Future<MechanicAssignment> update(MechanicAssignment assignment);
  Future<void> delete(String id);
}
