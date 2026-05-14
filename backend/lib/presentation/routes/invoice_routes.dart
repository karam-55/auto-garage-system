import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/booking_invoice_data.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/booking_invoice_data_repository.dart';
import '../middlewares/auth_middleware.dart';

class InvoiceRoutes {
  final BookingInvoiceDataRepository _invoiceRepository;
  final AuthMiddleware _authMiddleware;

  InvoiceRoutes(this._invoiceRepository, this._authMiddleware);

  Router get router {
    final router = Router();

    // Get invoice by booking ID
    router.get('/api/bookings/<id>/invoice', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getInvoice)));

    // Get invoice PDF by booking ID
    router.get('/api/bookings/<id>/invoice/pdf', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getInvoicePdf)));

    return router;
  }

  Future<Response> _getInvoice(Request request) async {
    final id = request.params['id'];
    try {
      final invoice = await _invoiceRepository.generateOrGetInvoice(id);
      return Response.ok(
        jsonEncode(invoice.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get invoice: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getInvoicePdf(Request request) async {
    final id = request.params['id'];
    try {
      final invoice = await _invoiceRepository.generateOrGetInvoice(id);
      
      // TODO: Generate PDF from invoice data
      // For now, return a simple text response
      final invoiceText = '''
Invoice for Booking: ${invoice.bookingId}
Total Price: ${invoice.totalPrice} SYP
Invoice Created At: ${invoice.invoiceCreatedAt}
''';

      return Response.ok(
        invoiceText,
        headers: {'Content-Type': 'text/plain'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to generate invoice PDF: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
