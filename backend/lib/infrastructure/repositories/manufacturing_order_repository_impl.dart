import '../../domain/entities/manufacturing_order.dart';
import '../../domain/repositories/manufacturing_order_repository.dart';
import '../database/database_connection.dart';

class ManufacturingOrderRepositoryImpl implements ManufacturingOrderRepository {
  final DatabaseConnection _db;

  ManufacturingOrderRepositoryImpl(this._db);

  @override
  Future<ManufacturingOrder> create(ManufacturingOrder order) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''INSERT INTO manufacturing_orders (order_number, bom_id, status, quantity, start_date, expected_completion_date, notes, created_at)
           VALUES (@orderNumber, @bomId, @status, @quantity, @startDate, @expectedCompletionDate, @notes, @createdAt)
           RETURNING id, created_at''',
        parameters: {
          'orderNumber': order.orderNumber,
          'bomId': order.bomId,
          'status': order.status,
          'quantity': order.quantity,
          'startDate': order.startDate,
          'expectedCompletionDate': order.expectedCompletionDate,
          'notes': order.notes,
          'createdAt': order.createdAt,
        },
      );
      final row = result.first;
      return order.copyWith(
        id: row[0] as int,
        createdAt: row[1] as DateTime,
      );
    });
  }

  @override
  Future<ManufacturingOrder?> findById(int id) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, order_number, bom_id, status, quantity, start_date, expected_completion_date, actual_completion_date, notes, created_at, updated_at
           FROM manufacturing_orders WHERE id = @id''',
        parameters: {'id': id},
      );
      if (result.isEmpty) return null;
      return _mapRowToOrder(result.first);
    });
  }

  @override
  Future<List<ManufacturingOrder>> findByBomId(int bomId) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, order_number, bom_id, status, quantity, start_date, expected_completion_date, actual_completion_date, notes, created_at, updated_at
           FROM manufacturing_orders WHERE bom_id = @bomId ORDER BY created_at DESC''',
        parameters: {'bomId': bomId},
      );
      return result.map(_mapRowToOrder).toList();
    });
  }

  @override
  Future<List<ManufacturingOrder>> findByStatus(String status) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, order_number, bom_id, status, quantity, start_date, expected_completion_date, actual_completion_date, notes, created_at, updated_at
           FROM manufacturing_orders WHERE status = @status ORDER BY created_at DESC''',
        parameters: {'status': status},
      );
      return result.map(_mapRowToOrder).toList();
    });
  }

  @override
  Future<List<ManufacturingOrder>> findAll() async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, order_number, bom_id, status, quantity, start_date, expected_completion_date, actual_completion_date, notes, created_at, updated_at
           FROM manufacturing_orders ORDER BY created_at DESC''',
      );
      return result.map(_mapRowToOrder).toList();
    });
  }

  @override
  Future<ManufacturingOrder> update(ManufacturingOrder order) async {
    return await _db.runInTransaction((session) async {
      await session.execute(
        '''UPDATE manufacturing_orders SET
           order_number = @orderNumber,
           bom_id = @bomId,
           status = @status,
           quantity = @quantity,
           start_date = @startDate,
           expected_completion_date = @expectedCompletionDate,
           actual_completion_date = @actualCompletionDate,
           notes = @notes,
           updated_at = NOW()
           WHERE id = @id''',
        parameters: {
          'id': order.id,
          'orderNumber': order.orderNumber,
          'bomId': order.bomId,
          'status': order.status,
          'quantity': order.quantity,
          'startDate': order.startDate,
          'expectedCompletionDate': order.expectedCompletionDate,
          'actualCompletionDate': order.actualCompletionDate,
          'notes': order.notes,
        },
      );
      return order.copyWith(updatedAt: DateTime.now());
    });
  }

  @override
  Future<void> delete(int id) async {
    return await _db.runInTransaction((session) async {
      await session.execute('DELETE FROM manufacturing_orders WHERE id = @id', parameters: {'id': id});
    });
  }

  ManufacturingOrder _mapRowToOrder(List<dynamic> row) {
    return ManufacturingOrder(
      id: row[0] as int,
      orderNumber: row[1] as String,
      bomId: row[2] as int,
      status: row[3] as String,
      quantity: row[4] as int,
      startDate: row[5] as DateTime?,
      expectedCompletionDate: row[6] as DateTime?,
      actualCompletionDate: row[7] as DateTime?,
      notes: row[8] as String?,
      createdAt: row[9] as DateTime,
      updatedAt: row[10] as DateTime?,
    );
  }
}
