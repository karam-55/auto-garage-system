import '../entities/inventory_transfer.dart';

abstract class InventoryTransferRepository {
  Future<InventoryTransfer> create(InventoryTransfer transfer);
  Future<InventoryTransfer?> findById(int id);
  Future<List<InventoryTransfer>> findAll();
  Future<InventoryTransfer> update(InventoryTransfer transfer);
  Future<void> delete(int id);
}
