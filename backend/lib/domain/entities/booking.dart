import 'package:json_annotation/json_annotation.dart';
import 'booking_status.dart';

part 'booking.g.dart';

@JsonSerializable()
class Booking {
  final String id;
  final String customerId;
  final String vehicleId;
  final BookingStatus status;
  final String publicToken;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? estimatedCompletionDate;

  Booking({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.status,
    required this.publicToken,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.estimatedCompletionDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);

  Booking copyWith({
    String? id,
    String? customerId,
    String? vehicleId,
    BookingStatus? status,
    String? publicToken,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? estimatedCompletionDate,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      status: status ?? this.status,
      publicToken: publicToken ?? this.publicToken,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedCompletionDate: estimatedCompletionDate ?? this.estimatedCompletionDate,
    );
  }
}
