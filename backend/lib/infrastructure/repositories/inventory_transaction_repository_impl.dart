import 'package:postgres/postgres.dart';
import '../../domain/entities/inventory_transaction.dart';
import '../../domain/repositories/inventory_transaction_repository.dart';
import '../database/database_connection.dart';

class InventoryTransactionRepositoryImpl implements InventoryTransactionRepository {
  final DatabaseConnection _db;

  InventoryTransactionRepositoryImpl(this._db);

  @override
  Future<List<InventoryTransaction>> findAll() async {
    final result = await _db.execute('''
      SELECT * FROM inventory_transactions
      ORDER BY created_at DESC
    ''');

    return result.map((row) {
      final data = row.toColumnMap();
      return InventoryTransaction(
        id: data['id'] as String,
        itemId: data['item_id'] as String,
        variantId: data['variant_id'] as String,
        bookingId: data['booking_id'] as String?,
        mechanicId: data['mechanic_id'] as String?,
        type: TransactionType.fromString(data['type'] as String),
        quantity: data['quantity'] as int,
        notes: data['notes'] as String?,
        createdAt: DateTime.parse(data['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<List<InventoryTransaction>> findByItemId(String itemId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM inventory_transactions WHERE item_id = @itemId ORDER BY created_at DESC'),
      parameters: {'itemId': itemId},
    );

    return result.map((row) {
      final data = row.toColumnMap();
      return InventoryTransaction(
        id: data['id'] as String,
        itemId: data['item_id'] as String,
        variantId: data['variant_id'] as String,
        bookingId: data['booking_id'] as String?,
        mechanicId: data['mechanic_id'] as String?,
        type: TransactionType.fromString(data['type'] as String),
        quantity: data['quantity'] as int,
        notes: data['notes'] as String?,
        createdAt: DateTime.parse(data['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<List<InventoryTransaction>> findByVariantId(String variantId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM inventory_transactions WHERE variant_id = @variantId ORDER BY created_at DESC'),
      parameters: {'variantId': variantId},
    );

    return result.map((row) {
      final data = row.toColumnMap();
      return InventoryTransaction(
        id: data['id'] as String,
        itemId: data['item_id'] as String,
        variantId: data['variant_id'] as String,
        bookingId: data['booking_id'] as String?,
        mechanicId: data['mechanic_id'] as String?,
        type: TransactionType.fromString(data['type'] as String),
        quantity: data['quantity'] as int,
        notes: data['notes'] as String?,
        createdAt: DateTime.parse(data['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<List<InventoryTransaction>> findByBookingId(String bookingId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM inventory_transactions WHERE booking_id = @bookingId ORDER BY created_at DESC'),
      parameters: {'bookingId': bookingId},
    );

    return result.map((row) {
      final data = row.toColumnMap();
      return InventoryTransaction(
        id: data['id'] as String,
        itemId: data['item_id'] as String,
        variantId: data['variant_id'] as String,
        bookingId: data['booking_id'] as String?,
        mechanicId: data['mechanic_id'] as String?,
        type: TransactionType.fromString(data['type'] as String),
        quantity: data['quantity'] as int,
        notes: data['notes'] as String?,
        createdAt: DateTime.parse(data['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<List<InventoryTransaction>> findByMechanicId(String mechanicId) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM inventory_transactions WHERE mechanic_id = @mechanicId ORDER BY created_at DESC'),
      parameters: {'mechanicId': mechanicId},
    );

    return result.map((row) {
      final data = row.toColumnMap();
      return InventoryTransaction(
        id: data['id'] as String,
        itemId: data['item_id'] as String,
        variantId: data['variant_id'] as String,
        bookingId: data['booking_id'] as String?,
        mechanicId: data['mechanic_id'] as String?,
        type: TransactionType.fromString(data['type'] as String),
        quantity: data['quantity'] as int,
        notes: data['notes'] as String?,
        createdAt: DateTime.parse(data['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<InventoryTransaction> create(InventoryTransaction transaction) async {
    final result = await _db.execute(
      Sql.named('''
        INSERT INTO inventory_transactions (id, item_id, variant_id, booking_id, mechanic_id, type, quantity, notes, created_at)
        VALUES (@id, @itemId, @variantId, @bookingId, @mechanicId, @type, @quantity, @notes, @createdAt)
        RETURNING *
      '''),
      parameters: {
        'id': transaction.id,
        'itemId': transaction.itemId,
        'variantId': transaction.variantId,
        'bookingId': transaction.bookingId,
        'mechanicId': transaction.mechanicId,
        'type': transaction.type.toStringValue(),
        'quantity': transaction.quantity,
        'notes': transaction.notes,
        'createdAt': transaction.createdAt,
      },
    );

    final data = result.first.toColumnMap();
    return InventoryTransaction(
      id: data['id'] as String,
      itemId: data['item_id'] as String,
      variantId: data['variant_id'] as String,
      bookingId: data['booking_id'] as String?,
      mechanicId: data['mechanic_id'] as String?,
      type: TransactionType.fromString(data['type'] as String),
      quantity: data['quantity'] as int,
      notes: data['notes'] as String?,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}
