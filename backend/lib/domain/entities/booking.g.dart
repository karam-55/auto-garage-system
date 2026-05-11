// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: json['id'] as String,
  customerId: json['customerId'] as String,
  vehicleId: json['vehicleId'] as String,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  publicToken: json['publicToken'] as String,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  estimatedCompletionDate: json['estimatedCompletionDate'] == null
      ? null
      : DateTime.parse(json['estimatedCompletionDate'] as String),
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'vehicleId': instance.vehicleId,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'publicToken': instance.publicToken,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'estimatedCompletionDate': instance.estimatedCompletionDate
      ?.toIso8601String(),
};

const _$BookingStatusEnumMap = {
  BookingStatus.PENDING: 'PENDING',
  BookingStatus.IN_PROGRESS: 'IN_PROGRESS',
  BookingStatus.WAITING_PARTS: 'WAITING_PARTS',
  BookingStatus.READY: 'READY',
  BookingStatus.DELIVERED: 'DELIVERED',
  BookingStatus.CANCELLED: 'CANCELLED',
};
