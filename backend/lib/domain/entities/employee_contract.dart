class EmployeeContract {
  final int id;
  final String userId;
  final String contractType;
  final DateTime startDate;
  final DateTime? endDate;
  final double? baseSalary;
  final String? benefits;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeContract({
    required this.id,
    required this.userId,
    required this.contractType,
    required this.startDate,
    this.endDate,
    this.baseSalary,
    this.benefits,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'contract_type': contractType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'base_salary': baseSalary,
      'benefits': benefits,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  EmployeeContract copyWith({
    int? id,
    String? userId,
    String? contractType,
    DateTime? startDate,
    DateTime? endDate,
    double? baseSalary,
    String? benefits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeContract(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contractType: contractType ?? this.contractType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      baseSalary: baseSalary ?? this.baseSalary,
      benefits: benefits ?? this.benefits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LeaveRequest {
  final int id;
  final String userId;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final String status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.reason,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'leave_type': leaveType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'reason': reason,
      'status': status,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LeaveRequest copyWith({
    int? id,
    String? userId,
    String? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    String? status,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PerformanceReview {
  final int id;
  final String userId;
  final DateTime reviewDate;
  final String reviewerId;
  final int rating;
  final String? comments;
  final DateTime createdAt;

  PerformanceReview({
    required this.id,
    required this.userId,
    required this.reviewDate,
    required this.reviewerId,
    required this.rating,
    this.comments,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'review_date': reviewDate.toIso8601String(),
      'reviewer_id': reviewerId,
      'rating': rating,
      'comments': comments,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PerformanceReview copyWith({
    int? id,
    String? userId,
    DateTime? reviewDate,
    String? reviewerId,
    int? rating,
    String? comments,
    DateTime? createdAt,
  }) {
    return PerformanceReview(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reviewDate: reviewDate ?? this.reviewDate,
      reviewerId: reviewerId ?? this.reviewerId,
      rating: rating ?? this.rating,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
