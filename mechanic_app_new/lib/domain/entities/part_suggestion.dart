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
}
