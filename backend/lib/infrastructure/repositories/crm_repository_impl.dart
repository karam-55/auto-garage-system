import '../../domain/entities/crm_lead.dart';
import '../../domain/repositories/crm_repository.dart';
import '../database/database_connection.dart';

class CrmLeadRepositoryImpl implements CrmLeadRepository {
  final DatabaseConnection _db;

  CrmLeadRepositoryImpl(this._db);

  @override
  Future<CrmLead> create(CrmLead lead) async {
    final result = await _db.pool.execute('''
      INSERT INTO crm_leads (customer_id, source, status, estimated_value, closing_date, assigned_to, notes)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'customer_id': lead.customerId,
      'source': lead.source,
      'status': lead.status,
      'estimated_value': lead.estimatedValue,
      'closing_date': lead.closingDate,
      'assigned_to': lead.assignedTo,
      'notes': lead.notes,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return lead.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<CrmLead?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM crm_leads WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToLead(row);
  }

  @override
  Future<List<CrmLead>> findAll() async {
    final result = await _db.pool.execute('''
      SELECT * FROM crm_leads ORDER BY created_at DESC
    ''');

    return result.map((row) => _mapRowToLead(row)).toList();
  }

  @override
  Future<List<CrmLead>> findByCustomerId(String customerId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM crm_leads WHERE customer_id = \$1 ORDER BY created_at DESC
    ''', parameters: {'customer_id': customerId});

    return result.map((row) => _mapRowToLead(row)).toList();
  }

  @override
  Future<List<CrmLead>> findByAssignedTo(String assignedTo) async {
    final result = await _db.pool.execute('''
      SELECT * FROM crm_leads WHERE assigned_to = \$1 ORDER BY created_at DESC
    ''', parameters: {'assigned_to': assignedTo});

    return result.map((row) => _mapRowToLead(row)).toList();
  }

  @override
  Future<CrmLead> update(CrmLead lead) async {
    await _db.pool.execute('''
      UPDATE crm_leads
      SET customer_id = \$1, source = \$2, status = \$3, estimated_value = \$4,
          closing_date = \$5, assigned_to = \$6, notes = \$7, updated_at = NOW()
      WHERE id = \$8
    ''', parameters: {
      'customer_id': lead.customerId,
      'source': lead.source,
      'status': lead.status,
      'estimated_value': lead.estimatedValue,
      'closing_date': lead.closingDate,
      'assigned_to': lead.assignedTo,
      'notes': lead.notes,
      'id': lead.id,
    });

    return lead.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM crm_leads WHERE id = \$1
    ''', parameters: {'id': id});
  }

  CrmLead _mapRowToLead(List<dynamic> row) {
    return CrmLead(
      id: row[0] as int,
      customerId: row[1] as String?,
      source: row[2] as String?,
      status: row[3] as String,
      estimatedValue: row[4] as double?,
      closingDate: row[5] as DateTime?,
      assignedTo: row[6] as String?,
      notes: row[7] as String?,
      createdAt: row[8] as DateTime,
      updatedAt: row[9] as DateTime,
    );
  }
}
