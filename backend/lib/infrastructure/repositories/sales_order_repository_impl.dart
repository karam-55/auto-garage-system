import '../../domain/entities/sales_order.dart';
import '../../domain/repositories/sales_order_repository.dart';
import '../database/database_connection.dart';

class SalesOrderRepositoryImpl implements SalesOrderRepository {
  final DatabaseConnection _db;

  SalesOrderRepositoryImpl(this._db);

  @override
  Future<SalesOrder> create(SalesOrder order) async {
    final result = await _db.pool.execute('''
      INSERT INTO sales_orders (customer_id, vehicle_id, order_number, order_date, expected_date, status, total_amount, tax_amount, notes, created_by)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'customer_id': order.customerId,
      'vehicle_id': order.vehicleId,
      'order_number': order.orderNumber,
      'order_date': order.orderDate,
      'expected_date': order.expectedDate,
      'status': order.status,
      'total_amount': order.totalAmount,
      'tax_amount': order.taxAmount,
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
  Future<SalesOrder?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM sales_orders WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToOrder(row);
  }

  @override
  Future<List<SalesOrder>> findAll() async {
    final result = await _db.pool.execute('''
      SELECT * FROM sales_orders ORDER BY order_date DESC
    ''');

    return result.map((row) => _mapRowToOrder(row)).toList();
  }

  @override
  Future<List<SalesOrder>> findByCustomer(String customerId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM sales_orders WHERE customer_id = \$1 ORDER BY order_date DESC
    ''', parameters: {'customer_id': customerId});

    return result.map((row) => _mapRowToOrder(row)).toList();
  }

  @override
  Future<SalesOrder> update(SalesOrder order) async {
    await _db.pool.execute('''
      UPDATE sales_orders
      SET customer_id = \$1, vehicle_id = \$2, order_number = \$3, order_date = \$4,
          expected_date = \$5, status = \$6, total_amount = \$7, tax_amount = \$8,
          notes = \$9, updated_at = NOW()
      WHERE id = \$10
    ''', parameters: {
      'customer_id': order.customerId,
      'vehicle_id': order.vehicleId,
      'order_number': order.orderNumber,
      'order_date': order.orderDate,
      'expected_date': order.expectedDate,
      'status': order.status,
      'total_amount': order.totalAmount,
      'tax_amount': order.taxAmount,
      'notes': order.notes,
      'id': order.id,
    });

    return order.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM sales_orders WHERE id = \$1
    ''', parameters: {'id': id});
  }

  SalesOrder _mapRowToOrder(List<dynamic> row) {
    return SalesOrder(
      id: row[0] as int,
      customerId: row[1] as String,
      vehicleId: row[2] as String,
      orderNumber: row[3] as String,
      orderDate: row[4] as DateTime,
      expectedDate: row[5] as DateTime?,
      status: row[6] as String,
      totalAmount: row[7] as double,
      taxAmount: row[8] as double,
      notes: row[9] as String?,
      createdBy: row[10] as String?,
      createdAt: row[11] as DateTime,
      updatedAt: row[12] as DateTime,
    );
  }
}
