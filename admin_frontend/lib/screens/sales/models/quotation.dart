class Quotation {
  final int id;
  final String customerId;
  final String quotationNumber;
  final DateTime date;
  final DateTime? validUntil;
  final String status;
  final double totalAmount;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuotationLine> lines;

  Quotation({
    required this.id,
    required this.customerId,
    required this.quotationNumber,
    required this.date,
    this.validUntil,
    required this.status,
    required this.totalAmount,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lines = const [],
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'] as int,
      customerId: json['customer_id'] as String,
      quotationNumber: json['quotation_number'] as String,
      date: DateTime.parse(json['date'] as String),
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => QuotationLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'quotation_number': quotationNumber,
      'date': date.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
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

class QuotationLine {
  final int id;
  final int quotationId;
  final String? serviceId;
  final String? inventoryVariantId;
  final String? description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;

  QuotationLine({
    required this.id,
    required this.quotationId,
    this.serviceId,
    this.inventoryVariantId,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
  });

  factory QuotationLine.fromJson(Map<String, dynamic> json) {
    return QuotationLine(
      id: json['id'] as int,
      quotationId: json['quotation_id'] as int,
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
      'quotation_id': quotationId,
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
