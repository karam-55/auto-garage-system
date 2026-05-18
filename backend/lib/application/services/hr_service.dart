import '../../domain/entities/employee_contract.dart';
import '../../domain/entities/leave_request.dart' as leave;
import '../../domain/entities/performance_review.dart' as review;
import '../../domain/repositories/hr_repository.dart';
import '../../domain/repositories/leave_request_repository.dart';
import '../../domain/repositories/performance_review_repository.dart';
import '../../application/usecases/hr_usecases.dart' as hr;

class HrService {
  final EmployeeContractRepository _contractRepository;
  final LeaveRequestRepository _leaveRepository;
  final PerformanceReviewRepository _reviewRepository;
  late final hr.CreateEmployeeContractUseCase _createContractUseCase;
  late final hr.GetEmployeeContractUseCase _getContractUseCase;
  late final hr.UpdateEmployeeContractUseCase _updateContractUseCase;
  late final hr.DeleteEmployeeContractUseCase _deleteContractUseCase;
  late final hr.CreateLeaveRequestUseCase _createLeaveUseCase;
  late final hr.GetLeaveRequestUseCase _getLeaveUseCase;
  late final hr.ApproveLeaveRequestUseCase _approveLeaveUseCase;
  late final hr.RejectLeaveRequestUseCase _rejectLeaveUseCase;
  late final hr.DeleteLeaveRequestUseCase _deleteLeaveUseCase;
  late final hr.CreatePerformanceReviewUseCase _createReviewUseCase;
  late final hr.GetPerformanceReviewUseCase _getReviewUseCase;
  late final hr.DeletePerformanceReviewUseCase _deleteReviewUseCase;

  HrService(this._contractRepository, this._leaveRepository, this._reviewRepository) {
    _createContractUseCase = hr.CreateEmployeeContractUseCase(_contractRepository);
    _getContractUseCase = hr.GetEmployeeContractUseCase(_contractRepository);
    _updateContractUseCase = hr.UpdateEmployeeContractUseCase(_contractRepository);
    _deleteContractUseCase = hr.DeleteEmployeeContractUseCase(_contractRepository);
    _createLeaveUseCase = hr.CreateLeaveRequestUseCase(_leaveRepository);
    _getLeaveUseCase = hr.GetLeaveRequestUseCase(_leaveRepository);
    _approveLeaveUseCase = hr.ApproveLeaveRequestUseCase(_leaveRepository);
    _rejectLeaveUseCase = hr.RejectLeaveRequestUseCase(_leaveRepository);
    _deleteLeaveUseCase = hr.DeleteLeaveRequestUseCase(_leaveRepository);
    _createReviewUseCase = hr.CreatePerformanceReviewUseCase(_reviewRepository);
    _getReviewUseCase = hr.GetPerformanceReviewUseCase(_reviewRepository);
    _deleteReviewUseCase = hr.DeletePerformanceReviewUseCase(_reviewRepository);
  }

  Future<EmployeeContract> createContract(EmployeeContract contract) async {
    return await _createContractUseCase.execute(contract);
  }

  Future<EmployeeContract?> getContract(int id) async {
    return await _getContractUseCase.execute(id);
  }

  Future<List<EmployeeContract>> getContractsByUser(String userId) async {
    return await _getContractUseCase.executeByUserId(userId);
  }

  Future<EmployeeContract> updateContract(EmployeeContract contract) async {
    return await _updateContractUseCase.execute(contract);
  }

  Future<void> deleteContract(int id) async {
    await _deleteContractUseCase.execute(id);
  }

  Future<leave.LeaveRequest> createLeaveRequest(leave.LeaveRequest request) async {
    return await _createLeaveUseCase.execute(request);
  }

  Future<leave.LeaveRequest?> getLeaveRequest(int id) async {
    return await _getLeaveUseCase.execute(id);
  }

  Future<List<leave.LeaveRequest>> getLeaveRequestsByUser(String userId) async {
    return await _getLeaveUseCase.executeByUserId(userId);
  }

  Future<List<leave.LeaveRequest>> getLeaveRequestsByStatus(String status) async {
    return await _getLeaveUseCase.executeByStatus(status);
  }

  Future<leave.LeaveRequest> approveLeaveRequest(int id, String approvedBy) async {
    return await _approveLeaveUseCase.execute(id, approvedBy);
  }

  Future<leave.LeaveRequest> rejectLeaveRequest(int id) async {
    return await _rejectLeaveUseCase.execute(id);
  }

  Future<void> deleteLeaveRequest(int id) async {
    await _deleteLeaveUseCase.execute(id);
  }

  Future<review.PerformanceReview> createPerformanceReview(review.PerformanceReview review) async {
    return await _createReviewUseCase.execute(review);
  }

  Future<review.PerformanceReview?> getPerformanceReview(int id) async {
    return await _getReviewUseCase.execute(id);
  }

  Future<List<review.PerformanceReview>> getPerformanceReviewsByUser(String userId) async {
    return await _getReviewUseCase.executeByUserId(userId);
  }

  Future<void> deletePerformanceReview(int id) async {
    await _deleteReviewUseCase.execute(id);
  }
}
