import '../entities/purchase_invoice.dart';

abstract class PurchaseInvoiceRepository {
  Future<PurchaseInvoice> create(PurchaseInvoice invoice);
  Future<PurchaseInvoice?> findById(int id);
  Future<List<PurchaseInvoice>> findAll();
  Future<List<PurchaseInvoice>> findByVendorId(int vendorId);
  Future<List<PurchaseInvoice>> findByStatus(String status);
  Future<PurchaseInvoice> update(PurchaseInvoice invoice);
  Future<void> delete(int id);
  
  Future<PurchaseInvoiceItem> createItem(PurchaseInvoiceItem item);
  Future<List<PurchaseInvoiceItem>> findItemsByInvoiceId(int invoiceId);
  Future<PurchaseInvoiceItem> updateItem(PurchaseInvoiceItem item);
  Future<void> deleteItem(int id);
}
