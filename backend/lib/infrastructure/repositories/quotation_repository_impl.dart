import '../../domain/entities/quotation.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../database/database_connection.dart';

class QuotationRepositoryImpl implements QuotationRepository {
  final DatabaseConnection _db;

  QuotationRepositoryImpl(this._db);

  @override
  Future<Quotation> create(Quotation quotation) async {
    final result = await _db.pool.execute('''
      INSERT INTO quotations (
        customer_id, quotation_number, date, valid_until, 
        status, total_amount, notes, created_by
      ) VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'customer_id': quotation.customerId,
      'quotation_number': quotation.quotationNumber,
      'date': quotation.date,
      'valid_until': quotation.validUntil,
      'status': quotation.status,
      'total_amount': quotation.totalAmount,
      'notes': quotation.notes,
      'created_by': quotation.createdBy,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return quotation.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<Quotation?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM quotations WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToQuotation(row);
  }

  @override
  Future<List<Quotation>> findAll() async {
    final result = await _db.pool.execute('''
      SELECT * FROM quotations ORDER BY date DESC
    ''');

    return result.map((row) => _mapRowToQuotation(row)).toList();
  }

  @override
  Future<List<Quotation>> findByCustomerId(String customerId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM quotations WHERE customer_id = \$1 ORDER BY date DESC
    ''', parameters: {'customer_id': customerId});

    return result.map((row) => _mapRowToQuotation(row)).toList();
  }

  @override
  Future<Quotation> update(Quotation quotation) async {
    await _db.pool.execute('''
      UPDATE quotations
      SET customer_id = \$1, valid_until = \$2, status = \$3, 
          total_amount = \$4, notes = \$5, updated_at = NOW()
      WHERE id = \$6
    ''', parameters: {
      'customer_id': quotation.customerId,
      'valid_until': quotation.validUntil,
      'status': quotation.status,
      'total_amount': quotation.totalAmount,
      'notes': quotation.notes,
      'id': quotation.id,
    });

    return quotation.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM quotations WHERE id = \$1
    ''', parameters: {'id': id});
  }

  Quotation _mapRowToQuotation(List<dynamic> row) {
    return Quotation(
      id: row[0] as int,
      customerId: row[1] as String,
      quotationNumber: row[2] as String,
      date: row[3] as DateTime,
      validUntil: row[4] as DateTime?,
      status: row[5] as String,
      totalAmount: row[6] as double,
      notes: row[7] as String?,
      createdBy: row[8] as String?,
      createdAt: row[9] as DateTime,
      updatedAt: row[10] as DateTime,
    );
  }
}
