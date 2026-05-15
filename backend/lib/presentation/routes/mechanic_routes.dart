import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/mechanic_assignment_status.dart';
import '../../domain/entities/part_suggestion_status.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/mechanic_assignment_repository.dart';
import '../../domain/repositories/part_suggestion_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../application/usecases/assign_mechanic_usecase.dart';
import '../../application/usecases/create_part_suggestion_usecase.dart';
import '../middlewares/json_middleware.dart';
import '../middlewares/auth_middleware.dart';
import '../../application/services/notification_service.dart';

class MechanicRoutes {
  final MechanicAssignmentRepository _mechanicAssignmentRepository;
  final PartSuggestionRepository _partSuggestionRepository;
  final BookingRepository _bookingRepository;
  final VehicleRepository _vehicleRepository;
  final CustomerRepository _customerRepository;
  final AuthMiddleware _authMiddleware;

  MechanicRoutes(
    this._mechanicAssignmentRepository,
    this._partSuggestionRepository,
    this._bookingRepository,
    this._vehicleRepository,
    this._customerRepository,
    this._authMiddleware,
  );

  Router get router {
    final router = Router();

    // GET /api/mechanics/available-bookings
    router.get('/api/mechanics/available-bookings', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MECHANIC)(_getAvailableBookings)));

    // GET /api/mechanics/my-assignments
    router.get('/api/mechanics/my-assignments', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MECHANIC)(_getMyAssignments)));

    // POST /api/mechanics/assign
    router.post('/api/mechanics/assign', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MECHANIC)(_assignBooking)));

    // PATCH /api/mechanics/assignments/:id/status
    router.patch('/api/mechanics/assignments/<id>/status', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MECHANIC)(_updateAssignmentStatus)));

    // POST /api/mechanics/bookings/:id/part-suggestions
    router.post('/api/mechanics/bookings/<bookingId>/part-suggestions', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MECHANIC)(_createPartSuggestion)));

    // GET /api/mechanics/bookings/:id/part-suggestions
    router.get('/api/mechanics/bookings/<bookingId>/part-suggestions', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MECHANIC)(_getPartSuggestions)));

    // PATCH /api/part-suggestions/:id/status (for customer approval via public API)
    router.patch('/public/part-suggestions/<id>/status', _updatePartSuggestionStatus);

    return router;
  }

  Future<Response> _getAvailableBookings(Request request) async {
    try {
      print('Fetching available bookings for mechanic...');
      final availableBookings = await _bookingRepository.findAvailableForMechanic();
      print('Found ${availableBookings.length} available bookings');

      // Fetch vehicle and customer data for each booking
      final enrichedBookings = await Future.wait(availableBookings.map((booking) async {
        final vehicle = await _vehicleRepository.findById(booking.vehicleId);
        final customer = await _customerRepository.findById(booking.customerId);

        print('Vehicle: ${vehicle?.toJson()}');
        print('Customer: ${customer?.toJson()}');

        return {
          ...booking.toJson(),
          'vehicles': vehicle?.toJson(),
          'customers': customer?.toJson(),
        };
      }).toList());

      print('Enriched bookings: $enrichedBookings');
      return Response.ok(jsonEncode(enrichedBookings));
    } catch (e) {
      print('Error fetching available bookings: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get available bookings: $e'}),
      );
    }
  }

  Future<Response> _getMyAssignments(Request request) async {
    final user = request.context['user'];
    if (user == null) {
      return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
    }

    final typedUser = user as User;

    try {
      final assignments = await _mechanicAssignmentRepository.findByMechanicUserId(typedUser.id);
      return Response.ok(
        jsonEncode(assignments.map((a) => a.toJson()).toList()),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get assignments: $e'}),
      );
    }
  }

  Future<Response> _assignBooking(Request request) async {
    final user = request.context['user'];
    if (user == null) {
      return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
    }

    final typedUser = user as User;

    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final bookingId = (body['bookingId'] as String?)?.trim();
    if (bookingId == null || bookingId.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'bookingId is required'}));
    }

    try {
      final useCase = AssignMechanicUseCase(_mechanicAssignmentRepository, _bookingRepository);
      final assignment = await useCase.execute(bookingId, typedUser.id);
      return Response.ok(jsonEncode(assignment.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to assign booking: $e'}),
      );
    }
  }

  Future<Response> _updateAssignmentStatus(Request request) async {
    final id = request.params['id'];
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final statusStr = (body['status'] as String?)?.trim();
    final notes = (body['notes'] as String?)?.trim();

    if (statusStr == null || statusStr.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'status is required'}));
    }

    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      final existingAssignment = await _mechanicAssignmentRepository.findById(id);
      if (existingAssignment == null) {
        return Response.notFound(jsonEncode({'error': 'Assignment not found'}));
      }

      final updatedAssignment = existingAssignment.copyWith(
        status: MechanicAssignmentStatus.fromString(statusStr),
        notes: notes ?? existingAssignment.notes,
        updatedAt: DateTime.now().toUtc(),
      );

      final result = await _mechanicAssignmentRepository.update(updatedAssignment);
      return Response.ok(jsonEncode(result.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update assignment status: $e'}),
      );
    }
  }

  Future<Response> _createPartSuggestion(Request request) async {
    final user = request.context['user'];
    if (user == null) {
      return Response.unauthorized(jsonEncode({'error': 'Not authenticated'}));
    }

    final typedUser = user as User;

    final bookingId = request.params['bookingId'];
    if (bookingId == null || bookingId.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'bookingId is required'}));
    }
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final partType = (body['type'] as String?)?.trim();
    final description = (body['description'] as String?)?.trim();
    final priceSYP = body['priceSYP'];

    // Handle priceSYP type safely
    double? priceSYPDouble;
    if (priceSYP == null) {
      priceSYPDouble = null;
    } else if (priceSYP is num) {
      priceSYPDouble = (priceSYP).toDouble();
    } else if (priceSYP is String) {
      try {
        priceSYPDouble = double.parse(priceSYP);
      } catch (e) {
        return Response.badRequest(body: jsonEncode({'error': 'priceSYP must be a valid number'}));
      }
    } else {
      return Response.badRequest(body: jsonEncode({'error': 'priceSYP must be a number'}));
    }

    if (partType == null || partType.isEmpty || description == null || description.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'type and description are required'}));
    }

    try {
      final useCase = CreatePartSuggestionUseCase(
        _partSuggestionRepository,
        NotificationServiceImpl(),
      );
      final suggestion = await useCase.execute(
        bookingId,
        typedUser.id,
        partType,
        description,
        priceSYPDouble,
      );
      return Response.ok(jsonEncode(suggestion.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create part suggestion: $e'}),
      );
    }
  }

  Future<Response> _getPartSuggestions(Request request) async {
    final bookingId = request.params['bookingId'];
    if (bookingId == null || bookingId.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'bookingId is required'}));
    }
    try {
      final suggestions = await _partSuggestionRepository.findByBookingId(bookingId);
      return Response.ok(
        jsonEncode(suggestions.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get part suggestions: $e'}),
      );
    }
  }

  Future<Response> _updatePartSuggestionStatus(Request request) async {
    final id = request.params['id'];
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final statusStr = (body['status'] as String?)?.trim();
    if (statusStr == null || statusStr.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'status is required'}));
    }

    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      final existingSuggestion = await _partSuggestionRepository.findById(id);
      if (existingSuggestion == null) {
        return Response.notFound(jsonEncode({'error': 'Part suggestion not found'}));
      }

      final updatedSuggestion = existingSuggestion.copyWith(
        status: PartSuggestionStatus.fromString(statusStr),
        updatedAt: DateTime.now().toUtc(),
      );

      final result = await _partSuggestionRepository.update(updatedSuggestion);
      return Response.ok(jsonEncode(result.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update part suggestion status: $e'}),
      );
    }
  }
}
