enum AlertType {
  lowStock,
  system,
  booking;

  static AlertType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LOW_STOCK':
        return AlertType.lowStock;
      case 'SYSTEM':
        return AlertType.system;
      case 'BOOKING':
        return AlertType.booking;
      default:
        throw ArgumentError('Invalid alert type: $value');
    }
  }

  String toStringValue() {
    switch (this) {
      case AlertType.lowStock:
        return 'LOW_STOCK';
      case AlertType.system:
        return 'SYSTEM';
      case AlertType.booking:
        return 'BOOKING';
    }
  }
}

class Alert {
  final String id;
  final AlertType type;
  final String? relatedId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  Alert({
    required this.id,
    required this.type,
    this.relatedId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  Alert copyWith({
    String? id,
    AlertType? type,
    String? relatedId,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Alert(
      id: id ?? this.id,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toStringValue(),
      'relatedId': relatedId,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      type: AlertType.fromString(json['type'] as String),
      relatedId: json['relatedId'] as String?,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
