import '../services/journal_service.dart';
import '../services/accounting_settings_service.dart';
import '../../domain/entities/manufacturing_order.dart';

/// Use case to complete manufacturing order
/// 
/// Auto-Journaling:
/// When manufacturing order is completed, creates two journal entries:
/// 1. Raw materials consumption:
///    - Debit: Work In Progress (wipAccountId)
///    - Credit: Inventory (inventoryAccountId)
///    - Source: manufacturing_materials, sourceId: orderId
/// 2. Finished goods transfer:
///    - Debit: Inventory (inventoryAccountId)
///    - Credit: Work In Progress (wipAccountId)
///    - Source: manufacturing_finished, sourceId: orderId
class CompleteManufacturingOrderUseCase {
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  CompleteManufacturingOrderUseCase(
    this._journalService,
    this._accountingSettingsService,
  );

  Future<void> execute({
    required ManufacturingOrder order,
    required double rawMaterialsCost,
    required String createdBy,
  }) async {
    // 1. Get accounting settings
    final settings = await _accountingSettingsService.getSettings();

    // 2. Create journal entry for raw materials consumption (WIP debit, Inventory credit)
    if (rawMaterialsCost > 0) {
      await _journalService.createJournalEntry(
        date: DateTime.now(),
        reference: 'MO-${order.id}-MATERIALS',
        description: 'صرف المواد الخام لأمر إنتاج ${order.id}',
        lines: [
          JournalLineInput(
            accountId: settings.wipAccountId,
            debit: rawMaterialsCost,
            credit: 0,
            description: 'صرف المواد الخام لأمر إنتاج ${order.id}',
          ),
          JournalLineInput(
            accountId: settings.inventoryAccountId,
            debit: 0,
            credit: rawMaterialsCost,
            description: 'خصم المخزون من المواد الخام لأمر إنتاج ${order.id}',
          ),
        ],
        sourceType: 'manufacturing_materials',
        sourceId: order.id.toString(),
        createdBy: createdBy,
      );
    }

    // 3. Create journal entry for finished goods (Inventory debit, WIP credit)
    // Assuming the finished goods value equals raw materials cost for simplicity
    // In a real system, you might calculate this differently
    if (rawMaterialsCost > 0) {
      await _journalService.createJournalEntry(
        date: DateTime.now(),
        reference: 'MO-${order.id}-FINISHED',
        description: 'إضافة المنتج التام لأمر إنتاج ${order.id}',
        lines: [
          JournalLineInput(
            accountId: settings.inventoryAccountId,
            debit: rawMaterialsCost,
            credit: 0,
            description: 'إضافة المنتج التام لأمر إنتاج ${order.id}',
          ),
          JournalLineInput(
            accountId: settings.wipAccountId,
            debit: 0,
            credit: rawMaterialsCost,
            description: 'تحويل من تحت التشغيل إلى المخزون لأمر إنتاج ${order.id}',
          ),
        ],
        sourceType: 'manufacturing_finished',
        sourceId: order.id.toString(),
        createdBy: createdBy,
      );
    }
  }
}
