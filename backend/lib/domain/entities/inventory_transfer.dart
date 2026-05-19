class InventoryTransfer {
  final int id;
  final String? fromWarehouseId;
  final String? toWarehouseId;
  final String inventoryVariantId;
  final int quantity;
  final String status;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryTransfer({
    required this.id,
    this.fromWarehouseId,
    this.toWarehouseId,
    required this.inventoryVariantId,
    required this.quantity,
    required this.status,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_warehouse_id': fromWarehouseId,
      'to_warehouse_id': toWarehouseId,
      'inventory_variant_id': inventoryVariantId,
      'quantity': quantity,
      'status': status,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  InventoryTransfer copyWith({
    int? id,
    String? fromWarehouseId,
    String? toWarehouseId,
    String? inventoryVariantId,
    int? quantity,
    String? status,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryTransfer(
      id: id ?? this.id,
      fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      inventoryVariantId: inventoryVariantId ?? this.inventoryVariantId,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
