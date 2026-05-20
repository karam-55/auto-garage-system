import '../../domain/entities/purchase_invoice.dart';
import '../../domain/repositories/purchase_invoice_repository.dart';

class PayPurchaseInvoiceUseCase {
  final PurchaseInvoiceRepository _purchaseInvoiceRepository;

  PayPurchaseInvoiceUseCase(this._purchaseInvoiceRepository);

  Future<PurchaseInvoice> execute(
    int invoiceId,
    double paymentAmount,
    DateTime paymentDate,
    String paidBy,
  ) async {
    return await _purchaseInvoiceRepository.payWithJournal(
      invoiceId,
      paymentAmount,
      paymentDate,
      paidBy,
    );
  }
}
