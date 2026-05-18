import '../entities/purchase_order.dart';

abstract class PurchaseOrderRepository {
  Future<PurchaseOrder> create(PurchaseOrder order);
  Future<PurchaseOrder?> findById(int id);
  Future<List<PurchaseOrder>> findAll();
  Future<List<PurchaseOrder>> findByVendorId(int vendorId);
  Future<PurchaseOrder> update(PurchaseOrder order);
  Future<void> delete(int id);
}
