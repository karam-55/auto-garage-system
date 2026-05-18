import '../../domain/entities/bill_of_materials.dart';
import '../../domain/repositories/bill_of_materials_repository.dart';
import '../database/database_connection.dart';

class BillOfMaterialsRepositoryImpl implements BillOfMaterialsRepository {
  final DatabaseConnection _db;

  BillOfMaterialsRepositoryImpl(this._db);

  @override
  Future<BillOfMaterials> create(BillOfMaterials bom) async {
    final result = await _db.pool.execute('''
      INSERT INTO bill_of_materials (service_id, output_variant_id, name, quantity_output, is_active)
      VALUES (\$1, \$2, \$3, \$4, \$5)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'service_id': bom.serviceId,
      'output_variant_id': bom.outputVariantId,
      'name': bom.name,
      'quantity_output': bom.quantityOutput,
      'is_active': bom.isActive,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return bom.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<BillOfMaterials?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM bill_of_materials WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToBom(row);
  }

  @override
  Future<List<BillOfMaterials>> findAll() async {
    final result = await _db.pool.execute('''
      SELECT * FROM bill_of_materials ORDER BY name
    ''');

    return result.map((row) => _mapRowToBom(row)).toList();
  }

  @override
  Future<List<BillOfMaterials>> findByServiceId(String serviceId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM bill_of_materials WHERE service_id = \$1
    ''', parameters: {'service_id': serviceId});

    return result.map((row) => _mapRowToBom(row)).toList();
  }

  @override
  Future<BillOfMaterials> update(BillOfMaterials bom) async {
    await _db.pool.execute('''
      UPDATE bill_of_materials
      SET service_id = \$1, output_variant_id = \$2, name = \$3, 
          quantity_output = \$4, is_active = \$5, updated_at = NOW()
      WHERE id = \$6
    ''', parameters: {
      'service_id': bom.serviceId,
      'output_variant_id': bom.outputVariantId,
      'name': bom.name,
      'quantity_output': bom.quantityOutput,
      'is_active': bom.isActive,
      'id': bom.id,
    });

    return bom.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM bill_of_materials WHERE id = \$1
    ''', parameters: {'id': id});
  }

  BillOfMaterials _mapRowToBom(List<dynamic> row) {
    return BillOfMaterials(
      id: row[0] as int,
      serviceId: row[1] as String?,
      outputVariantId: row[2] as String?,
      name: row[3] as String,
      quantityOutput: row[4] as int,
      isActive: row[5] as bool,
      createdAt: row[6] as DateTime,
      updatedAt: row[7] as DateTime,
    );
  }
}

class ManufacturingOrderRepositoryImpl implements ManufacturingOrderRepository {
  final DatabaseConnection _db;

  ManufacturingOrderRepositoryImpl(this._db);

  @override
  Future<ManufacturingOrder> create(ManufacturingOrder order) async {
    final result = await _db.pool.execute('''
      INSERT INTO manufacturing_orders (bom_id, quantity_to_produce, start_date, end_date, status, created_by, notes)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'bom_id': order.bomId,
      'quantity_to_produce': order.quantityToProduce,
      'start_date': order.startDate,
      'end_date': order.endDate,
      'status': order.status,
      'created_by': order.createdBy,
      'notes': order.notes,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return order.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<ManufacturingOrder?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM manufacturing_orders WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToOrder(row);
  }

  @override
  Future<List<ManufacturingOrder>> findAll() async {
    final result = await _db.pool.execute('''
      SELECT * FROM manufacturing_orders ORDER BY created_at DESC
    ''');

    return result.map((row) => _mapRowToOrder(row)).toList();
  }

  @override
  Future<List<ManufacturingOrder>> findByStatus(String status) async {
    final result = await _db.pool.execute('''
      SELECT * FROM manufacturing_orders WHERE status = \$1 ORDER BY created_at DESC
    ''', parameters: {'status': status});

    return result.map((row) => _mapRowToOrder(row)).toList();
  }

  @override
  Future<ManufacturingOrder> update(ManufacturingOrder order) async {
    await _db.pool.execute('''
      UPDATE manufacturing_orders
      SET bom_id = \$1, quantity_to_produce = \$2, produced_quantity = \$3,
          start_date = \$4, end_date = \$5, status = \$6, notes = \$7, updated_at = NOW()
      WHERE id = \$8
    ''', parameters: {
      'bom_id': order.bomId,
      'quantity_to_produce': order.quantityToProduce,
      'produced_quantity': order.producedQuantity,
      'start_date': order.startDate,
      'end_date': order.endDate,
      'status': order.status,
      'notes': order.notes,
      'id': order.id,
    });

    return order.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM manufacturing_orders WHERE id = \$1
    ''', parameters: {'id': id});
  }

  ManufacturingOrder _mapRowToOrder(List<dynamic> row) {
    return ManufacturingOrder(
      id: row[0] as int,
      bomId: row[1] as int,
      quantityToProduce: row[2] as int,
      producedQuantity: row[3] as int,
      startDate: row[4] as DateTime?,
      endDate: row[5] as DateTime?,
      status: row[6] as String,
      createdBy: row[7] as String?,
      notes: row[8] as String?,
      createdAt: row[9] as DateTime,
      updatedAt: row[10] as DateTime,
    );
  }
}
