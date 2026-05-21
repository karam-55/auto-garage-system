import 'package:postgres/postgres.dart';
import '../../domain/entities/crm_activity.dart';
import '../../domain/repositories/crm_activity_repository.dart';
import '../database/database_connection.dart';

class CrmActivityRepositoryImpl implements CrmActivityRepository {
  final DatabaseConnection _db;

  CrmActivityRepositoryImpl(this._db);

  @override
  Future<CrmActivity> create(CrmActivity activity) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''INSERT INTO crm_activities (lead_id, customer_id, activity_type, description, due_date, is_completed, created_at, created_by)
           VALUES (@leadId, @customerId, @activityType, @description, @dueDate, @isCompleted, @createdAt, @createdBy)
           RETURNING id, created_at'''),
        parameters: {
          'leadId': activity.leadId,
          'customerId': activity.customerId,
          'activityType': activity.activityType,
          'description': activity.description,
          'dueDate': activity.dueDate,
          'isCompleted': activity.isCompleted,
          'createdAt': activity.createdAt,
          'createdBy': activity.createdBy,
        },
      );
      final row = result.first;
      return activity.copyWith(
        id: row[0] as int,
        createdAt: row[1] as DateTime,
      );
    });
  }

  @override
  Future<CrmActivity?> findById(int id) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''SELECT id, lead_id, customer_id, activity_type, description, due_date, is_completed, created_at, updated_at, created_by
           FROM crm_activities WHERE id = @id'''),
        parameters: {'id': id},
      );
      if (result.isEmpty) return null;
      return _mapRowToActivity(result.first);
    });
  }

  @override
  Future<List<CrmActivity>> findByLeadId(int leadId) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''SELECT id, lead_id, customer_id, activity_type, description, due_date, is_completed, created_at, updated_at, created_by
           FROM crm_activities WHERE lead_id = @leadId ORDER BY created_at DESC'''),
        parameters: {'leadId': leadId},
      );
      return result.map(_mapRowToActivity).toList();
    });
  }

  @override
  Future<List<CrmActivity>> findByCustomerId(String customerId) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''SELECT id, lead_id, customer_id, activity_type, description, due_date, is_completed, created_at, updated_at, created_by
           FROM crm_activities WHERE customer_id = @customerId ORDER BY created_at DESC'''),
        parameters: {'customerId': customerId},
      );
      return result.map(_mapRowToActivity).toList();
    });
  }

  @override
  Future<List<CrmActivity>> findAll() async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, lead_id, customer_id, activity_type, description, due_date, is_completed, created_at, updated_at, created_by
           FROM crm_activities ORDER BY created_at DESC''',
      );
      return result.map(_mapRowToActivity).toList();
    });
  }

  @override
  Future<CrmActivity> update(CrmActivity activity) async {
    return await _db.runInTransaction((session) async {
      await session.execute(
        Sql.named('''UPDATE crm_activities SET
           lead_id = @leadId,
           customer_id = @customerId,
           activity_type = @activityType,
           description = @description,
           due_date = @dueDate,
           is_completed = @isCompleted,
           updated_at = NOW()
           WHERE id = @id'''),
        parameters: {
          'id': activity.id,
          'leadId': activity.leadId,
          'customerId': activity.customerId,
          'activityType': activity.activityType,
          'description': activity.description,
          'dueDate': activity.dueDate,
          'isCompleted': activity.isCompleted,
        },
      );
      return activity.copyWith(updatedAt: DateTime.now());
    });
  }

  @override
  Future<void> delete(int id) async {
    return await _db.runInTransaction((session) async {
      await session.execute(Sql.named('DELETE FROM crm_activities WHERE id = @id'), parameters: {'id': id});
    });
  }

  CrmActivity _mapRowToActivity(List<dynamic> row) {
    return CrmActivity(
      id: row[0] as int,
      leadId: row[1] as int,
      customerId: row[2] as String,
      activityType: row[3] as String,
      description: row[4] as String,
      dueDate: row[5] as DateTime?,
      isCompleted: row[6] as bool,
      createdAt: row[7] as DateTime,
      updatedAt: row[8] as DateTime?,
      createdBy: row[9] as String?,
    );
  }
}
