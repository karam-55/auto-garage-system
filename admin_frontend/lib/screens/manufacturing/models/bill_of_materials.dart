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

  factory BillOfMaterials.fromJson(Map<String, dynamic> json) {
    return BillOfMaterials(
      id: json['id'] as int,
      serviceId: json['service_id'] as String?,
      outputVariantId: json['output_variant_id'] as String?,
      name: json['name'] as String,
      quantityOutput: json['quantity_output'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => BomLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

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
      'lines': lines.map((e) => e.toJson()).toList(),
    };
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

  factory BomLine.fromJson(Map<String, dynamic> json) {
    return BomLine(
      id: json['id'] as int,
      bomId: json['bom_id'] as int,
      inputVariantId: json['input_variant_id'] as String,
      quantityRequired: json['quantity_required'] as int,
      unitCost: (json['unit_cost'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

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
}
