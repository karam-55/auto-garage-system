import '../../domain/entities/purchase_invoice.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/purchase_invoice_repository.dart';
import '../../application/services/journal_service.dart';
import '../../application/services/accounting_settings_service.dart';

class PayPurchaseInvoiceUseCase {
  final PurchaseInvoiceRepository _purchaseInvoiceRepository;
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  PayPurchaseInvoiceUseCase(
    this._purchaseInvoiceRepository,
    this._journalService,
    this._accountingSettingsService,
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
    final settings = await _accountingSettingsService.getSettings();
    final vendorsAccountId = settings.payableAccountId; // Using payable account for vendors
    final cashAccountId = settings.cashAccountId;

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
