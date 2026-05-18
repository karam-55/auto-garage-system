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

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      leaveType: json['leave_type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      reason: json['reason'] as String?,
      status: json['status'] as String,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

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
}
