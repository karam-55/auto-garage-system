import '../../domain/entities/employee_contract.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/entities/performance_review.dart';
import '../../domain/repositories/hr_repository.dart';
import '../../domain/repositories/leave_request_repository.dart';
import '../../domain/repositories/performance_review_repository.dart';

class CreateEmployeeContractUseCase {
  final EmployeeContractRepository _repository;

  CreateEmployeeContractUseCase(this._repository);

  Future<EmployeeContract> execute(EmployeeContract contract) async {
    return await _repository.create(contract);
  }
}

class GetEmployeeContractUseCase {
  final EmployeeContractRepository _repository;

  GetEmployeeContractUseCase(this._repository);

  Future<EmployeeContract?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<EmployeeContract>> executeAll() async {
    return await _repository.findAll();
  }

  Future<List<EmployeeContract>> executeByUserId(String userId) async {
    return await _repository.findByUserId(userId);
  }
}

class UpdateEmployeeContractUseCase {
  final EmployeeContractRepository _repository;

  UpdateEmployeeContractUseCase(this._repository);

  Future<EmployeeContract> execute(EmployeeContract contract) async {
    return await _repository.update(contract);
  }
}

class DeleteEmployeeContractUseCase {
  final EmployeeContractRepository _repository;

  DeleteEmployeeContractUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}

class CreateLeaveRequestUseCase {
  final LeaveRequestRepository _repository;

  CreateLeaveRequestUseCase(this._repository);

  Future<LeaveRequest> execute(LeaveRequest request) async {
    return await _repository.create(request);
  }
}

class GetLeaveRequestUseCase {
  final LeaveRequestRepository _repository;

  GetLeaveRequestUseCase(this._repository);

  Future<LeaveRequest?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<LeaveRequest>> executeByUserId(String userId) async {
    return await _repository.findByUserId(userId);
  }

  Future<List<LeaveRequest>> executeByStatus(String status) async {
    return await _repository.findByStatus(status);
  }
}

class UpdateLeaveRequestUseCase {
  final LeaveRequestRepository _repository;

  UpdateLeaveRequestUseCase(this._repository);

  Future<LeaveRequest> execute(LeaveRequest request) async {
    return await _repository.update(request);
  }
}

class DeleteLeaveRequestUseCase {
  final LeaveRequestRepository _repository;

  DeleteLeaveRequestUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}

class CreatePerformanceReviewUseCase {
  final PerformanceReviewRepository _repository;

  CreatePerformanceReviewUseCase(this._repository);

  Future<PerformanceReview> execute(PerformanceReview review) async {
    return await _repository.create(review);
  }
}

class GetPerformanceReviewUseCase {
  final PerformanceReviewRepository _repository;

  GetPerformanceReviewUseCase(this._repository);

  Future<PerformanceReview?> execute(int id) async {
    return await _repository.findById(id);
  }

  Future<List<PerformanceReview>> executeByUserId(String userId) async {
    return await _repository.findByUserId(userId);
  }
}

class UpdatePerformanceReviewUseCase {
  final PerformanceReviewRepository _repository;

  UpdatePerformanceReviewUseCase(this._repository);

  Future<PerformanceReview> execute(PerformanceReview review) async {
    return await _repository.update(review);
  }
}

class DeletePerformanceReviewUseCase {
  final PerformanceReviewRepository _repository;

  DeletePerformanceReviewUseCase(this._repository);

  Future<void> execute(int id) async {
    await _repository.delete(id);
  }
}
