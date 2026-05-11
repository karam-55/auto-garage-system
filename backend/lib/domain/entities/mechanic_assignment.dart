import 'package:json_annotation/json_annotation.dart';
import 'mechanic_assignment_status.dart';

part 'mechanic_assignment.g.dart';

@JsonSerializable()
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

  factory MechanicAssignment.fromJson(Map<String, dynamic> json) => _$MechanicAssignmentFromJson(json);
  Map<String, dynamic> toJson() => _$MechanicAssignmentToJson(this);

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
