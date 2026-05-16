class PartSuggestion {
  final String id;
  final String bookingId;
  final String mechanicUserId;
  final String type;
  final String description;
  final double? priceSYP;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  PartSuggestion({
    required this.id,
    required this.bookingId,
    required this.mechanicUserId,
    required this.type,
    required this.description,
    this.priceSYP,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory PartSuggestion.fromJson(Map<String, dynamic> json) {
    return PartSuggestion(
      id: json['id'] as String? ?? '',
      bookingId: json['booking_id'] as String? ?? '',
      mechanicUserId: json['mechanic_user_id'] as String? ?? '',
      type: json['type'] as String? ?? 'GENERIC',
      description: json['description'] as String? ?? '',
      priceSYP: json['price_syp'] as double?,
      status: json['status'] as String? ?? 'PENDING_CUSTOMER_APPROVAL',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'mechanic_user_id': mechanicUserId,
      'type': type,
      'description': description,
      'price_syp': priceSYP,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
