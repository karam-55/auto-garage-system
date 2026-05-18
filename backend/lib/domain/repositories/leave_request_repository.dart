import '../entities/leave_request.dart';

abstract class LeaveRequestRepository {
  Future<LeaveRequest> create(LeaveRequest request);
  Future<LeaveRequest?> findById(int id);
  Future<List<LeaveRequest>> findByUserId(String userId);
  Future<List<LeaveRequest>> findByStatus(String status);
  Future<List<LeaveRequest>> findAll();
  Future<LeaveRequest> update(LeaveRequest request);
  Future<void> delete(int id);
}
