import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'dart:convert';
import 'dart:io';
import '../../infrastructure/database/database_connection.dart';

class PublicRoutes {
  final DatabaseConnection _db;

  PublicRoutes(this._db);

  Router get router {
    final router = Router();

    // Public endpoint for customers to view their car booking
    router.get('/car/<publicCarId>', _getCarByPublicId);
    
    // Endpoint to seed sample data (temporary for development)
    router.post('/seed-data', _seedSampleData);

    return router;
  }

  Future<Response> _getCarByPublicId(Request request) async {
    final publicCarId = request.params['publicCarId'];
    print('DEBUG: Public car request received. publicCarId: $publicCarId');
    
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
      print('DEBUG: Vehicle data: $vehicleData');

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

      if (bookingResult.isNotEmpty) {
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

        print('DEBUG public route servicesResult count: ${servicesResult.length}');
        servicesData = servicesResult.map((row) {
          final data = row.toColumnMap();
          print('DEBUG public route service data: $data');
          final priceSYP = data['price_syp'];
          print('DEBUG public route priceSYP: $priceSYP (${priceSYP.runtimeType})');
          return {
            'serviceName': data['service_name'],
            'serviceDescription': data['service_description'],
            'priceSYP': priceSYP is num ? (priceSYP as num).toDouble() : double.tryParse(priceSYP?.toString() ?? '0') ?? 0,
            'notes': data['notes'],
          };
        }).toList();
        
        print('DEBUG public route servicesData: $servicesData');
      }

      // Build response with only safe data
      final response = {
        'vehicle': {
          'make': vehicleData['make'],
          'model': vehicleData['model'],
          'year': vehicleData['year'],
          'licensePlate': vehicleData['license_plate'],
          'publicCarId': vehicleData['public_car_id'],
        },
        'customer': {
          'fullName': customerData['full_name'],
        },
        if (bookingData != null) 'booking': {
          'id': bookingData['id'],
          'status': bookingData['status'],
          'notes': bookingData['notes'],
          'estimatedCompletionDate': bookingData['estimated_completion_date']?.toString(),
          'createdAt': bookingData['created_at']?.toString(),
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

  Future<Response> _seedSampleData(Request request) async {
    try {
      print('Starting sample data seeding...');
      
      // Read the SQL file
      final sqlFile = File('lib/infrastructure/database/sample_data.sql');
      if (!await sqlFile.exists()) {
        return Response.notFound(jsonEncode({'error': 'SQL file not found'}));
      }
      
      final sqlContent = await sqlFile.readAsString();
      
      // Split by semicolons and execute each statement
      final statements = sqlContent.split(';').where((s) => s.trim().isNotEmpty);
      
      int executed = 0;
      int failed = 0;
      List<String> errors = [];
      
      for (final statement in statements) {
        final trimmedStatement = statement.trim();
        if (trimmedStatement.isEmpty || trimmedStatement.startsWith('--')) continue;
        
        try {
          await _db.execute(Sql.named(trimmedStatement));
          executed++;
          if (executed % 10 == 0) {
            print('Executed $executed statements...');
          }
        } catch (e) {
          failed++;
          errors.add('Statement failed: $e');
          print('Failed to execute statement: $e');
        }
      }
      
      final result = {
        'success': true,
        'executed': executed,
        'failed': failed,
        'errors': errors.take(5).toList(), // Limit errors to first 5
        'message': 'Sample data seeding completed',
      };
      
      print('Sample data seeding completed: $executed executed, $failed failed');
      
      return Response.ok(jsonEncode(result));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to seed sample data: $e'}),
      );
    }
  }
}
