class ManufacturingOrder {
  final int? id;
  final String orderNumber;
  final int bomId;
  final String status; // pending, in_progress, completed, cancelled
  final int quantity;
  final DateTime? startDate;
  final DateTime? expectedCompletionDate;
  final DateTime? actualCompletionDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ManufacturingOrder({
    this.id,
    required this.orderNumber,
    required this.bomId,
    this.status = 'pending',
    required this.quantity,
    this.startDate,
    this.expectedCompletionDate,
    this.actualCompletionDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  ManufacturingOrder copyWith({
    int? id,
    String? orderNumber,
    int? bomId,
    String? status,
    int? quantity,
    DateTime? startDate,
    DateTime? expectedCompletionDate,
    DateTime? actualCompletionDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ManufacturingOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      bomId: bomId ?? this.bomId,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      startDate: startDate ?? this.startDate,
      expectedCompletionDate: expectedCompletionDate ?? this.expectedCompletionDate,
      actualCompletionDate: actualCompletionDate ?? this.actualCompletionDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'bom_id': bomId,
      'status': status,
      'quantity': quantity,
      'start_date': startDate?.toIso8601String(),
      'expected_completion_date': expectedCompletionDate?.toIso8601String(),
      'actual_completion_date': actualCompletionDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ManufacturingOrder.fromJson(Map<String, dynamic> json) {
    return ManufacturingOrder(
      id: json['id'] as int?,
      orderNumber: json['order_number'] as String,
      bomId: json['bom_id'] as int,
      status: json['status'] as String? ?? 'pending',
      quantity: json['quantity'] as int,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      expectedCompletionDate: json['expected_completion_date'] != null ? DateTime.parse(json['expected_completion_date'] as String) : null,
      actualCompletionDate: json['actual_completion_date'] != null ? DateTime.parse(json['actual_completion_date'] as String) : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }
}
