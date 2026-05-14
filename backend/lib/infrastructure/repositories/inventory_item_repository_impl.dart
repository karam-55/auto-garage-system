import 'package:postgres/postgres.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_item_repository.dart';
import '../database/database_connection.dart';

class InventoryItemRepositoryImpl implements InventoryItemRepository {
  final DatabaseConnection _db;

  InventoryItemRepositoryImpl(this._db);

  @override
  Future<List<InventoryItem>> findAll() async {
    final result = await _db.execute('''
      SELECT * FROM inventory_items
      ORDER BY created_at DESC
    ''');

    return result.map((row) {
      final data = row.toColumnMap();
      return InventoryItem(
        id: data['id'] as String,
        name: data['name'] as String,
        category: data['category'] as String?,
        unit: data['unit'] as String?,
        lowStockThreshold: data['low_stock_threshold'] as int? ?? 5,
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : null,
      );
    }).toList();
  }

  @override
  Future<InventoryItem?> findById(String id) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM inventory_items WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;

    final data = result.first.toColumnMap();
    return InventoryItem(
      id: data['id'] as String,
      name: data['name'] as String,
      category: data['category'] as String?,
      unit: data['unit'] as String?,
      lowStockThreshold: data['low_stock_threshold'] as int? ?? 5,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : null,
    );
  }

  @override
  Future<InventoryItem> create(InventoryItem item) async {
    final result = await _db.execute(
      Sql.named('''
        INSERT INTO inventory_items (id, name, category, unit, low_stock_threshold, created_at, updated_at)
        VALUES (@id, @name, @category, @unit, @lowStockThreshold, @createdAt, @updatedAt)
        RETURNING *
      '''),
      parameters: {
        'id': item.id,
        'name': item.name,
        'category': item.category,
        'unit': item.unit,
        'lowStockThreshold': item.lowStockThreshold,
        'createdAt': item.createdAt,
        'updatedAt': item.updatedAt,
      },
    );

    final data = result.first.toColumnMap();
    return InventoryItem(
      id: data['id'] as String,
      name: data['name'] as String,
      category: data['category'] as String?,
      unit: data['unit'] as String?,
      lowStockThreshold: data['low_stock_threshold'] as int? ?? 5,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : null,
    );
  }

  @override
  Future<InventoryItem> update(InventoryItem item) async {
    final result = await _db.execute(
      Sql.named('''
        UPDATE inventory_items
        SET name = @name,
            category = @category,
            unit = @unit,
            low_stock_threshold = @lowStockThreshold,
            updated_at = @updatedAt
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': item.id,
        'name': item.name,
        'category': item.category,
        'unit': item.unit,
        'lowStockThreshold': item.lowStockThreshold,
        'updatedAt': DateTime.now().toUtc(),
      },
    );

    final data = result.first.toColumnMap();
    return InventoryItem(
      id: data['id'] as String,
      name: data['name'] as String,
      category: data['category'] as String?,
      unit: data['unit'] as String?,
      lowStockThreshold: data['low_stock_threshold'] as int? ?? 5,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : null,
    );
  }

  @override
  Future<void> delete(String id) async {
    await _db.execute(
      Sql.named('DELETE FROM inventory_items WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<List<InventoryItem>> findByCategory(String category) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM inventory_items WHERE category = @category ORDER BY created_at DESC'),
      parameters: {'category': category},
    );

    return result.map((row) {
      final data = row.toColumnMap();
      return InventoryItem(
        id: data['id'] as String,
        name: data['name'] as String,
        category: data['category'] as String?,
        unit: data['unit'] as String?,
        lowStockThreshold: data['low_stock_threshold'] as int? ?? 5,
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : null,
      );
    }).toList();
  }

  @override
  Future<List<InventoryItem>> findLowStock() async {
    final result = await _db.execute('''
      SELECT DISTINCT i.*
      FROM inventory_items i
      INNER JOIN inventory_variants v ON i.id = v.item_id
      WHERE v.quantity <= i.low_stock_threshold
      ORDER BY i.created_at DESC
    ''');

    return result.map((row) {
      final data = row.toColumnMap();
      return InventoryItem(
        id: data['id'] as String,
        name: data['name'] as String,
        category: data['category'] as String?,
        unit: data['unit'] as String?,
        lowStockThreshold: data['low_stock_threshold'] as int? ?? 5,
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : null,
      );
    }).toList();
  }
}
