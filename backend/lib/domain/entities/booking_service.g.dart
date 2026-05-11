// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingService _$BookingServiceFromJson(Map<String, dynamic> json) =>
    BookingService(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      serviceId: json['serviceId'] as String,
      priceSYP: (json['priceSYP'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BookingServiceToJson(BookingService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'serviceId': instance.serviceId,
      'priceSYP': instance.priceSYP,
      'notes': instance.notes,
    };
