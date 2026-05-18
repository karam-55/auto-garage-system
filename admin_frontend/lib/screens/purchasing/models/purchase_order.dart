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

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as int,
      vendorId: json['vendor_id'] as int,
      orderNumber: json['order_number'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      expectedDate: json['expected_date'] != null
          ? DateTime.parse(json['expected_date'] as String)
          : null,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => PurchaseOrderLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

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
      'lines': lines.map((e) => e.toJson()).toList(),
    };
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

  factory PurchaseOrderLine.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderLine(
      id: json['id'] as int,
      purchaseOrderId: json['purchase_order_id'] as int,
      inventoryVariantId: json['inventory_variant_id'] as String,
      quantityOrdered: json['quantity_ordered'] as int,
      quantityReceived: json['quantity_received'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

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
}
