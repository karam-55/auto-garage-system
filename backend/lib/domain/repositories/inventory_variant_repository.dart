import '../entities/inventory_variant.dart';

abstract class InventoryVariantRepository {
  Future<List<InventoryVariant>> findAll();
  Future<InventoryVariant?> findById(String id);
  Future<List<InventoryVariant>> findByIds(List<String> ids);
  Future<List<InventoryVariant>> findByItemId(String itemId);
  Future<InventoryVariant> create(InventoryVariant variant);
  Future<InventoryVariant> update(InventoryVariant variant);
  Future<void> delete(String id);
  Future<InventoryVariant?> findByItemAndType(String itemId, String variantType);
  Future<List<InventoryVariant>> findLowStock();
}
