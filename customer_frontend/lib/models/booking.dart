class Booking {
  final String id;
  final String customerId;
  final String vehicleId;
  final String status;
  final String publicToken;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  Booking({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.status,
    required this.publicToken,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      vehicleId: json['vehicleId'] as String,
      status: json['status'] as String,
      publicToken: json['publicToken'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
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
