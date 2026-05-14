import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/customer_repository.dart';
import '../middlewares/json_middleware.dart';
import '../middlewares/auth_middleware.dart';
import 'package:uuid/uuid.dart';

class CustomerRoutes {
  final CustomerRepository _customerRepository;
  final AuthMiddleware _authMiddleware;

  CustomerRoutes(this._customerRepository, this._authMiddleware);

  Router get router {
    final router = Router();

    // GET /api/customers
    router.get('/api/customers', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getAllCustomers)));

    // GET /api/customers/:id
    router.get('/api/customers/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getCustomerById)));

    // POST /api/customers
    router.post('/api/customers', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_createCustomer)));

    // PUT /api/customers/:id
    router.put('/api/customers/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_updateCustomer)));

    // DELETE /api/customers/:id
    router.delete('/api/customers/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_deleteCustomer)));

    return router;
  }

  Future<Response> _getAllCustomers(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final search = queryParams['search'];
      final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
      final limit = int.tryParse(queryParams['limit'] ?? '20') ?? 20;

      final result = await _customerRepository.findAllPaginated(
        search: search,
        page: page,
        limit: limit,
      );

      return Response.ok(
        jsonEncode({
          'data': result.data.map((c) => c.toJson()).toList(),
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
        body: jsonEncode({'error': 'Failed to get customers: $e'}),
      );
    }
  }

  Future<Response> _getCustomerById(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      final customer = await _customerRepository.findById(id);
      if (customer == null) {
        return Response.notFound(jsonEncode({'error': 'Customer not found'}));
      }
      return Response.ok(jsonEncode(customer.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get customer: $e'}),
      );
    }
  }

  Future<Response> _createCustomer(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final fullName = (body['fullName'] as String?)?.trim();
    final phone = (body['phone'] as String?)?.trim();
    final address = (body['address'] as String?)?.trim();

    if (fullName == null || fullName.isEmpty || phone == null || phone.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'fullName and phone are required and cannot be empty'}));
    }

    // Validate phone format (basic validation for Syrian phone numbers)
    if (!RegExp(r'^[0-9]{9,15}$').hasMatch(phone)) {
      return Response.badRequest(body: jsonEncode({'error': 'Phone number must be 9-15 digits'}));
    }

    try {
      final customer = Customer(
        id: const Uuid().v4(),
        fullName: fullName,
        phone: phone,
        address: address,
        createdAt: DateTime.now().toUtc(),
      );

      final createdCustomer = await _customerRepository.create(customer);
      return Response.ok(jsonEncode(createdCustomer.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create customer: $e'}),
      );
    }
  }

  Future<Response> _updateCustomer(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    try {
      final existingCustomer = await _customerRepository.findById(id);
      if (existingCustomer == null) {
        return Response.notFound(jsonEncode({'error': 'Customer not found'}));
      }

      final updatedCustomer = existingCustomer.copyWith(
        fullName: (body['fullName'] as String?)?.trim() ?? existingCustomer.fullName,
        phone: (body['phone'] as String?)?.trim() ?? existingCustomer.phone,
        address: (body['address'] as String?)?.trim(),
        updatedAt: DateTime.now().toUtc(),
      );

      final result = await _customerRepository.update(updatedCustomer);
      return Response.ok(jsonEncode(result.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update customer: $e'}),
      );
    }
  }

  Future<Response> _deleteCustomer(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      await _customerRepository.delete(id);
      return Response.ok(jsonEncode({'message': 'Customer deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete customer: $e'}),
      );
    }
  }
}
