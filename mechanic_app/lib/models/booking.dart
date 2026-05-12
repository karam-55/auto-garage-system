class Booking {
  final String id;
  final String customerId;
  final String vehicleId;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? estimatedCompletionDate;
  final Map<String, dynamic>? vehicles;
  final Map<String, dynamic>? customers;
  
  Booking({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.status,
    this.notes,
    required this.createdAt,
    this.estimatedCompletionDate,
    this.vehicles,
    this.customers,
  });
  
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      customerId: json['customer_id'] as String? ?? json['customerId'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? json['vehicleId'] as String? ?? '',
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? json['createdAt'] as String),
      estimatedCompletionDate: json['estimated_completion_date'] != null 
          ? DateTime.parse(json['estimated_completion_date'] as String)
          : null,
      vehicles: json['vehicles'] as Map<String, dynamic>?,
      customers: json['customers'] as Map<String, dynamic>?,
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
  
  String get vehicleInfo {
    if (vehicles != null) {
      final v = vehicles!;
      return '${v['make']} ${v['model']} ${v['year']} - ${v['license_plate'] ?? 'N/A'}';
    }
    return 'Vehicle: $vehicleId';
  }
  
  String get customerName {
    if (customers != null) {
      return customers!['full_name'] as String? ?? 'Unknown';
    }
    return 'Customer: $customerId';
  }
}
