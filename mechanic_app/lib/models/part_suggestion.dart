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
      id: json['id'] as String,
      bookingId: json['booking_id'] as String? ?? json['bookingId'] as String? ?? '',
      mechanicUserId: json['mechanic_user_id'] as String? ?? json['mechanicUserId'] as String? ?? '',
      type: json['type'] as String,
      description: json['description'] as String,
      priceSYP: (json['price_syp'] ?? json['priceSYP'])?.toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String? ?? json['createdAt'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  
  String get typeDisplay {
    switch (type) {
      case 'ORIGINAL':
        return 'أصلي';
      case 'COMMERCIAL':
        return 'تجاري';
      case 'USED':
        return 'مستعمل';
      default:
        return type;
    }
  }
  
  String get statusDisplay {
    switch (status) {
      case 'PENDING_CUSTOMER_APPROVAL':
        return 'بانتظار موافقة الزبون';
      case 'APPROVED':
        return 'تمت الموافقة';
      case 'REJECTED':
        return 'تم الرفض';
      default:
        return status;
    }
  }
}
