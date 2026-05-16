import '../entities/inventory_item.dart';
import '../../core/error/failures.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventoryItems();
  Future<bool> consumePart(String variantId, int quantity, String bookingId);
}
