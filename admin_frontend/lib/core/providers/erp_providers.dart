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
  return (res.data as List).map((j) => PurchaseOrder.fromJson(j)).toList();
});

final purchaseOrderProvider = FutureProvider.family<PurchaseOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/purchase-orders/$id');
  return PurchaseOrder.fromJson(res.data);
});

final createPurchaseOrderProvider = FutureProvider.family<PurchaseOrder, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/purchase-orders', data: data);
  return PurchaseOrder.fromJson(res.data);
});

final updatePurchaseOrderProvider = FutureProvider.family<PurchaseOrder, {int id, Map<String, dynamic> data}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/purchase-orders/${params.id}', data: params.data);
  return PurchaseOrder.fromJson(res.data);
});

final deletePurchaseOrderProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/purchase-orders/$id');
});

final confirmPurchaseOrderProvider = FutureProvider.family<PurchaseOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/purchase-orders/$id/confirm');
  return PurchaseOrder.fromJson(res.data);
});

final receivePurchaseOrderProvider = FutureProvider.family<PurchaseOrder, {int id, Map<String, dynamic> data}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/purchase-orders/${params.id}/receive', data: params.data);
  return PurchaseOrder.fromJson(res.data);
});

// ========== المبيعات ==========
final quotationsProvider = FutureProvider<List<Quotation>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/quotations');
  return (res.data as List).map((j) => Quotation.fromJson(j)).toList();
});

final quotationProvider = FutureProvider.family<Quotation, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/quotations/$id');
  return Quotation.fromJson(res.data);
});

final createQuotationProvider = FutureProvider.family<Quotation, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/quotations', data: data);
  return Quotation.fromJson(res.data);
});

final updateQuotationProvider = FutureProvider.family<Quotation, {int id, Map<String, dynamic> data}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/quotations/${params.id}', data: params.data);
  return Quotation.fromJson(res.data);
});

final deleteQuotationProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/quotations/$id');
});

final convertQuotationToOrderProvider = FutureProvider.family<SalesOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/quotations/$id/convert-to-order');
  return SalesOrder.fromJson(res.data);
});

final salesOrdersProvider = FutureProvider<List<SalesOrder>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/sales-orders');
  return (res.data as List).map((j) => SalesOrder.fromJson(j)).toList();
});

final salesOrderProvider = FutureProvider.family<SalesOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/sales-orders/$id');
  return SalesOrder.fromJson(res.data);
});

final createSalesOrderProvider = FutureProvider.family<SalesOrder, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/sales-orders', data: data);
  return SalesOrder.fromJson(res.data);
});

final updateSalesOrderProvider = FutureProvider.family<SalesOrder, {int id, Map<String, dynamic> data}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/sales-orders/${params.id}', data: params.data);
  return SalesOrder.fromJson(res.data);
});

final deleteSalesOrderProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/sales-orders/$id');
});

// ========== المستودعات ==========
final warehousesProvider = FutureProvider<List<Warehouse>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/warehouses');
  return (res.data as List).map((j) => Warehouse.fromJson(j)).toList();
});

final warehouseProvider = FutureProvider.family<Warehouse, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/warehouses/$id');
  return Warehouse.fromJson(res.data);
});

final createWarehouseProvider = FutureProvider.family<Warehouse, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/warehouses', data: data);
  return Warehouse.fromJson(res.data);
});

final updateWarehouseProvider = FutureProvider.family<Warehouse, {int id, Map<String, dynamic> data}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/warehouses/${params.id}', data: params.data);
  return Warehouse.fromJson(res.data);
});

final deleteWarehouseProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/warehouses/$id');
});

final inventoryTransfersProvider = FutureProvider<List<InventoryTransfer>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/inventory-transfers');
  return (res.data as List).map((j) => InventoryTransfer.fromJson(j)).toList();
});

final createInventoryTransferProvider = FutureProvider.family<InventoryTransfer, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/inventory-transfers', data: data);
  return InventoryTransfer.fromJson(res.data);
});

final deleteInventoryTransferProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/inventory-transfers/$id');
});

// ========== الإنتاج ==========
final bomsProvider = FutureProvider<List<BillOfMaterials>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/manufacturing/boms');
  return (res.data as List).map((j) => BillOfMaterials.fromJson(j)).toList();
});

final bomProvider = FutureProvider.family<BillOfMaterials, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/manufacturing/boms/$id');
  return BillOfMaterials.fromJson(res.data);
});

final createBomProvider = FutureProvider.family<BillOfMaterials, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/manufacturing/boms', data: data);
  return BillOfMaterials.fromJson(res.data);
});

final updateBomProvider = FutureProvider.family<BillOfMaterials, {int id, Map<String, dynamic> data}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/manufacturing/boms/${params.id}', data: params.data);
  return BillOfMaterials.fromJson(res.data);
});

final deleteBomProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/manufacturing/boms/$id');
});

final manufacturingOrdersProvider = FutureProvider<List<ManufacturingOrder>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/manufacturing/orders');
  return (res.data as List).map((j) => ManufacturingOrder.fromJson(j)).toList();
});

final manufacturingOrderProvider = FutureProvider.family<ManufacturingOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/manufacturing/orders/$id');
  return ManufacturingOrder.fromJson(res.data);
});

final createManufacturingOrderProvider = FutureProvider.family<ManufacturingOrder, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/manufacturing/orders', data: data);
  return ManufacturingOrder.fromJson(res.data);
});

final updateManufacturingOrderProvider = FutureProvider.family<ManufacturingOrder, {int id, Map<String, dynamic> data}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/manufacturing/orders/${params.id}', data: params.data);
  return ManufacturingOrder.fromJson(res.data);
});

final completeManufacturingOrderProvider = FutureProvider.family<ManufacturingOrder, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/manufacturing/orders/$id/complete');
  return ManufacturingOrder.fromJson(res.data);
});

final deleteManufacturingOrderProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/manufacturing/orders/$id');
});

// ========== CRM ==========
final crmLeadsProvider = FutureProvider<List<CrmLead>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/crm/leads');
  return (res.data as List).map((j) => CrmLead.fromJson(j)).toList();
});

final crmLeadProvider = FutureProvider.family<CrmLead, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/crm/leads/$id');
  return CrmLead.fromJson(res.data);
});

final createCrmLeadProvider = FutureProvider.family<CrmLead, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/crm/leads', data: data);
  return CrmLead.fromJson(res.data);
});

final updateCrmLeadProvider = FutureProvider.family<CrmLead, {int id, Map<String, dynamic> data}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/crm/leads/${params.id}', data: params.data);
  return CrmLead.fromJson(res.data);
});

final convertLeadProvider = FutureProvider.family<CrmLead, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/crm/leads/$id/convert');
  return CrmLead.fromJson(res.data);
});

final deleteCrmLeadProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/crm/leads/$id');
});

// ========== الموارد البشرية ==========
final employeeContractsProvider = FutureProvider<List<EmployeeContract>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/hr/contracts');
  return (res.data as List).map((j) => EmployeeContract.fromJson(j)).toList();
});

final employeeContractProvider = FutureProvider.family<EmployeeContract, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/hr/contracts/$id');
  return EmployeeContract.fromJson(res.data);
});

final createEmployeeContractProvider = FutureProvider.family<EmployeeContract, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/hr/contracts', data: data);
  return EmployeeContract.fromJson(res.data);
});

final updateEmployeeContractProvider = FutureProvider.family<EmployeeContract, {int id, Map<String, dynamic> data}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/hr/contracts/${params.id}', data: params.data);
  return EmployeeContract.fromJson(res.data);
});

final deleteEmployeeContractProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/hr/contracts/$id');
});

final leaveRequestsProvider = FutureProvider<List<LeaveRequest>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/hr/leave-requests');
  return (res.data as List).map((j) => LeaveRequest.fromJson(j)).toList();
});

final leaveRequestProvider = FutureProvider.family<LeaveRequest, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/hr/leave-requests/$id');
  return LeaveRequest.fromJson(res.data);
});

final createLeaveRequestProvider = FutureProvider.family<LeaveRequest, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/hr/leave-requests', data: data);
  return LeaveRequest.fromJson(res.data);
});

final approveLeaveRequestProvider = FutureProvider.family<LeaveRequest, {int id, String approvedBy}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/hr/leave-requests/${params.id}/approve', data: {'approved_by': params.approvedBy});
  return LeaveRequest.fromJson(res.data);
});

final rejectLeaveRequestProvider = FutureProvider.family<LeaveRequest, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/hr/leave-requests/$id/reject');
  return LeaveRequest.fromJson(res.data);
});

final deleteLeaveRequestProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/hr/leave-requests/$id');
});

// ========== الأصول الثابتة ==========
final fixedAssetsProvider = FutureProvider<List<FixedAsset>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/assets');
  return (res.data as List).map((j) => FixedAsset.fromJson(j)).toList();
});

final fixedAssetProvider = FutureProvider.family<FixedAsset, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/assets/$id');
  return FixedAsset.fromJson(res.data);
});

final createFixedAssetProvider = FutureProvider.family<FixedAsset, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/assets', data: data);
  return FixedAsset.fromJson(res.data);
});

final updateFixedAssetProvider = FutureProvider.family<FixedAsset, {int id, Map<String, dynamic> data}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/assets/${params.id}', data: params.data);
  return FixedAsset.fromJson(res.data);
});

final deleteFixedAssetProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/assets/$id');
});

// ========== عقود الصيانة ==========
final maintenanceContractsProvider = FutureProvider<List<MaintenanceContract>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/maintenance/contracts');
  return (res.data as List).map((j) => MaintenanceContract.fromJson(j)).toList();
});

final maintenanceContractProvider = FutureProvider.family<MaintenanceContract, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/maintenance/contracts/$id');
  return MaintenanceContract.fromJson(res.data);
});

final createMaintenanceContractProvider = FutureProvider.family<MaintenanceContract, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.post('/maintenance/contracts', data: data);
  return MaintenanceContract.fromJson(res.data);
});

final updateMaintenanceContractProvider = FutureProvider.family<MaintenanceContract, {int id, Map<String, dynamic> data}>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.put('/maintenance/contracts/${params.id}', data: params.data);
  return MaintenanceContract.fromJson(res.data);
});

final deleteMaintenanceContractProvider = FutureProvider.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/maintenance/contracts/$id');
});
