import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/booking_service_repository.dart';
import '../../application/usecases/create_booking_usecase.dart';
import '../../application/usecases/update_booking_status_usecase.dart';
import '../middlewares/json_middleware.dart';
import '../middlewares/auth_middleware.dart';
import 'package:uuid/uuid.dart';

class BookingRoutes {
  final BookingRepository _bookingRepository;
  final BookingServiceRepository _bookingServiceRepository;
  final AuthMiddleware _authMiddleware;

  BookingRoutes(
    this._bookingRepository,
    this._bookingServiceRepository,
    this._authMiddleware,
  );

  Router get router {
    final router = Router();

    // GET /api/bookings
    router.get('/api/bookings', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getAllBookings)));

    // GET /api/bookings/:id
    router.get('/api/bookings/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getBookingById)));

    // GET /api/bookings/customer/:customerId
    router.get('/api/bookings/customer/<customerId>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getBookingsByCustomerId)));

    // GET /api/bookings/status/:status
    router.get('/api/bookings/status/<status>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getBookingsByStatus)));

    // POST /api/bookings
    router.post('/api/bookings', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_createBooking)));

    // PUT /api/bookings/:id
    router.put('/api/bookings/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_updateBooking)));

    // PATCH /api/bookings/:id/status
    router.patch('/api/bookings/<id>/status', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_updateBookingStatus)));

    // DELETE /api/bookings/:id
    router.delete('/api/bookings/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_deleteBooking)));

    // Public endpoint for customer tracking
    router.get('/public/bookings/<publicToken>', _getBookingByPublicToken);

    return router;
  }

  Future<Response> _getAllBookings(Request request) async {
    try {
      final bookings = await _bookingRepository.findAll();
      return Response.ok(
        jsonEncode(bookings.map((b) => b.toJson()).toList()),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get bookings: $e'}),
      );
    }
  }

  Future<Response> _getBookingById(Request request) async {
    final id = request.params['id'];
    try {
      final booking = await _bookingRepository.findById(id!);
      if (booking == null) {
        return Response.notFound(jsonEncode({'error': 'Booking not found'}));
      }
      return Response.ok(jsonEncode(booking.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get booking: $e'}),
      );
    }
  }

  Future<Response> _getBookingByPublicToken(Request request) async {
    final publicToken = request.params['publicToken'];
    try {
      final booking = await _bookingRepository.findByPublicToken(publicToken!);
      if (booking == null) {
        return Response.notFound(jsonEncode({'error': 'Booking not found'}));
      }

      // Get booking services
      final services = await _bookingServiceRepository.findByBookingId(booking.id);

      return Response.ok(jsonEncode({
        'booking': booking.toJson(),
        'services': services.map((s) => s.toJson()).toList(),
      }));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get booking: $e'}),
      );
    }
  }

  Future<Response> _getBookingsByCustomerId(Request request) async {
    final customerId = request.params['customerId'];
    try {
      final bookings = await _bookingRepository.findByCustomerId(customerId!);
      return Response.ok(
        jsonEncode(bookings.map((b) => b.toJson()).toList()),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get bookings: $e'}),
      );
    }
  }

  Future<Response> _getBookingsByStatus(Request request) async {
    final status = request.params['status'];
    try {
      final bookings = await _bookingRepository.findByStatus(status!);
      return Response.ok(
        jsonEncode(bookings.map((b) => b.toJson()).toList()),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get bookings: $e'}),
      );
    }
  }

  Future<Response> _createBooking(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final customerId = body['customerId'] as String?;
    final vehicleId = body['vehicleId'] as String?;
    final notes = body['notes'] as String?;
    final servicesData = body['services'] as List<dynamic>?;
    final estimatedCompletionDate = body['estimatedCompletionDate'] as String?;

    if (customerId == null || vehicleId == null || servicesData == null) {
      return Response.badRequest(body: jsonEncode({'error': 'customerId, vehicleId, and services are required'}));
    }

    try {
      final booking = Booking(
        id: const Uuid().v4(),
        customerId: customerId,
        vehicleId: vehicleId,
        status: BookingStatus.PENDING,
        publicToken: const Uuid().v4().replaceAll('-', ''),
        notes: notes,
        createdAt: DateTime.now().toUtc(),
        estimatedCompletionDate: estimatedCompletionDate != null
            ? DateTime.parse(estimatedCompletionDate).toUtc()
            : null,
      );

      final services = servicesData.map((data) {
        return BookingService(
          id: '',
          bookingId: booking.id,
          serviceId: data['serviceId'] as String,
          priceSYP: (data['priceSYP'] as num).toDouble(),
          notes: data['notes'] as String?,
        );
      }).toList();

      final useCase = CreateBookingUseCase(_bookingRepository, _bookingServiceRepository);
      final createdBooking = await useCase.execute(booking, services);

      return Response.ok(jsonEncode(createdBooking.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create booking: $e'}),
      );
    }
  }

  Future<Response> _updateBooking(Request request) async {
    final id = request.params['id'];
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    try {
      final existingBooking = await _bookingRepository.findById(id!);
      if (existingBooking == null) {
        return Response.notFound(jsonEncode({'error': 'Booking not found'}));
      }

      final updatedBooking = existingBooking.copyWith(
        customerId: body['customerId'] as String? ?? existingBooking.customerId,
        vehicleId: body['vehicleId'] as String? ?? existingBooking.vehicleId,
        status: body['status'] != null
            ? BookingStatus.fromString(body['status'] as String)
            : existingBooking.status,
        notes: body['notes'] as String?,
        estimatedCompletionDate: body['estimatedCompletionDate'] != null
            ? DateTime.parse(body['estimatedCompletionDate'] as String).toUtc()
            : existingBooking.estimatedCompletionDate,
        updatedAt: DateTime.now().toUtc(),
      );

      final result = await _bookingRepository.update(updatedBooking);
      return Response.ok(jsonEncode(result.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update booking: $e'}),
      );
    }
  }

  Future<Response> _updateBookingStatus(Request request) async {
    final id = request.params['id'];
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }

    final statusStr = body['status'] as String?;
    if (statusStr == null) {
      return Response.badRequest(body: jsonEncode({'error': 'status is required'}));
    }

    try {
      final useCase = UpdateBookingStatusUseCase(_bookingRepository);
      final updatedBooking = await useCase.execute(id!, BookingStatus.fromString(statusStr));
      return Response.ok(jsonEncode(updatedBooking.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update booking status: $e'}),
      );
    }
  }

  Future<Response> _deleteBooking(Request request) async {
    final id = request.params['id'];
    try {
      await _bookingRepository.delete(id!);
      return Response.ok(jsonEncode({'message': 'Booking deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete booking: $e'}),
      );
    }
  }
}
