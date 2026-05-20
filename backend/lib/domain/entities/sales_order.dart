class SalesOrder {
  final int id;
  final String customerId;
  final String vehicleId;
  final String orderNumber;
  final DateTime orderDate;
  final DateTime? expectedDate;
  final String status;
  final double totalAmount;
  final double taxAmount;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalesOrder({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.orderNumber,
    required this.orderDate,
    this.expectedDate,
    required this.status,
    required this.totalAmount,
    required this.taxAmount,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'vehicle_id': vehicleId,
      'order_number': orderNumber,
      'order_date': orderDate.toIso8601String(),
      'expected_date': expectedDate?.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'tax_amount': taxAmount,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SalesOrder copyWith({
    int? id,
    String? customerId,
    String? vehicleId,
    String? orderNumber,
    DateTime? orderDate,
    DateTime? expectedDate,
    String? status,
    double? totalAmount,
    double? taxAmount,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      orderNumber: orderNumber ?? this.orderNumber,
      orderDate: orderDate ?? this.orderDate,
      expectedDate: expectedDate ?? this.expectedDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
