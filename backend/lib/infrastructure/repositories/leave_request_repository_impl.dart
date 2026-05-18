import '../../domain/entities/leave_request.dart';
import '../../domain/repositories/leave_request_repository.dart';
import '../database/database_connection.dart';

class LeaveRequestRepositoryImpl implements LeaveRequestRepository {
  final DatabaseConnection _db;

  LeaveRequestRepositoryImpl(this._db);

  @override
  Future<LeaveRequest> create(LeaveRequest request) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''INSERT INTO leave_requests (user_id, leave_type, start_date, end_date, reason, status, created_at)
           VALUES (@userId, @leaveType, @startDate, @endDate, @reason, @status, @createdAt)
           RETURNING id, created_at''',
        parameters: {
          'userId': request.userId,
          'leaveType': request.leaveType,
          'startDate': request.startDate,
          'endDate': request.endDate,
          'reason': request.reason,
          'status': request.status,
          'createdAt': request.createdAt,
        },
      );
      final row = result.first;
      return request.copyWith(
        id: row[0] as int,
        createdAt: row[1] as DateTime,
      );
    });
  }

  @override
  Future<LeaveRequest?> findById(int id) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, user_id, leave_type, start_date, end_date, reason, status, approved_by, approved_at, rejection_reason, created_at, updated_at
           FROM leave_requests WHERE id = @id''',
        parameters: {'id': id},
      );
      if (result.isEmpty) return null;
      return _mapRowToRequest(result.first);
    });
  }

  @override
  Future<List<LeaveRequest>> findByUserId(String userId) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, user_id, leave_type, start_date, end_date, reason, status, approved_by, approved_at, rejection_reason, created_at, updated_at
           FROM leave_requests WHERE user_id = @userId ORDER BY created_at DESC''',
        parameters: {'userId': userId},
      );
      return result.map(_mapRowToRequest).toList();
    });
  }

  @override
  Future<List<LeaveRequest>> findByStatus(String status) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, user_id, leave_type, start_date, end_date, reason, status, approved_by, approved_at, rejection_reason, created_at, updated_at
           FROM leave_requests WHERE status = @status ORDER BY created_at DESC''',
        parameters: {'status': status},
      );
      return result.map(_mapRowToRequest).toList();
    });
  }

  @override
  Future<List<LeaveRequest>> findAll() async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, user_id, leave_type, start_date, end_date, reason, status, approved_by, approved_at, rejection_reason, created_at, updated_at
           FROM leave_requests ORDER BY created_at DESC''',
      );
      return result.map(_mapRowToRequest).toList();
    });
  }

  @override
  Future<LeaveRequest> update(LeaveRequest request) async {
    return await _db.runInTransaction((session) async {
      await session.execute(
        '''UPDATE leave_requests SET
           user_id = @userId,
           leave_type = @leaveType,
           start_date = @startDate,
           end_date = @endDate,
           reason = @reason,
           status = @status,
           approved_by = @approvedBy,
           approved_at = @approvedAt,
           rejection_reason = @rejectionReason,
           updated_at = NOW()
           WHERE id = @id''',
        parameters: {
          'id': request.id,
          'userId': request.userId,
          'leaveType': request.leaveType,
          'startDate': request.startDate,
          'endDate': request.endDate,
          'reason': request.reason,
          'status': request.status,
          'approvedBy': request.approvedBy,
          'approvedAt': request.approvedAt,
          'rejectionReason': request.rejectionReason,
        },
      );
      return request.copyWith(updatedAt: DateTime.now());
    });
  }

  @override
  Future<void> delete(int id) async {
    return await _db.runInTransaction((session) async {
      await session.execute('DELETE FROM leave_requests WHERE id = @id', parameters: {'id': id});
    });
  }

  LeaveRequest _mapRowToRequest(List<dynamic> row) {
    return LeaveRequest(
      id: row[0] as int,
      userId: row[1] as String,
      leaveType: row[2] as String,
      startDate: row[3] as DateTime,
      endDate: row[4] as DateTime,
      reason: row[5] as String?,
      status: row[6] as String,
      approvedBy: row[7] as String?,
      approvedAt: row[8] as DateTime?,
      rejectionReason: row[9] as String?,
      createdAt: row[10] as DateTime,
      updatedAt: row[11] as DateTime?,
    );
  }
}
