import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:pdf/widgets.dart';
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
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid booking ID'}));
    }
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
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid booking ID'}));
    }
    try {
      final invoice = await _invoiceRepository.generateOrGetInvoice(id);
      
      // Generate PDF from invoice data
      final pdf = Document();
      
      pdf.addPage(Page(
        build: (Context context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('فاتورة الحجز', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('رقم الحجز: ${invoice.bookingId}'),
              Text('تاريخ الفاتورة: ${invoice.invoiceCreatedAt.toIso8601String()}'),
              SizedBox(height: 20),
              Text('الخدمات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              if (invoice.servicesSnapshot != null)
                ..._buildServicesList(invoice.servicesSnapshot!),
              SizedBox(height: 20),
              Text('القطع:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              if (invoice.partsSnapshot != null)
                ..._buildPartsList(invoice.partsSnapshot!),
              SizedBox(height: 20),
              Text('الإجمالي: ${invoice.totalPrice} ل.س', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          );
        },
      ));

      final pdfData = await pdf.save();
      
      return Response.ok(
        pdfData,
        headers: {
          'Content-Type': 'application/pdf',
          'Content-Disposition': 'attachment; filename=invoice_${invoice.bookingId}.pdf',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to generate invoice PDF: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  List<Widget> _buildServicesList(Map<String, dynamic> servicesSnapshot) {
    final services = servicesSnapshot['services'] as List<dynamic>?;
    if (services == null || services.isEmpty) {
      return [Text('لا توجد خدمات')];
    }
    
    return services.map((service) {
      final s = service as Map<String, dynamic>;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${s['serviceName'] ?? 'خدمة'}'),
            Text('${s['priceSYP'] ?? 0} ل.س'),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildPartsList(Map<String, dynamic> partsSnapshot) {
    final parts = partsSnapshot['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      return [Text('لا توجد قطع')];
    }
    
    return parts.map((part) {
      final p = part as Map<String, dynamic>;
      final quantity = p['quantity'] as int? ?? 1;
      final price = (p['sellingPrice'] is num ? p['sellingPrice'] as num : double.tryParse(p['sellingPrice'] as String? ?? '0'))?.toDouble() ?? 0;
      final total = price * quantity;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${p['itemName'] ?? 'قطعة'} (${p['variantType'] ?? ''}) x$quantity'),
            Text('$total ل.س'),
          ],
        ),
      );
    }).toList();
  }
}
