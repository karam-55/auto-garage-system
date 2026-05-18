class PurchaseOrder {
  final int id;
  final int vendorId;
  final String orderNumber;
  final DateTime orderDate;
  final DateTime? expectedDate;
  final String status;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PurchaseOrderLine> lines;

  PurchaseOrder({
    required this.id,
    required this.vendorId,
    required this.orderNumber,
    required this.orderDate,
    this.expectedDate,
    required this.status,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lines = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'order_number': orderNumber,
      'order_date': orderDate.toIso8601String(),
      'expected_date': expectedDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'lines': lines.map((l) => l.toJson()).toList(),
    };
  }

  PurchaseOrder copyWith({
    int? id,
    int? vendorId,
    String? orderNumber,
    DateTime? orderDate,
    DateTime? expectedDate,
    String? status,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PurchaseOrderLine>? lines,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      orderNumber: orderNumber ?? this.orderNumber,
      orderDate: orderDate ?? this.orderDate,
      expectedDate: expectedDate ?? this.expectedDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lines: lines ?? this.lines,
    );
  }
}

class PurchaseOrderLine {
  final int id;
  final int purchaseOrderId;
  final String inventoryVariantId;
  final int quantityOrdered;
  final int quantityReceived;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;

  PurchaseOrderLine({
    required this.id,
    required this.purchaseOrderId,
    required this.inventoryVariantId,
    required this.quantityOrdered,
    required this.quantityReceived,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_order_id': purchaseOrderId,
      'inventory_variant_id': inventoryVariantId,
      'quantity_ordered': quantityOrdered,
      'quantity_received': quantityReceived,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PurchaseOrderLine copyWith({
    int? id,
    int? purchaseOrderId,
    String? inventoryVariantId,
    int? quantityOrdered,
    int? quantityReceived,
    double? unitPrice,
    double? totalPrice,
    DateTime? createdAt,
  }) {
    return PurchaseOrderLine(
      id: id ?? this.id,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      inventoryVariantId: inventoryVariantId ?? this.inventoryVariantId,
      quantityOrdered: quantityOrdered ?? this.quantityOrdered,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
