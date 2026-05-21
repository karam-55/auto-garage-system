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
  final double? totalPrice;
  final double? amountPaid;
  final double? amountRemaining;
  final String? paymentStatus;

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
    this.totalPrice,
    this.amountPaid,
    this.amountRemaining,
    this.paymentStatus,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      vehicleId: json['vehicleId'] as String,
      status: BookingStatus.fromString(json['status'] as String),
      publicToken: json['publicToken'] as String,
      notes: json['notes'] is String ? json['notes'] as String? : null,
      createdAt: json['createdAt'] is DateTime ? json['createdAt'] as DateTime : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] is DateTime ? json['updatedAt'] as DateTime : DateTime.parse(json['updatedAt'] as String))
          : null,
      estimatedCompletionDate: json['estimatedCompletionDate'] != null
          ? (json['estimatedCompletionDate'] is DateTime ? json['estimatedCompletionDate'] as DateTime : DateTime.parse(json['estimatedCompletionDate'] as String))
          : null,
      totalPrice: json['totalPrice'] is num ? (json['totalPrice'] as num).toDouble() : null,
      amountPaid: json['amountPaid'] is num ? (json['amountPaid'] as num).toDouble() : null,
      amountRemaining: json['amountRemaining'] is num ? (json['amountRemaining'] as num).toDouble() : null,
      paymentStatus: json['paymentStatus'] as String?,
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
      'totalPrice': totalPrice,
      'amountPaid': amountPaid,
      'amountRemaining': amountRemaining,
      'paymentStatus': paymentStatus,
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
    double? totalPrice,
    double? amountPaid,
    double? amountRemaining,
    String? paymentStatus,
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
      totalPrice: totalPrice ?? this.totalPrice,
      amountPaid: amountPaid ?? this.amountPaid,
      amountRemaining: amountRemaining ?? this.amountRemaining,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}
