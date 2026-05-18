import '../../domain/entities/employee_contract.dart';
import '../../domain/repositories/hr_repository.dart';
import '../database/database_connection.dart';

class EmployeeContractRepositoryImpl implements EmployeeContractRepository {
  final DatabaseConnection _db;

  EmployeeContractRepositoryImpl(this._db);

  @override
  Future<EmployeeContract> create(EmployeeContract contract) async {
    final result = await _db.pool.execute('''
      INSERT INTO employee_contracts (user_id, contract_type, start_date, end_date, base_salary, benefits)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'user_id': contract.userId,
      'contract_type': contract.contractType,
      'start_date': contract.startDate,
      'end_date': contract.endDate,
      'base_salary': contract.baseSalary,
      'benefits': contract.benefits,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return contract.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<EmployeeContract?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM employee_contracts WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToContract(row);
  }

  @override
  Future<List<EmployeeContract>> findByUserId(String userId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM employee_contracts WHERE user_id = \$1 ORDER BY start_date DESC
    ''', parameters: {'user_id': userId});

    return result.map((row) => _mapRowToContract(row)).toList();
  }

  @override
  Future<List<EmployeeContract>> findAll() async {
    final result = await _db.pool.execute('''
      SELECT * FROM employee_contracts ORDER BY start_date DESC
    ''');

    return result.map((row) => _mapRowToContract(row)).toList();
  }

  @override
  Future<EmployeeContract> update(EmployeeContract contract) async {
    await _db.pool.execute('''
      UPDATE employee_contracts
      SET user_id = \$1, contract_type = \$2, start_date = \$3, end_date = \$4,
          base_salary = \$5, benefits = \$6, updated_at = NOW()
      WHERE id = \$7
    ''', parameters: {
      'user_id': contract.userId,
      'contract_type': contract.contractType,
      'start_date': contract.startDate,
      'end_date': contract.endDate,
      'base_salary': contract.baseSalary,
      'benefits': contract.benefits,
      'id': contract.id,
    });

    return contract.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM employee_contracts WHERE id = \$1
    ''', parameters: {'id': id});
  }

  EmployeeContract _mapRowToContract(List<dynamic> row) {
    return EmployeeContract(
      id: row[0] as int,
      userId: row[1] as String,
      contractType: row[2] as String,
      startDate: row[3] as DateTime,
      endDate: row[4] as DateTime?,
      baseSalary: row[5] as double?,
      benefits: row[6] as String?,
      createdAt: row[7] as DateTime,
      updatedAt: row[8] as DateTime,
    );
  }
}

class LeaveRequestRepositoryImpl implements LeaveRequestRepository {
  final DatabaseConnection _db;

  LeaveRequestRepositoryImpl(this._db);

  @override
  Future<LeaveRequest> create(LeaveRequest request) async {
    final result = await _db.pool.execute('''
      INSERT INTO leave_requests (user_id, leave_type, start_date, end_date, reason, status)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6)
      RETURNING id, created_at, updated_at
    ''', parameters: {
      'user_id': request.userId,
      'leave_type': request.leaveType,
      'start_date': request.startDate,
      'end_date': request.endDate,
      'reason': request.reason,
      'status': request.status,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;
    final updatedAt = row[2] as DateTime;

    return request.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<LeaveRequest?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM leave_requests WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToRequest(row);
  }

  @override
  Future<List<LeaveRequest>> findByUserId(String userId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM leave_requests WHERE user_id = \$1 ORDER BY start_date DESC
    ''', parameters: {'user_id': userId});

    return result.map((row) => _mapRowToRequest(row)).toList();
  }

  @override
  Future<List<LeaveRequest>> findByStatus(String status) async {
    final result = await _db.pool.execute('''
      SELECT * FROM leave_requests WHERE status = \$1 ORDER BY start_date DESC
    ''', parameters: {'status': status});

    return result.map((row) => _mapRowToRequest(row)).toList();
  }

  @override
  Future<LeaveRequest> update(LeaveRequest request) async {
    await _db.pool.execute('''
      UPDATE leave_requests
      SET user_id = \$1, leave_type = \$2, start_date = \$3, end_date = \$4,
          reason = \$5, status = \$6, approved_by = \$7, approved_at = NOW(), updated_at = NOW()
      WHERE id = \$8
    ''', parameters: {
      'user_id': request.userId,
      'leave_type': request.leaveType,
      'start_date': request.startDate,
      'end_date': request.endDate,
      'reason': request.reason,
      'status': request.status,
      'approved_by': request.approvedBy,
      'id': request.id,
    });

    return request.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM leave_requests WHERE id = \$1
    ''', parameters: {'id': id});
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
      createdAt: row[9] as DateTime,
      updatedAt: row[10] as DateTime,
    );
  }
}

class PerformanceReviewRepositoryImpl implements PerformanceReviewRepository {
  final DatabaseConnection _db;

  PerformanceReviewRepositoryImpl(this._db);

  @override
  Future<PerformanceReview> create(PerformanceReview review) async {
    final result = await _db.pool.execute('''
      INSERT INTO performance_reviews (user_id, review_date, reviewer_id, rating, comments)
      VALUES (\$1, \$2, \$3, \$4, \$5)
      RETURNING id, created_at
    ''', parameters: {
      'user_id': review.userId,
      'review_date': review.reviewDate,
      'reviewer_id': review.reviewerId,
      'rating': review.rating,
      'comments': review.comments,
    });

    final row = result.first;
    final id = row[0] as int;
    final createdAt = row[1] as DateTime;

    return review.copyWith(
      id: id,
      createdAt: createdAt,
    );
  }

  @override
  Future<PerformanceReview?> findById(int id) async {
    final result = await _db.pool.execute('''
      SELECT * FROM performance_reviews WHERE id = \$1
    ''', parameters: {'id': id});

    if (result.isEmpty) return null;

    final row = result.first;
    return _mapRowToReview(row);
  }

  @override
  Future<List<PerformanceReview>> findByUserId(String userId) async {
    final result = await _db.pool.execute('''
      SELECT * FROM performance_reviews WHERE user_id = \$1 ORDER BY review_date DESC
    ''', parameters: {'user_id': userId});

    return result.map((row) => _mapRowToReview(row)).toList();
  }

  @override
  Future<void> delete(int id) async {
    await _db.pool.execute('''
      DELETE FROM performance_reviews WHERE id = \$1
    ''', parameters: {'id': id});
  }

  PerformanceReview _mapRowToReview(List<dynamic> row) {
    return PerformanceReview(
      id: row[0] as int,
      userId: row[1] as String,
      reviewDate: row[2] as DateTime,
      reviewerId: row[3] as String,
      rating: row[4] as int,
      comments: row[5] as String?,
      createdAt: row[6] as DateTime,
    );
  }
}
