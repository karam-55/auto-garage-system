import 'part_type.dart';
import 'part_suggestion_status.dart';

class PartSuggestion {
  final String id;
  final String bookingId;
  final String mechanicUserId;
  final PartType type;
  final String description;
  final double? priceSYP;
  final PartSuggestionStatus status;
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
      bookingId: json['bookingId'] as String,
      mechanicUserId: json['mechanicUserId'] as String,
      type: PartType.fromString(json['type'] as String),
      description: json['description'] as String,
      priceSYP: json['priceSYP'] != null ? (json['priceSYP'] as num).toDouble() : null,
      status: PartSuggestionStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'mechanicUserId': mechanicUserId,
      'type': type.value,
      'description': description,
      'priceSYP': priceSYP,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PartSuggestion copyWith({
    String? id,
    String? bookingId,
    String? mechanicUserId,
    PartType? type,
    String? description,
    double? priceSYP,
    PartSuggestionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartSuggestion(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      mechanicUserId: mechanicUserId ?? this.mechanicUserId,
      type: type ?? this.type,
      description: description ?? this.description,
      priceSYP: priceSYP ?? this.priceSYP,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
