import '../entities/inventory_item.dart';

abstract class InventoryItemRepository {
  Future<List<InventoryItem>> findAll();
  Future<InventoryItem?> findById(String id);
  Future<InventoryItem> create(InventoryItem item);
  Future<InventoryItem> update(InventoryItem item);
  Future<void> delete(String id);
  Future<List<InventoryItem>> findByCategory(String category);
  Future<List<InventoryItem>> findLowStock();
}
