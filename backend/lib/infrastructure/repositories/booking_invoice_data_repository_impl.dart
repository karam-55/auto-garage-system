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
      totalPrice: (data['total_price'] is num ? data['total_price'] as num : double.tryParse(data['total_price'] as String? ?? '0'))?.toDouble() ?? 0,
      invoiceCreatedAt: DateTime.parse(data['invoice_created_at'] as String),
      publicToken: data['public_token'] as String?,
      qrCodeUrl: data['qr_code_url'] as String?,
    );
  }

  @override
  Future<BookingInvoiceData> create(BookingInvoiceData invoiceData) async {
    final result = await _db.execute(
      Sql.named('''
        INSERT INTO booking_invoice_data (id, booking_id, services_snapshot, parts_snapshot, total_price, invoice_created_at, public_token, qr_code_url)
        VALUES (@id, @bookingId, @servicesSnapshot, @partsSnapshot, @totalPrice, @invoiceCreatedAt, @publicToken, @qrCodeUrl)
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
        'publicToken': invoiceData.publicToken,
        'qrCodeUrl': invoiceData.qrCodeUrl,
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
      totalPrice: (data['total_price'] is num ? data['total_price'] as num : double.tryParse(data['total_price'] as String? ?? '0'))?.toDouble() ?? 0,
      invoiceCreatedAt: DateTime.parse(data['invoice_created_at'] as String),
      publicToken: data['public_token'] as String?,
      qrCodeUrl: data['qr_code_url'] as String?,
    );
  }

  @override
  Future<BookingInvoiceData> update(BookingInvoiceData invoiceData) async {
    final result = await _db.execute(
      Sql.named('''
        UPDATE booking_invoice_data
        SET services_snapshot = @servicesSnapshot,
            parts_snapshot = @partsSnapshot,
            total_price = @totalPrice,
            public_token = @publicToken,
            qr_code_url = @qrCodeUrl
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
        'publicToken': invoiceData.publicToken,
        'qrCodeUrl': invoiceData.qrCodeUrl,
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
      totalPrice: (data['total_price'] is num ? data['total_price'] as num : double.tryParse(data['total_price'] as String? ?? '0'))?.toDouble() ?? 0,
      invoiceCreatedAt: DateTime.parse(data['invoice_created_at'] as String),
      publicToken: data['public_token'] as String?,
      qrCodeUrl: data['qr_code_url'] as String?,
    );
  }

  @override
  Future<BookingInvoiceData> generateOrGetInvoice(String bookingId) async {
    try {
      print('DEBUG generateOrGetInvoice bookingId: $bookingId');
      final existingInvoice = await findByBookingId(bookingId);
      if (existingInvoice != null) {
        print('DEBUG existingInvoice found');
        return existingInvoice;
      }

      print('DEBUG fetching booking from database');
      final bookingResult = await _db.execute(
        Sql.named('SELECT * FROM bookings WHERE id = @bookingId'),
        parameters: {'bookingId': bookingId},
      );

      if (bookingResult.isEmpty) {
        throw Exception('Booking not found');
      }

      final bookingData = bookingResult.first.toColumnMap();
      final publicToken = bookingData['public_token'] as String?;
      print('DEBUG publicToken from booking: $publicToken');

      // Get booking services
      print('DEBUG fetching booking services');
      final servicesResult = await _db.execute(
        Sql.named('''
          SELECT bs.*, s.name as service_name, s.description as service_description
          FROM booking_services bs
          JOIN services s ON bs.service_id = s.id
          WHERE bs.booking_id = @bookingId
        '''),
        parameters: {'bookingId': bookingId},
      );

      print('DEBUG services count: ${servicesResult.length}');
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
      print('DEBUG fetching parts');
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
        final price = service['priceSYP'];
        if (price is num) {
          totalPrice += price.toDouble();
        } else if (price is String) {
          totalPrice += double.tryParse(price) ?? 0.0;
        }
      }
      for (final part in partsSnapshot) {
        final sellingPrice = part['sellingPrice'];
        final quantity = part['quantity'];
        final price = sellingPrice is num
            ? sellingPrice.toDouble()
            : double.tryParse(sellingPrice?.toString() ?? '0') ?? 0.0;
        final qty = quantity is int ? quantity : int.tryParse(quantity?.toString() ?? '0') ?? 0;
        totalPrice += price * qty;
      }

      // Create invoice data
      // Generate QR code URL using publicToken
      final qrCodeUrl = publicToken != null
          ? 'https://auto-garage-system-backend.onrender.com/track?token=$publicToken'
          : null;

      print('DEBUG creating invoice data');
      final invoiceData = BookingInvoiceData(
        id: bookingData['id'].toString(),
        bookingId: bookingId,
        servicesSnapshot: {'services': servicesSnapshot},
        partsSnapshot: {'parts': partsSnapshot},
        totalPrice: totalPrice,
        invoiceCreatedAt: DateTime.now().toUtc(),
        publicToken: publicToken,
        qrCodeUrl: qrCodeUrl,
      );

      // Save to database
      print('DEBUG saving invoice to database');
      return await create(invoiceData);
    } catch (e) {
      print('ERROR in generateOrGetInvoice: $e');
      rethrow;
    }
  }
