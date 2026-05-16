class Booking {
  final String id;
  final String customerId;
  final String vehicleId;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? publicToken;
  final Vehicle vehicle;
  final Customer customer;

  Booking({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.publicToken,
    required this.vehicle,
    required this.customer,
  });

  Booking copyWith({
    String? id,
    String? customerId,
    String? vehicleId,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? publicToken,
    Vehicle? vehicle,
    Customer? customer,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publicToken: publicToken ?? this.publicToken,
      vehicle: vehicle ?? this.vehicle,
      customer: customer ?? this.customer,
    );
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
}
