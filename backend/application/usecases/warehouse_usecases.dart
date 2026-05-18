import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/warehouse_repository.dart';

class CreateWarehouseUseCase {
  final WarehouseRepository _repository;

  CreateWarehouseUseCase(this._repository);

  Future<Warehouse> execute(Warehouse warehouse) async {
    return await _repository.create(warehouse);
  }
}

class GetWarehouseUseCase {
  final WarehouseRepository _repository;

  GetWarehouseUseCase(this._repository);

  Future<Warehouse?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<Warehouse>> executeAll() async {
    return await _repository.findAll();
  }
}

class UpdateWarehouseUseCase {
  final WarehouseRepository _repository;

  UpdateWarehouseUseCase(this._repository);

  Future<Warehouse> execute(Warehouse warehouse) async {
    return await _repository.update(warehouse);
  }
}

class DeleteWarehouseUseCase {
  final WarehouseRepository _repository;

  DeleteWarehouseUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}

class UpdateInventoryQuantityUseCase {
  final InventoryVariantWarehouseRepository _repository;

  UpdateInventoryQuantityUseCase(this._repository);

  Future<InventoryVariantWarehouse> execute(InventoryVariantWarehouse inventory) async {
    return await _repository.update(inventory);
  }

  Future<InventoryVariantWarehouse?> executeByVariantAndWarehouse(
    String variantId, int warehouseId
  ) async {
    return await _repository.findByVariantAndWarehouse(variantId, warehouseId);
  }
}
