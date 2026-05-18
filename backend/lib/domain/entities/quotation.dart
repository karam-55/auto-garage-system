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
      'lines': lines.map((l) => l.toJson()).toList(),
    };
  }

  Quotation copyWith({
    int? id,
    String? customerId,
    String? quotationNumber,
    DateTime? date,
    DateTime? validUntil,
    String? status,
    double? totalAmount,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<QuotationLine>? lines,
  }) {
    return Quotation(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      quotationNumber: quotationNumber ?? this.quotationNumber,
      date: date ?? this.date,
      validUntil: validUntil ?? this.validUntil,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lines: lines ?? this.lines,
    );
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

  QuotationLine copyWith({
    int? id,
    int? quotationId,
    String? serviceId,
    String? inventoryVariantId,
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? createdAt,
  }) {
    return QuotationLine(
      id: id ?? this.id,
      quotationId: quotationId ?? this.quotationId,
      serviceId: serviceId ?? this.serviceId,
      inventoryVariantId: inventoryVariantId ?? this.inventoryVariantId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
