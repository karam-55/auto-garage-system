import '../../domain/entities/purchase_invoice.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/purchase_invoice_repository.dart';
import '../../application/services/journal_service.dart';
import '../../domain/repositories/inventory_variant_repository.dart';

class CreatePurchaseInvoiceUseCase {
  final PurchaseInvoiceRepository _purchaseInvoiceRepository;
  final JournalService _journalService;
  final InventoryVariantRepository _inventoryVariantRepository;

  CreatePurchaseInvoiceUseCase(
    this._purchaseInvoiceRepository,
    this._journalService,
    this._inventoryVariantRepository,
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
      // TODO: Implement inventory update logic
      // await _inventoryVariantRepository.addQuantity(item.inventoryVariantId, item.quantity, item.unitPrice);
    }

    // Create journal entry
    // TODO: Get inventory account ID and vendors account ID from accounting settings
    final inventoryAccountId = 1; // Default inventory account
    final vendorsAccountId = 2; // Default vendors account

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
