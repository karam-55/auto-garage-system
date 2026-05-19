import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../screens/purchasing/models/purchase_order.dart';
import '../../screens/sales/models/quotation.dart';
import '../../screens/sales/models/sales_order.dart';
import '../../screens/warehouse/models/warehouse.dart';
import '../../screens/warehouse/models/inventory_transfer.dart';
import '../../screens/manufacturing/models/bill_of_materials.dart';
import '../../screens/manufacturing/models/manufacturing_order.dart';
import '../../screens/crm/models/crm_lead.dart';
import '../../screens/hr/models/employee_contract.dart';
import '../../screens/hr/models/leave_request.dart';
import '../../screens/fixed_assets/models/fixed_asset.dart';
import '../../screens/maintenance/models/maintenance_contract.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Helper classes for multi-parameter providers
class UpdateArgs {
  final int id;
  final Map<String, dynamic> data;
  UpdateArgs(this.id, this.data);
}

class ApproveArgs {
  final int id;
  final String approvedBy;
  ApproveArgs(this.id, this.approvedBy);
}

// ========== البيانات المرجعية ==========
final inventoryVariantsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/inventory/variants');
  return response as List<dynamic>;
});

final customersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/customers');
  return response as List<dynamic>;
});

// ========== المشتريات ==========
final purchaseOrdersProvider = FutureProvider<List<PurchaseOrder>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/purchase-orders');
  return (res as List).map((j) => PurchaseOrder.fromJson(j)).toList();
});

final purchaseOrderProvider = FutureProvider.family<PurchaseOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/purchase-orders/$id');
  return PurchaseOrder.fromJson(res);
});

final createPurchaseOrderProvider = FutureProvider.family<PurchaseOrder, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/purchase-orders', data);
  return PurchaseOrder.fromJson(res);
});

final updatePurchaseOrderProvider = FutureProvider.family<PurchaseOrder, UpdateArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/purchase-orders/${args.id}', args.data);
  return PurchaseOrder.fromJson(res);
});

final deletePurchaseOrderProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/purchase-orders/$id');
});

final confirmPurchaseOrderProvider = FutureProvider.family<PurchaseOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/purchase-orders/$id/confirm', {});
  return PurchaseOrder.fromJson(res);
});

final receivePurchaseOrderProvider = FutureProvider.family<PurchaseOrder, UpdateArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/purchase-orders/${args.id}/receive', args.data);
  return PurchaseOrder.fromJson(res);
});

// ========== المبيعات ==========
final quotationsProvider = FutureProvider<List<Quotation>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/quotations');
  return (res as List).map((j) => Quotation.fromJson(j)).toList();
});

final quotationProvider = FutureProvider.family<Quotation, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/quotations/$id');
  return Quotation.fromJson(res);
});

final createQuotationProvider = FutureProvider.family<Quotation, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/quotations', data);
  return Quotation.fromJson(res);
});

final updateQuotationProvider = FutureProvider.family<Quotation, UpdateArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/quotations/${args.id}', args.data);
  return Quotation.fromJson(res);
});

final deleteQuotationProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/quotations/$id');
});

final convertQuotationToOrderProvider = FutureProvider.family<SalesOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/quotations/$id/convert-to-order', {});
  return SalesOrder.fromJson(res);
});

final salesOrdersProvider = FutureProvider<List<SalesOrder>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/sales-orders');
  return (res as List).map((j) => SalesOrder.fromJson(j)).toList();
});

final salesOrderProvider = FutureProvider.family<SalesOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/sales-orders/$id');
  return SalesOrder.fromJson(res);
});

final createSalesOrderProvider = FutureProvider.family<SalesOrder, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/sales-orders', data);
  return SalesOrder.fromJson(res);
});

final updateSalesOrderProvider = FutureProvider.family<SalesOrder, UpdateArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/sales-orders/${args.id}', args.data);
  return SalesOrder.fromJson(res);
});

final deleteSalesOrderProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/sales-orders/$id');
});

// ========== المستودعات ==========
final warehousesProvider = FutureProvider<List<Warehouse>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/warehouses');
  return (res as List).map((j) => Warehouse.fromJson(j)).toList();
});

final warehouseProvider = FutureProvider.family<Warehouse, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/warehouses/$id');
  return Warehouse.fromJson(res);
});

final createWarehouseProvider = FutureProvider.family<Warehouse, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/warehouses', data);
  return Warehouse.fromJson(res);
});

final updateWarehouseProvider = FutureProvider.family<Warehouse, UpdateArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/warehouses/${args.id}', args.data);
  return Warehouse.fromJson(res);
});

final deleteWarehouseProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/warehouses/$id');
});

final inventoryTransfersProvider = FutureProvider<List<InventoryTransfer>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/inventory-transfers');
  return (res as List).map((j) => InventoryTransfer.fromJson(j)).toList();
});

final createInventoryTransferProvider = FutureProvider.family<InventoryTransfer, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/inventory-transfers', data);
  return InventoryTransfer.fromJson(res);
});

final deleteInventoryTransferProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/inventory-transfers/$id');
});

// ========== الإنتاج ==========
final bomsProvider = FutureProvider<List<BillOfMaterials>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/manufacturing/boms');
  return (res as List).map((j) => BillOfMaterials.fromJson(j)).toList();
});

final bomProvider = FutureProvider.family<BillOfMaterials, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/manufacturing/boms/$id');
  return BillOfMaterials.fromJson(res);
});

final createBomProvider = FutureProvider.family<BillOfMaterials, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/manufacturing/boms', data);
  return BillOfMaterials.fromJson(res);
});

final updateBomProvider = FutureProvider.family<BillOfMaterials, UpdateArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/manufacturing/boms/${args.id}', args.data);
  return BillOfMaterials.fromJson(res);
});

final deleteBomProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/manufacturing/boms/$id');
});

final manufacturingOrdersProvider = FutureProvider<List<ManufacturingOrder>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/manufacturing/orders');
  return (res as List).map((j) => ManufacturingOrder.fromJson(j)).toList();
});

final manufacturingOrderProvider = FutureProvider.family<ManufacturingOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/manufacturing/orders/$id');
  return ManufacturingOrder.fromJson(res);
});

final createManufacturingOrderProvider = FutureProvider.family<ManufacturingOrder, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/manufacturing/orders', data);
  return ManufacturingOrder.fromJson(res);
});

final updateManufacturingOrderProvider = FutureProvider.family<ManufacturingOrder, UpdateArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/manufacturing/orders/${args.id}', args.data);
  return ManufacturingOrder.fromJson(res);
});

final completeManufacturingOrderProvider = FutureProvider.family<ManufacturingOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/manufacturing/orders/$id/complete', {});
  return ManufacturingOrder.fromJson(res);
});

final deleteManufacturingOrderProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/manufacturing/orders/$id');
});

// ========== CRM ==========
final crmLeadsProvider = FutureProvider<List<CrmLead>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/crm/leads');
  return (res as List).map((j) => CrmLead.fromJson(j)).toList();
});

final crmLeadProvider = FutureProvider.family<CrmLead, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/crm/leads/$id');
  return CrmLead.fromJson(res);
});

final createCrmLeadProvider = FutureProvider.family<CrmLead, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/crm/leads', data);
  return CrmLead.fromJson(res);
});

final updateCrmLeadProvider = FutureProvider.family<CrmLead, UpdateArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/crm/leads/${args.id}', args.data);
  return CrmLead.fromJson(res);
});

final convertLeadProvider = FutureProvider.family<CrmLead, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/crm/leads/$id/convert', {});
  return CrmLead.fromJson(res);
});

final deleteCrmLeadProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/crm/leads/$id');
});

// ========== الموارد البشرية ==========
final employeeContractsProvider = FutureProvider<List<EmployeeContract>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/hr/contracts');
  return (res as List).map((j) => EmployeeContract.fromJson(j)).toList();
});

final employeeContractProvider = FutureProvider.family<EmployeeContract, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/hr/contracts/$id');
  return EmployeeContract.fromJson(res);
});

final createEmployeeContractProvider = FutureProvider.family<EmployeeContract, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/hr/contracts', data);
  return EmployeeContract.fromJson(res);
});

final updateEmployeeContractProvider = FutureProvider.family<EmployeeContract, UpdateArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/hr/contracts/${args.id}', args.data);
  return EmployeeContract.fromJson(res);
});

final deleteEmployeeContractProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/hr/contracts/$id');
});

final leaveRequestsProvider = FutureProvider<List<LeaveRequest>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/hr/leave-requests');
  return (res as List).map((j) => LeaveRequest.fromJson(j)).toList();
});

final leaveRequestProvider = FutureProvider.family<LeaveRequest, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/hr/leave-requests/$id');
  return LeaveRequest.fromJson(res);
});

final createLeaveRequestProvider = FutureProvider.family<LeaveRequest, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/hr/leave-requests', data);
  return LeaveRequest.fromJson(res);
});

final approveLeaveRequestProvider = FutureProvider.family<LeaveRequest, ApproveArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/hr/leave-requests/${args.id}/approve', {'approved_by': args.approvedBy});
  return LeaveRequest.fromJson(res);
});

final rejectLeaveRequestProvider = FutureProvider.family<LeaveRequest, ApproveArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/hr/leave-requests/${args.id}/reject', {'approved_by': args.approvedBy});
  return LeaveRequest.fromJson(res);
});

final deleteLeaveRequestProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/hr/leave-requests/$id');
});

// ========== الأصول الثابتة ==========
final fixedAssetsProvider = FutureProvider<List<FixedAsset>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/assets');
  return (res as List).map((j) => FixedAsset.fromJson(j)).toList();
});

final fixedAssetProvider = FutureProvider.family<FixedAsset, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/assets/$id');
  return FixedAsset.fromJson(res);
});

final createFixedAssetProvider = FutureProvider.family<FixedAsset, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/assets', data);
  return FixedAsset.fromJson(res);
});

final updateFixedAssetProvider = FutureProvider.family<FixedAsset, UpdateArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/assets/${args.id}', args.data);
  return FixedAsset.fromJson(res);
});

final deleteFixedAssetProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/assets/$id');
});

// ========== عقود الصيانة ==========
final maintenanceContractsProvider = FutureProvider<List<MaintenanceContract>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/maintenance/contracts');
  return (res as List).map((j) => MaintenanceContract.fromJson(j)).toList();
});

final maintenanceContractProvider = FutureProvider.family<MaintenanceContract, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/maintenance/contracts/$id');
  return MaintenanceContract.fromJson(res);
});

final createMaintenanceContractProvider = FutureProvider.family<MaintenanceContract, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/maintenance/contracts', data);
  return MaintenanceContract.fromJson(res);
});

final updateMaintenanceContractProvider = FutureProvider.family<MaintenanceContract, UpdateArgs>((ref, args) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/maintenance/contracts/${args.id}', args.data);
  return MaintenanceContract.fromJson(res);
});

final deleteMaintenanceContractProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/maintenance/contracts/$id');
});
