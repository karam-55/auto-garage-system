import 'dart:convert';
import 'package:postgres/postgres.dart';
import '../../domain/entities/booking_invoice_data.dart';
import '../../domain/repositories/booking_invoice_data_repository.dart';
import '../database/database_connection.dart';

class BookingInvoiceDataRepositoryImpl implements BookingInvoiceDataRepository {
  final DatabaseConnection _db;

  BookingInvoiceDataRepositoryImpl(this._db);

  @override
  Future<BookingInvoiceData?> findByBookingId(String bookingId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM booking_invoice_data WHERE booking_id = @bookingId'),
      parameters: {'bookingId': bookingId},
    );

    if (result.isEmpty) return null;

    final data = result.first.toColumnMap();
    return BookingInvoiceData(
      id: data['id'] as String,
      bookingId: data['booking_id'] as String,
      servicesSnapshot: data['services_snapshot'] != null 
          ? jsonDecode(data['services_snapshot'] as String) as Map<String, dynamic>
          : null,
      partsSnapshot: data['parts_snapshot'] != null
          ? jsonDecode(data['parts_snapshot'] as String) as Map<String, dynamic>
          : null,
      totalPrice: (data['total_price'] as num?)?.toDouble() ?? 0,
      invoiceCreatedAt: DateTime.parse(data['invoice_created_at'] as String),
    );
  }

  @override
  Future<BookingInvoiceData> create(BookingInvoiceData invoiceData) async {
    final result = await _db.execute(
      Sql.named('''
        INSERT INTO booking_invoice_data (id, booking_id, services_snapshot, parts_snapshot, total_price, invoice_created_at)
        VALUES (@id, @bookingId, @servicesSnapshot, @partsSnapshot, @totalPrice, @invoiceCreatedAt)
        RETURNING *
      '''),
      parameters: {
        'id': invoiceData.id,
        'bookingId': invoiceData.bookingId,
        'servicesSnapshot': invoiceData.servicesSnapshot != null 
            ? jsonEncode(invoiceData.servicesSnapshot)
            : null,
        'partsSnapshot': invoiceData.partsSnapshot != null
            ? jsonEncode(invoiceData.partsSnapshot)
            : null,
        'totalPrice': invoiceData.totalPrice,
        'invoiceCreatedAt': invoiceData.invoiceCreatedAt,
      },
    );

    final data = result.first.toColumnMap();
    return BookingInvoiceData(
      id: data['id'] as String,
      bookingId: data['booking_id'] as String,
      servicesSnapshot: data['services_snapshot'] != null 
          ? jsonDecode(data['services_snapshot'] as String) as Map<String, dynamic>
          : null,
      partsSnapshot: data['parts_snapshot'] != null
          ? jsonDecode(data['parts_snapshot'] as String) as Map<String, dynamic>
          : null,
      totalPrice: (data['total_price'] as num?)?.toDouble() ?? 0,
      invoiceCreatedAt: DateTime.parse(data['invoice_created_at'] as String),
    );
  }

  @override
  Future<BookingInvoiceData> update(BookingInvoiceData invoiceData) async {
    final result = await _db.execute(
      Sql.named('''
        UPDATE booking_invoice_data
        SET services_snapshot = @servicesSnapshot,
            parts_snapshot = @partsSnapshot,
            total_price = @totalPrice
        WHERE booking_id = @bookingId
        RETURNING *
      '''),
      parameters: {
        'bookingId': invoiceData.bookingId,
        'servicesSnapshot': invoiceData.servicesSnapshot != null 
            ? jsonEncode(invoiceData.servicesSnapshot)
            : null,
        'partsSnapshot': invoiceData.partsSnapshot != null
            ? jsonEncode(invoiceData.partsSnapshot)
            : null,
        'totalPrice': invoiceData.totalPrice,
      },
    );

    final data = result.first.toColumnMap();
    return BookingInvoiceData(
      id: data['id'] as String,
      bookingId: data['booking_id'] as String,
      servicesSnapshot: data['services_snapshot'] != null 
          ? jsonDecode(data['services_snapshot'] as String) as Map<String, dynamic>
          : null,
      partsSnapshot: data['parts_snapshot'] != null
          ? jsonDecode(data['parts_snapshot'] as String) as Map<String, dynamic>
          : null,
      totalPrice: (data['total_price'] as num?)?.toDouble() ?? 0,
      invoiceCreatedAt: DateTime.parse(data['invoice_created_at'] as String),
    );
  }

  @override
  Future<BookingInvoiceData> generateOrGetInvoice(String bookingId) async {
    // Check if invoice already exists
    final existing = await findByBookingId(bookingId);
    if (existing != null) {
      return existing;
    }

    // Generate new invoice from booking data
    final bookingResult = await _db.execute(
      Sql.named('SELECT * FROM bookings WHERE id = @bookingId'),
      parameters: {'bookingId': bookingId},
    );

    if (bookingResult.isEmpty) {
      throw Exception('Booking not found');
    }

    final bookingData = bookingResult.first.toColumnMap();

    // Get booking services
    final servicesResult = await _db.execute(
      Sql.named('''
        SELECT bs.*, s.name as service_name, s.description as service_description
        FROM booking_services bs
        JOIN services s ON bs.service_id = s.id
        WHERE bs.booking_id = @bookingId
      '''),
      parameters: {'bookingId': bookingId},
    );

    final servicesSnapshot = servicesResult.map((row) {
      final data = row.toColumnMap();
      return {
        'serviceId': data['service_id'],
        'serviceName': data['service_name'],
        'serviceDescription': data['service_description'],
        'priceSYP': data['price_syp'],
        'notes': data['notes'],
      };
    }).toList();

    // Get consumed parts from transactions
    final partsResult = await _db.execute(
      Sql.named('''
        SELECT it.*, iv.variant_type, iv.selling_price, i.name as item_name
        FROM inventory_transactions it
        JOIN inventory_variants iv ON it.variant_id = iv.id
        JOIN inventory_items i ON iv.item_id = i.id
        WHERE it.booking_id = @bookingId AND it.type = 'CONSUME'
      '''),
      parameters: {'bookingId': bookingId},
    );

    final partsSnapshot = partsResult.map((row) {
      final data = row.toColumnMap();
      return {
        'itemId': data['item_id'],
        'itemName': data['item_name'],
        'variantId': data['variant_id'],
        'variantType': data['variant_type'],
        'quantity': data['quantity'],
        'sellingPrice': data['selling_price'],
      };
    }).toList();

    // Calculate total price
    double totalPrice = 0;
    for (final service in servicesSnapshot) {
      totalPrice += (service['priceSYP'] as num).toDouble();
    }
    for (final part in partsSnapshot) {
      totalPrice += (part['sellingPrice'] as num).toDouble() * (part['quantity'] as int);
    }

    // Create invoice data
    final invoiceData = BookingInvoiceData(
      id: bookingData['id'].toString(),
      bookingId: bookingId,
      servicesSnapshot: {'services': servicesSnapshot},
      partsSnapshot: {'parts': partsSnapshot},
      totalPrice: totalPrice,
      invoiceCreatedAt: DateTime.now().toUtc(),
    );

    // Save to database
    return await create(invoiceData);
  }
}
