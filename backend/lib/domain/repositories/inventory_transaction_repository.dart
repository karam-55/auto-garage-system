import '../entities/inventory_transaction.dart';

abstract class InventoryTransactionRepository {
  Future<List<InventoryTransaction>> findAll();
  Future<List<InventoryTransaction>> findByItemId(String itemId);
  Future<List<InventoryTransaction>> findByVariantId(String variantId);
  Future<List<InventoryTransaction>> findByBookingId(String bookingId);
  Future<List<InventoryTransaction>> findByMechanicId(String mechanicId);
  Future<InventoryTransaction> create(InventoryTransaction transaction);
}
