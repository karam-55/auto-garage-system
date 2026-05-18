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
