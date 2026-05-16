import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  BookingModel({
    required super.id,
    required super.customerId,
    required super.vehicleId,
    required super.status,
    super.notes,
    required super.createdAt,
    super.updatedAt,
    super.publicToken,
    required super.vehicle,
    required super.customer,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      publicToken: json['public_token'] as String?,
      vehicle: json['vehicles'] != null
          ? VehicleModel.fromJson(json['vehicles'] as Map<String, dynamic>)
          : VehicleModel.fromJson({}),
      customer: json['customers'] != null
          ? CustomerModel.fromJson(json['customers'] as Map<String, dynamic>)
          : CustomerModel.fromJson({}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'vehicle_id': vehicleId,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'public_token': publicToken,
    };
  }

  Booking toEntity() => Booking(
        id: id,
        customerId: customerId,
        vehicleId: vehicleId,
        status: status,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        publicToken: publicToken,
        vehicle: vehicle,
        customer: customer,
      );
}

class VehicleModel extends Vehicle {
  VehicleModel({
    required super.id,
    super.customerId,
    required super.make,
    required super.model,
    super.year,
    super.licensePlate,
    super.vin,
    super.publicCarId,
    super.createdAt,
    super.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
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

  Vehicle toEntity() => Vehicle(
        id: id,
        customerId: customerId,
        make: make,
        model: model,
        year: year,
        licensePlate: licensePlate,
        vin: vin,
        publicCarId: publicCarId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

class CustomerModel extends Customer {
  CustomerModel({
    required super.id,
    required super.fullName,
    super.phone,
    super.address,
    super.createdAt,
    super.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
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

  Customer toEntity() => Customer(
        id: id,
        fullName: fullName,
        phone: phone,
        address: address,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
