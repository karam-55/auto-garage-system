import 'package:postgres/postgres.dart';
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
  Future<PurchaseInvoiceItem?> findItemById(int id) async {
    final result = await _db.execute(
      Sql.named('SELECT * FROM purchase_invoice_items WHERE id = @id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return _mapRowToPurchaseInvoiceItem(result.first);
  }

  @override
  Future<List<PurchaseInvoice>> findAll({int limit = 100, int offset = 0}) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, vendor_id, invoice_number, issue_date, due_date, total_amount, paid_amount, status, created_at 
        FROM purchase_invoices ORDER BY issue_date DESC LIMIT @limit OFFSET @offset''',
        parameters: {'limit': limit, 'offset': offset},
      );
      return result.map(_mapRowToPurchaseInvoice).toList();
    });
  }

  @override
  Future<List<PurchaseInvoice>> findByVendorId(int vendorId, {int limit = 100, int offset = 0}) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, vendor_id, invoice_number, issue_date, due_date, total_amount, paid_amount, status, created_at 
        FROM purchase_invoices WHERE vendor_id = @vendorId ORDER BY issue_date DESC LIMIT @limit OFFSET @offset''',
        parameters: {'vendorId': vendorId, 'limit': limit, 'offset': offset},
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
  Future<dynamic> createItem(dynamic item) async {
    final result = await _db.execute(
      Sql.named('''
        INSERT INTO purchase_invoice_items (id, invoice_id, inventory_variant_id, quantity, unit_price, total_price)
        VALUES (@id, @invoiceId, @inventoryVariantId, @quantity, @unitPrice, @totalPrice)
        RETURNING *
      '''),
      parameters: {
        'id': item.id,
        'invoiceId': item.invoiceId,
        'inventoryVariantId': item.inventoryVariantId,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'totalPrice': item.totalPrice,
      },
    );
    return result.first;
  }

  @override
  Future<dynamic> findItemsByInvoiceId(int invoiceId) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        'SELECT id, invoice_id, inventory_variant_id, quantity, unit_price, total_price FROM purchase_invoice_items WHERE invoice_id = @invoiceId',
        parameters: {'invoiceId': invoiceId},
      );
      return result.toList();
    });
  }

  @override
  Future<dynamic> updateItem(dynamic item) async {
    final result = await _db.execute(
      Sql.named('''
        UPDATE purchase_invoice_items
        SET quantity = @quantity, unit_price = @unitPrice, total_price = @totalPrice
        WHERE id = @id
        RETURNING *
      '''),
      parameters: {
        'id': item.id,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'totalPrice': item.totalPrice,
      },
    );
    return result.first;
  }

  @override
  Future<void> deleteItem(int id) async {
    await _db.execute(
      Sql.named('DELETE FROM purchase_invoice_items WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  @override
  Future<PurchaseInvoice> createWithInventoryAndJournal(
    PurchaseInvoice invoice,
    List<dynamic> items,
    String createdBy,
  ) async {
    return await _db.runInTransaction((session) async {
      // Create purchase invoice
      final invoiceResult = await session.execute(
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
      final invoiceRow = invoiceResult.first;
      final createdInvoice = invoice.copyWith(
        id: invoiceRow[0] as int,
        createdAt: invoiceRow[1] as DateTime,
      );

      // Create items
      for (final item in items) {
        await session.execute(
          Sql.named('''
            INSERT INTO purchase_invoice_items (id, invoice_id, inventory_variant_id, quantity, unit_price, total_price)
            VALUES (@id, @invoiceId, @inventoryVariantId, @quantity, @unitPrice, @totalPrice)
          '''),
          parameters: {
            'id': item.id,
            'invoiceId': createdInvoice.id,
            'inventoryVariantId': item.inventoryVariantId,
            'quantity': item.quantity,
            'unitPrice': item.unitPrice,
            'totalPrice': item.totalPrice,
          },
        );

        // Update inventory
        await session.execute(
          Sql.named('''
            UPDATE inventory_variants
            SET quantity = quantity + @quantity,
                cost_price = @costPrice,
                updated_at = @updatedAt
            WHERE id = @id
          '''),
          parameters: {
            'id': item.inventoryVariantId,
            'quantity': item.quantity,
            'costPrice': item.unitPrice,
            'updatedAt': DateTime.now().toUtc(),
          },
        );
      }

      // Create journal entry
      final journalEntryResult = await session.execute(
        Sql.named('''
          INSERT INTO journal_entries (entry_date, reference, description, created_by, created_at)
          VALUES (@entryDate, @reference, @description, @createdBy, @createdAt)
          RETURNING id
        '''),
        parameters: {
          'entryDate': invoice.issueDate,
          'reference': 'PUR-${invoice.invoiceNumber}',
          'description': 'فاتورة شراء رقم ${invoice.invoiceNumber}',
          'createdBy': createdBy,
          'createdAt': DateTime.now().toUtc(),
        },
      );
      final journalEntryId = journalEntryResult.first[0] as int;

      // Create journal lines (simplified - would need account IDs from settings)
      // For now, just update invoice with journal entry ID
      await session.execute(
        Sql.named('''
          UPDATE purchase_invoices
          SET journal_entry_id = @journalEntryId
          WHERE id = @id
        '''),
        parameters: {
          'journalEntryId': journalEntryId,
          'id': createdInvoice.id,
        },
      );

      return createdInvoice.copyWith(journalEntryId: journalEntryId);
    });
  }

  @override
  Future<PurchaseInvoice> payWithJournal(
    int invoiceId,
    double paymentAmount,
    DateTime paymentDate,
    String paidBy,
  ) async {
    return await _db.runInTransaction((session) async {
      // Get invoice
      final invoiceResult = await session.execute(
        '''SELECT id, vendor_id, invoice_number, issue_date, due_date, total_amount, paid_amount, status
           FROM purchase_invoices WHERE id = @id''',
        parameters: {'id': invoiceId},
      );
      if (invoiceResult.isEmpty) {
        throw Exception('Invoice not found');
      }
      final invoiceRow = invoiceResult.first;
      final currentPaidAmount = invoiceRow[6] as double;
      final totalAmount = invoiceRow[5] as double;
      final invoiceNumber = invoiceRow[2] as String;

      // Update invoice
      final newPaidAmount = currentPaidAmount + paymentAmount;
      final newStatus = newPaidAmount >= totalAmount ? 'paid' : 'partial';
      await session.execute(
        Sql.named('''
          UPDATE purchase_invoices
          SET paid_amount = @paidAmount, status = @status
          WHERE id = @id
        '''),
        parameters: {
          'paidAmount': newPaidAmount,
          'status': newStatus,
          'id': invoiceId,
        },
      );

      // Create journal entry for payment
      final journalEntryResult = await session.execute(
        Sql.named('''
          INSERT INTO journal_entries (entry_date, reference, description, created_by, created_at)
          VALUES (@entryDate, @reference, @description, @createdBy, @createdAt)
          RETURNING id
        '''),
        parameters: {
          'entryDate': paymentDate,
          'reference': 'PAY-$invoiceNumber',
          'description': 'دفعة لفاتورة شراء رقم $invoiceNumber',
          'createdBy': paidBy,
          'createdAt': DateTime.now().toUtc(),
        },
      );
      final journalEntryId = journalEntryResult.first[0] as int;

      // Create journal lines (simplified - would need account IDs from settings)
      // For now, just return updated invoice
      return PurchaseInvoice(
        id: invoiceRow[0] as int,
        vendorId: invoiceRow[1] as int,
        invoiceNumber: invoiceNumber,
        issueDate: invoiceRow[3] as DateTime,
        dueDate: invoiceRow[4] as DateTime?,
        totalAmount: totalAmount,
        paidAmount: newPaidAmount,
        status: newStatus,
        journalEntryId: journalEntryId,
        createdAt: DateTime.now().toUtc(),
      );
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
