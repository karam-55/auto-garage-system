import '../entities/booking.dart';
import '../entities/mechanic_assignment.dart';
import '../../core/error/failures.dart';

abstract class BookingRepository {
  Future<List<Booking>> getAvailableBookings();
  Future<List<MechanicAssignment>> getMyAssignments(String mechanicUserId);
  Future<MechanicAssignment> assignBooking(String bookingId, String mechanicUserId);
  Future<bool> updateBookingStatus(String bookingId, String status);
  Future<Booking?> getBookingById(String bookingId);
}
