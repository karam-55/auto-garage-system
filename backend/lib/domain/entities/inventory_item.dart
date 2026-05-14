class InventoryItem {
  final String id;
  final String name;
  final String? category;
  final String? unit;
  final int lowStockThreshold;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InventoryItem({
    required this.id,
    required this.name,
    this.category,
    this.unit,
    this.lowStockThreshold = 5,
    required this.createdAt,
    this.updatedAt,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    String? unit,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'lowStockThreshold': lowStockThreshold,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      unit: json['unit'] as String?,
      lowStockThreshold: json['lowStockThreshold'] as int? ?? 5,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }
}
