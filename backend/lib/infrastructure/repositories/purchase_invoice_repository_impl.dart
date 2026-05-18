import '../../domain/entities/purchase_invoice.dart';
import '../../domain/repositories/purchase_invoice_repository.dart';
import '../database/database_connection.dart';

class PurchaseInvoiceRepositoryImpl implements PurchaseInvoiceRepository {
  final DatabaseConnection _db;

  PurchaseInvoiceRepositoryImpl(this._db);

  @override
  Future<PurchaseInvoice> create(PurchaseInvoice invoice) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''INSERT INTO purchase_invoices (vendor_id, invoice_number, issue_date, due_date, total_amount, paid_amount, status)
           VALUES (@vendorId, @invoiceNumber, @issueDate, @dueDate, @totalAmount, @paidAmount, @status)
           RETURNING id, created_at''',
        parameters: {
          'vendorId': invoice.vendorId,
          'invoiceNumber': invoice.invoiceNumber,
          'issueDate': invoice.issueDate,
          'dueDate': invoice.dueDate,
          'totalAmount': invoice.totalAmount,
          'paidAmount': invoice.paidAmount,
          'status': invoice.status,
        },
      );
      final row = result.first;
      return invoice.copyWith(
        id: row[0] as int,
        createdAt: row[1] as DateTime,
      );
    });
  }

  @override
  Future<PurchaseInvoice?> findById(int id) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, vendor_id, invoice_number, issue_date, due_date, total_amount, paid_amount, status, created_at 
        FROM purchase_invoices WHERE id = @id''',
        parameters: {'id': id},
      );
      if (result.isEmpty) return null;
      return _mapRowToPurchaseInvoice(result.first);
    });
  }

  @override
  Future<List<PurchaseInvoice>> findAll() async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, vendor_id, invoice_number, issue_date, due_date, total_amount, paid_amount, status, created_at 
        FROM purchase_invoices ORDER BY issue_date DESC''',
      );
      return result.map(_mapRowToPurchaseInvoice).toList();
    });
  }

  @override
  Future<List<PurchaseInvoice>> findByVendorId(int vendorId) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, vendor_id, invoice_number, issue_date, due_date, total_amount, paid_amount, status, created_at 
        FROM purchase_invoices WHERE vendor_id = @vendorId ORDER BY issue_date DESC''',
        parameters: {'vendorId': vendorId},
      );
      return result.map(_mapRowToPurchaseInvoice).toList();
    });
  }

  @override
  Future<List<PurchaseInvoice>> findByStatus(String status) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, vendor_id, invoice_number, issue_date, due_date, total_amount, paid_amount, status, created_at 
        FROM purchase_invoices WHERE status = @status ORDER BY issue_date DESC''',
        parameters: {'status': status},
      );
      return result.map(_mapRowToPurchaseInvoice).toList();
    });
  }

  @override
  Future<PurchaseInvoice> update(PurchaseInvoice invoice) async {
    return await _db.runInTransaction((session) async {
      await session.execute(
        '''UPDATE purchase_invoices SET
           vendor_id = @vendorId,
           invoice_number = @invoiceNumber,
           issue_date = @issueDate,
           due_date = @dueDate,
           total_amount = @totalAmount,
           paid_amount = @paidAmount,
           status = @status
           WHERE id = @id''',
        parameters: {
          'id': invoice.id,
          'vendorId': invoice.vendorId,
          'invoiceNumber': invoice.invoiceNumber,
          'issueDate': invoice.issueDate,
          'dueDate': invoice.dueDate,
          'totalAmount': invoice.totalAmount,
          'paidAmount': invoice.paidAmount,
          'status': invoice.status,
        },
      );
      return invoice;
    });
  }

  @override
  Future<void> delete(int id) async {
    return await _db.runInTransaction((session) async {
      await session.execute('DELETE FROM purchase_invoices WHERE id = @id', parameters: {'id': id});
    });
  }

  @override
  Future<PurchaseInvoiceItem> createItem(PurchaseInvoiceItem item) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''INSERT INTO purchase_invoice_items (invoice_id, inventory_variant_id, quantity, unit_price, total_price)
           VALUES (@invoiceId, @inventoryVariantId, @quantity, @unitPrice, @totalPrice)
           RETURNING id''',
        parameters: {
          'invoiceId': item.invoiceId,
          'inventoryVariantId': item.inventoryVariantId,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'totalPrice': item.totalPrice,
        },
      );
      final row = result.first;
      return item.copyWith(id: row[0] as int);
    });
  }

  @override
  Future<List<PurchaseInvoiceItem>> findItemsByInvoiceId(int invoiceId) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        'SELECT id, invoice_id, inventory_variant_id, quantity, unit_price, total_price FROM purchase_invoice_items WHERE invoice_id = @invoiceId',
        parameters: {'invoiceId': invoiceId},
      );
      return result.map(_mapRowToPurchaseInvoiceItem).toList();
    });
  }

  @override
  Future<PurchaseInvoiceItem> updateItem(PurchaseInvoiceItem item) async {
    return await _db.runInTransaction((session) async {
      await session.execute(
        '''UPDATE purchase_invoice_items SET
           invoice_id = @invoiceId,
           inventory_variant_id = @inventoryVariantId,
           quantity = @quantity,
           unit_price = @unitPrice,
           total_price = @totalPrice
           WHERE id = @id''',
        parameters: {
          'id': item.id,
          'invoiceId': item.invoiceId,
          'inventoryVariantId': item.inventoryVariantId,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'totalPrice': item.totalPrice,
        },
      );
      return item;
    });
  }

  @override
  Future<void> deleteItem(int id) async {
    return await _db.runInTransaction((session) async {
      await session.execute('DELETE FROM purchase_invoice_items WHERE id = @id', parameters: {'id': id});
    });
  }

  PurchaseInvoice _mapRowToPurchaseInvoice(List<dynamic> row) {
    return PurchaseInvoice(
      id: row[0] as int,
      vendorId: row[1] as int,
      invoiceNumber: row[2] as String,
      issueDate: row[3] as DateTime,
      dueDate: row[4] as DateTime?,
      totalAmount: (row[5] as num).toDouble(),
      paidAmount: (row[6] as num).toDouble(),
      status: row[7] as String,
      createdAt: row[8] as DateTime,
    );
  }

  PurchaseInvoiceItem _mapRowToPurchaseInvoiceItem(List<dynamic> row) {
    return PurchaseInvoiceItem(
      id: row[0] as int,
      invoiceId: row[1] as int,
      inventoryVariantId: row[2] as String,
      quantity: row[3] as int,
      unitPrice: (row[4] as num).toDouble(),
      totalPrice: (row[5] as num).toDouble(),
    );
  }
}
