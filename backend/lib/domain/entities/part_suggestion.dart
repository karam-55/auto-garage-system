import 'package:json_annotation/json_annotation.dart';
import 'part_type.dart';
import 'part_suggestion_status.dart';

part 'part_suggestion.g.dart';

@JsonSerializable()
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

  factory PartSuggestion.fromJson(Map<String, dynamic> json) => _$PartSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$PartSuggestionToJson(this);

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
