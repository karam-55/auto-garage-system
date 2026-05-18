class PurchaseInvoice {
  final int id;
  final int vendorId;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime? dueDate;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final int? journalEntryId;
  final DateTime createdAt;

  PurchaseInvoice({
    required this.id,
    required this.vendorId,
    required this.invoiceNumber,
    required this.issueDate,
    this.dueDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    this.journalEntryId,
    required this.createdAt,
  });

  PurchaseInvoice copyWith({
    int? id,
    int? vendorId,
    String? invoiceNumber,
    DateTime? issueDate,
    DateTime? dueDate,
    double? totalAmount,
    double? paidAmount,
    String? status,
    int? journalEntryId,
    DateTime? createdAt,
  }) {
    return PurchaseInvoice(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'invoice_number': invoiceNumber,
      'issue_date': issueDate.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'status': status,
      'journal_entry_id': journalEntryId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PurchaseInvoice.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoice(
      id: json['id'] as int,
      vendorId: json['vendor_id'] as int,
      invoiceNumber: json['invoice_number'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'] as String) 
          : null,
      totalAmount: (json['total_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num).toDouble(),
      status: json['status'] as String,
      journalEntryId: json['journal_entry_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class PurchaseInvoiceItem {
  final int id;
  final int invoiceId;
  final String inventoryVariantId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  PurchaseInvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.inventoryVariantId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  PurchaseInvoiceItem copyWith({
    int? id,
    int? invoiceId,
    String? inventoryVariantId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return PurchaseInvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      inventoryVariantId: inventoryVariantId ?? this.inventoryVariantId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'inventory_variant_id': inventoryVariantId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  factory PurchaseInvoiceItem.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoiceItem(
      id: json['id'] as int,
      invoiceId: json['invoice_id'] as int,
      inventoryVariantId: json['inventory_variant_id'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }
}
