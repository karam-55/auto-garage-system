import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/warehouse_repository.dart';

class WarehouseService {
  final WarehouseRepository _warehouseRepository;

  WarehouseService(this._warehouseRepository, dynamic inventoryRepository);

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
}
