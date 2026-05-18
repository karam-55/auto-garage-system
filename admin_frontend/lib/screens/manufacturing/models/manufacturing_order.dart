class ManufacturingOrder {
  final int id;
  final int bomId;
  final int quantityToProduce;
  final int producedQuantity;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String? createdBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ManufacturingOrder({
    required this.id,
    required this.bomId,
    required this.quantityToProduce,
    required this.producedQuantity,
    this.startDate,
    this.endDate,
    required this.status,
    this.createdBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ManufacturingOrder.fromJson(Map<String, dynamic> json) {
    return ManufacturingOrder(
      id: json['id'] as int,
      bomId: json['bom_id'] as int,
      quantityToProduce: json['quantity_to_produce'] as int,
      producedQuantity: json['produced_quantity'] as int,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      status: json['status'] as String,
      createdBy: json['created_by'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bom_id': bomId,
      'quantity_to_produce': quantityToProduce,
      'produced_quantity': producedQuantity,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'created_by': createdBy,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
