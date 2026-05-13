import 'booking.dart';

class MechanicAssignment {
  final String id;
  final String status;
  final String? notes;
  final DateTime assignedAt;
  final DateTime? updatedAt;
  final Booking? booking;
  
  MechanicAssignment({
    required this.id,
    required this.status,
    this.notes,
    required this.assignedAt,
    this.updatedAt,
    this.booking,
  });
  
  factory MechanicAssignment.fromJson(Map<String, dynamic> json) {
    return MechanicAssignment(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'ASSIGNED',
      notes: json['notes'] as String?,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      booking: json['bookings'] != null ? Booking.fromJson(json['bookings'] as Map<String, dynamic>) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'notes': notes,
      'assigned_at': assignedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
