import '../entities/manufacturing_order.dart';

abstract class ManufacturingOrderRepository {
  Future<ManufacturingOrder> create(ManufacturingOrder order);
  Future<ManufacturingOrder?> findById(int id);
  Future<List<ManufacturingOrder>> findByBomId(int bomId);
  Future<List<ManufacturingOrder>> findByStatus(String status);
  Future<List<ManufacturingOrder>> findAll();
  Future<ManufacturingOrder> update(ManufacturingOrder order);
  Future<void> delete(int id);
}
