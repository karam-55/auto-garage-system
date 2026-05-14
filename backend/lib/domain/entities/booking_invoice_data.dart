class BookingInvoiceData {
  final String id;
  final String bookingId;
  final Map<String, dynamic>? servicesSnapshot;
  final Map<String, dynamic>? partsSnapshot;
  final double totalPrice;
  final DateTime invoiceCreatedAt;
  final String? publicToken;
  final String? qrCodeUrl;

  BookingInvoiceData({
    required this.id,
    required this.bookingId,
    this.servicesSnapshot,
    this.partsSnapshot,
    this.totalPrice = 0,
    required this.invoiceCreatedAt,
    this.publicToken,
    this.qrCodeUrl,
  });

  BookingInvoiceData copyWith({
    String? id,
    String? bookingId,
    Map<String, dynamic>? servicesSnapshot,
    Map<String, dynamic>? partsSnapshot,
    double? totalPrice,
    DateTime? invoiceCreatedAt,
    String? publicToken,
    String? qrCodeUrl,
  }) {
    return BookingInvoiceData(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      servicesSnapshot: servicesSnapshot ?? this.servicesSnapshot,
      partsSnapshot: partsSnapshot ?? this.partsSnapshot,
      totalPrice: totalPrice ?? this.totalPrice,
      invoiceCreatedAt: invoiceCreatedAt ?? this.invoiceCreatedAt,
      publicToken: publicToken ?? this.publicToken,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
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
      'publicToken': publicToken,
      'qrCodeUrl': qrCodeUrl,
    };
  }

  factory BookingInvoiceData.fromJson(Map<String, dynamic> json) {
    return BookingInvoiceData(
      id: json['id'] as String,
      bookingId: json['booking_id'] is String
          ? json['booking_id'] as String
          : json['bookingId'] as String,
      servicesSnapshot: json['servicesSnapshot'] as Map<String, dynamic>?,
      partsSnapshot: json['partsSnapshot'] as Map<String, dynamic>?,
      totalPrice: (json['totalPrice'] is num ? json['totalPrice'] as num : double.tryParse(json['totalPrice'] as String? ?? '0'))?.toDouble() ?? 0,
      invoiceCreatedAt: DateTime.parse(json['invoiceCreatedAt'] as String),
      publicToken: json['publicToken'] as String?,
      qrCodeUrl: json['qrCodeUrl'] as String?,
    );
  }
}
