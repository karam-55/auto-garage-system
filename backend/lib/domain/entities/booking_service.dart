import 'package:json_annotation/json_annotation.dart';

part 'booking_service.g.dart';

@JsonSerializable()
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

  factory BookingService.fromJson(Map<String, dynamic> json) => _$BookingServiceFromJson(json);
  Map<String, dynamic> toJson() => _$BookingServiceToJson(this);

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
