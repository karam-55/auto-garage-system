import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/repositories/booking_service_repository.dart';
import '../../infrastructure/repositories/purchase_order_repository_impl.dart';
import '../../infrastructure/repositories/quotation_repository_impl.dart';
import '../../infrastructure/repositories/warehouse_repository_impl.dart';
import '../../infrastructure/repositories/bill_of_materials_repository_impl.dart';
import '../../infrastructure/repositories/inventory_item_repository_impl.dart';
import '../../infrastructure/repositories/inventory_variant_repository_impl.dart';
import '../../infrastructure/repositories/hr_repository_impl.dart';
import '../../infrastructure/repositories/fixed_asset_repository_impl.dart';
import '../middlewares/auth_middleware.dart';

class DashboardRoutes {
  final BookingRepository _bookingRepository;
  final CustomerRepository _customerRepository;
  final VehicleRepository _vehicleRepository;
  final BookingServiceRepository _bookingServiceRepository;
  final PurchaseOrderRepositoryImpl _purchaseOrderRepository;
  final QuotationRepositoryImpl _quotationRepository;
  final WarehouseRepositoryImpl _warehouseRepository;
  final BillOfMaterialsRepositoryImpl _bomRepository;
  final InventoryItemRepositoryImpl _inventoryItemRepository;
  final InventoryVariantRepositoryImpl _inventoryVariantRepository;
  final EmployeeContractRepositoryImpl _hrRepository;
  final FixedAssetRepositoryImpl _fixedAssetRepository;
  final AuthMiddleware _authMiddleware;

  DashboardRoutes(
    this._bookingRepository,
    this._customerRepository,
    this._vehicleRepository,
    this._bookingServiceRepository,
    this._purchaseOrderRepository,
    this._quotationRepository,
    this._warehouseRepository,
    this._bomRepository,
    this._inventoryItemRepository,
    this._inventoryVariantRepository,
    this._hrRepository,
    this._fixedAssetRepository,
    this._authMiddleware,
  );

  Router get router {
    final router = Router();

    // GET /api/dashboard/stats
    router.get('/api/dashboard/stats', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getDashboardStats)));

    // GET /api/dashboard/revenue
    router.get('/api/dashboard/revenue', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_getRevenueStats)));

    // ERP Dashboard Stats
    router.get('/dashboard/sales-stats', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getSalesStats)));
    router.get('/dashboard/purchase-stats', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getPurchaseStats)));
    router.get('/dashboard/inventory-stats', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getInventoryStats)));
    router.get('/dashboard/manufacturing-stats', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getManufacturingStats)));
    router.get('/dashboard/hr-stats', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.HR_MANAGER])(_getHrStats)));
    router.get('/dashboard/fixed-assets-stats', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getFixedAssetsStats)));

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

      if (filteredBookings.isNotEmpty) {
        final bookingIds = filteredBookings.map((b) => b.id).toList();
        final services = await _bookingServiceRepository.findByBookingIds(bookingIds);
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

  // ERP Dashboard Stats Handlers
  Future<Response> _getSalesStats(Request request) async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      
      final quotations = await _quotationRepository.findAll();
      final monthQuotations = quotations.where((q) => q.createdAt.isAfter(monthStart)).toList();
      
      double totalSales = 0;
      int totalInvoices = 0;
      final topServices = <String, double>{};
      
      for (final quote in monthQuotations) {
        totalSales += quote.totalAmount;
        totalInvoices++;
      }

      return Response.ok(jsonEncode({
        'totalSales': totalSales,
        'totalInvoices': totalInvoices,
        'averageInvoiceValue': totalInvoices > 0 ? totalSales / totalInvoices : 0,
        'topServices': topServices,
      }));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get sales stats: $e'}));
    }
  }

  Future<Response> _getPurchaseStats(Request request) async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      
      final orders = await _purchaseOrderRepository.findAll();
      final monthOrders = orders.where((o) => o.orderDate.isAfter(monthStart)).toList();
      
      double totalPurchases = 0;
      int totalOrders = 0;
      final topVendors = <String, double>{};
      
      for (final order in monthOrders) {
        for (final line in order.lines) {
          totalPurchases += line.totalPrice;
        }
        totalOrders++;
        topVendors[order.vendorId.toString()] = (topVendors[order.vendorId.toString()] ?? 0) + order.lines.fold(0.0, (sum, line) => sum + line.totalPrice);
      }

      return Response.ok(jsonEncode({
        'totalPurchases': totalPurchases,
        'totalOrders': totalOrders,
        'averageOrderValue': totalOrders > 0 ? totalPurchases / totalOrders : 0,
        'topVendors': topVendors,
      }));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get purchase stats: $e'}));
    }
  }

  Future<Response> _getInventoryStats(Request request) async {
    try {
      final inventory = await _inventoryItemRepository.findAll();
      
      double totalValue = 0;
      int lowStockItems = 0;
      final topMovingItems = <String, int>{};
      
      for (final item in inventory) {
        // InventoryItem doesn't have quantity, unitCost - use placeholder values
        // In a real system, this would use InventoryVariantWarehouse
        totalValue += 0; 
        if (item.lowStockThreshold < 10) {
          lowStockItems++;
        }
        topMovingItems[item.name] = 0;
      }

      return Response.ok(jsonEncode({
        'totalValue': totalValue,
        'totalItems': inventory.length,
        'lowStockItems': lowStockItems,
        'topMovingItems': topMovingItems,
      }));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get inventory stats: $e'}));
    }
  }

  Future<Response> _getManufacturingStats(Request request) async {
    try {
      final boms = await _billOfMaterialsRepository.findAll();
      
      int totalBoms = boms.length;
      
      return Response.ok(jsonEncode({
        'totalBoms': totalBoms,
      }));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get manufacturing stats: $e'}));
    }
  }

  Future<Response> _getHrStats(Request request) async {
    try {
      final contracts = await _hrRepository.findAll();
      
      int totalEmployees = contracts.length;
      double totalSalaries = contracts.fold(0.0, (sum, contract) => sum + (contract.baseSalary ?? 0));
      
      return Response.ok(jsonEncode({
        'totalEmployees': totalEmployees,
        'totalSalaries': totalSalaries,
      }));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get HR stats: $e'}));
    }
  }

  Future<Response> _getFixedAssetsStats(Request request) async {
    try {
      final assets = await _fixedAssetRepository.findAll();
      
      double totalCost = assets.fold(0.0, (sum, asset) => sum + asset.acquisitionCost);
      double accumulatedDepreciation = assets.fold(0.0, (sum, asset) {
        final netBookValue = asset.currentNetBookValue ?? asset.acquisitionCost;
        return sum + (asset.acquisitionCost - netBookValue);
      });
      double netBookValue = totalCost - accumulatedDepreciation;

      return Response.ok(jsonEncode({
        'totalAssets': assets.length,
        'totalCost': totalCost,
        'accumulatedDepreciation': accumulatedDepreciation,
        'netBookValue': netBookValue,
      }));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get fixed assets stats: $e'}));
    }
  }
}
