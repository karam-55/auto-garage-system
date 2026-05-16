class Booking {
  final String id;
  final String customerId;
  final String vehicleId;
  final String status;
  final String? notes;
  final DateTime? estimatedCompletionDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? publicToken;
  final Vehicle? vehicle;
  final Customer? customer;

  Booking({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.status,
    this.notes,
    this.estimatedCompletionDate,
    required this.createdAt,
    this.updatedAt,
    this.publicToken,
    this.vehicle,
    this.customer,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      notes: json['notes'] as String? ?? '',
      estimatedCompletionDate: json['estimated_completion_date'] != null
          ? DateTime.parse(json['estimated_completion_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      publicToken: json['public_token'] as String?,
      vehicle: json['vehicles'] != null ? Vehicle.fromJson(json['vehicles'] as Map<String, dynamic>) : null,
      customer: json['customers'] != null ? Customer.fromJson(json['customers'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'vehicle_id': vehicleId,
      'status': status,
      'notes': notes,
      'estimated_completion_date': estimatedCompletionDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'public_token': publicToken,
    };
  }
}

class Vehicle {
  final String id;
  final String? customerId;
  final String make;
  final String model;
  final int? year;
  final String? licensePlate;
  final String? vin;
  final String? publicCarId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vehicle({
    required this.id,
    this.customerId,
    required this.make,
    required this.model,
    this.year,
    this.licensePlate,
    this.vin,
    this.publicCarId,
    this.createdAt,
    this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String? ?? '',
      customerId: json['customer_id'] as String?,
      make: json['make'] as String? ?? 'غير محدد',
      model: json['model'] as String? ?? 'غير محدد',
      year: json['year'] as int?,
      licensePlate: json['license_plate'] as String?,
      vin: json['vin'] as String?,
      publicCarId: json['public_car_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'make': make,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'vin': vin,
      'public_car_id': publicCarId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get displayName => '$make $model ${year ?? ''}'.trim();
}

class Customer {
  final String id;
  final String fullName;
  final String? phone;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Customer({
    required this.id,
    required this.fullName,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'غير محدد',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
