class Warehouse {
  final int id;
  final String name;
  final String? location;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Warehouse({
    required this.id,
    required this.name,
    this.location,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Warehouse copyWith({
    int? id,
    String? name,
    String? location,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class InventoryVariantWarehouse {
  final int id;
  final String variantId;
  final int warehouseId;
  final int quantity;
  final int lowStockThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryVariantWarehouse({
    required this.id,
    required this.variantId,
    required this.warehouseId,
    required this.quantity,
    required this.lowStockThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variant_id': variantId,
      'warehouse_id': warehouseId,
      'quantity': quantity,
      'low_stock_threshold': lowStockThreshold,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  InventoryVariantWarehouse copyWith({
    int? id,
    String? variantId,
    int? warehouseId,
    int? quantity,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryVariantWarehouse(
      id: id ?? this.id,
      variantId: variantId ?? this.variantId,
      warehouseId: warehouseId ?? this.warehouseId,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
