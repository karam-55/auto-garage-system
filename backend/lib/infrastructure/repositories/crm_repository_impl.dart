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

class CrmActivityRepositoryImpl implements CrmActivityRepository {
  final DatabaseConnection _db;

  CrmActivityRepositoryImpl(this._db);

  @override
  Future<CrmActivity> create(CrmActivity activity) async {
    final result = await _db.pool.execute('''
      INSERT INTO crm_activities (lead_id, customer_id, activity_type, activity_date, summary, created_by)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6)
      RETURNING id, created_at
    ''', parameters: {
      'lead_id': activity.leadId,
      'customer_id': activity.customerId,
      'activity_type': activity.activityType,
      'activity_date': activity.activityDate,
      'summary': activity.summary,
      'created_by': activity.createdBy,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;

    return activity.copyWith(
      id: id,
      createdAt: createdAt,
    );
  }

  @override
  Future<CrmActivity?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM crm_activities WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToActivity(row);
  }

  @override
  Future<List<CrmActivity>> findByLeadId(int leadId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM crm_activities WHERE lead_id = \$1 ORDER BY activity_date DESC
    ''', parameters: {'lead_id': leadId});

    return result.map((row) => _mapRowToActivity(row)).toList();
  }

  @override
  Future<List<CrmActivity>> findByCustomerId(String customerId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM crm_activities WHERE customer_id = \$1 ORDER BY activity_date DESC
    ''', parameters: {'customer_id': customerId});

    return result.map((row) => _mapRowToActivity(row)).toList();
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM crm_activities WHERE id = \$1
    ''', parameters: {'id': id});
  }

  CrmActivity _mapRowToActivity(List<dynamic> row) {
    return CrmActivity(
      id: row[0] as int,
      leadId: row[1] as int?,
      customerId: row[2] as String?,
      activityType: row[3] as String,
      activityDate: row[4] as DateTime,
      summary: row[5] as String?,
      createdBy: row[6] as String?,
      createdAt: row[7] as DateTime,
    );
  }
}
