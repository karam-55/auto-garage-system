import '../../domain/entities/fixed_asset.dart';
import '../../domain/repositories/fixed_asset_repository.dart';

/// Use case to run depreciation for fixed assets
///
/// Auto-Journaling:
/// When depreciation is calculated, creates a journal entry:
/// - Debit: Depreciation Expense (depreciationExpenseAccountId)
/// - Credit: Accumulated Depreciation (accumulatedDepreciationAccountId)
/// - Source: depreciation, sourceId: timestamp
///
/// Supports two depreciation methods:
/// - Straight line: (Acquisition Cost - Salvage Value) / UsefulLife / 12
/// - Declining balance: (Net Book Value * 2 / UsefulLife) / 12
class RunDepreciationUseCase {
  final FixedAssetRepository _fixedAssetRepository;

  RunDepreciationUseCase(this._fixedAssetRepository);

  Future<void> execute({
    required List<FixedAsset> assets,
    required String createdBy,
  }) async {
    await _fixedAssetRepository.runDepreciationWithJournal(assets, createdBy);
  }
}
