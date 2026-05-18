class FiscalPeriod {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isClosed;
  final DateTime createdAt;

  FiscalPeriod({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isClosed,
    required this.createdAt,
  });

  FiscalPeriod copyWith({
    int? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isClosed,
    DateTime? createdAt,
  }) {
    return FiscalPeriod(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isClosed: isClosed ?? this.isClosed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_closed': isClosed,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FiscalPeriod.fromJson(Map<String, dynamic> json) {
    return FiscalPeriod(
      id: json['id'] as int,
      name: json['name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isClosed: json['is_closed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
