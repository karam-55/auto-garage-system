import '../entities/purchase_invoice.dart';

abstract class PurchaseInvoiceRepository {
  Future<PurchaseInvoice> create(PurchaseInvoice invoice);
  Future<PurchaseInvoice?> findById(int id);
  Future<List<PurchaseInvoice>> findAll({int limit = 100, int offset = 0});
  Future<List<PurchaseInvoice>> findByVendorId(int vendorId, {int limit = 100, int offset = 0});
  Future<PurchaseInvoice> update(PurchaseInvoice invoice);
  Future<void> delete(int id);
  
  // Items
  Future<dynamic> createItem(dynamic item);
  Future<dynamic?> findItemById(int id);
  Future<dynamic> findItemsByInvoiceId(int invoiceId);
  Future<dynamic> updateItem(dynamic item);
  Future<void> deleteItem(int id);
  
  // Transactional operations
  Future<PurchaseInvoice> createWithInventoryAndJournal(
    PurchaseInvoice invoice,
    List<dynamic> items,
    String createdBy,
  );
  Future<PurchaseInvoice> payWithJournal(
    int invoiceId,
    double paymentAmount,
    DateTime paymentDate,
    String paidBy,
  );
}
