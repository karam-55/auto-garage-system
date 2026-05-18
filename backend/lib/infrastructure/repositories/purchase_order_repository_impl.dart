import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_order_repository.dart';
import '../database/database_connection.dart';

class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  final DatabaseConnection _db;

  PurchaseOrderRepositoryImpl(this._db);

  @override
  Future<PurchaseOrder> create(PurchaseOrder order) async {
    final result = await _db.pool.execute('''
      INSERT INTO purchase_orders (
        vendor_id, order_number, order_date, expected_date, 
        status, notes, created_by
      ) VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'vendor_id': order.vendorId,
      'order_number': order.orderNumber,
      'order_date': order.orderDate,
      'expected_date': order.expectedDate,
      'status': order.status,
      'notes': order.notes,
      'created_by': order.createdBy,
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
  Future<PurchaseOrder?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM purchase_orders WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToOrder(row);
  }

  @override
  Future<List<PurchaseOrder>> findAll() async {
    final result = await _db.pool.execute('''
      SELECT * FROM purchase_orders ORDER BY order_date DESC
    ''');

    return result.map((row) => _mapRowToOrder(row)).toList();
  }

  @override
  Future<List<PurchaseOrder>> findByVendorId(int vendorId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM purchase_orders WHERE vendor_id = \$1 ORDER BY order_date DESC
    ''', parameters: {'vendor_id': vendorId});

    return result.map((row) => _mapRowToOrder(row)).toList();
  }

  @override
  Future<PurchaseOrder> update(PurchaseOrder order) async {
    await _db.pool.execute('''
      UPDATE purchase_orders
      SET vendor_id = \$1, expected_date = \$2, status = \$3, 
          notes = \$4, updated_at = NOW()
      WHERE id = \$5
    ''', parameters: {
      'vendor_id': order.vendorId,
      'expected_date': order.expectedDate,
      'status': order.status,
      'notes': order.notes,
      'id': order.id,
    });

    return order.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM purchase_orders WHERE id = \$1
    ''', parameters: {'id': id});
  }

  PurchaseOrder _mapRowToOrder(List<dynamic> row) {
    return PurchaseOrder(
      id: row[0] as int,
      vendorId: row[1] as int,
      orderNumber: row[2] as String,
      orderDate: row[3] as DateTime,
      expectedDate: row[4] as DateTime?,
      status: row[5] as String,
      notes: row[6] as String?,
      createdBy: row[7] as String?,
      createdAt: row[8] as DateTime,
      updatedAt: row[9] as DateTime,
    );
  }
}
