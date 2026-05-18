import '../entities/employee_contract.dart';

abstract class EmployeeContractRepository {
  Future<EmployeeContract> create(EmployeeContract contract);
  Future<EmployeeContract?> findById(int id);
  Future<List<EmployeeContract>> findByUserId(String userId);
  Future<EmployeeContract> update(EmployeeContract contract);
  Future<void> delete(int id);
}

abstract class LeaveRequestRepository {
  Future<LeaveRequest> create(LeaveRequest request);
  Future<LeaveRequest?> findById(int id);
  Future<List<LeaveRequest>> findByUserId(String userId);
  Future<List<LeaveRequest>> findByStatus(String status);
  Future<LeaveRequest> update(LeaveRequest request);
  Future<void> delete(int id);
}

abstract class PerformanceReviewRepository {
  Future<PerformanceReview> create(PerformanceReview review);
  Future<PerformanceReview?> findById(int id);
  Future<List<PerformanceReview>> findByUserId(String userId);
  Future<void> delete(int id);
}
