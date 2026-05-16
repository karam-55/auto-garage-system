import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';
import '../../core/error/failures.dart';

class GetInventoryUseCase {
  final InventoryRepository _inventoryRepository;

  GetInventoryUseCase(this._inventoryRepository);

  Future<List<InventoryItem>> call() async {
    try {
      return await _inventoryRepository.getInventoryItems();
    } on ServerFailure catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkFailure catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get inventory: $e');
    }
  }
}
