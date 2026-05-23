import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_service.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/booking_service_repository.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/booking_invoice_data_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../application/usecases/create_booking_usecase.dart';
import '../../application/usecases/update_booking_status_usecase.dart';
import '../../application/usecases/process_booking_payment_usecase.dart';
import '../../application/services/journal_service.dart';
import '../../application/services/accounting_settings_service.dart';
import '../../infrastructure/database/database_connection.dart';
import '../middlewares/json_middleware.dart';
import '../middlewares/auth_middleware.dart';
import 'package:uuid/uuid.dart';

class BookingRoutes {
  final BookingRepository _bookingRepository;
  final BookingServiceRepository _bookingServiceRepository;
  final AuthMiddleware _authMiddleware;
  final DatabaseConnection _db;
  final VehicleRepository _vehicleRepository;
  final BookingInvoiceDataRepository _invoiceDataRepository;
  final CustomerRepository _customerRepository;
  final AccountRepository _accountRepository;
  final JournalRepository _journalRepository;
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  BookingRoutes(
    this._bookingRepository,
    this._bookingServiceRepository,
    this._authMiddleware,
    this._db,
    this._vehicleRepository,
    this._invoiceDataRepository,
    this._customerRepository,
    this._accountRepository,
    this._journalRepository,
    this._journalService,
    this._accountingSettingsService,
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

    // PATCH /api/bookings/:id/status (accessible by MECHANIC, RECEPTIONIST, MANAGER, OWNER)
    router.patch('/api/bookings/<id>/status', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.MECHANIC, Role.RECEPTIONIST, Role.MANAGER, Role.OWNER])(_updateBookingStatus)));

    // PATCH /api/bookings/:id/services
    router.patch('/api/bookings/<id>/services', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_updateBookingServices)));

    // POST /api/bookings/:id/payment (accessible by RECEPTIONIST, MANAGER, OWNER)
    router.post('/api/bookings/<id>/payment', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.RECEPTIONIST, Role.MANAGER, Role.OWNER])(_processPayment)));

    // GET /api/bookings/:id/invoice (accessible by RECEPTIONIST, MANAGER, OWNER)
    router.get('/api/bookings/<id>/invoice', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.RECEPTIONIST, Role.MANAGER, Role.OWNER])(_getBookingInvoice)));

    // GET /api/bookings/batch-invoices (accessible by RECEPTIONIST, MANAGER, OWNER)
    router.get('/api/bookings/batch-invoices', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.RECEPTIONIST, Role.MANAGER, Role.OWNER])(_getBatchInvoices)));

    // DELETE /api/bookings/:id
    router.delete('/api/bookings/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_deleteBooking)));

    // Public endpoint for customer tracking
    router.get('/public/bookings/<publicToken>', _getBookingByPublicToken);

    return router;
  }

  Future<Response> _getAllBookings(Request request) async {
    try {
      final queryParams = request.url.queryParameters;
      final status = queryParams['status'];
      final customerId = queryParams['customerId'];
      final from = queryParams['from'];
      final to = queryParams['to'];
      final search = queryParams['search'];
      final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
      final limit = int.tryParse(queryParams['limit'] ?? '20') ?? 20;

      DateTime? fromDate;
      DateTime? toDate;

      if (from != null && from.isNotEmpty) {
        fromDate = DateTime.parse(from);
      }

      if (to != null && to.isNotEmpty) {
        toDate = DateTime.parse(to);
      }

      final result = await _bookingRepository.findAllPaginated(
        status: status,
        customerId: customerId,
        fromDate: fromDate,
        toDate: toDate,
        search: search,
        page: page,
        limit: limit,
      );

      return Response.ok(
        jsonEncode({
          'data': result.data.map((b) => b.toJson()).toList(),
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
        body: jsonEncode({'error': 'Failed to get bookings: $e'}),
      );
    }
  }

  Future<Response> _getBookingById(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      final booking = await _bookingRepository.findById(id);
      if (booking == null) {
        return Response.notFound(jsonEncode({'error': 'Booking not found'}));
      }

      // Get vehicle
      final vehicle = await _vehicleRepository.findById(booking.vehicleId);

      // Get customer
      final customer = await _customerRepository.findById(booking.customerId);

      // Get services
      final services = await _bookingServiceRepository.findByBookingId(id);

      // Build response with all data
      final response = {
        'booking': booking.toJson(),
        'vehicle': vehicle?.toJson(),
        'customer': customer?.toJson(),
        'services': services.map((s) => s.toJson()).toList(),
      };

      return Response.ok(jsonEncode(response));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get booking: $e'}),
      );
    }
  }

  Future<Response> _getBookingByPublicToken(Request request) async {
    final publicToken = request.params['publicToken'];
    if (publicToken == null || publicToken.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'publicToken is required'}));
    }
    try {
      final booking = await _bookingRepository.findByPublicToken(publicToken);
      if (booking == null) {
        return Response.notFound(jsonEncode({'error': 'Booking not found'}));
      }

      // Get booking services
      final services = await _bookingServiceRepository.findByBookingId(booking.id);

      // Return only non-sensitive data for public endpoint
      return Response.ok(jsonEncode({
        'booking': {
          'status': booking.status.value,
          'publicToken': booking.publicToken,
          'notes': booking.notes,
          'createdAt': booking.createdAt.toIso8601String(),
          'estimatedCompletionDate': booking.estimatedCompletionDate?.toIso8601String(),
        },
        'services': services.map((s) => {
          'priceSYP': s.priceSYP,
          'notes': s.notes,
        }).toList(),
      }));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get booking: $e'}),
      );
    }
  }

  Future<Response> _getBookingsByCustomerId(Request request) async {
    final customerId = request.params['customerId'];
    if (customerId == null || customerId.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'customerId is required'}));
    }
    try {
      final bookings = await _bookingRepository.findByCustomerId(customerId);
      return Response.ok(jsonEncode(bookings.map((b) => b.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get bookings: $e'}),
      );
    }
  }

  Future<Response> _getBookingsByStatus(Request request) async {
    final status = request.params['status'];
    if (status == null || status.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'status is required'}));
    }
    try {
      final bookings = await _bookingRepository.findByStatus(status);
      return Response.ok(jsonEncode(bookings.map((b) => b.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get bookings: $e'}),
      );
    }
  }

  Future<Response> _createBooking(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // Validate required fields
      if (!data.containsKey('customerId') || data['customerId'] == null) {
        return Response.badRequest(body: jsonEncode({'error': 'customerId is required'}));
      }
      if (!data.containsKey('vehicleId') || data['vehicleId'] == null) {
        return Response.badRequest(body: jsonEncode({'error': 'vehicleId is required'}));
      }
      if (!data.containsKey('services') || (data['services'] as List).isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'At least one service is required'}));
      }

      final customerId = data['customerId'] as String;
      final vehicleId = data['vehicleId'] as String;
      final servicesData = data['services'] as List<Map<String, dynamic>>;
      final notes = data['notes'] as String?;
      final estimatedCompletionDate = data['estimatedCompletionDate'] != null
          ? DateTime.parse(data['estimatedCompletionDate'] as String)
          : null;

      // Create booking entity
      final booking = Booking(
        id: const Uuid().v4(),
        customerId: customerId,
        vehicleId: vehicleId,
        status: BookingStatus.PENDING,
        notes: notes,
        createdAt: DateTime.now(),
        estimatedCompletionDate: estimatedCompletionDate,
        publicToken: const Uuid().v4(),
      );

      // Create booking services
      final bookingServices = servicesData.map((serviceData) {
        return BookingService(
          id: const Uuid().v4(),
          bookingId: booking.id,
          serviceId: serviceData['serviceId'] as String,
          priceSYP: (serviceData['priceSYP'] as num).toDouble(),
          notes: serviceData['notes'] as String?,
        );
      }).toList();

      // Execute use case
      final useCase = CreateBookingUseCase(
        _bookingRepository,
        _invoiceDataRepository,
      );

      final createdBooking = await useCase.execute(booking, bookingServices);

      // Fetch vehicle for publicCarId
      final vehicle = await _vehicleRepository.findById(vehicleId);

      // Return booking with publicToken
      return Response.ok(jsonEncode({
        ...createdBooking.toJson(),
        'publicCarId': vehicle?.publicCarId,
        'services': bookingServices.map((s) => s.toJson()).toList(),
      }));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create booking: $e'}),
      );
    }
  }

  Future<Response> _updateBooking(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final booking = await _bookingRepository.findById(id);
      if (booking == null) {
        return Response.notFound(jsonEncode({'error': 'Booking not found'}));
      }

      final updatedBooking = booking.copyWith(
        notes: data['notes'] as String?,
        estimatedCompletionDate: data['estimatedCompletionDate'] != null
            ? DateTime.parse(data['estimatedCompletionDate'] as String)
            : null,
      );

      await _bookingRepository.update(updatedBooking);

      return Response.ok(jsonEncode(updatedBooking.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update booking: $e'}),
      );
    }
  }

  Future<Response> _updateBookingStatus(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status == null || status.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'status is required'}));
      }

      final booking = await _bookingRepository.findById(id);
      if (booking == null) {
        return Response.notFound(jsonEncode({'error': 'Booking not found'}));
      }

      final bookingStatus = BookingStatus.fromString(status);
      final updatedBooking = booking.copyWith(status: bookingStatus);

      await _bookingRepository.update(updatedBooking);

      return Response.ok(jsonEncode(updatedBooking.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update booking status: $e'}),
      );
    }
  }

  Future<Response> _updateBookingServices(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final servicesData = data['services'] as List<Map<String, dynamic>>;

      // Delete existing services
      await _bookingServiceRepository.deleteByBookingId(id);

      // Create new services
      final bookingServices = servicesData.map((serviceData) {
        return BookingService(
          id: const Uuid().v4(),
          bookingId: id,
          serviceId: serviceData['serviceId'] as String,
          priceSYP: (serviceData['priceSYP'] as num).toDouble(),
          notes: serviceData['notes'] as String?,
        );
      }).toList();

      for (final service in bookingServices) {
        await _bookingServiceRepository.create(service);
      }

      return Response.ok(jsonEncode(bookingServices.map((s) => s.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update booking services: $e'}),
      );
    }
  }

  Future<Response> _processPayment(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final paymentMethod = data['payment_method'] as String?;
      final paymentAmount = data['payment_amount'];

      if (paymentMethod == null || paymentMethod.isEmpty) {
        return Response.badRequest(body: jsonEncode({'error': 'payment_method is required'}));
      }
      if (paymentAmount == null) {
        return Response.badRequest(body: jsonEncode({'error': 'payment_amount is required'}));
      }

      double paymentAmountDouble;
      if (paymentAmount is num) {
        paymentAmountDouble = paymentAmount.toDouble();
      } else if (paymentAmount is String) {
        paymentAmountDouble = double.tryParse(paymentAmount) ?? 0.0;
      } else {
        return Response.badRequest(body: jsonEncode({'error': 'payment_amount must be a number'}));
      }

      if (paymentAmountDouble <= 0) {
        return Response.badRequest(body: jsonEncode({'error': 'payment_amount must be greater than 0'}));
      }

      try {
        final useCase = ProcessBookingPaymentUseCase(
          _invoiceDataRepository,
          _accountRepository,
          _journalRepository,
          _journalService,
          _accountingSettingsService,
        );

        final userId = request.context['user'] != null ? (request.context['user'] as dynamic).id : null;

        final updatedInvoice = await useCase.execute(
          bookingId: id,
          paymentMethod: paymentMethod,
          paymentAmount: paymentAmountDouble,
          userId: userId,
        );

        return Response.ok(jsonEncode(updatedInvoice.toJson()));
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to process payment: $e'}),
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to process payment: $e'}),
      );
    }
  }

  Future<Response> _getBookingInvoice(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      final invoiceData = await _invoiceDataRepository.findByBookingId(id);
      if (invoiceData == null) {
        return Response.notFound(jsonEncode({'error': 'Invoice not found'}));
      }
      return Response.ok(jsonEncode(invoiceData.toJson()));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch invoice: $e'}),
      );
    }
  }

  Future<Response> _getBatchInvoices(Request request) async {
    final params = request.url.queryParameters;
    final bookingIds = params['ids']?.split(',') ?? [];

    if (bookingIds.isEmpty) {
      return Response(400, body: jsonEncode({'error': 'No booking IDs provided'}));
    }

    try {
      final invoices = await _getInvoiceDataForBookings(bookingIds);
      return Response.ok(jsonEncode(invoices));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch batch invoices: $e'}),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getInvoiceDataForBookings(List<String> bookingIds) async {
    final List<Map<String, dynamic>> invoices = [];
    for (final bookingId in bookingIds) {
      try {
        final invoiceData = await _invoiceDataRepository.findByBookingId(bookingId);
        if (invoiceData != null) {
          invoices.add({
            'bookingId': bookingId,
            'invoice': invoiceData.toJson(),
          });
        }
      } catch (e) {
        // Skip failed invoices
        continue;
      }
    }
    return invoices;
  }

  Future<Response> _deleteBooking(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'id is required'}));
    }
    try {
      await _bookingRepository.delete(id);
      return Response.ok(jsonEncode({'message': 'Booking deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete booking: $e'}),
      );
    }
  }
}
