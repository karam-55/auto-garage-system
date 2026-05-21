import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/employee_contract.dart' as contract_entity;
import '../../domain/entities/leave_request.dart';
import '../../domain/entities/performance_review.dart' as review_entity;
import '../../domain/repositories/hr_repository.dart';
import '../../domain/repositories/leave_request_repository.dart';
import '../../domain/repositories/performance_review_repository.dart';
import '../../application/usecases/hr_usecases.dart';
import '../middlewares/json_middleware.dart';
import '../middlewares/auth_middleware.dart';

class HrRoutes {
  final EmployeeContractRepository _contractRepository;
  final LeaveRequestRepository _leaveRequestRepository;
  final PerformanceReviewRepository _performanceReviewRepository;
  final AuthMiddleware _authMiddleware;

  HrRoutes(
    this._contractRepository,
    this._leaveRequestRepository,
    this._performanceReviewRepository,
    this._authMiddleware,
  );

  Router get router {
    final router = Router();

    // Employee Contracts
    router.get('/api/hr/contracts', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_getAllContracts)));
    router.get('/api/hr/contracts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_getContractById)));
    router.post('/api/hr/contracts', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_createContract)));
    router.put('/api/hr/contracts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_updateContract)));
    router.delete('/api/hr/contracts/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_deleteContract)));

    // Leave Requests
    router.get('/api/hr/leave-requests', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_getAllLeaveRequests)));
    router.get('/api/hr/leave-requests/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_getLeaveRequestById)));
    router.post('/api/hr/leave-requests', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_createLeaveRequest)));
    router.put('/api/hr/leave-requests/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_updateLeaveRequest)));
    router.put('/api/hr/leave-requests/<id>/approve', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_approveLeaveRequest)));
    router.put('/api/hr/leave-requests/<id>/reject', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_rejectLeaveRequest)));
    router.delete('/api/hr/leave-requests/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_deleteLeaveRequest)));

    // Performance Reviews
    router.get('/api/hr/performance-reviews', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_getAllPerformanceReviews)));
    router.get('/api/hr/performance-reviews/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_getPerformanceReviewById)));
    router.post('/api/hr/performance-reviews', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_createPerformanceReview)));
    router.put('/api/hr/performance-reviews/<id>', _authMiddleware.authenticate()(_authMiddleware.requireAnyRole([Role.HR_MANAGER, Role.MANAGER, Role.OWNER])(_updatePerformanceReview)));
    router.delete('/api/hr/performance-reviews/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_deletePerformanceReview)));

    return router;
  }

  // Employee Contracts handlers
  Future<Response> _getAllContracts(Request request) async {
    try {
      final useCase = GetEmployeeContractUseCase(_contractRepository);
      final contracts = await useCase.executeAll();
      return Response.ok(jsonEncode(contracts.map((c) => c.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get contracts: $e'}));
    }
  }

  Future<Response> _getContractById(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid contract ID'}));
    }
    try {
      final useCase = GetEmployeeContractUseCase(_contractRepository);
      final contract = await useCase.execute(id);
      if (contract == null) {
        return Response.notFound(jsonEncode({'error': 'Contract not found'}));
      }
      return Response.ok(jsonEncode(contract.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get contract: $e'}));
    }
  }

  Future<Response> _createContract(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }
    try {
      final contract = contract_entity.EmployeeContract(
        id: body['id'] ?? DateTime.now().millisecondsSinceEpoch,
        userId: body['userId'],
        contractType: body['contractType'] ?? 'full-time',
        startDate: DateTime.parse(body['startDate']),
        endDate: body['endDate'] != null ? DateTime.parse(body['endDate']) : null,
        baseSalary: (body['baseSalary'] as num?)?.toDouble() ?? 0.0,
        benefits: body['benefits'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final useCase = CreateEmployeeContractUseCase(_contractRepository);
      final createdContract = await useCase.execute(contract);
      return Response.ok(jsonEncode(createdContract.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create contract: $e'}));
    }
  }

  Future<Response> _updateContract(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid contract ID'}));
    }
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }
    try {
      final contract = contract_entity.EmployeeContract(
        id: id,
        userId: body['userId'],
        contractType: body['contractType'] ?? 'full-time',
        startDate: DateTime.parse(body['startDate']),
        endDate: body['endDate'] != null ? DateTime.parse(body['endDate']) : null,
        baseSalary: (body['baseSalary'] as num?)?.toDouble() ?? 0.0,
        benefits: body['benefits'],
        createdAt: DateTime.parse(body['createdAt']),
        updatedAt: DateTime.now(),
      );
      
      final useCase = UpdateEmployeeContractUseCase(_contractRepository);
      final updatedContract = await useCase.execute(contract);
      return Response.ok(jsonEncode(updatedContract.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update contract: $e'}));
    }
  }

  Future<Response> _deleteContract(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid contract ID'}));
    }
    try {
      final useCase = DeleteEmployeeContractUseCase(_contractRepository);
      await useCase.execute(id);
      return Response.ok(jsonEncode({'message': 'Contract deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete contract: $e'}));
    }
  }

  // Leave Requests handlers
  Future<Response> _getAllLeaveRequests(Request request) async {
    try {
      final useCase = GetLeaveRequestUseCase(_leaveRequestRepository);
      final status = request.url.queryParameters['status'] ?? 'pending';
      final requests = await useCase.executeByStatus(status);
      return Response.ok(jsonEncode(requests.map((r) => r.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get leave requests: $e'}));
    }
  }

  Future<Response> _getLeaveRequestById(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid leave request ID'}));
    }
    try {
      final useCase = GetLeaveRequestUseCase(_leaveRequestRepository);
      final leaveRequest = await useCase.execute(id);
      if (leaveRequest == null) {
        return Response.notFound(jsonEncode({'error': 'Leave request not found'}));
      }
      return Response.ok(jsonEncode(leaveRequest.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get leave request: $e'}));
    }
  }

  Future<Response> _createLeaveRequest(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }
    try {
      final leaveRequest = LeaveRequest(
        id: body['id'] ?? DateTime.now().millisecondsSinceEpoch,
        userId: body['userId'],
        leaveType: body['leaveType'] ?? 'annual',
        startDate: DateTime.parse(body['startDate']),
        endDate: DateTime.parse(body['endDate']),
        reason: body['reason'],
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final useCase = CreateLeaveRequestUseCase(_leaveRequestRepository);
      final createdRequest = await useCase.execute(leaveRequest);
      return Response.ok(jsonEncode(createdRequest.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create leave request: $e'}));
    }
  }

  Future<Response> _updateLeaveRequest(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid leave request ID'}));
    }
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }
    try {
      final leaveRequest = LeaveRequest(
        id: id,
        userId: body['userId'],
        leaveType: body['leaveType'] ?? 'annual',
        startDate: DateTime.parse(body['startDate']),
        endDate: DateTime.parse(body['endDate']),
        reason: body['reason'],
        status: body['status'] ?? 'pending',
        approvedBy: body['approvedBy'],
        approvedAt: body['approvedAt'] != null ? DateTime.parse(body['approvedAt']) : null,
        createdAt: DateTime.parse(body['createdAt']),
        updatedAt: DateTime.now(),
      );
      
      final useCase = UpdateLeaveRequestUseCase(_leaveRequestRepository);
      final updatedRequest = await useCase.execute(leaveRequest);
      return Response.ok(jsonEncode(updatedRequest.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update leave request: $e'}));
    }
  }

  Future<Response> _approveLeaveRequest(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid leave request ID'}));
    }
    try {
      final user = request.context['user'];
      final approvedBy = user != null ? (user as dynamic).id.toString() : 'system';
      
      final useCase = ApproveLeaveRequestUseCase(_leaveRequestRepository);
      final approvedRequest = await useCase.execute(id, approvedBy);
      return Response.ok(jsonEncode(approvedRequest.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to approve leave request: $e'}));
    }
  }

  Future<Response> _rejectLeaveRequest(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid leave request ID'}));
    }
    try {
      final useCase = RejectLeaveRequestUseCase(_leaveRequestRepository);
      final rejectedRequest = await useCase.execute(id);
      return Response.ok(jsonEncode(rejectedRequest.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to reject leave request: $e'}));
    }
  }

  Future<Response> _deleteLeaveRequest(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid leave request ID'}));
    }
    try {
      final useCase = DeleteLeaveRequestUseCase(_leaveRequestRepository);
      await useCase.execute(id);
      return Response.ok(jsonEncode({'message': 'Leave request deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete leave request: $e'}));
    }
  }

  // Performance Reviews handlers
  Future<Response> _getAllPerformanceReviews(Request request) async {
    try {
      final useCase = GetPerformanceReviewUseCase(_performanceReviewRepository);
      final reviews = await useCase.executeByUserId('');
      return Response.ok(jsonEncode(reviews.map((r) => r.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get performance reviews: $e'}));
    }
  }

  Future<Response> _getPerformanceReviewById(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid performance review ID'}));
    }
    try {
      final useCase = GetPerformanceReviewUseCase(_performanceReviewRepository);
      final review = await useCase.execute(id);
      if (review == null) {
        return Response.notFound(jsonEncode({'error': 'Performance review not found'}));
      }
      return Response.ok(jsonEncode(review.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to get performance review: $e'}));
    }
  }

  Future<Response> _createPerformanceReview(Request request) async {
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }
    try {
      final review = review_entity.PerformanceReview(
        id: body['id'] ?? DateTime.now().millisecondsSinceEpoch,
        userId: body['userId'],
        reviewerId: body['reviewerId'],
        reviewDate: DateTime.now(),
        overallRating: (body['overallRating'] as num?)?.toDouble() ?? 5.0,
        strengths: body['strengths'],
        weaknesses: body['weaknesses'],
        goals: body['goals'],
        comments: body['comments'],
        createdAt: DateTime.now(),
      );
      
      final useCase = CreatePerformanceReviewUseCase(_performanceReviewRepository);
      final createdReview = await useCase.execute(review);
      return Response.ok(jsonEncode(createdReview.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to create performance review: $e'}));
    }
  }

  Future<Response> _updatePerformanceReview(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid performance review ID'}));
    }
    final body = await JsonMiddleware.parseJsonBody(request);
    if (body == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid request body'}));
    }
    try {
      final review = review_entity.PerformanceReview(
        id: id,
        userId: body['userId'],
        reviewerId: body['reviewerId'],
        reviewDate: DateTime.parse(body['reviewDate']),
        overallRating: (body['overallRating'] as num?)?.toDouble() ?? 5.0,
        strengths: body['strengths'],
        weaknesses: body['weaknesses'],
        goals: body['goals'],
        comments: body['comments'],
        createdAt: DateTime.parse(body['createdAt']),
      );
      
      final useCase = UpdatePerformanceReviewUseCase(_performanceReviewRepository);
      final updatedReview = await useCase.execute(review);
      return Response.ok(jsonEncode(updatedReview.toJson()));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to update performance review: $e'}));
    }
  }

  Future<Response> _deletePerformanceReview(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid performance review ID'}));
    }
    try {
      final useCase = DeletePerformanceReviewUseCase(_performanceReviewRepository);
      await useCase.execute(id);
      return Response.ok(jsonEncode({'message': 'Performance review deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Failed to delete performance review: $e'}));
    }
  }
}
