import '../../domain/entities/purchase_invoice.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/purchase_invoice_repository.dart';
import '../../application/services/journal_service.dart';

class PayPurchaseInvoiceUseCase {
  final PurchaseInvoiceRepository _purchaseInvoiceRepository;
  final JournalService _journalService;

  PayPurchaseInvoiceUseCase(
    this._purchaseInvoiceRepository,
    this._journalService,
  );

  Future<PurchaseInvoice> execute(
    int invoiceId,
    double paymentAmount,
    DateTime paymentDate,
    String paidBy,
  ) async {
    final invoice = await _purchaseInvoiceRepository.findById(invoiceId);
    if (invoice == null) {
      throw Exception('Invoice not found');
    }

    // Update invoice
    final updatedInvoice = invoice.copyWith(
      paidAmount: invoice.paidAmount + paymentAmount,
      status: (invoice.paidAmount + paymentAmount) >= invoice.totalAmount ? 'paid' : 'partial',
    );
    await _purchaseInvoiceRepository.update(updatedInvoice);

    // Create journal entry for payment
    // TODO: Get vendors account ID and cash account ID from accounting settings
    final vendorsAccountId = 2; // Default vendors account
    final cashAccountId = 3; // Default cash account

    final journalEntry = await _journalService.createJournalEntry(
      date: paymentDate,
      reference: 'PAY-${invoice.invoiceNumber}',
      description: 'دفعة لفاتورة شراء رقم ${invoice.invoiceNumber}',
      lines: [
        JournalLineInput(
          accountId: vendorsAccountId,
          debit: paymentAmount,
          credit: 0,
          description: 'الموردين',
        ),
        JournalLineInput(
          accountId: cashAccountId,
          debit: 0,
          credit: paymentAmount,
          description: 'الصندوق',
        ),
      ],
      sourceType: 'purchase_payment',
      sourceId: invoiceId.toString(),
      createdBy: paidBy,
    );

    return updatedInvoice;
  }
}
