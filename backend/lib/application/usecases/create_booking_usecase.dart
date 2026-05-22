import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_service.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/booking_invoice_data_repository.dart';

class CreateBookingUseCase {
  final BookingRepository _bookingRepository;
  final BookingInvoiceDataRepository _invoiceDataRepository;

  CreateBookingUseCase(this._bookingRepository, this._invoiceDataRepository);

  Future<Booking> execute(Booking booking, List<BookingService> services) async {
    try {
      final createdBooking = await _bookingRepository.createWithServices(booking, services);
      
      // Generate invoice data for the booking
      try {
        await _invoiceDataRepository.generateOrGetInvoice(createdBooking.id);
      } catch (e) {
        // Don't fail booking creation if invoice generation fails
        // The invoice can be generated later
      }
      
      return createdBooking;
    } catch (e) {
      throw ServerFailure('Failed to create booking: $e');
    }
  }
}
