import '../../domain/entities/inventory_transfer.dart';
import '../../domain/repositories/inventory_transfer_repository.dart';
import '../database/database_connection.dart';

class InventoryTransferRepositoryImpl implements InventoryTransferRepository {
  final DatabaseConnection _db;

  InventoryTransferRepositoryImpl(this._db);

  @override
  Future<InventoryTransfer> create(InventoryTransfer transfer) async {
    final result = await _db.pool.execute('''
      INSERT INTO inventory_transfers (from_warehouse_id, to_warehouse_id, inventory_variant_id, quantity, status, notes, created_by)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'from_warehouse_id': transfer.fromWarehouseId,
      'to_warehouse_id': transfer.toWarehouseId,
      'inventory_variant_id': transfer.inventoryVariantId,
      'quantity': transfer.quantity,
      'status': transfer.status,
      'notes': transfer.notes,
      'created_by': transfer.createdBy,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return transfer.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<InventoryTransfer?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM inventory_transfers WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToTransfer(row);
  }

  @override
  Future<List<InventoryTransfer>> findAll() async {
    final result = await _db.pool.execute('''
      SELECT * FROM inventory_transfers ORDER BY created_at DESC
    ''');

    return result.map((row) => _mapRowToTransfer(row)).toList();
  }

  @override
  Future<InventoryTransfer> update(InventoryTransfer transfer) async {
    await _db.pool.execute('''
      UPDATE inventory_transfers
      SET from_warehouse_id = \$1, to_warehouse_id = \$2, inventory_variant_id = \$3,
          quantity = \$4, status = \$5, notes = \$6, updated_at = NOW()
      WHERE id = \$7
    ''', parameters: {
      'from_warehouse_id': transfer.fromWarehouseId,
      'to_warehouse_id': transfer.toWarehouseId,
      'inventory_variant_id': transfer.inventoryVariantId,
      'quantity': transfer.quantity,
      'status': transfer.status,
      'notes': transfer.notes,
      'id': transfer.id,
    });

    return transfer.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM inventory_transfers WHERE id = \$1
    ''', parameters: {'id': id});
  }

  InventoryTransfer _mapRowToTransfer(List<dynamic> row) {
    return InventoryTransfer(
      id: row[0] as int,
      fromWarehouseId: row[1] as String?,
      toWarehouseId: row[2] as String?,
      inventoryVariantId: row[3] as String,
      quantity: row[4] as int,
      status: row[5] as String,
      notes: row[6] as String?,
      createdBy: row[7] as String?,
      createdAt: row[8] as DateTime,
      updatedAt: row[9] as DateTime,
    );
  }
}
