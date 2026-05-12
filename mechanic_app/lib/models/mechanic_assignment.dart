class MechanicAssignment {
  final String id;
  final String bookingId;
  final String mechanicUserId;
  final String status;
  final String? notes;
  final DateTime assignedAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? bookings;
  
  MechanicAssignment({
    required this.id,
    required this.bookingId,
    required this.mechanicUserId,
    required this.status,
    this.notes,
    required this.assignedAt,
    this.updatedAt,
    this.bookings,
  });
  
  factory MechanicAssignment.fromJson(Map<String, dynamic> json) {
    return MechanicAssignment(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String? ?? json['bookingId'] as String? ?? '',
      mechanicUserId: json['mechanic_user_id'] as String? ?? json['mechanicUserId'] as String? ?? '',
      status: json['status'] as String,
      notes: json['notes'] as String?,
      assignedAt: DateTime.parse(json['assigned_at'] as String? ?? json['assignedAt'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      bookings: json['bookings'] as Map<String, dynamic>?,
    );
  }
  
  String get statusDisplay {
    switch (status) {
      case 'ASSIGNED':
        return 'مُسند';
      case 'IN_PROGRESS':
        return 'قيد العمل';
      case 'WAITING_PARTS':
        return 'بانتظار القطع';
      case 'READY':
        return 'جاهز';
      case 'DELIVERED':
        return 'تم التسليم';
      default:
        return status;
    }
  }
  
  String get bookingInfo {
    if (bookings != null) {
      final b = bookings!;
      final v = b['vehicles'] as Map<String, dynamic>?;
      final c = b['customers'] as Map<String, dynamic>?;
      final vehicleInfo = v != null 
          ? '${v['make']} ${v['model']} ${v['year']} - ${v['license_plate'] ?? 'N/A'}'
          : 'Vehicle: ${b['vehicle_id']}';
      final customerInfo = c != null ? c['full_name'] : 'Customer: ${b['customer_id']}';
      return '$vehicleInfo\n$customerInfo';
    }
    return 'Booking: $bookingId';
  }
}
