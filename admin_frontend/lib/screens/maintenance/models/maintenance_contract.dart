class MaintenanceContract {
  final int id;
  final String customerId;
  final String vehicleId;
  final String? contractNumber;
  final DateTime startDate;
  final DateTime endDate;
  final int? serviceIntervalKm;
  final int? serviceIntervalDays;
  final int? lastServiceKm;
  final DateTime? nextServiceDue;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceContract({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    this.contractNumber,
    required this.startDate,
    required this.endDate,
    this.serviceIntervalKm,
    this.serviceIntervalDays,
    this.lastServiceKm,
    this.nextServiceDue,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceContract.fromJson(Map<String, dynamic> json) {
    return MaintenanceContract(
      id: json['id'] as int,
      customerId: json['customer_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      contractNumber: json['contract_number'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      serviceIntervalKm: json['service_interval_km'] as int?,
      serviceIntervalDays: json['service_interval_days'] as int?,
      lastServiceKm: json['last_service_km'] as int?,
      nextServiceDue: json['next_service_due'] != null
          ? DateTime.parse(json['next_service_due'] as String)
          : null,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'vehicle_id': vehicleId,
      'contract_number': contractNumber,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'service_interval_km': serviceIntervalKm,
      'service_interval_days': serviceIntervalDays,
      'last_service_km': lastServiceKm,
      'next_service_due': nextServiceDue?.toIso8601String(),
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
