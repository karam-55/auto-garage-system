// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartSuggestion _$PartSuggestionFromJson(Map<String, dynamic> json) =>
    PartSuggestion(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      mechanicUserId: json['mechanicUserId'] as String,
      type: $enumDecode(_$PartTypeEnumMap, json['type']),
      description: json['description'] as String,
      priceSYP: (json['priceSYP'] as num?)?.toDouble(),
      status: $enumDecode(_$PartSuggestionStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PartSuggestionToJson(PartSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'mechanicUserId': instance.mechanicUserId,
      'type': _$PartTypeEnumMap[instance.type]!,
      'description': instance.description,
      'priceSYP': instance.priceSYP,
      'status': _$PartSuggestionStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PartTypeEnumMap = {
  PartType.ORIGINAL: 'ORIGINAL',
  PartType.COMMERCIAL: 'COMMERCIAL',
  PartType.USED: 'USED',
};

const _$PartSuggestionStatusEnumMap = {
  PartSuggestionStatus.PENDING_CUSTOMER_APPROVAL: 'PENDING_CUSTOMER_APPROVAL',
  PartSuggestionStatus.APPROVED: 'APPROVED',
  PartSuggestionStatus.REJECTED: 'REJECTED',
};
