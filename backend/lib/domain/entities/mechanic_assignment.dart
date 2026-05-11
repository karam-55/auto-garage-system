import 'mechanic_assignment_status.dart';

class MechanicAssignment {
  final String id;
  final String bookingId;
  final String mechanicUserId;
  final MechanicAssignmentStatus status;
  final String? notes;
  final DateTime assignedAt;
  final DateTime? updatedAt;

  MechanicAssignment({
    required this.id,
    required this.bookingId,
    required this.mechanicUserId,
    required this.status,
    this.notes,
    required this.assignedAt,
    this.updatedAt,
  });

  factory MechanicAssignment.fromJson(Map<String, dynamic> json) {
    return MechanicAssignment(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      mechanicUserId: json['mechanicUserId'] as String,
      status: MechanicAssignmentStatus.fromString(json['status'] as String),
      notes: json['notes'] as String?,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'mechanicUserId': mechanicUserId,
      'status': status.value,
      'notes': notes,
      'assignedAt': assignedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  MechanicAssignment copyWith({
    String? id,
    String? bookingId,
    String? mechanicUserId,
    MechanicAssignmentStatus? status,
    String? notes,
    DateTime? assignedAt,
    DateTime? updatedAt,
  }) {
    return MechanicAssignment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      mechanicUserId: mechanicUserId ?? this.mechanicUserId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      assignedAt: assignedAt ?? this.assignedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
