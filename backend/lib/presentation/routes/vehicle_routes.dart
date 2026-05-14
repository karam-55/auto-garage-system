import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../middlewares/json_middleware.dart';
import '../middlewares/auth_middleware.dart';
import 'package:uuid/uuid.dart';

class VehicleRoutes {
  final VehicleRepository _vehicleRepository;
  final AuthMiddleware _authMiddleware;

  VehicleRoutes(this._vehicleRepository, this._authMiddleware);

  Router get router {
    final router = Router();

    // GET /api/vehicles
    router.get('/api/vehicles', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getAllVehicles)));

    // GET /api/vehicles/:id
    router.get('/api/vehicles/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getVehicleById)));

    // GET /api/vehicles/customer/:customerId
    router.get('/api/vehicles/customer/<customerId>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getVehiclesByCustomerId)));

    // POST /api/vehicles
    router.post('/api/vehicles', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_createVehicle)));

    // PUT /api/vehicles/:id
    router.put('/api/vehicles/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_updateVehicle)));

    // DELETE /api/vehicles/:id
    router.delete('/api/vehicles/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_deleteVehicle)));

    return router;
  }

  Future<Response> _getAllVehicles(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final search = queryParams['search'];
      final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
      final limit = int.tryParse(queryParams['limit'] ?? '20') ?? 20;

      final result = await _vehicleRepository.findAllPaginated(
        search: search,
        page: page,
        limit: limit,
      );

      return Response.ok(
        jsonEncode({
          'data': result.data.map((v) => v.toJson()).toList(),
          'totalCount': result.totalCount,
          'page': result.page,
          'limit': result.limit,
          'totalPages': result.totalPages,
          'hasNextPage': result.hasNextPage,
          'hasPreviousPage': result.hasPreviousPage,
        }),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get vehicles: $e'}),
      );
    }
  }

  Future<Response> _getVehicleById(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      final vehicle = await _vehicleRepository.findById(id);
      if (vehicle == null) {
        return Response.notFound(jsonEncode({'error': 'Vehicle not found'}));
      }
      return Response.ok(jsonEncode(vehicle.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get vehicle: $e'}),
      );
    }
  }

  Future<Response> _getVehiclesByCustomerId(Request request) async {
    final customerId = request.params['customerId'];
    if (customerId == null || customerId.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'customerId is required'}));
    }
    try {
      final vehicles = await _vehicleRepository.findByCustomerId(customerId);
      return Response.ok(
        jsonEncode(vehicles.map((v) => v.toJson()).toList()),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get vehicles: $e'}),
      );
    }
  }

  Future<Response> _createVehicle(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final customerId = (body['customerId'] as String?)?.trim();
    final make = (body['make'] as String?)?.trim();
    final model = (body['model'] as String?)?.trim();
    final year = body['year'];
    final licensePlate = (body['licensePlate'] as String?)?.trim();
    final vin = (body['vin'] as String?)?.trim();

    // Handle year type safely
    int? yearInt;
    if (year == null) {
      yearInt = null;
    } else if (year is int) {
      yearInt = year as int;
    } else if (year is String) {
      try {
        yearInt = int.parse(year as String);
      } catch (e) {
        return Response.badRequest(body: jsonEncode({'error': 'year must be a valid integer'}));
      }
    } else {
      return Response.badRequest(body: jsonEncode({'error': 'year must be an integer'}));
    }

    if (customerId == null || customerId.isEmpty ||
        make == null || make.isEmpty ||
        model == null || model.isEmpty ||
        yearInt == null || yearInt < 1900 || yearInt > DateTime.now().year + 1) {
      return Response.badRequest(body: jsonEncode({'error': 'customerId, make, model, and a valid year (1900-${DateTime.now().year + 1}) are required'}));
    }

    try {
      final vehicle = Vehicle(
        id: const Uuid().v4(),
        customerId: customerId,
        make: make,
        model: model,
        year: yearInt,
        licensePlate: licensePlate,
        vin: vin,
        publicCarId: '', // Will be generated by repository
        createdAt: DateTime.now().toUtc(),
      );

      final createdVehicle = await _vehicleRepository.create(vehicle);
      return Response.ok(jsonEncode(createdVehicle.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create vehicle: $e'}),
      );
    }
  }

  Future<Response> _updateVehicle(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    try {
      final existingVehicle = await _vehicleRepository.findById(id);
      if (existingVehicle == null) {
        return Response.notFound(jsonEncode({'error': 'Vehicle not found'}));
      }

      final updatedVehicle = existingVehicle.copyWith(
        customerId: (body['customerId'] as String?)?.trim() ?? existingVehicle.customerId,
        make: (body['make'] as String?)?.trim() ?? existingVehicle.make,
        model: (body['model'] as String?)?.trim() ?? existingVehicle.model,
        year: body['year'] as int? ?? existingVehicle.year,
        licensePlate: (body['licensePlate'] as String?)?.trim(),
        vin: (body['vin'] as String?)?.trim(),
        updatedAt: DateTime.now().toUtc(),
      );

      final result = await _vehicleRepository.update(updatedVehicle);
      return Response.ok(jsonEncode(result.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update vehicle: $e'}),
      );
    }
  }

  Future<Response> _deleteVehicle(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      await _vehicleRepository.delete(id);
      return Response.ok(jsonEncode({'message': 'Vehicle deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete vehicle: $e'}),
      );
    }
  }
}
