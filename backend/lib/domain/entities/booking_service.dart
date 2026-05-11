class BookingService {
  final String id;
  final String bookingId;
  final String serviceId;
  final double priceSYP;
  final String? notes;

  BookingService({
    required this.id,
    required this.bookingId,
    required this.serviceId,
    required this.priceSYP,
    this.notes,
  });

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      serviceId: json['serviceId'] as String,
      priceSYP: (json['priceSYP'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'serviceId': serviceId,
      'priceSYP': priceSYP,
      'notes': notes,
    };
  }

  BookingService copyWith({
    String? id,
    String? bookingId,
    String? serviceId,
    double? priceSYP,
    String? notes,
  }) {
    return BookingService(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      serviceId: serviceId ?? this.serviceId,
      priceSYP: priceSYP ?? this.priceSYP,
      notes: notes ?? this.notes,
    );
  }
}
