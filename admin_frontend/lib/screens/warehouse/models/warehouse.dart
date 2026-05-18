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

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

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

  factory InventoryVariantWarehouse.fromJson(Map<String, dynamic> json) {
    return InventoryVariantWarehouse(
      id: json['id'] as int,
      variantId: json['variant_id'] as String,
      warehouseId: json['warehouse_id'] as int,
      quantity: json['quantity'] as int,
      lowStockThreshold: json['low_stock_threshold'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

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
}
