import 'package:postgres/postgres.dart';
import '../../domain/entities/inventory_variant.dart';
import '../../domain/repositories/inventory_variant_repository.dart';
import '../database/database_connection.dart';

class InventoryVariantRepositoryImpl implements InventoryVariantRepository {
  final DatabaseConnection _db;

  InventoryVariantRepositoryImpl(this._db);

  @override
  Future<List<InventoryVariant>> findAll() async {
    final result = await _db.execute('''
      SELECT * FROM inventory_variants
      ORDER BY created_at DESC
    ''');

    return result.map((row) {
      final data = row.toColumnMap();
      return InventoryVariant(
        id: data['id'] as String,
        itemId: data['item_id'] as String,
        variantType: VariantType.fromString(data['variant_type'] as String),
        quantity: data['quantity'] as int? ?? 0,
        costPrice: (data['cost_price'] is num ? data['cost_price'] as num : double.tryParse(data['cost_price'] as String? ?? '0'))?.toDouble() ?? 0,
        sellingPrice: (data['selling_price'] is num ? data['selling_price'] as num : double.tryParse(data['selling_price'] as String? ?? '0'))?.toDouble() ?? 0,
        supplier: data['supplier'] as String?,
        createdAt: data['created_at'] is DateTime ? data['created_at'] as DateTime : DateTime.parse(data['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<InventoryVariant?> findById(String id) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM inventory_variants WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;

    final data = result.first.toColumnMap();
    return InventoryVariant(
      id: data['id'] as String,
      itemId: data['item_id'] as String,
      variantType: VariantType.fromString(data['variant_type'] as String),
      quantity: data['quantity'] as int? ?? 0,
      costPrice: (data['cost_price'] is num ? data['cost_price'] as num : double.tryParse(data['cost_price'] as String? ?? '0'))?.toDouble() ?? 0,
      sellingPrice: (data['selling_price'] is num ? data['selling_price'] as num : double.tryParse(data['selling_price'] as String? ?? '0'))?.toDouble() ?? 0,
      supplier: data['supplier'] as String?,
      createdAt: data['created_at'] is DateTime ? data['created_at'] as DateTime : DateTime.parse(data['created_at'] as String),
    );
  }

  @override
  Future<List<InventoryVariant>> findByItemId(String itemId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM inventory_variants WHERE item_id = @itemId ORDER BY created_at DESC'),
      parameters: {'itemId': itemId},
    );

    return result.map((row) {
      final data = row.toColumnMap();
      return InventoryVariant(
        id: data['id'] as String,
        itemId: data['item_id'] as String,
        variantType: VariantType.fromString(data['variant_type'] as String),
        quantity: data['quantity'] as int? ?? 0,
        costPrice: (data['cost_price'] is num ? data['cost_price'] as num : double.tryParse(data['cost_price'] as String? ?? '0'))?.toDouble() ?? 0,
        sellingPrice: (data['selling_price'] is num ? data['selling_price'] as num : double.tryParse(data['selling_price'] as String? ?? '0'))?.toDouble() ?? 0,
        supplier: data['supplier'] as String?,
        createdAt: data['created_at'] is DateTime ? data['created_at'] as DateTime : DateTime.parse(data['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<InventoryVariant> create(InventoryVariant variant) async {
    final result = await _db.execute(
      Sql.named('''
        INSERT INTO inventory_variants (id, item_id, variant_type, quantity, cost_price, selling_price, supplier, created_at)
        VALUES (@id, @itemId, @variantType, @quantity, @costPrice, @sellingPrice, @supplier, @createdAt)
        RETURNING *
      '''),
      parameters: {
        'id': variant.id,
        'itemId': variant.itemId,
        'variantType': variant.variantType.toStringValue(),
        'quantity': variant.quantity,
        'costPrice': variant.costPrice,
        'sellingPrice': variant.sellingPrice,
        'supplier': variant.supplier,
        'createdAt': variant.createdAt,
      },
    );

    final data = result.first.toColumnMap();
    return InventoryVariant(
      id: data['id'] as String,
      itemId: data['item_id'] as String,
      variantType: VariantType.fromString(data['variant_type'] as String),
      quantity: data['quantity'] as int? ?? 0,
      costPrice: (data['cost_price'] is num ? data['cost_price'] as num : double.tryParse(data['cost_price'] as String? ?? '0'))?.toDouble() ?? 0,
      sellingPrice: (data['selling_price'] is num ? data['selling_price'] as num : double.tryParse(data['selling_price'] as String? ?? '0'))?.toDouble() ?? 0,
      supplier: data['supplier'] as String?,
      createdAt: data['created_at'] is DateTime ? data['created_at'] as DateTime : DateTime.parse(data['created_at'] as String),
    );
  }

  @override
  Future<InventoryVariant> update(InventoryVariant variant) async {
    final result = await _db.execute(
      Sql.named('''
        UPDATE inventory_variants
        SET quantity = @quantity,
            cost_price = @costPrice,
            selling_price = @sellingPrice,
            supplier = @supplier
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': variant.id,
        'quantity': variant.quantity,
        'costPrice': variant.costPrice,
        'sellingPrice': variant.sellingPrice,
        'supplier': variant.supplier,
      },
    );

    final data = result.first.toColumnMap();
    return InventoryVariant(
      id: data['id'] as String,
      itemId: data['item_id'] as String,
      variantType: VariantType.fromString(data['variant_type'] as String),
      quantity: data['quantity'] as int? ?? 0,
      costPrice: (data['cost_price'] is num ? data['cost_price'] as num : double.tryParse(data['cost_price'] as String? ?? '0'))?.toDouble() ?? 0,
      sellingPrice: (data['selling_price'] is num ? data['selling_price'] as num : double.tryParse(data['selling_price'] as String? ?? '0'))?.toDouble() ?? 0,
      supplier: data['supplier'] as String?,
      createdAt: data['created_at'] is DateTime ? data['created_at'] as DateTime : DateTime.parse(data['created_at'] as String),
    );
  }

  @override
  Future<void> delete(String id) async {
    await _db.execute(
      Sql.named('DELETE FROM inventory_variants WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<InventoryVariant?> findByItemAndType(String itemId, String variantType) async {
    final result = await _db.execute(
      Sql.named('''
        SELECT * FROM inventory_variants
        WHERE item_id = @itemId AND variant_type = @variantType
      '''),
      parameters: {
        'itemId': itemId,
        'variantType': variantType,
      },
    );

    if (result.isEmpty) return null;

    final data = result.first.toColumnMap();
    return InventoryVariant(
      id: data['id'] as String,
      itemId: data['item_id'] as String,
      variantType: VariantType.fromString(data['variant_type'] as String),
      quantity: data['quantity'] as int? ?? 0,
      costPrice: (data['cost_price'] is num ? data['cost_price'] as num : double.tryParse(data['cost_price'] as String? ?? '0'))?.toDouble() ?? 0,
      sellingPrice: (data['selling_price'] is num ? data['selling_price'] as num : double.tryParse(data['selling_price'] as String? ?? '0'))?.toDouble() ?? 0,
      supplier: data['supplier'] as String?,
      createdAt: data['created_at'] is DateTime ? data['created_at'] as DateTime : DateTime.parse(data['created_at'] as String),
    );
  }

  @override
  Future<List<InventoryVariant>> findLowStock() async {
    final result = await _db.execute('''
      SELECT v.*, i.low_stock_threshold
      FROM inventory_variants v
      INNER JOIN inventory_items i ON v.item_id = i.id
      WHERE v.quantity <= i.low_stock_threshold
      ORDER BY v.created_at DESC
    ''');

    return result.map((row) {
      final data = row.toColumnMap();
      return InventoryVariant(
        id: data['id'] as String,
        itemId: data['item_id'] as String,
        variantType: VariantType.fromString(data['variant_type'] as String),
        quantity: data['quantity'] as int? ?? 0,
        costPrice: (data['cost_price'] is num ? data['cost_price'] as num : double.tryParse(data['cost_price'] as String? ?? '0'))?.toDouble() ?? 0,
        sellingPrice: (data['selling_price'] is num ? data['selling_price'] as num : double.tryParse(data['selling_price'] as String? ?? '0'))?.toDouble() ?? 0,
        supplier: data['supplier'] as String?,
        createdAt: data['created_at'] is DateTime ? data['created_at'] as DateTime : DateTime.parse(data['created_at'] as String),
      );
    }).toList();
  }
}
