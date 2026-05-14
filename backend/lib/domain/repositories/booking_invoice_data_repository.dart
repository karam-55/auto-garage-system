import '../entities/booking_invoice_data.dart';

abstract class BookingInvoiceDataRepository {
  Future<BookingInvoiceData?> findByBookingId(String bookingId);
  Future<BookingInvoiceData> create(BookingInvoiceData invoiceData);
  Future<BookingInvoiceData> update(BookingInvoiceData invoiceData);
  Future<BookingInvoiceData> generateOrGetInvoice(String bookingId);
}
