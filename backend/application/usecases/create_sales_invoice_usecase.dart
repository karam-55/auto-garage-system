import '../services/journal_service.dart';
import '../services/accounting_settings_service.dart';

class CreateSalesInvoiceUseCase {
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  CreateSalesInvoiceUseCase(
    this._journalService,
    this._accountingSettingsService,
  );

  Future<void> execute({
    required int salesOrderId,
    required String orderNumber,
    required double totalAmount,
    required double taxAmount,
    required double cogsAmount,
    required String createdBy,
  }) async {
    // 1. Get accounting settings
    final settings = await _accountingSettingsService.getSettings();

    // 2. Create journal entry for revenue
    final lines = <JournalLineInput>[
      JournalLineInput(
        accountId: settings.receivableAccountId,
        debit: totalAmount,
        credit: 0,
        description: 'ذمم مدينة من فاتورة بيع $orderNumber',
      ),
      JournalLineInput(
        accountId: settings.revenueServiceAccountId,
        debit: 0,
        credit: totalAmount - taxAmount,
        description: 'إيرادات خدمات من فاتورة بيع $orderNumber',
      ),
    ];

    // 3. Add tax line if applicable
    if (taxAmount > 0) {
      lines.add(JournalLineInput(
        accountId: settings.salesTaxAccountId,
        debit: 0,
        credit: taxAmount,
        description: 'ضريبة المبيعات من فاتورة بيع $orderNumber',
      ));
    }

    await _journalService.createJournalEntry(
      date: DateTime.now(),
      reference: 'SO-$orderNumber-INVOICE',
      description: 'فاتورة بيع من أمر بيع $orderNumber',
      lines: lines,
      sourceType: 'sales_invoice',
      sourceId: salesOrderId.toString(),
      createdBy: createdBy,
    );

    // 4. Create COGS journal entry if applicable
    if (cogsAmount > 0) {
      await _journalService.createJournalEntry(
        date: DateTime.now(),
        reference: 'SO-$orderNumber-COGS',
        description: 'تكلفة البضاعة المباعة من فاتورة بيع $orderNumber',
        lines: [
          JournalLineInput(
            accountId: settings.cogsPartsAccountId,
            debit: cogsAmount,
            credit: 0,
            description: 'تكلفة البضاعة المباعة من فاتورة بيع $orderNumber',
          ),
          JournalLineInput(
            accountId: settings.inventoryAccountId,
            debit: 0,
            credit: cogsAmount,
            description: 'خصم المخزون من فاتورة بيع $orderNumber',
          ),
        ],
        sourceType: 'sales_cogs',
        sourceId: salesOrderId.toString(),
        createdBy: createdBy,
      );
    }
  }
}
