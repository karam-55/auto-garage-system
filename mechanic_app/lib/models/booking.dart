class Booking {
  final String id;
  final String customerId;
  final String vehicleId;
  final String status;
  final String? notes;
  final DateTime createdAt;
  
  Booking({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.status,
    this.notes,
    required this.createdAt,
  });
  
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      vehicleId: json['vehicleId'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  
  String get statusDisplay {
    switch (status) {
      case 'PENDING':
        return 'قيد الانتظار';
      case 'IN_PROGRESS':
        return 'قيد العمل';
      case 'WAITING_PARTS':
        return 'بانتظار القطع';
      case 'READY':
        return 'جاهزة';
      case 'DELIVERED':
        return 'تم التسليم';
      case 'CANCELLED':
        return 'ملغاة';
      default:
        return status;
    }
  }
}
