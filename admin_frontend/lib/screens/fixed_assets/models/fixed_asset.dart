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

  factory FixedAsset.fromJson(Map<String, dynamic> json) {
    return FixedAsset(
      id: json['id'] as int,
      name: json['name'] as String,
      acquisitionDate: DateTime.parse(json['acquisition_date'] as String),
      acquisitionCost: (json['acquisition_cost'] as num).toDouble(),
      salvageValue: (json['salvage_value'] as num).toDouble(),
      usefulLifeYears: json['useful_life_years'] as int,
      depreciationMethod: json['depreciation_method'] as String,
      currentNetBookValue: json['current_net_book_value'] != null
          ? (json['current_net_book_value'] as num).toDouble()
          : null,
      location: json['location'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      depreciationEntries: (json['depreciation_entries'] as List<dynamic>?)
              ?.map((e) => DepreciationEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

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
      'depreciation_entries': depreciationEntries.map((e) => e.toJson()).toList(),
    };
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

  factory DepreciationEntry.fromJson(Map<String, dynamic> json) {
    return DepreciationEntry(
      id: json['id'] as int,
      assetId: json['asset_id'] as int,
      period: DateTime.parse(json['period'] as String),
      depreciationAmount: (json['depreciation_amount'] as num).toDouble(),
      journalEntryId: json['journal_entry_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

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
}
