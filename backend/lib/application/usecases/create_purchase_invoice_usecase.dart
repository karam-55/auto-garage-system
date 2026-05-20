import '../../domain/entities/purchase_invoice.dart';
import '../../domain/repositories/purchase_invoice_repository.dart';

class CreatePurchaseInvoiceUseCase {
  final PurchaseInvoiceRepository _purchaseInvoiceRepository;

  CreatePurchaseInvoiceUseCase(this._purchaseInvoiceRepository);

  Future<PurchaseInvoice> execute(
    PurchaseInvoice invoice,
    List<dynamic> items,
    String createdBy,
  ) async {
    return await _purchaseInvoiceRepository.createWithInventoryAndJournal(
      invoice,
      items,
      createdBy,
    );
  }
}
