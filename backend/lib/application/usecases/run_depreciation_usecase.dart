import '../services/journal_service.dart';
import '../services/accounting_settings_service.dart';
import '../../domain/entities/fixed_asset.dart';

class RunDepreciationUseCase {
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  RunDepreciationUseCase(
    this._journalService,
    this._accountingSettingsService,
  );

  Future<void> execute({
    required List<FixedAsset> assets,
    required String createdBy,
  }) async {
    // 1. Get accounting settings
    final settings = await _accountingSettingsService.getSettings();

    // 2. Calculate total depreciation for all assets
    double totalDepreciation = 0;
    final assetEntries = <Map<String, dynamic>>[];

    for (final asset in assets) {
      // Skip if asset is fully depreciated
      if (asset.currentNetBookValue != null && asset.currentNetBookValue! <= asset.salvageValue) {
        continue;
      }

      // Calculate monthly depreciation based on method
      double monthlyDepreciation = 0;
      if (asset.depreciationMethod == 'straight_line') {
        // Straight-line: (Cost - Salvage) / UsefulLife (years) / 12
        final depreciableAmount = asset.acquisitionCost - asset.salvageValue;
        monthlyDepreciation = depreciableAmount / asset.usefulLifeYears / 12;
      } else if (asset.depreciationMethod == 'declining_balance') {
        // Declining balance: (Net Book Value * 2 / UsefulLife) / 12
        final netBookValue = asset.currentNetBookValue ?? asset.acquisitionCost;
        monthlyDepreciation = (netBookValue * 2 / asset.usefulLifeYears) / 12;
      }

      if (monthlyDepreciation > 0) {
        totalDepreciation += monthlyDepreciation;
        assetEntries.add({
          'asset_id': asset.id,
          'asset_name': asset.name,
          'depreciation_amount': monthlyDepreciation,
        });
      }
    }

    if (totalDepreciation == 0) {
      return; // No depreciation to record
    }

    // 3. Create journal entry for depreciation
    await _journalService.createJournalEntry(
      date: DateTime.now(),
      reference: 'DEPRECIATION-${DateTime.now().year}-${DateTime.now().month}',
      description: 'إهلاك شهري للأصول الثابتة',
      lines: [
        JournalLineInput(
          accountId: settings.depreciationExpenseAccountId,
          debit: totalDepreciation,
          credit: 0,
          description: 'مصروف الإهلاك الشهري',
        ),
        JournalLineInput(
          accountId: settings.accumulatedDepreciationAccountId,
          debit: 0,
          credit: totalDepreciation,
          description: 'مجمع الإهلاك الشهري',
        ),
      ],
      sourceType: 'depreciation',
      sourceId: DateTime.now().toString(),
      createdBy: createdBy,
    );
  }
}
