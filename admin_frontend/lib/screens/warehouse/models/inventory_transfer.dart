class InventoryTransfer {
  final int id;
  final String variantId;
  final int fromWarehouseId;
  final int toWarehouseId;
  final int quantity;
  final DateTime transferDate;
  final String status;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryTransfer({
    required this.id,
    required this.variantId,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    required this.quantity,
    required this.transferDate,
    required this.status,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryTransfer.fromJson(Map<String, dynamic> json) {
    return InventoryTransfer(
      id: json['id'] as int,
      variantId: json['variant_id'] as String,
      fromWarehouseId: json['from_warehouse_id'] as int,
      toWarehouseId: json['to_warehouse_id'] as int,
      quantity: json['quantity'] as int,
      transferDate: DateTime.parse(json['transfer_date'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variant_id': variantId,
      'from_warehouse_id': fromWarehouseId,
      'to_warehouse_id': toWarehouseId,
      'quantity': quantity,
      'transfer_date': transferDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
