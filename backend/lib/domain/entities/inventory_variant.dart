enum VariantType {
  original,
  commercial,
  used;

  static VariantType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ORIGINAL':
        return VariantType.original;
      case 'COMMERCIAL':
        return VariantType.commercial;
      case 'USED':
        return VariantType.used;
      default:
        throw ArgumentError('Invalid variant type: $value');
    }
  }

  String toStringValue() {
    switch (this) {
      case VariantType.original:
        return 'ORIGINAL';
      case VariantType.commercial:
        return 'COMMERCIAL';
      case VariantType.used:
        return 'USED';
    }
  }
}

class InventoryVariant {
  final String id;
  final String itemId;
  final VariantType variantType;
  final int quantity;
  final double costPrice;
  final double sellingPrice;
  final String? supplier;
  final DateTime createdAt;

  InventoryVariant({
    required this.id,
    required this.itemId,
    required this.variantType,
    this.quantity = 0,
    this.costPrice = 0,
    this.sellingPrice = 0,
    this.supplier,
    required this.createdAt,
  });

  InventoryVariant copyWith({
    String? id,
    String? itemId,
    VariantType? variantType,
    int? quantity,
    double? costPrice,
    double? sellingPrice,
    String? supplier,
    DateTime? createdAt,
  }) {
    return InventoryVariant(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      variantType: variantType ?? this.variantType,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      supplier: supplier ?? this.supplier,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'variantType': variantType.toStringValue(),
      'quantity': quantity,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'supplier': supplier,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InventoryVariant.fromJson(Map<String, dynamic> json) {
    return InventoryVariant(
      id: json['id'] as String,
      itemId: json['item_id'] as String? ?? json['itemId'] as String,
      variantType: VariantType.fromString(json['variantType'] as String),
      quantity: json['quantity'] as int? ?? 0,
      costPrice: (json['costPrice'] is num ? json['costPrice'] as num : double.tryParse(json['costPrice'] as String? ?? '0'))?.toDouble() ?? 0,
      sellingPrice: (json['sellingPrice'] is num ? json['sellingPrice'] as num : double.tryParse(json['sellingPrice'] as String? ?? '0'))?.toDouble() ?? 0,
      supplier: json['supplier'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
