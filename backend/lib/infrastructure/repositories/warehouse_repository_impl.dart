import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../database/database_connection.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final DatabaseConnection _db;

  WarehouseRepositoryImpl(this._db);

  @override
  Future<Warehouse> create(Warehouse warehouse) async {
    final result = await _db.pool.execute('''
      INSERT INTO warehouses (name, location, is_active)
      VALUES (\$1, \$2, \$3)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'name': warehouse.name,
      'location': warehouse.location,
      'is_active': warehouse.isActive,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return warehouse.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<Warehouse?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM warehouses WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToWarehouse(row);
  }

  @override
  Future<List<Warehouse>> findAll() async {
    final result = await _db.pool.execute('''
      SELECT * FROM warehouses ORDER BY name
    ''');

    return result.map((row) => _mapRowToWarehouse(row)).toList();
  }

  @override
  Future<Warehouse> update(Warehouse warehouse) async {
    await _db.pool.execute('''
      UPDATE warehouses
      SET name = \$1, location = \$2, is_active = \$3, updated_at = NOW()
      WHERE id = \$4
    ''', parameters: {
      'name': warehouse.name,
      'location': warehouse.location,
      'is_active': warehouse.isActive,
      'id': warehouse.id,
    });

    return warehouse.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM warehouses WHERE id = \$1
    ''', parameters: {'id': id});
  }

  Warehouse _mapRowToWarehouse(List<dynamic> row) {
    return Warehouse(
      id: row[0] as int,
      name: row[1] as String,
      location: row[2] as String?,
      isActive: row[3] as bool,
      createdAt: row[4] as DateTime,
      updatedAt: row[5] as DateTime,
    );
  }
}

class InventoryVariantWarehouseRepositoryImpl implements InventoryVariantWarehouseRepository {
  final DatabaseConnection _db;

  InventoryVariantWarehouseRepositoryImpl(this._db);

  @override
  Future<InventoryVariantWarehouse> create(InventoryVariantWarehouse inventory) async {
    final result = await _db.pool.execute('''
      INSERT INTO inventory_variant_warehouse (variant_id, warehouse_id, quantity, low_stock_threshold)
      VALUES (\$1, \$2, \$3, \$4)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'variant_id': inventory.variantId,
      'warehouse_id': inventory.warehouseId,
      'quantity': inventory.quantity,
      'low_stock_threshold': inventory.lowStockThreshold,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return inventory.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<InventoryVariantWarehouse?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM inventory_variant_warehouse WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToInventory(row);
  }

  @override
  Future<List<InventoryVariantWarehouse>> findByVariantId(String variantId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM inventory_variant_warehouse WHERE variant_id = \$1
    ''', parameters: {'variant_id': variantId});

    return result.map((row) => _mapRowToInventory(row)).toList();
  }

  @override
  Future<List<InventoryVariantWarehouse>> findByWarehouseId(int warehouseId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM inventory_variant_warehouse WHERE warehouse_id = \$1
    ''', parameters: {'warehouse_id': warehouseId});

    return result.map((row) => _mapRowToInventory(row)).toList();
  }

  @override
  Future<InventoryVariantWarehouse?> findByVariantAndWarehouse(String variantId, int warehouseId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM inventory_variant_warehouse 
      WHERE variant_id = \$1 AND warehouse_id = \$2
    ''', parameters: {
      'variant_id': variantId,
      'warehouse_id': warehouseId,
    });

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToInventory(row);
  }

  @override
  Future<InventoryVariantWarehouse> update(InventoryVariantWarehouse inventory) async {
    await _db.pool.execute('''
      UPDATE inventory_variant_warehouse
      SET quantity = \$1, low_stock_threshold = \$2, updated_at = NOW()
      WHERE id = \$3
    ''', parameters: {
      'quantity': inventory.quantity,
      'low_stock_threshold': inventory.lowStockThreshold,
      'id': inventory.id,
    });

    return inventory.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM inventory_variant_warehouse WHERE id = \$1
    ''', parameters: {'id': id});
  }

  InventoryVariantWarehouse _mapRowToInventory(List<dynamic> row) {
    return InventoryVariantWarehouse(
      id: row[0] as int,
      variantId: row[1] as String,
      warehouseId: row[2] as int,
      quantity: row[3] as int,
      lowStockThreshold: row[4] as int,
      createdAt: row[5] as DateTime,
      updatedAt: row[6] as DateTime,
    );
  }
}
