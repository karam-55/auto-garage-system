import '../../domain/entities/purchase_invoice.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/purchase_invoice_repository.dart';
import '../../application/services/journal_service.dart';
import '../../domain/repositories/inventory_variant_repository.dart';
import '../../application/services/accounting_settings_service.dart';

class CreatePurchaseInvoiceUseCase {
  final PurchaseInvoiceRepository _purchaseInvoiceRepository;
  final JournalService _journalService;
  final InventoryVariantRepository _inventoryVariantRepository;
  final AccountingSettingsService _accountingSettingsService;

  CreatePurchaseInvoiceUseCase(
    this._purchaseInvoiceRepository,
    this._journalService,
    this._inventoryVariantRepository,
    this._accountingSettingsService,
  );

  Future<PurchaseInvoice> execute(
    PurchaseInvoice invoice,
    List<PurchaseInvoiceItem> items,
    String createdBy,
  ) async {
    // Create purchase invoice
    final createdInvoice = await _purchaseInvoiceRepository.create(invoice);

    // Create items and update inventory
    for (final item in items) {
      final itemWithInvoiceId = item.copyWith(invoiceId: createdInvoice.id);
      await _purchaseInvoiceRepository.createItem(itemWithInvoiceId);

      // Update inventory - add quantity
      final variant = await _inventoryVariantRepository.findById(item.inventoryVariantId);
      if (variant != null) {
        final updatedVariant = variant.copyWith(
          quantity: variant.quantity + item.quantity,
          costPrice: item.unitPrice,
        );
        await _inventoryVariantRepository.update(updatedVariant);
      }
    }

    // Create journal entry
    final settings = await _accountingSettingsService.getSettings();
    final inventoryAccountId = settings.inventoryAccountId;
    final vendorsAccountId = settings.payableAccountId; // Using payable account for vendors

    final journalEntry = await _journalService.createJournalEntry(
      date: invoice.issueDate,
      reference: 'PUR-${invoice.invoiceNumber}',
      description: 'فاتورة شراء رقم ${invoice.invoiceNumber} من المورد ${invoice.vendorId}',
      lines: [
        JournalLineInput(
          accountId: inventoryAccountId,
          debit: invoice.totalAmount,
          credit: 0,
          description: 'المخزون',
        ),
        JournalLineInput(
          accountId: vendorsAccountId,
          debit: 0,
          credit: invoice.totalAmount,
          description: 'الموردين',
        ),
      ],
      sourceType: 'purchase',
      sourceId: createdInvoice.id.toString(),
      createdBy: createdBy,
    );

    // Update invoice with journal entry ID
    final updatedInvoice = createdInvoice.copyWith(journalEntryId: journalEntry.id);
    await _purchaseInvoiceRepository.update(updatedInvoice);

    return updatedInvoice;
  }
}
