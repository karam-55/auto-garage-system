import '../entities/bill_of_materials.dart';

abstract class BillOfMaterialsRepository {
  Future<BillOfMaterials> create(BillOfMaterials bom);
  Future<BillOfMaterials?> findById(int id);
  Future<List<BillOfMaterials>> findAll();
  Future<List<BillOfMaterials>> findByServiceId(String serviceId);
  Future<BillOfMaterials> update(BillOfMaterials bom);
  Future<void> delete(int id);
}

abstract class ManufacturingOrderRepository {
  Future<ManufacturingOrder> create(ManufacturingOrder order);
  Future<ManufacturingOrder?> findById(int id);
  Future<List<ManufacturingOrder>> findAll();
  Future<List<ManufacturingOrder>> findByStatus(String status);
  Future<ManufacturingOrder> update(ManufacturingOrder order);
  Future<void> delete(int id);
}
