import '../../domain/entities/mechanic_assignment.dart';
import 'booking_model.dart';

class MechanicAssignmentModel extends MechanicAssignment {
  MechanicAssignmentModel({
    required super.id,
    required super.bookingId,
    required super.mechanicUserId,
    required super.status,
    super.notes,
    required super.assignedAt,
    super.updatedAt,
    super.booking,
  });

  factory MechanicAssignmentModel.fromJson(Map<String, dynamic> json) {
    return MechanicAssignmentModel(
      id: json['id'] as String? ?? '',
      bookingId: (json['bookingId'] ?? json['booking_id']) as String? ?? '',
      mechanicUserId: (json['mechanicUserId'] ?? json['mechanic_user_id']) as String? ?? '',
      status: json['status'] as String? ?? 'ASSIGNED',
      notes: json['notes'] as String?,
      assignedAt: (json['assignedAt'] ?? json['assigned_at']) != null
          ? DateTime.parse((json['assignedAt'] ?? json['assigned_at']) as String)
          : DateTime.now(),
      updatedAt: (json['updatedAt'] ?? json['updated_at']) != null
          ? DateTime.parse((json['updatedAt'] ?? json['updated_at']) as String)
          : null,
      booking: (json['booking'] ?? json['bookings']) != null
          ? BookingModel.fromJson((json['booking'] ?? json['bookings']) as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'mechanic_user_id': mechanicUserId,
      'status': status,
      'notes': notes,
      'assigned_at': assignedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  MechanicAssignment toEntity() => MechanicAssignment(
        id: id,
        bookingId: bookingId,
        mechanicUserId: mechanicUserId,
        status: status,
        notes: notes,
        assignedAt: assignedAt,
        updatedAt: updatedAt,
        booking: booking,
      );
}
