class Service {
  final String id;
  final String name;
  final String? description;
  final double priceSYP;
  final int? estimatedDurationMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    this.description,
    required this.priceSYP,
    this.estimatedDurationMinutes,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceSYP: json['priceSYP'] is num
          ? (json['priceSYP'] as num).toDouble()
          : double.tryParse(json['priceSYP']?.toString() ?? '0') ?? 0.0,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priceSYP': priceSYP,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  Service copyWith({
    String? id,
    String? name,
    String? description,
    double? priceSYP,
    int? estimatedDurationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceSYP: priceSYP ?? this.priceSYP,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
