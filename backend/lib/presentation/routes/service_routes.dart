import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/service_repository.dart';
import '../middlewares/json_middleware.dart';
import '../middlewares/auth_middleware.dart';
import 'package:uuid/uuid.dart';

class ServiceRoutes {
  final ServiceRepository _serviceRepository;
  final AuthMiddleware _authMiddleware;

  ServiceRoutes(this._serviceRepository, this._authMiddleware);

  Router get router {
    final router = Router();

    // GET /api/services
    router.get('/api/services', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getAllServices)));

    // GET /api/services/:id
    router.get('/api/services/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getServiceById)));

    // POST /api/services
    router.post('/api/services', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_createService)));

    // PUT /api/services/:id
    router.put('/api/services/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_updateService)));

    // DELETE /api/services/:id
    router.delete('/api/services/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_deleteService)));

    return router;
  }

  Future<Response> _getAllServices(Request request) async {
    try {
      final activeOnly = request.url.queryParameters['activeOnly'] == 'true';
      final services = await _serviceRepository.findAll(activeOnly: activeOnly);
      return Response.ok(
        jsonEncode(services.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get services: $e'}),
      );
    }
  }

  Future<Response> _getServiceById(Request request) async {
    final id = request.params['id'];
    try {
      final service = await _serviceRepository.findById(id!);
      if (service == null) {
        return Response.notFound(jsonEncode({'error': 'Service not found'}));
      }
      return Response.ok(jsonEncode(service.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get service: $e'}),
      );
    }
  }

  Future<Response> _createService(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final name = body['name'] as String?;
    final description = body['description'] as String?;
    final priceSYP = body['priceSYP'] as double?;
    final estimatedDurationMinutes = body['estimatedDurationMinutes'] as int?;

    if (name == null || priceSYP == null) {
      return Response.badRequest(body: jsonEncode({'error': 'name and priceSYP are required'}));
    }

    try {
      final service = Service(
        id: const Uuid().v4(),
        name: name,
        description: description,
        priceSYP: priceSYP,
        estimatedDurationMinutes: estimatedDurationMinutes,
        createdAt: DateTime.now().toUtc(),
      );

      final createdService = await _serviceRepository.create(service);
      return Response.ok(jsonEncode(createdService.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create service: $e'}),
      );
    }
  }

  Future<Response> _updateService(Request request) async {
    final id = request.params['id'];
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    try {
      final existingService = await _serviceRepository.findById(id!);
      if (existingService == null) {
        return Response.notFound(jsonEncode({'error': 'Service not found'}));
      }

      final updatedService = existingService.copyWith(
        name: body['name'] as String? ?? existingService.name,
        description: body['description'] as String?,
        priceSYP: body['priceSYP'] as double? ?? existingService.priceSYP,
        estimatedDurationMinutes: body['estimatedDurationMinutes'] as int?,
        isActive: body['isActive'] as bool?,
        updatedAt: DateTime.now().toUtc(),
      );

      final result = await _serviceRepository.update(updatedService);
      return Response.ok(jsonEncode(result.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update service: $e'}),
      );
    }
  }

  Future<Response> _deleteService(Request request) async {
    final id = request.params['id'];
    try {
      await _serviceRepository.delete(id!);
      return Response.ok(jsonEncode({'message': 'Service deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete service: $e'}),
      );
    }
  }
}
