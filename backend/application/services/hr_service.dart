import '../../domain/entities/employee_contract.dart';
import '../../domain/repositories/hr_repository.dart';
import '../../application/usecases/hr_usecases.dart';

class HrService {
  final EmployeeContractRepository _contractRepository;
  final LeaveRequestRepository _leaveRepository;
  final PerformanceReviewRepository _reviewRepository;
  late final CreateEmployeeContractUseCase _createContractUseCase;
  late final GetEmployeeContractUseCase _getContractUseCase;
  late final UpdateEmployeeContractUseCase _updateContractUseCase;
  late final DeleteEmployeeContractUseCase _deleteContractUseCase;
  late final CreateLeaveRequestUseCase _createLeaveUseCase;
  late final GetLeaveRequestUseCase _getLeaveUseCase;
  late final ApproveLeaveRequestUseCase _approveLeaveUseCase;
  late final RejectLeaveRequestUseCase _rejectLeaveUseCase;
  late final DeleteLeaveRequestUseCase _deleteLeaveUseCase;
  late final CreatePerformanceReviewUseCase _createReviewUseCase;
  late final GetPerformanceReviewUseCase _getReviewUseCase;
  late final DeletePerformanceReviewUseCase _deleteReviewUseCase;

  HrService(this._contractRepository, this._leaveRepository, this._reviewRepository) {
    _createContractUseCase = CreateEmployeeContractUseCase(_contractRepository);
    _getContractUseCase = GetEmployeeContractUseCase(_contractRepository);
    _updateContractUseCase = UpdateEmployeeContractUseCase(_contractRepository);
    _deleteContractUseCase = DeleteEmployeeContractUseCase(_contractRepository);
    _createLeaveUseCase = CreateLeaveRequestUseCase(_leaveRepository);
    _getLeaveUseCase = GetLeaveRequestUseCase(_leaveRepository);
    _approveLeaveUseCase = ApproveLeaveRequestUseCase(_leaveRepository);
    _rejectLeaveUseCase = RejectLeaveRequestUseCase(_leaveRepository);
    _deleteLeaveUseCase = DeleteLeaveRequestUseCase(_leaveRepository);
    _createReviewUseCase = CreatePerformanceReviewUseCase(_reviewRepository);
    _getReviewUseCase = GetPerformanceReviewUseCase(_reviewRepository);
    _deleteReviewUseCase = DeletePerformanceReviewUseCase(_reviewRepository);
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

  Future<LeaveRequest> createLeaveRequest(LeaveRequest request) async {
    return await _createLeaveUseCase.execute(request);
  }

  Future<LeaveRequest?> getLeaveRequest(int id) async {
    return await _getLeaveUseCase.execute(id);
  }

  Future<List<LeaveRequest>> getLeaveRequestsByUser(String userId) async {
    return await _getLeaveUseCase.executeByUserId(userId);
  }

  Future<List<LeaveRequest>> getLeaveRequestsByStatus(String status) async {
    return await _getLeaveUseCase.executeByStatus(status);
  }

  Future<LeaveRequest> approveLeaveRequest(int id, String approvedBy) async {
    return await _approveLeaveUseCase.execute(id, approvedBy);
  }

  Future<LeaveRequest> rejectLeaveRequest(int id) async {
    return await _rejectLeaveUseCase.execute(id);
  }

  Future<void> deleteLeaveRequest(int id) async {
    await _deleteLeaveUseCase.execute(id);
  }

  Future<PerformanceReview> createPerformanceReview(PerformanceReview review) async {
    return await _createReviewUseCase.execute(review);
  }

  Future<PerformanceReview?> getPerformanceReview(int id) async {
    return await _getReviewUseCase.execute(id);
  }

  Future<List<PerformanceReview>> getPerformanceReviewsByUser(String userId) async {
    return await _getReviewUseCase.executeByUserId(userId);
  }

  Future<void> deletePerformanceReview(int id) async {
    await _deleteReviewUseCase.execute(id);
  }
}
