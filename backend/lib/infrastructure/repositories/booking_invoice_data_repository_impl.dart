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

    if (result.isEmpty) {
      return null;
    }

    final data = result.first.toColumnMap();
    
    // Handle services_snapshot - it might be Map or String
    Map<String, dynamic>? servicesSnapshot;
    if (data['services_snapshot'] != null) {
      if (data['services_snapshot'] is Map) {
        servicesSnapshot = data['services_snapshot'] as Map<String, dynamic>;
      } else if (data['services_snapshot'] is String) {
        servicesSnapshot = jsonDecode(data['services_snapshot'] as String) as Map<String, dynamic>;
      }
    }
    
    // Handle parts_snapshot - it might be Map or String
    Map<String, dynamic>? partsSnapshot;
    if (data['parts_snapshot'] != null) {
      if (data['parts_snapshot'] is Map) {
        partsSnapshot = data['parts_snapshot'] as Map<String, dynamic>;
      } else if (data['parts_snapshot'] is String) {
        partsSnapshot = jsonDecode(data['parts_snapshot'] as String) as Map<String, dynamic>;
      }
    }
    
    final invoice = BookingInvoiceData(
      id: data['id'] as String,
      bookingId: data['booking_id'] as String,
      servicesSnapshot: servicesSnapshot,
      partsSnapshot: partsSnapshot,
      totalPrice: (data['total_price'] is num ? data['total_price'] as num : double.tryParse(data['total_price'] as String? ?? '0'))?.toDouble() ?? 0,
      invoiceCreatedAt: data['invoice_created_at'] is DateTime 
          ? data['invoice_created_at'] as DateTime 
          : DateTime.parse(data['invoice_created_at'] as String),
      publicToken: data['public_token'] is String ? data['public_token'] as String? : null,
      qrCodeUrl: data['qr_code_url'] is String ? data['qr_code_url'] as String? : null,
      journalEntryId: data['journal_entry_id'] as int?,
    );
    
    return invoice;
  }

  @override
  Future<BookingInvoiceData> create(BookingInvoiceData invoiceData) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''
          INSERT INTO booking_invoice_data (id, booking_id, services_snapshot, parts_snapshot, total_price, invoice_created_at, public_token, qr_code_url, journal_entry_id)
          VALUES (@id, @bookingId, @servicesSnapshot, @partsSnapshot, @totalPrice, @invoiceCreatedAt, @publicToken, @qrCodeUrl, @journalEntryId)
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
          'journalEntryId': invoiceData.journalEntryId,
        },
      );

      final data = result.first.toColumnMap();
      
      // Handle services_snapshot - it might be Map or String
      Map<String, dynamic>? servicesSnapshot;
      if (data['services_snapshot'] != null) {
        if (data['services_snapshot'] is Map) {
          servicesSnapshot = data['services_snapshot'] as Map<String, dynamic>;
        } else if (data['services_snapshot'] is String) {
          servicesSnapshot = jsonDecode(data['services_snapshot'] as String) as Map<String, dynamic>;
        }
      }
      
      // Handle parts_snapshot - it might be Map or String
      Map<String, dynamic>? partsSnapshot;
      if (data['parts_snapshot'] != null) {
        if (data['parts_snapshot'] is Map) {
          partsSnapshot = data['parts_snapshot'] as Map<String, dynamic>;
        } else if (data['parts_snapshot'] is String) {
          partsSnapshot = jsonDecode(data['parts_snapshot'] as String) as Map<String, dynamic>;
        }
      }
      
      return BookingInvoiceData(
        id: data['id'] as String,
        bookingId: data['booking_id'] as String,
        servicesSnapshot: servicesSnapshot,
        partsSnapshot: partsSnapshot,
        totalPrice: (data['total_price'] is num ? data['total_price'] as num : double.tryParse(data['total_price'] as String? ?? '0'))?.toDouble() ?? 0,
        invoiceCreatedAt: data['invoice_created_at'] is DateTime 
            ? data['invoice_created_at'] as DateTime 
            : DateTime.parse(data['invoice_created_at'] as String),
        publicToken: data['public_token'] is String ? data['public_token'] as String? : null,
        qrCodeUrl: data['qr_code_url'] is String ? data['qr_code_url'] as String? : null,
        journalEntryId: data['journal_entry_id'] as int?,
      );
    });
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
            qr_code_url = @qrCodeUrl,
            journal_entry_id = @journalEntryId
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
        'journalEntryId': invoiceData.journalEntryId,
      },
    );

    final data = result.first.toColumnMap();
    
    // Handle services_snapshot - it might be Map or String
    Map<String, dynamic>? servicesSnapshot;
    if (data['services_snapshot'] != null) {
      if (data['services_snapshot'] is String) {
        try {
          servicesSnapshot = jsonDecode(data['services_snapshot'] as String) as Map<String, dynamic>;
        } catch (e) {
          servicesSnapshot = null;
        }
      } else {
        servicesSnapshot = data['services_snapshot'] as Map<String, dynamic>;
      }
    }
    
    // Handle parts_snapshot - it might be Map or String
    Map<String, dynamic>? partsSnapshot;
    if (data['parts_snapshot'] != null) {
      if (data['parts_snapshot'] is String) {
        try {
          partsSnapshot = jsonDecode(data['parts_snapshot'] as String) as Map<String, dynamic>;
        } catch (e) {
          partsSnapshot = null;
        }
      } else {
        partsSnapshot = data['parts_snapshot'] as Map<String, dynamic>;
      }
    }

    return BookingInvoiceData(
      id: data['id'] as String,
      bookingId: data['booking_id'] as String,
      servicesSnapshot: servicesSnapshot,
      partsSnapshot: partsSnapshot,
      totalPrice: (data['total_price'] is num ? data['total_price'] as num : double.tryParse(data['total_price'] as String? ?? '0'))?.toDouble() ?? 0,
      invoiceCreatedAt: data['invoice_created_at'] is DateTime 
          ? data['invoice_created_at'] as DateTime 
          : DateTime.parse(data['invoice_created_at'] as String),
      publicToken: data['public_token'] is String ? data['public_token'] as String? : null,
      qrCodeUrl: data['qr_code_url'] is String ? data['qr_code_url'] as String? : null,
      journalEntryId: data['journal_entry_id'] as int?,
    );
  }

  @override
  Future<BookingInvoiceData> generateOrGetInvoice(String bookingId) async {
    try {
      final existingInvoice = await findByBookingId(bookingId);
      if (existingInvoice != null) {
        return existingInvoice;
      }

      final bookingResult = await _db.execute(
        Sql.named('SELECT * FROM bookings WHERE id = @bookingId'),
        parameters: {'bookingId': bookingId},
      );

      if (bookingResult.isEmpty) {
        throw Exception('Booking not found');
      }

      final bookingData = bookingResult.first.toColumnMap();
      final publicToken = bookingData['public_token'] as String?;

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
        final priceSYP = data['price_syp'];
        double priceSYPDouble = 0;
        if (priceSYP is num) {
          priceSYPDouble = priceSYP.toDouble();
        } else if (priceSYP is String) {
          priceSYPDouble = double.tryParse(priceSYP) ?? 0.0;
        }
        return {
          'serviceId': data['service_id'],
          'serviceName': data['service_name'],
          'serviceDescription': data['service_description'],
          'priceSYP': priceSYPDouble,
          'notes': data['notes'],
        };
      }).toList();

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
        final sellingPrice = data['selling_price'];
        double sellingPriceDouble = 0;
        if (sellingPrice is num) {
          sellingPriceDouble = sellingPrice.toDouble();
        } else if (sellingPrice is String) {
          sellingPriceDouble = double.tryParse(sellingPrice) ?? 0.0;
        }
        final quantity = data['quantity'];
        int quantityInt = 0;
        if (quantity is int) {
          quantityInt = quantity;
        } else if (quantity is String) {
          quantityInt = int.tryParse(quantity) ?? 0;
        } else if (quantity is num) {
          quantityInt = quantity.toInt();
        }
        return {
          'itemId': data['item_id'],
          'itemName': data['item_name'],
          'variantId': data['variant_id'],
          'variantType': data['variant_type'],
          'quantity': quantityInt,
          'sellingPrice': sellingPriceDouble,
        };
      }).toList();

      double totalPrice = 0;
      for (final service in servicesSnapshot) {
        final price = service['priceSYP'] as double;
        totalPrice += price;
      }
      for (final part in partsSnapshot) {
        final sellingPrice = part['sellingPrice'] as double;
        final quantity = part['quantity'] as int;
        totalPrice += sellingPrice * quantity;
      }

      // Get publicCarId from vehicle for QR code
      final vehicleResult = await _db.execute(
        Sql.named('SELECT public_car_id FROM vehicles WHERE id = @vehicleId'),
        parameters: {'vehicleId': bookingData['vehicle_id']},
      );
      
      String? publicCarId;
      if (vehicleResult.isNotEmpty) {
        final vehicleData = vehicleResult.first.toColumnMap();
        publicCarId = vehicleData['public_car_id'] as String?;
      }

      final qrCodeUrl = publicCarId != null
          ? 'https://auto-garage-customer-frontend.pages.dev/?publicCarId=$publicCarId'
          : null;

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

      return await create(invoiceData);
    } catch (e) {
      rethrow;
    }
  }
}
