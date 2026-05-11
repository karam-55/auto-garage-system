class PartSuggestion {
  final String id;
  final String bookingId;
  final String type;
  final String description;
  final double? priceSYP;
  final String status;
  
  PartSuggestion({
    required this.id,
    required this.bookingId,
    required this.type,
    required this.description,
    this.priceSYP,
    required this.status,
  });
  
  factory PartSuggestion.fromJson(Map<String, dynamic> json) {
    return PartSuggestion(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      priceSYP: json['priceSYP']?.toDouble(),
      status: json['status'] as String,
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
        return 'بانتظار موافقتك';
      case 'APPROVED':
        return 'تمت الموافقة';
      case 'REJECTED':
        return 'تم الرفض';
      default:
        return status;
    }
  }
}
