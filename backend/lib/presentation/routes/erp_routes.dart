import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/role.dart';
import '../middlewares/auth_middleware.dart';
import '../../infrastructure/database/database_connection.dart';
import '../../infrastructure/repositories/purchase_order_repository_impl.dart';
import '../../infrastructure/repositories/quotation_repository_impl.dart';
import '../../infrastructure/repositories/warehouse_repository_impl.dart';
import '../../infrastructure/repositories/bill_of_materials_repository_impl.dart';
import '../../infrastructure/repositories/crm_repository_impl.dart';
import '../../infrastructure/repositories/hr_repository_impl.dart';
import '../../infrastructure/repositories/fixed_asset_repository_impl.dart';
import '../../infrastructure/repositories/crm_activity_repository_impl.dart' as crm_activity_impl;
import '../../infrastructure/repositories/leave_request_repository_impl.dart' as leave_request_impl;
import '../../infrastructure/repositories/performance_review_repository_impl.dart' as performance_review_impl;
import '../../infrastructure/repositories/maintenance_contract_repository_impl.dart' as maintenance_contract_impl;
import '../../infrastructure/repositories/manufacturing_order_repository_impl.dart' as manufacturing_order_impl;
import '../../infrastructure/repositories/sales_order_repository_impl.dart';
import '../../infrastructure/repositories/inventory_transfer_repository_impl.dart';
import '../../infrastructure/repositories/journal_repository_impl.dart';
import '../../infrastructure/repositories/account_repository_impl.dart';
import '../../infrastructure/repositories/company_settings_repository_impl.dart';
import '../../infrastructure/repositories/purchase_invoice_repository_impl.dart';
import '../../domain/entities/crm_activity.dart';
import '../../domain/entities/manufacturing_order.dart' as order;
import '../../domain/entities/performance_review.dart' as review;
import '../../application/services/purchase_order_service.dart';
import '../../application/services/quotation_service.dart';
import '../../application/services/warehouse_service.dart';
import '../../application/services/manufacturing_service.dart';
import '../../application/services/crm_service.dart';
import '../../application/services/hr_service.dart';
import '../../application/services/fixed_asset_service.dart';
import '../../application/services/sales_order_service.dart';
import '../../application/services/inventory_transfer_service.dart';
import '../../application/services/journal_service.dart';
import '../../application/services/accounting_settings_service.dart';
import '../../application/usecases/receive_purchase_order_usecase.dart';
import '../../application/usecases/pay_purchase_invoice_usecase.dart';
import '../../application/usecases/create_sales_invoice_usecase.dart';
import '../../application/usecases/complete_manufacturing_order_usecase.dart';
import '../../application/usecases/run_depreciation_usecase.dart';

class ErpRoutes {
  final PurchaseOrderService _purchaseOrderService;
  final QuotationService _quotationService;
  final WarehouseService _warehouseService;
  final ManufacturingService _manufacturingService;
  final CrmService _crmService;
  final HrService _hrService;
  final FixedAssetService _fixedAssetService;
  final SalesOrderService _salesOrderService;
  final InventoryTransferService _inventoryTransferService;
  final AuthMiddleware _authMiddleware;
  final ReceivePurchaseOrderUseCase _receivePurchaseOrderUseCase;
  final PayPurchaseInvoiceUseCase _payPurchaseInvoiceUseCase;
  final CreateSalesInvoiceUseCase _createSalesInvoiceUseCase;
  final CompleteManufacturingOrderUseCase _completeManufacturingOrderUseCase;
  final RunDepreciationUseCase _runDepreciationUseCase;

  ErpRoutes(
    this._purchaseOrderService,
    this._quotationService,
    this._warehouseService,
    this._manufacturingService,
    this._crmService,
    this._hrService,
    this._fixedAssetService,
    this._salesOrderService,
    this._inventoryTransferService,
    this._authMiddleware,
    this._receivePurchaseOrderUseCase,
    this._payPurchaseInvoiceUseCase,
    this._createSalesInvoiceUseCase,
    this._completeManufacturingOrderUseCase,
    this._runDepreciationUseCase,
  );

  factory ErpRoutes.create(DatabaseConnection db, AuthMiddleware authMiddleware) {
    final purchaseOrderRepo = PurchaseOrderRepositoryImpl(db);
    final quotationRepo = QuotationRepositoryImpl(db);
    final warehouseRepo = WarehouseRepositoryImpl(db);
    final inventoryRepo = InventoryVariantWarehouseRepositoryImpl(db);
    final bomRepo = BillOfMaterialsRepositoryImpl(db);
    final orderRepo = manufacturing_order_impl.ManufacturingOrderRepositoryImpl(db);
    final salesOrderRepo = SalesOrderRepositoryImpl(db);
    final inventoryTransferRepo = InventoryTransferRepositoryImpl(db);
    final leadRepo = CrmLeadRepositoryImpl(db);
    final activityRepo = crm_activity_impl.CrmActivityRepositoryImpl(db);
    final contractRepo = EmployeeContractRepositoryImpl(db);
    final leaveRepo = leave_request_impl.LeaveRequestRepositoryImpl(db);
    final reviewRepo = performance_review_impl.PerformanceReviewRepositoryImpl(db);
    final assetRepo = FixedAssetRepositoryImpl(db);
    final maintenanceRepo = maintenance_contract_impl.MaintenanceContractRepositoryImpl(db);
    final purchaseInvoiceRepo = PurchaseInvoiceRepositoryImpl(db);
    final journalRepo = JournalRepositoryImpl(db);
    final accountRepo = AccountRepositoryImpl(db);
    final settingsRepo = CompanySettingsRepositoryImpl(db);

    final purchaseOrderService = PurchaseOrderService(purchaseOrderRepo);
    final quotationService = QuotationService(quotationRepo);
    final warehouseService = WarehouseService(warehouseRepo);
    final manufacturingService = ManufacturingService(bomRepo, orderRepo);
    final salesOrderService = SalesOrderService(salesOrderRepo);
    final inventoryTransferService = InventoryTransferService(inventoryTransferRepo);
    final crmService = CrmService(leadRepo, activityRepo);
    final hrService = HrService(contractRepo, leaveRepo, reviewRepo);
    final fixedAssetService = FixedAssetService(assetRepo, maintenanceRepo);
    final journalService = JournalService(journalRepo, accountRepo);
    final accountingSettingsService = AccountingSettingsService(settingsRepo, accountRepo);

    final receivePurchaseOrderUseCase = ReceivePurchaseOrderUseCase(purchaseOrderRepo, journalService, accountingSettingsService);
    final payPurchaseInvoiceUseCase = PayPurchaseInvoiceUseCase(purchaseInvoiceRepo, journalService);
    final createSalesInvoiceUseCase = CreateSalesInvoiceUseCase(journalService, accountingSettingsService);
    final completeManufacturingOrderUseCase = CompleteManufacturingOrderUseCase(journalService, accountingSettingsService);
    final runDepreciationUseCase = RunDepreciationUseCase(journalService, accountingSettingsService);

    return ErpRoutes(
      purchaseOrderService,
      quotationService,
      warehouseService,
      manufacturingService,
      crmService,
      hrService,
      fixedAssetService,
      salesOrderService,
      inventoryTransferService,
      authMiddleware,
      receivePurchaseOrderUseCase,
      payPurchaseInvoiceUseCase,
      createSalesInvoiceUseCase,
      completeManufacturingOrderUseCase,
      runDepreciationUseCase,
    );
  }

  Router get router {
    final router = Router();

    // Purchase Orders
    router.get('/purchase-orders', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getPurchaseOrders)));
    router.get('/purchase-orders/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getPurchaseOrder)));
    router.post('/purchase-orders', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_createPurchaseOrder)));
    router.put('/purchase-orders/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_updatePurchaseOrder)));
    router.delete('/purchase-orders/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deletePurchaseOrder)));
    router.put('/purchase-orders/<id>/confirm', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_confirmPurchaseOrder)));
    router.put('/purchase-orders/<id>/receive', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_receivePurchaseOrder)));
    router.post('/purchase-invoices/<id>/pay', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_payPurchaseInvoice)));

    // Quotations
    router.get('/quotations', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_SALES, Role.ACCOUNTANT])(_getQuotations)));
    router.get('/quotations/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_SALES, Role.ACCOUNTANT])(_getQuotation)));
    router.post('/quotations', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_SALES])(_createQuotation)));
    router.put('/quotations/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_SALES])(_updateQuotation)));
    router.delete('/quotations/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteQuotation)));
    router.post('/quotations/<id>/convert-to-order', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_SALES])(_convertQuotationToOrder)));

    // Warehouses
    router.get('/warehouses', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_WAREHOUSE, Role.ACCOUNTANT])(_getWarehouses)));
    router.get('/warehouses/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_WAREHOUSE, Role.ACCOUNTANT])(_getWarehouse)));
    router.post('/warehouses', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_createWarehouse)));
    router.put('/warehouses/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_updateWarehouse)));
    router.delete('/warehouses/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteWarehouse)));

    // Manufacturing
    router.get('/manufacturing/boms', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_WAREHOUSE, Role.ACCOUNTANT])(_getBoms)));
    router.get('/manufacturing/boms/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_WAREHOUSE, Role.ACCOUNTANT])(_getBom)));
    router.post('/manufacturing/boms', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_createBom)));
    router.put('/manufacturing/boms/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_updateBom)));
    router.delete('/manufacturing/boms/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteBom)));

    router.get('/manufacturing/orders', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_WAREHOUSE, Role.ACCOUNTANT])(_getManufacturingOrders)));
    router.get('/manufacturing/orders/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_WAREHOUSE, Role.ACCOUNTANT])(_getManufacturingOrder)));
    router.post('/manufacturing/orders', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_createManufacturingOrder)));
    router.put('/manufacturing/orders/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_updateManufacturingOrder)));
    router.delete('/manufacturing/orders/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteManufacturingOrder)));
    router.post('/manufacturing/orders/<id>/complete', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_completeManufacturingOrder)));

    // Sales Orders
    router.get('/sales-orders', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_SALES, Role.ACCOUNTANT])(_getSalesOrders)));
    router.get('/sales-orders/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_SALES, Role.ACCOUNTANT])(_getSalesOrder)));
    router.post('/sales-orders', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_SALES])(_createSalesOrder)));
    router.put('/sales-orders/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_SALES])(_updateSalesOrder)));
    router.delete('/sales-orders/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteSalesOrder)));
    router.post('/sales-orders/<id>/invoice', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_createSalesInvoice)));

    // Inventory Transfers
    router.get('/inventory-transfers', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_WAREHOUSE, Role.ACCOUNTANT])(_getInventoryTransfers)));
    router.get('/inventory-transfers/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_WAREHOUSE, Role.ACCOUNTANT])(_getInventoryTransfer)));
    router.post('/inventory-transfers', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_WAREHOUSE])(_createInventoryTransfer)));
    router.delete('/inventory-transfers/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteInventoryTransfer)));

    // CRM
    router.get('/crm/leads', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_SALES, Role.ACCOUNTANT])(_getLeads)));
    router.get('/crm/leads/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_SALES, Role.ACCOUNTANT])(_getLead)));
    router.post('/crm/leads', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_SALES])(_createLead)));
    router.put('/crm/leads/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_SALES])(_updateLead)));
    router.put('/crm/leads/<id>/convert', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_SALES])(_convertLead)));
    router.delete('/crm/leads/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteLead)));

    router.get('/crm/activities', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_SALES, Role.ACCOUNTANT])(_getActivities)));
    router.get('/crm/activities/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_SALES, Role.ACCOUNTANT])(_getActivity)));
    router.post('/crm/activities', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_SALES])(_createActivity)));
    router.delete('/crm/activities/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteActivity)));

    // HR
    router.get('/hr/contracts', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.HR_MANAGER, Role.ACCOUNTANT])(_getContracts)));
    router.get('/hr/contracts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.HR_MANAGER, Role.ACCOUNTANT])(_getContract)));
    router.post('/hr/contracts', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.HR_MANAGER])(_createContract)));
    router.put('/hr/contracts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.HR_MANAGER])(_updateContract)));
    router.delete('/hr/contracts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteContract)));

    router.get('/hr/leave-requests', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.HR_MANAGER, Role.ACCOUNTANT])(_getLeaveRequests)));
    router.get('/hr/leave-requests/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.HR_MANAGER, Role.ACCOUNTANT])(_getLeaveRequest)));
    router.post('/hr/leave-requests', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.HR_MANAGER])(_createLeaveRequest)));
    router.put('/hr/leave-requests/<id>/approve', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.HR_MANAGER])(_approveLeaveRequest)));
    router.put('/hr/leave-requests/<id>/reject', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.HR_MANAGER])(_rejectLeaveRequest)));
    router.delete('/hr/leave-requests/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteLeaveRequest)));

    router.get('/hr/performance-reviews', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.HR_MANAGER, Role.ACCOUNTANT])(_getPerformanceReviews)));
    router.get('/hr/performance-reviews/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.HR_MANAGER, Role.ACCOUNTANT])(_getPerformanceReview)));
    router.post('/hr/performance-reviews', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.HR_MANAGER])(_createPerformanceReview)));
    router.delete('/hr/performance-reviews/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deletePerformanceReview)));

    // Fixed Assets
    router.get('/assets', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getFixedAssets)));
    router.get('/assets/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.ACCOUNTANT])(_getFixedAsset)));
    router.post('/assets', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_createFixedAsset)));
    router.put('/assets/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_updateFixedAsset)));
    router.delete('/assets/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteFixedAsset)));
    router.post('/assets/depreciate', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.ACCOUNTANT])(_runDepreciation)));

    // Maintenance Contracts
    router.get('/maintenance/contracts', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_SALES, Role.ACCOUNTANT])(_getMaintenanceContracts)));
    router.get('/maintenance/contracts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_SALES, Role.ACCOUNTANT])(_getMaintenanceContract)));
    router.get('/maintenance/contracts/due', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER, Role.MANAGER_SALES, Role.ACCOUNTANT])(_getDueMaintenanceContracts)));
    router.post('/maintenance/contracts', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_SALES])(_createMaintenanceContract)));
    router.put('/maintenance/contracts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER, Role.MANAGER_SALES])(_updateMaintenanceContract)));
    router.delete('/maintenance/contracts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.OWNER])(_deleteMaintenanceContract)));

    return router;
  }

  // Purchase Order Handlers
  Future<Response> _getPurchaseOrders(Request request) async {
    try {
      final orders = await _purchaseOrderService.getAllOrders();
      return Response.ok(jsonEncode(orders.map((o) => o.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch purchase orders: $e'}));
    }
  }

  Future<Response> _getPurchaseOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final order = await _purchaseOrderService.getOrder(id);
      if (order == null) {
        return Response.notFound(jsonEncode({'error': 'Purchase order not found'}));
      }
      return Response.ok(jsonEncode(order.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch purchase order: $e'}));
    }
  }

  Future<Response> _createPurchaseOrder(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create PurchaseOrder from data
      return Response.ok(jsonEncode({'message': 'Purchase order created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create purchase order: $e'}));
    }
  }

  Future<Response> _updatePurchaseOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and update PurchaseOrder from data
      return Response.ok(jsonEncode({'message': 'Purchase order updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update purchase order: $e'}));
    }
  }

  Future<Response> _deletePurchaseOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _purchaseOrderService.deleteOrder(id);
      return Response.ok(jsonEncode({'message': 'Purchase order deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete purchase order: $e'}));
    }
  }

  Future<Response> _confirmPurchaseOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Implement confirm purchase order logic
      return Response.ok(jsonEncode({'message': 'Purchase order confirmed'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to confirm purchase order: $e'}));
    }
  }

  // Quotation Handlers
  Future<Response> _getQuotations(Request request) async {
    try {
      final quotations = await _quotationService.getAllQuotations();
      return Response.ok(jsonEncode(quotations.map((q) => q.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch quotations: $e'}));
    }
  }

  Future<Response> _getQuotation(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final quotation = await _quotationService.getQuotation(id);
      if (quotation == null) {
        return Response.notFound(jsonEncode({'error': 'Quotation not found'}));
      }
      return Response.ok(jsonEncode(quotation.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch quotation: $e'}));
    }
  }

  Future<Response> _createQuotation(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create Quotation from data
      return Response.ok(jsonEncode({'message': 'Quotation created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create quotation: $e'}));
    }
  }

  Future<Response> _updateQuotation(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and update Quotation from data
      return Response.ok(jsonEncode({'message': 'Quotation updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update quotation: $e'}));
    }
  }

  Future<Response> _deleteQuotation(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _quotationService.deleteQuotation(id);
      return Response.ok(jsonEncode({'message': 'Quotation deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete quotation: $e'}));
    }
  }

  Future<Response> _convertQuotationToOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Implement convert quotation to sales order logic
      return Response.ok(jsonEncode({'message': 'Quotation converted to sales order'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to convert quotation: $e'}));
    }
  }

  // Warehouse Handlers
  Future<Response> _getWarehouses(Request request) async {
    try {
      final warehouses = await _warehouseService.getAllWarehouses();
      return Response.ok(jsonEncode(warehouses.map((w) => w.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch warehouses: $e'}));
    }
  }

  Future<Response> _getWarehouse(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final warehouse = await _warehouseService.getWarehouse(id);
      if (warehouse == null) {
        return Response.notFound(jsonEncode({'error': 'Warehouse not found'}));
      }
      return Response.ok(jsonEncode(warehouse.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch warehouse: $e'}));
    }
  }

  Future<Response> _createWarehouse(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create Warehouse from data
      return Response.ok(jsonEncode({'message': 'Warehouse created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create warehouse: $e'}));
    }
  }

  Future<Response> _updateWarehouse(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and update Warehouse from data
      return Response.ok(jsonEncode({'message': 'Warehouse updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update warehouse: $e'}));
    }
  }

  Future<Response> _deleteWarehouse(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _warehouseService.deleteWarehouse(id);
      return Response.ok(jsonEncode({'message': 'Warehouse deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete warehouse: $e'}));
    }
  }

  // Manufacturing Handlers
  Future<Response> _getBoms(Request request) async {
    try {
      final boms = await _manufacturingService.getAllBoms();
      return Response.ok(jsonEncode(boms.map((b) => b.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch BOMs: $e'}));
    }
  }

  Future<Response> _getBom(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final bom = await _manufacturingService.getBom(id);
      if (bom == null) {
        return Response.notFound(jsonEncode({'error': 'BOM not found'}));
      }
      return Response.ok(jsonEncode(bom.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch BOM: $e'}));
    }
  }

  Future<Response> _createBom(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create BOM from data
      return Response.ok(jsonEncode({'message': 'BOM created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create BOM: $e'}));
    }
  }

  Future<Response> _updateBom(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and update BOM from data
      return Response.ok(jsonEncode({'message': 'BOM updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update BOM: $e'}));
    }
  }

  Future<Response> _deleteBom(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _manufacturingService.deleteBom(id);
      return Response.ok(jsonEncode({'message': 'BOM deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete BOM: $e'}));
    }
  }

  Future<Response> _getManufacturingOrders(Request request) async {
    try {
      final orders = await _manufacturingService.getAllManufacturingOrders();
      return Response.ok(jsonEncode(orders.map((o) => (o as order.ManufacturingOrder).toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch manufacturing orders: $e'}));
    }
  }

  Future<Response> _getManufacturingOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final order = await _manufacturingService.getManufacturingOrder(id);
      if (order == null) {
        return Response.notFound(jsonEncode({'error': 'Manufacturing order not found'}));
      }
      return Response.ok(jsonEncode(order.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch manufacturing order: $e'}));
    }
  }

  Future<Response> _createManufacturingOrder(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create ManufacturingOrder from data
      return Response.ok(jsonEncode({'message': 'Manufacturing order created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create manufacturing order: $e'}));
    }
  }

  Future<Response> _updateManufacturingOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and update ManufacturingOrder from data
      return Response.ok(jsonEncode({'message': 'Manufacturing order updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update manufacturing order: $e'}));
    }
  }

  Future<Response> _deleteManufacturingOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _manufacturingService.deleteManufacturingOrder(id);
      return Response.ok(jsonEncode({'message': 'Manufacturing order deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete manufacturing order: $e'}));
    }
  }

  Future<Response> _completeManufacturingOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _manufacturingService.completeManufacturingOrder(id);
      return Response.ok(jsonEncode({'message': 'Manufacturing order completed'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to complete manufacturing order: $e'}));
    }
  }

  // CRM Handlers
  Future<Response> _getLeads(Request request) async {
    try {
      final leads = await _crmService.getAllLeads();
      return Response.ok(jsonEncode(leads.map((l) => l.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch leads: $e'}));
    }
  }

  Future<Response> _getLead(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final lead = await _crmService.getLead(id);
      if (lead == null) {
        return Response.notFound(jsonEncode({'error': 'Lead not found'}));
      }
      return Response.ok(jsonEncode(lead.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch lead: $e'}));
    }
  }

  Future<Response> _createLead(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create CrmLead from data
      return Response.ok(jsonEncode({'message': 'Lead created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create lead: $e'}));
    }
  }

  Future<Response> _updateLead(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and update CrmLead from data
      return Response.ok(jsonEncode({'message': 'Lead updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update lead: $e'}));
    }
  }

  Future<Response> _convertLead(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _crmService.convertLeadToCustomer(id);
      return Response.ok(jsonEncode({'message': 'Lead converted to customer'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to convert lead: $e'}));
    }
  }

  Future<Response> _deleteLead(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _crmService.deleteLead(id);
      return Response.ok(jsonEncode({'message': 'Lead deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete lead: $e'}));
    }
  }

  Future<Response> _getActivities(Request request) async {
    try {
      final leadId = request.url.queryParameters['lead_id'];
      if (leadId != null) {
        final activities = await _crmService.getActivitiesByLeadId(int.parse(leadId));
        return Response.ok(jsonEncode(activities.map((a) => (a as CrmActivity).toJson()).toList()));
      }
      return Response.badRequest(body: jsonEncode({'error': 'lead_id parameter required'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch activities: $e'}));
    }
  }

  Future<Response> _getActivity(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final activity = await _crmService.getActivity(id);
      if (activity == null) {
        return Response.notFound(jsonEncode({'error': 'Activity not found'}));
      }
      return Response.ok(jsonEncode(activity.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch activity: $e'}));
    }
  }

  Future<Response> _createActivity(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create CrmActivity from data
      return Response.ok(jsonEncode({'message': 'Activity created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create activity: $e'}));
    }
  }

  Future<Response> _deleteActivity(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _crmService.deleteActivity(id);
      return Response.ok(jsonEncode({'message': 'Activity deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete activity: $e'}));
    }
  }

  // HR Handlers
  Future<Response> _getContracts(Request request) async {
    try {
      final userId = request.url.queryParameters['user_id'];
      if (userId != null) {
        final contracts = await _hrService.getContractsByUser(userId);
        return Response.ok(jsonEncode(contracts.map((c) => c.toJson()).toList()));
      }
      return Response.badRequest(body: jsonEncode({'error': 'user_id parameter required'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch contracts: $e'}));
    }
  }

  Future<Response> _getContract(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final contract = await _hrService.getContract(id);
      if (contract == null) {
        return Response.notFound(jsonEncode({'error': 'Contract not found'}));
      }
      return Response.ok(jsonEncode(contract.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch contract: $e'}));
    }
  }

  Future<Response> _createContract(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create EmployeeContract from data
      return Response.ok(jsonEncode({'message': 'Contract created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create contract: $e'}));
    }
  }

  Future<Response> _updateContract(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and update EmployeeContract from data
      return Response.ok(jsonEncode({'message': 'Contract updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update contract: $e'}));
    }
  }

  Future<Response> _deleteContract(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _hrService.deleteContract(id);
      return Response.ok(jsonEncode({'message': 'Contract deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete contract: $e'}));
    }
  }

  Future<Response> _getLeaveRequests(Request request) async {
    try {
      final status = request.url.queryParameters['status'];
      if (status != null) {
        final requests = await _hrService.getLeaveRequestsByStatus(status);
        return Response.ok(jsonEncode(requests.map((r) => r.toJson()).toList()));
      }
      return Response.badRequest(body: jsonEncode({'error': 'status parameter required'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch leave requests: $e'}));
    }
  }

  Future<Response> _getLeaveRequest(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final leaveRequest = await _hrService.getLeaveRequest(id);
      if (leaveRequest == null) {
        return Response.notFound(jsonEncode({'error': 'Leave request not found'}));
      }
      return Response.ok(jsonEncode(leaveRequest.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch leave request: $e'}));
    }
  }

  Future<Response> _createLeaveRequest(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create LeaveRequest from data
      return Response.ok(jsonEncode({'message': 'Leave request created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create leave request: $e'}));
    }
  }

  Future<Response> _deleteLeaveRequest(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _hrService.deleteLeaveRequest(id);
      return Response.ok(jsonEncode({'message': 'Leave request deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete leave request: $e'}));
    }
  }

  Future<Response> _approveLeaveRequest(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final approvedBy = data['approved_by'] as String;
      await _hrService.approveLeaveRequest(id, approvedBy);
      return Response.ok(jsonEncode({'message': 'Leave request approved'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to approve leave request: $e'}));
    }
  }

  Future<Response> _rejectLeaveRequest(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _hrService.rejectLeaveRequest(id);
      return Response.ok(jsonEncode({'message': 'Leave request rejected'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to reject leave request: $e'}));
    }
  }

  Future<Response> _getPerformanceReviews(Request request) async {
    try {
      final userId = request.url.queryParameters['user_id'];
      if (userId != null) {
        final reviews = await _hrService.getPerformanceReviewsByUser(userId);
        return Response.ok(jsonEncode(reviews.map((r) => (r as review.PerformanceReview).toJson()).toList()));
      }
      return Response.badRequest(body: jsonEncode({'error': 'user_id parameter required'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch performance reviews: $e'}));
    }
  }

  Future<Response> _getPerformanceReview(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final review = await _hrService.getPerformanceReview(id);
      if (review == null) {
        return Response.notFound(jsonEncode({'error': 'Performance review not found'}));
      }
      return Response.ok(jsonEncode(review.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch performance review: $e'}));
    }
  }

  Future<Response> _createPerformanceReview(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create PerformanceReview from data
      return Response.ok(jsonEncode({'message': 'Performance review created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create performance review: $e'}));
    }
  }

  Future<Response> _deletePerformanceReview(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _hrService.deletePerformanceReview(id);
      return Response.ok(jsonEncode({'message': 'Performance review deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete performance review: $e'}));
    }
  }

  // Fixed Assets Handlers
  Future<Response> _getFixedAssets(Request request) async {
    try {
      final assets = await _fixedAssetService.getAllFixedAssets();
      return Response.ok(jsonEncode(assets.map((a) => a.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch fixed assets: $e'}));
    }
  }

  Future<Response> _getFixedAsset(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final asset = await _fixedAssetService.getFixedAsset(id);
      if (asset == null) {
        return Response.notFound(jsonEncode({'error': 'Fixed asset not found'}));
      }
      return Response.ok(jsonEncode(asset.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch fixed asset: $e'}));
    }
  }

  Future<Response> _createFixedAsset(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create FixedAsset from data
      return Response.ok(jsonEncode({'message': 'Fixed asset created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create fixed asset: $e'}));
    }
  }

  Future<Response> _updateFixedAsset(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and update FixedAsset from data
      return Response.ok(jsonEncode({'message': 'Fixed asset updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update fixed asset: $e'}));
    }
  }

  Future<Response> _deleteFixedAsset(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _fixedAssetService.deleteFixedAsset(id);
      return Response.ok(jsonEncode({'message': 'Fixed asset deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete fixed asset: $e'}));
    }
  }

  // Maintenance Contracts Handlers
  Future<Response> _getMaintenanceContracts(Request request) async {
    try {
      final customerId = request.url.queryParameters['customer_id'];
      final vehicleId = request.url.queryParameters['vehicle_id'];
      if (customerId != null) {
        final contracts = await _fixedAssetService.getContractsByCustomer(customerId);
        return Response.ok(jsonEncode(contracts.map((c) => c.toJson()).toList()));
      } else if (vehicleId != null) {
        final contracts = await _fixedAssetService.getContractsByVehicle(vehicleId);
        return Response.ok(jsonEncode(contracts.map((c) => c.toJson()).toList()));
      }
      return Response.badRequest(body: jsonEncode({'error': 'customer_id or vehicle_id parameter required'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch maintenance contracts: $e'}));
    }
  }

  Future<Response> _getMaintenanceContract(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final contract = await _fixedAssetService.getMaintenanceContract(id);
      if (contract == null) {
        return Response.notFound(jsonEncode({'error': 'Maintenance contract not found'}));
      }
      return Response.ok(jsonEncode(contract.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch maintenance contract: $e'}));
    }
  }

  Future<Response> _getDueMaintenanceContracts(Request request) async {
    try {
      final contracts = await _fixedAssetService.getDueContracts();
      return Response.ok(jsonEncode(contracts.map((c) => c.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch due maintenance contracts: $e'}));
    }
  }

  Future<Response> _createMaintenanceContract(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create MaintenanceContract from data
      return Response.ok(jsonEncode({'message': 'Maintenance contract created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create maintenance contract: $e'}));
    }
  }

  Future<Response> _updateMaintenanceContract(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and update MaintenanceContract from data
      return Response.ok(jsonEncode({'message': 'Maintenance contract updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update maintenance contract: $e'}));
    }
  }

  Future<Response> _deleteMaintenanceContract(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _fixedAssetService.deleteMaintenanceContract(id);
      return Response.ok(jsonEncode({'message': 'Maintenance contract deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete maintenance contract: $e'}));
    }
  }

  // Accounting Integration Handlers
  Future<Response> _receivePurchaseOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final createdBy = data['created_by'] as String? ?? 'system';
      
      final updatedOrder = await _receivePurchaseOrderUseCase.execute(id, createdBy);
      return Response.ok(jsonEncode(updatedOrder.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to receive purchase order: $e'}));
    }
  }

  Future<Response> _payPurchaseInvoice(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      await _payPurchaseInvoiceUseCase.execute(
        id,
        data['amount'] as double,
        DateTime.now(),
        data['created_by'] as String? ?? 'system',
      );
      
      return Response.ok(jsonEncode({'message': 'Purchase invoice paid'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to pay purchase invoice: $e'}));
    }
  }

  Future<Response> _createSalesInvoice(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      await _createSalesInvoiceUseCase.execute(
        salesOrderId: id,
        orderNumber: data['order_number'] as String? ?? 'SO-$id',
        totalAmount: data['amount'] as double? ?? 0.0,
        taxAmount: data['tax_amount'] as double? ?? 0.0,
        cogsAmount: data['cogs_amount'] as double? ?? 0.0,
        createdBy: data['created_by'] as String? ?? 'system',
      );
      
      return Response.ok(jsonEncode({'message': 'Sales invoice created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create sales invoice: $e'}));
    }
  }

  // Sales Order Handlers
  Future<Response> _getSalesOrders(Request request) async {
    try {
      final orders = await _salesOrderService.getAllSalesOrders();
      return Response.ok(jsonEncode(orders.map((o) => o.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch sales orders: $e'}));
    }
  }

  Future<Response> _getSalesOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final order = await _salesOrderService.getSalesOrder(id);
      if (order == null) {
        return Response.notFound(jsonEncode({'error': 'Sales order not found'}));
      }
      return Response.ok(jsonEncode(order.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch sales order: $e'}));
    }
  }

  Future<Response> _createSalesOrder(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create SalesOrder from data
      return Response.ok(jsonEncode({'message': 'Sales order created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create sales order: $e'}));
    }
  }

  Future<Response> _updateSalesOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and update SalesOrder from data
      return Response.ok(jsonEncode({'message': 'Sales order updated'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update sales order: $e'}));
    }
  }

  Future<Response> _deleteSalesOrder(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _salesOrderService.deleteSalesOrder(id);
      return Response.ok(jsonEncode({'message': 'Sales order deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete sales order: $e'}));
    }
  }

  // Inventory Transfer Handlers
  Future<Response> _getInventoryTransfers(Request request) async {
    try {
      final transfers = await _inventoryTransferService.getAllInventoryTransfers();
      return Response.ok(jsonEncode(transfers.map((t) => t.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch inventory transfers: $e'}));
    }
  }

  Future<Response> _getInventoryTransfer(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      final transfer = await _inventoryTransferService.getInventoryTransfer(id);
      if (transfer == null) {
        return Response.notFound(jsonEncode({'error': 'Inventory transfer not found'}));
      }
      return Response.ok(jsonEncode(transfer.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to fetch inventory transfer: $e'}));
    }
  }

  Future<Response> _createInventoryTransfer(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      // TODO: Parse and create InventoryTransfer from data
      return Response.ok(jsonEncode({'message': 'Inventory transfer created'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create inventory transfer: $e'}));
    }
  }

  Future<Response> _deleteInventoryTransfer(Request request) async {
    try {
      final id = int.parse(request.params['id'] as String);
      await _inventoryTransferService.deleteInventoryTransfer(id);
      return Response.ok(jsonEncode({'message': 'Inventory transfer deleted'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete inventory transfer: $e'}));
    }
  }

  Future<Response> _runDepreciation(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final createdBy = data['created_by'] as String? ?? 'system';
      
      // Get all fixed assets
      final assets = await _fixedAssetService.getAllFixedAssets();
      
      await _runDepreciationUseCase.execute(
        assets: assets,
        createdBy: createdBy,
      );
      
      return Response.ok(jsonEncode({'message': 'Depreciation run completed'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to run depreciation: $e'}));
    }
  }
}
