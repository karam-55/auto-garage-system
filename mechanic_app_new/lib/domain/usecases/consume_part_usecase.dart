import '../repositories/inventory_repository.dart';
import '../../core/error/failures.dart';

class ConsumePartUseCase {
  final InventoryRepository _inventoryRepository;

  ConsumePartUseCase(this._inventoryRepository);

  Future<bool> call(String variantId, int quantity, String bookingId) async {
    try {
      return await _inventoryRepository.consumePart(variantId, quantity, bookingId);
    } on ServerFailure catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkFailure catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to consume part: $e');
    }
  }
}
