class MaintenanceContract {
  final int? id;
  final int assetId;
  final String contractNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String? provider;
  final double? cost;
  final String? terms;
  final String status; // active, expired, cancelled
  final DateTime createdAt;
  final DateTime? updatedAt;

  MaintenanceContract({
    this.id,
    required this.assetId,
    required this.contractNumber,
    required this.startDate,
    required this.endDate,
    this.provider,
    this.cost,
    this.terms,
    this.status = 'active',
    required this.createdAt,
    this.updatedAt,
  });

  MaintenanceContract copyWith({
    int? id,
    int? assetId,
    String? contractNumber,
    DateTime? startDate,
    DateTime? endDate,
    String? provider,
    double? cost,
    String? terms,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceContract(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      contractNumber: contractNumber ?? this.contractNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      provider: provider ?? this.provider,
      cost: cost ?? this.cost,
      terms: terms ?? this.terms,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_id': assetId,
      'contract_number': contractNumber,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'provider': provider,
      'cost': cost,
      'terms': terms,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory MaintenanceContract.fromJson(Map<String, dynamic> json) {
    return MaintenanceContract(
      id: json['id'] as int?,
      assetId: json['asset_id'] as int,
      contractNumber: json['contract_number'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      provider: json['provider'] as String?,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      terms: json['terms'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }
}
