class Booking {
  final String id;
  final String status;
  final String? notes;
  final DateTime? estimatedCompletionDate;
  final DateTime createdAt;
  final Vehicle? vehicle;
  final Customer? customer;
  
  Booking({
    required this.id,
    required this.status,
    this.notes,
    this.estimatedCompletionDate,
    required this.createdAt,
    this.vehicle,
    this.customer,
  });
  
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'PENDING',
      notes: json['notes'] as String?,
      estimatedCompletionDate: json['estimated_completion_date'] != null
          ? DateTime.parse(json['estimated_completion_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      vehicle: json['vehicles'] != null ? Vehicle.fromJson(json['vehicles'] as Map<String, dynamic>) : null,
      customer: json['customers'] != null ? Customer.fromJson(json['customers'] as Map<String, dynamic>) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'notes': notes,
      'estimated_completion_date': estimatedCompletionDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Vehicle {
  final String id;
  final String make;
  final String model;
  final int? year;
  final String? licensePlate;
  final String? publicCarId;
  
  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    this.year,
    this.licensePlate,
    this.publicCarId,
  });
  
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as int?,
      licensePlate: json['license_plate'] as String?,
      publicCarId: json['public_car_id'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'public_car_id': publicCarId,
    };
  }
  
  String get displayName => '$make $model ${year ?? ''}'.trim();
}

class Customer {
  final String id;
  final String fullName;
  final String? phone;
  
  Customer({
    required this.id,
    required this.fullName,
    this.phone,
  });
  
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
    };
  }
}
