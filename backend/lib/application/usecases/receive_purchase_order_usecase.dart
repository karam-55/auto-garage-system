import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_order_repository.dart';
import '../services/journal_service.dart';
import '../services/accounting_settings_service.dart';

/// Use case to receive purchase order
/// 
/// Auto-Journaling:
/// When purchase order is received, creates a journal entry:
/// - Debit: Inventory (inventoryAccountId)
/// - Credit: Accounts Payable (payableAccountId)
/// - Source: purchase_receipt, sourceId: purchaseOrderId
class ReceivePurchaseOrderUseCase {
  final PurchaseOrderRepository _repository;
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  ReceivePurchaseOrderUseCase(
    this._repository,
    this._journalService,
    this._accountingSettingsService,
  );

  Future<PurchaseOrder> execute(int purchaseOrderId, String createdBy) async {
    // 1. Get the purchase order
    final order = await _repository.findById(purchaseOrderId);
    if (order == null) {
      throw Exception('Purchase order not found');
    }

    if (order.status != 'confirmed') {
      throw Exception('Purchase order must be confirmed before receiving');
    }

    // 2. Calculate total cost of received items
    double totalCost = 0;
    for (final line in order.lines) {
      if (line.quantityReceived > 0) {
        totalCost += line.quantityReceived * line.unitPrice;
      }
    }

    if (totalCost == 0) {
      throw Exception('No items received');
    }

    // 3. Get accounting settings
    final settings = await _accountingSettingsService.getSettings();

    // 4. Create journal entry
    await _journalService.createJournalEntry(
      date: DateTime.now(),
      reference: 'PO-${order.orderNumber}-RECEIPT',
      description: 'استلام أمر شراء رقم ${order.orderNumber}',
      lines: [
        JournalLineInput(
          accountId: settings.inventoryAccountId,
          debit: totalCost,
          credit: 0,
          description: 'استلام مخزون من أمر شراء ${order.orderNumber}',
        ),
        JournalLineInput(
          accountId: settings.payableAccountId,
          debit: 0,
          credit: totalCost,
          description: 'ذمم دائنة للمورد من أمر شراء ${order.orderNumber}',
        ),
      ],
      sourceType: 'purchase_receipt',
      sourceId: purchaseOrderId.toString(),
      createdBy: createdBy,
    );

    // 5. Update purchase order status to 'received'
    final updatedOrder = order.copyWith(
      status: 'received',
      updatedAt: DateTime.now(),
    );

    return await _repository.update(updatedOrder);
  }
}
