import 'booking_status.dart';

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

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      vehicleId: json['vehicleId'] as String,
      status: BookingStatus.fromString(json['status'] as String),
      publicToken: json['publicToken'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      estimatedCompletionDate: json['estimatedCompletionDate'] != null
          ? DateTime.parse(json['estimatedCompletionDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'vehicleId': vehicleId,
      'status': status.value,
      'publicToken': publicToken,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'estimatedCompletionDate': estimatedCompletionDate?.toIso8601String(),
    };
  }

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
