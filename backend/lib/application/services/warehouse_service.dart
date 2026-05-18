import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../../application/usecases/warehouse_usecases.dart';

class WarehouseService {
  final WarehouseRepository _warehouseRepository;
  final InventoryVariantWarehouseRepository _inventoryRepository;
  late final CreateWarehouseUseCase _createWarehouseUseCase;
  late final GetWarehouseUseCase _getWarehouseUseCase;
  late final UpdateWarehouseUseCase _updateWarehouseUseCase;

  WarehouseService(this._warehouseRepository, this._inventoryRepository) {
    _createWarehouseUseCase = CreateWarehouseUseCase(_warehouseRepository);
    _getWarehouseUseCase = GetWarehouseUseCase(_warehouseRepository);
    _updateWarehouseUseCase = UpdateWarehouseUseCase(_warehouseRepository);
  }

  Future<Warehouse> createWarehouse(Warehouse warehouse) async {
    return await _createWarehouseUseCase.execute(warehouse);
  }

  Future<Warehouse?> getWarehouse(int id) async {
    return await _getWarehouseUseCase.execute(id);
  }

  Future<List<Warehouse>> getAllWarehouses() async {
    return await _getWarehouseUseCase.executeAll();
  }

  Future<Warehouse> updateWarehouse(Warehouse warehouse) async {
    return await _updateWarehouseUseCase.execute(warehouse);
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
