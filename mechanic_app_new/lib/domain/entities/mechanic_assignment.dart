import 'booking.dart';

class MechanicAssignment {
  final String id;
  final String bookingId;
  final String mechanicUserId;
  final String status;
  final String? notes;
  final DateTime assignedAt;
  final DateTime? updatedAt;
  final Booking? booking;

  MechanicAssignment({
    required this.id,
    required this.bookingId,
    required this.mechanicUserId,
    required this.status,
    this.notes,
    required this.assignedAt,
    this.updatedAt,
    this.booking,
  });

  MechanicAssignment copyWith({
    String? id,
    String? bookingId,
    String? mechanicUserId,
    String? status,
    String? notes,
    DateTime? assignedAt,
    DateTime? updatedAt,
    Booking? booking,
  }) {
    return MechanicAssignment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      mechanicUserId: mechanicUserId ?? this.mechanicUserId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      assignedAt: assignedAt ?? this.assignedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      booking: booking ?? this.booking,
    );
  }
}
