import '../services/journal_service.dart';
import '../services/accounting_settings_service.dart';

class PayPurchaseInvoiceUseCase {
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  PayPurchaseInvoiceUseCase(
    this._journalService,
    this._accountingSettingsService,
  );

  Future<void> execute({
    required int purchaseOrderId,
    required double amount,
    required String paymentMethod,
    required String createdBy,
  }) async {
    // 1. Get accounting settings
    final settings = await _accountingSettingsService.getSettings();

    // 2. Determine the cash/bank account based on payment method
    int cashAccountId = settings.cashAccountId;
    if (paymentMethod.toLowerCase() == 'bank' || paymentMethod.toLowerCase() == 'transfer') {
      // In a real system, you'd have a separate bank account or multiple bank accounts
      // For now, we'll use the cash account as a placeholder
      cashAccountId = settings.cashAccountId;
    }

    // 3. Create journal entry
    await _journalService.createJournalEntry(
      date: DateTime.now(),
      reference: 'PO-$purchaseOrderId-PAYMENT',
      description: 'دفع فاتورة شراء رقم $purchaseOrderId',
      lines: [
        JournalLineInput(
          accountId: settings.payableAccountId,
          debit: amount,
          credit: 0,
          description: 'تسوية ذمم المورد من فاتورة شراء $purchaseOrderId',
        ),
        JournalLineInput(
          accountId: cashAccountId,
          debit: 0,
          credit: amount,
          description: 'دفع نقداً/بنكاً لفاتورة شراء $purchaseOrderId',
        ),
      ],
      sourceType: 'purchase_payment',
      sourceId: purchaseOrderId.toString(),
      createdBy: createdBy,
    );
  }
}
