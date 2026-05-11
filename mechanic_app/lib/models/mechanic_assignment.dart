class MechanicAssignment {
  final String id;
  final String bookingId;
  final String mechanicUserId;
  final String status;
  final String? notes;
  final DateTime assignedAt;
  
  MechanicAssignment({
    required this.id,
    required this.bookingId,
    required this.mechanicUserId,
    required this.status,
    this.notes,
    required this.assignedAt,
  });
  
  factory MechanicAssignment.fromJson(Map<String, dynamic> json) {
    return MechanicAssignment(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      mechanicUserId: json['mechanicUserId'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
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
}
