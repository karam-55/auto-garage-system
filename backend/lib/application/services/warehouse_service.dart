import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../../domain/repositories/inventory_variant_warehouse_repository.dart';

class WarehouseService {
  final WarehouseRepository _warehouseRepository;
  final InventoryVariantWarehouseRepository _inventoryRepository;

  WarehouseService(this._warehouseRepository, this._inventoryRepository);

  Future<Warehouse> createWarehouse(Warehouse warehouse) async {
    return await _warehouseRepository.create(warehouse);
  }

  Future<Warehouse?> getWarehouse(int id) async {
    return await _warehouseRepository.findById(id);
  }

  Future<List<Warehouse>> getAllWarehouses() async {
    return await _warehouseRepository.findAll();
  }

  Future<Warehouse> updateWarehouse(Warehouse warehouse) async {
    return await _warehouseRepository.update(warehouse);
  }

  Future<void> deleteWarehouse(int id) async {
    await _warehouseRepository.delete(id);
  }

  Future<InventoryVariantWarehouse?> getInventoryByVariantAndWarehouse(
    String variantId, int warehouseId
  ) async {
    return await _inventoryRepository.findByVariantAndWarehouse(variantId, warehouseId);
  }

  Future<InventoryVariantWarehouse> updateInventoryQuantity(
    InventoryVariantWarehouse inventory
  ) async {
    return await _inventoryRepository.update(inventory);
  }

  Future<int> getTotalQuantityForVariant(String variantId) async {
    final inventories = await _inventoryRepository.findByVariantId(variantId);
    int total = 0;
    for (final inv in inventories) {
      total += inv.quantity;
    }
    return total;
  }
}
