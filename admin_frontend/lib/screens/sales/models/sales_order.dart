class SalesOrder {
  final int id;
  final String customerId;
  final String orderNumber;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String status;
  final double totalAmount;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SalesOrderLine> lines;

  SalesOrder({
    required this.id,
    required this.customerId,
    required this.orderNumber,
    required this.orderDate,
    this.deliveryDate,
    required this.status,
    required this.totalAmount,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lines = const [],
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      id: json['id'] as int,
      customerId: json['customer_id'] as String,
      orderNumber: json['order_number'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'] as String)
          : null,
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => SalesOrderLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'order_number': orderNumber,
      'order_date': orderDate.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'lines': lines.map((e) => e.toJson()).toList(),
    };
  }
}

class SalesOrderLine {
  final int id;
  final int salesOrderId;
  final String? serviceId;
  final String? inventoryVariantId;
  final String? description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;

  SalesOrderLine({
    required this.id,
    required this.salesOrderId,
    this.serviceId,
    this.inventoryVariantId,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
  });

  factory SalesOrderLine.fromJson(Map<String, dynamic> json) {
    return SalesOrderLine(
      id: json['id'] as int,
      salesOrderId: json['sales_order_id'] as int,
      serviceId: json['service_id'] as String?,
      inventoryVariantId: json['inventory_variant_id'] as String?,
      description: json['description'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sales_order_id': salesOrderId,
      'service_id': serviceId,
      'inventory_variant_id': inventoryVariantId,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
