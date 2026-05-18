class FixedAsset {
  final int id;
  final String name;
  final DateTime acquisitionDate;
  final double acquisitionCost;
  final double salvageValue;
  final int usefulLifeYears;
  final String depreciationMethod;
  final double? currentNetBookValue;
  final String? location;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DepreciationEntry> depreciationEntries;

  FixedAsset({
    required this.id,
    required this.name,
    required this.acquisitionDate,
    required this.acquisitionCost,
    required this.salvageValue,
    required this.usefulLifeYears,
    required this.depreciationMethod,
    this.currentNetBookValue,
    this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.depreciationEntries = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'acquisition_date': acquisitionDate.toIso8601String(),
      'acquisition_cost': acquisitionCost,
      'salvage_value': salvageValue,
      'useful_life_years': usefulLifeYears,
      'depreciation_method': depreciationMethod,
      'current_net_book_value': currentNetBookValue,
      'location': location,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'depreciation_entries': depreciationEntries.map((d) => d.toJson()).toList(),
    };
  }

  FixedAsset copyWith({
    int? id,
    String? name,
    DateTime? acquisitionDate,
    double? acquisitionCost,
    double? salvageValue,
    int? usefulLifeYears,
    String? depreciationMethod,
    double? currentNetBookValue,
    String? location,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<DepreciationEntry>? depreciationEntries,
  }) {
    return FixedAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      acquisitionCost: acquisitionCost ?? this.acquisitionCost,
      salvageValue: salvageValue ?? this.salvageValue,
      usefulLifeYears: usefulLifeYears ?? this.usefulLifeYears,
      depreciationMethod: depreciationMethod ?? this.depreciationMethod,
      currentNetBookValue: currentNetBookValue ?? this.currentNetBookValue,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      depreciationEntries: depreciationEntries ?? this.depreciationEntries,
    );
  }
}

class DepreciationEntry {
  final int id;
  final int assetId;
  final DateTime period;
  final double depreciationAmount;
  final int? journalEntryId;
  final DateTime createdAt;

  DepreciationEntry({
    required this.id,
    required this.assetId,
    required this.period,
    required this.depreciationAmount,
    this.journalEntryId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_id': assetId,
      'period': period.toIso8601String(),
      'depreciation_amount': depreciationAmount,
      'journal_entry_id': journalEntryId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DepreciationEntry copyWith({
    int? id,
    int? assetId,
    DateTime? period,
    double? depreciationAmount,
    int? journalEntryId,
    DateTime? createdAt,
  }) {
    return DepreciationEntry(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      period: period ?? this.period,
      depreciationAmount: depreciationAmount ?? this.depreciationAmount,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

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

  MaintenanceContract copyWith({
    int? id,
    String? customerId,
    String? vehicleId,
    String? contractNumber,
    DateTime? startDate,
    DateTime? endDate,
    int? serviceIntervalKm,
    int? serviceIntervalDays,
    int? lastServiceKm,
    DateTime? nextServiceDue,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceContract(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      contractNumber: contractNumber ?? this.contractNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      serviceIntervalKm: serviceIntervalKm ?? this.serviceIntervalKm,
      serviceIntervalDays: serviceIntervalDays ?? this.serviceIntervalDays,
      lastServiceKm: lastServiceKm ?? this.lastServiceKm,
      nextServiceDue: nextServiceDue ?? this.nextServiceDue,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
