import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_service.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/booking_invoice_data_repository.dart';
import '../../domain/repositories/service_repository.dart';

class CreateBookingUseCase {
  final BookingRepository _bookingRepository;
  final BookingInvoiceDataRepository _invoiceDataRepository;
  final ServiceRepository _serviceRepository;

  CreateBookingUseCase(this._bookingRepository, this._invoiceDataRepository, this._serviceRepository);

  Future<Booking> execute(Booking booking, List<BookingService> services) async {
    try {
      // Validate that all services exist
      for (final service in services) {
        final existingService = await _serviceRepository.findById(service.serviceId);
        if (existingService == null) {
          throw ValidationFailure('Service not found');
        }
      }

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
