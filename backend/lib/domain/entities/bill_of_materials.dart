class BillOfMaterials {
  final int id;
  final String? serviceId;
  final String? outputVariantId;
  final String name;
  final int quantityOutput;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<BomLine> lines;

  BillOfMaterials({
    required this.id,
    this.serviceId,
    this.outputVariantId,
    required this.name,
    required this.quantityOutput,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lines = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'output_variant_id': outputVariantId,
      'name': name,
      'quantity_output': quantityOutput,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'lines': lines.map((l) => l.toJson()).toList(),
    };
  }

  BillOfMaterials copyWith({
    int? id,
    String? serviceId,
    String? outputVariantId,
    String? name,
    int? quantityOutput,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BomLine>? lines,
  }) {
    return BillOfMaterials(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      outputVariantId: outputVariantId ?? this.outputVariantId,
      name: name ?? this.name,
      quantityOutput: quantityOutput ?? this.quantityOutput,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lines: lines ?? this.lines,
    );
  }
}

class BomLine {
  final int id;
  final int bomId;
  final String inputVariantId;
  final int quantityRequired;
  final double unitCost;
  final DateTime createdAt;

  BomLine({
    required this.id,
    required this.bomId,
    required this.inputVariantId,
    required this.quantityRequired,
    required this.unitCost,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bom_id': bomId,
      'input_variant_id': inputVariantId,
      'quantity_required': quantityRequired,
      'unit_cost': unitCost,
      'created_at': createdAt.toIso8601String(),
    };
  }

  BomLine copyWith({
    int? id,
    int? bomId,
    String? inputVariantId,
    int? quantityRequired,
    double? unitCost,
    DateTime? createdAt,
  }) {
    return BomLine(
      id: id ?? this.id,
      bomId: bomId ?? this.bomId,
      inputVariantId: inputVariantId ?? this.inputVariantId,
      quantityRequired: quantityRequired ?? this.quantityRequired,
      unitCost: unitCost ?? this.unitCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

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

  ManufacturingOrder copyWith({
    int? id,
    int? bomId,
    int? quantityToProduce,
    int? producedQuantity,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? createdBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ManufacturingOrder(
      id: id ?? this.id,
      bomId: bomId ?? this.bomId,
      quantityToProduce: quantityToProduce ?? this.quantityToProduce,
      producedQuantity: producedQuantity ?? this.producedQuantity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
