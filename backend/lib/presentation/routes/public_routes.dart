import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'dart:convert';
import '../../infrastructure/database/database_connection.dart';

class PublicRoutes {
  final DatabaseConnection _db;

  PublicRoutes(this._db);

  Router get router {
    final router = Router();

    // Public endpoint for customers to view their car booking
    router.get('/public/car/<publicCarId>', _getCarByPublicId);

    return router;
  }

  Future<Response> _getCarByPublicId(Request request) async {
    final publicCarId = request.params['publicCarId'];
    
    if (publicCarId == null || publicCarId.isEmpty) {
      return Response.notFound(jsonEncode({'error': 'Public car ID is required'}));
    }

    try {
      // Get vehicle by publicCarId
      final vehicleResult = await _db.execute(
        Sql.named('SELECT * FROM vehicles WHERE public_car_id = @publicCarId'),
        parameters: {'publicCarId': publicCarId},
      );

      if (vehicleResult.isEmpty) {
        return Response.notFound(jsonEncode({'error': 'Car not found'}));
      }

      final vehicleData = vehicleResult.first.toColumnMap();

      // Get customer data
      final customerResult = await _db.execute(
        Sql.named('SELECT full_name, phone FROM customers WHERE id = @customerId'),
        parameters: {'customerId': vehicleData['customer_id']},
      );

      if (customerResult.isEmpty) {
        return Response.notFound(jsonEncode({'error': 'Customer not found'}));
      }

      final customerData = customerResult.first.toColumnMap();

      // Get current booking for this vehicle
      final bookingResult = await _db.execute(
        Sql.named('''
        SELECT * FROM bookings 
        WHERE vehicle_id = @vehicleId 
        AND status NOT IN ('DELIVERED', 'CANCELLED')
        ORDER BY created_at DESC 
        LIMIT 1
        '''),
        parameters: {'vehicleId': vehicleData['id']},
      );

      Map<String, dynamic>? bookingData;
      List<Map<String, dynamic>> servicesData = [];

      if (!bookingResult.isEmpty) {
        bookingData = bookingResult.first.toColumnMap();

        // Get booking services
        final servicesResult = await _db.execute(
          Sql.named('''
          SELECT bs.*, s.name as service_name, s.description as service_description
          FROM booking_services bs
          JOIN services s ON bs.service_id = s.id
          WHERE bs.booking_id = @bookingId
          '''),
          parameters: {'bookingId': bookingData['id']},
        );

        servicesData = servicesResult.map((row) {
          final data = row.toColumnMap();
          return {
            'serviceName': data['service_name'],
            'serviceDescription': data['service_description'],
            'priceSYP': data['price_syp'],
            'notes': data['notes'],
          };
        }).toList();
      }

      // Build response with only safe data
      final response = {
        'vehicle': {
          'make': vehicleData['make'],
          'model': vehicleData['model'],
          'year': vehicleData['year'],
          'licensePlate': vehicleData['license_plate'],
        },
        'customer': {
          'fullName': customerData['full_name'],
        },
        if (bookingData != null) 'booking': {
          'id': bookingData['id'],
          'status': bookingData['status'],
          'notes': bookingData['notes'],
          'estimatedCompletionDate': bookingData['estimated_completion_date'],
          'createdAt': bookingData['created_at'],
        },
        if (servicesData.isNotEmpty) 'services': servicesData,
      };

      return Response.ok(jsonEncode(response));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get car data: $e'}),
      );
    }
  }
}
