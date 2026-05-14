class BookingInvoiceData {
  final String id;
  final String bookingId;
  final Map<String, dynamic>? servicesSnapshot;
  final Map<String, dynamic>? partsSnapshot;
  final double totalPrice;
  final DateTime invoiceCreatedAt;

  BookingInvoiceData({
    required this.id,
    required this.bookingId,
    this.servicesSnapshot,
    this.partsSnapshot,
    this.totalPrice = 0,
    required this.invoiceCreatedAt,
  });

  BookingInvoiceData copyWith({
    String? id,
    String? bookingId,
    Map<String, dynamic>? servicesSnapshot,
    Map<String, dynamic>? partsSnapshot,
    double? totalPrice,
    DateTime? invoiceCreatedAt,
  }) {
    return BookingInvoiceData(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      servicesSnapshot: servicesSnapshot ?? this.servicesSnapshot,
      partsSnapshot: partsSnapshot ?? this.partsSnapshot,
      totalPrice: totalPrice ?? this.totalPrice,
      invoiceCreatedAt: invoiceCreatedAt ?? this.invoiceCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'servicesSnapshot': servicesSnapshot,
      'partsSnapshot': partsSnapshot,
      'totalPrice': totalPrice,
      'invoiceCreatedAt': invoiceCreatedAt.toIso8601String(),
    };
  }

  factory BookingInvoiceData.fromJson(Map<String, dynamic> json) {
    return BookingInvoiceData(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String? ?? json['bookingId'] as String,
      servicesSnapshot: json['servicesSnapshot'] as Map<String, dynamic>?,
      partsSnapshot: json['partsSnapshot'] as Map<String, dynamic>?,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      invoiceCreatedAt: DateTime.parse(json['invoiceCreatedAt'] as String),
    );
  }
}
