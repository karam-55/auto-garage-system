import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/repositories/booking_service_repository.dart';
import '../middlewares/auth_middleware.dart';

class DashboardRoutes {
  final BookingRepository _bookingRepository;
  final CustomerRepository _customerRepository;
  final VehicleRepository _vehicleRepository;
  final BookingServiceRepository _bookingServiceRepository;
  final AuthMiddleware _authMiddleware;

  DashboardRoutes(
    this._bookingRepository,
    this._customerRepository,
    this._vehicleRepository,
    this._bookingServiceRepository,
    this._authMiddleware,
  );

  Router get router {
    final router = Router();

    // GET /api/dashboard/stats
    router.get('/api/dashboard/stats', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getDashboardStats)));

    // GET /api/dashboard/revenue
    router.get('/api/dashboard/revenue', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_getRevenueStats)));

    return router;
  }

  Future<Response> _getDashboardStats(Request request) async {
    try {
      final allBookings = await _bookingRepository.findAll();
      final customers = await _customerRepository.findAll();
      final vehicles = await _vehicleRepository.findAll();

      final pendingBookings = allBookings.where((b) => b.status == BookingStatus.PENDING).length;
      final inProgressBookings = allBookings.where((b) => b.status == BookingStatus.IN_PROGRESS).length;
      final waitingPartsBookings = allBookings.where((b) => b.status == BookingStatus.WAITING_PARTS).length;
      final readyBookings = allBookings.where((b) => b.status == BookingStatus.READY).length;
      final deliveredBookings = allBookings.where((b) => b.status == BookingStatus.DELIVERED).length;

      final stats = {
        'totalBookings': allBookings.length,
        'totalCustomers': customers.length,
        'totalVehicles': vehicles.length,
        'bookingsByStatus': {
          'pending': pendingBookings,
          'inProgress': inProgressBookings,
          'waitingParts': waitingPartsBookings,
          'ready': readyBookings,
          'delivered': deliveredBookings,
        },
        'vehiclesInWorkshop': inProgressBookings + waitingPartsBookings,
      };

      return Response.ok(jsonEncode(stats));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get dashboard stats: $e'}),
      );
    }
  }

  Future<Response> _getRevenueStats(Request request) async {
    final period = request.url.queryParameters['period'] ?? 'month';
    try {
      final allBookings = await _bookingRepository.findAll();
      final now = DateTime.now();
      
      DateTime startDate;
      switch (period) {
        case 'day':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      final filteredBookings = allBookings.where((b) => 
        b.createdAt.isAfter(startDate) && 
        b.status == BookingStatus.DELIVERED
      ).toList();

      double totalRevenue = 0;
      final serviceUsage = <String, int>{};

      for (final booking in filteredBookings) {
        final services = await _bookingServiceRepository.findByBookingId(booking.id);
        for (final service in services) {
          totalRevenue += service.priceSYP;
          serviceUsage[service.serviceId] = (serviceUsage[service.serviceId] ?? 0) + 1;
        }
      }

      final revenueStats = {
        'period': period,
        'startDate': startDate.toIso8601String(),
        'endDate': now.toIso8601String(),
        'totalRevenue': totalRevenue,
        'totalDeliveries': filteredBookings.length,
        'averageRevenuePerBooking': filteredBookings.isNotEmpty ? totalRevenue / filteredBookings.length : 0,
        'serviceUsage': serviceUsage,
      };

      return Response.ok(jsonEncode(revenueStats));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get revenue stats: $e'}),
      );
    }
  }
}
