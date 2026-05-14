import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import '../repositories/booking_repository.dart';
import '../repositories/booking_service_repository.dart';
import '../../domain/entities/booking.dart';

class ReportRoutes {
  final BookingRepository _bookingRepository;
  final BookingServiceRepository _bookingServiceRepository;

  ReportRoutes(this._bookingRepository, this._bookingServiceRepository);

  Router get router {
    final router = Router();

    // Export bookings to PDF
    router.add('/api/reports/bookings/pdf', ['GET'], _exportBookingsToPDF);
    
    // Export bookings to Excel
    router.add('/api/reports/bookings/excel', ['GET'], _exportBookingsToExcel);

    return router;
  }

  Future<Response> _exportBookingsToPDF(Request request) async {
    try {
      final bookings = await _bookingRepository.findAll();
      
      final pdf = pw.Document();
      
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Garage Go - Bookings Report', 
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromText(
              context: context,
              data: List<List<String>>.generate(
                bookings.length + 1,
                (index) {
                  if (index == 0) {
                    return ['ID', 'Customer', 'Vehicle', 'Status', 'Date'];
                  }
                  final booking = bookings[index - 1];
                  return [
                    booking.id.substring(0, 8),
                    booking.customerName,
                    '${booking.vehicleMake} ${booking.vehicleModel}',
                    booking.status.toString(),
                    booking.createdAt.toLocal().toString().substring(0, 10),
                  ];
                },
              ),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
            ),
          ];
        },
      ));

      final bytes = await pdf.save();
      
      return Response.ok(bytes, headers: {
        'Content-Type': 'application/pdf',
        'Content-Disposition': 'attachment; filename="bookings_report.pdf"',
      });
    } catch (e) {
      return Response.internalServerError(
        body: 'Error generating PDF: $e',
      );
    }
  }

  Future<Response> _exportBookingsToExcel(Request request) async {
    try {
      final bookings = await _bookingRepository.findAll();
      
      final excel = Excel.createExcel();
      final sheet = excel['Bookings'];
      
      // Add headers
      sheet.appendRow(['ID', 'Customer Name', 'Vehicle', 'License Plate', 'Status', 'Created At']);
      
      // Add data
      for (final booking in bookings) {
        sheet.appendRow([
          booking.id.substring(0, 8),
          booking.customerName,
          '${booking.vehicleMake} ${booking.vehicleModel}',
          booking.licensePlate,
          booking.status.toString(),
          booking.createdAt.toLocal().toString().substring(0, 10),
        ]);
      }
      
      final bytes = excel.encode();
      
      return Response.ok(bytes, headers: {
        'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'Content-Disposition': 'attachment; filename="bookings_report.xlsx"',
      });
    } catch (e) {
      return Response.internalServerError(
        body: 'Error generating Excel: $e',
      );
    }
  }
}
