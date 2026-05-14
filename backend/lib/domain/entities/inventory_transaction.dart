enum TransactionType {
  consume,
  add,
  return_;

  static TransactionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CONSUME':
        return TransactionType.consume;
      case 'ADD':
        return TransactionType.add;
      case 'RETURN':
        return TransactionType.return_;
      default:
        throw ArgumentError('Invalid transaction type: $value');
    }
  }

  String toStringValue() {
    switch (this) {
      case TransactionType.consume:
        return 'CONSUME';
      case TransactionType.add:
        return 'ADD';
      case TransactionType.return_:
        return 'RETURN';
    }
  }
}

class InventoryTransaction {
  final String id;
  final String itemId;
  final String variantId;
  final String? bookingId;
  final String? mechanicId;
  final TransactionType type;
  final int quantity;
  final String? notes;
  final DateTime createdAt;

  InventoryTransaction({
    required this.id,
    required this.itemId,
    required this.variantId,
    this.bookingId,
    this.mechanicId,
    required this.type,
    required this.quantity,
    this.notes,
    required this.createdAt,
  });

  InventoryTransaction copyWith({
    String? id,
    String? itemId,
    String? variantId,
    String? bookingId,
    String? mechanicId,
    TransactionType? type,
    int? quantity,
    String? notes,
    DateTime? createdAt,
  }) {
    return InventoryTransaction(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      variantId: variantId ?? this.variantId,
      bookingId: bookingId ?? this.bookingId,
      mechanicId: mechanicId ?? this.mechanicId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'variantId': variantId,
      'bookingId': bookingId,
      'mechanicId': mechanicId,
      'type': type.toStringValue(),
      'quantity': quantity,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      id: json['id'] as String,
      itemId: json['item_id'] as String? ?? json['itemId'] as String,
      variantId: json['variant_id'] as String? ?? json['variantId'] as String,
      bookingId: json['bookingId'] as String?,
      mechanicId: json['mechanicId'] as String?,
      type: TransactionType.fromString(json['type'] as String),
      quantity: json['quantity'] as int,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
