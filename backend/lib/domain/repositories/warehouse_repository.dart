import '../entities/warehouse.dart';

abstract class WarehouseRepository {
  Future<Warehouse> create(Warehouse warehouse);
  Future<Warehouse?> findById(int id);
  Future<List<Warehouse>> findAll();
  Future<Warehouse> update(Warehouse warehouse);
  Future<void> delete(int id);
}

abstract class InventoryVariantWarehouseRepository {
  Future<InventoryVariantWarehouse> create(InventoryVariantWarehouse inventory);
  Future<InventoryVariantWarehouse?> findById(int id);
  Future<List<InventoryVariantWarehouse>> findByVariantId(String variantId);
  Future<List<InventoryVariantWarehouse>> findByWarehouseId(int warehouseId);
  Future<InventoryVariantWarehouse?> findByVariantAndWarehouse(String variantId, int warehouseId);
  Future<InventoryVariantWarehouse> update(InventoryVariantWarehouse inventory);
  Future<void> delete(int id);
}
