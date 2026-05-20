class Account {
  final int id;
  final String code;
  final String nameAr;
  final String nameEn;
  final String accountType;
  final int? parentId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Account>? children;

  Account({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.accountType,
    this.parentId,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.children,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as int,
      code: json['code']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? json['name_ar']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? json['name_en']?.toString() ?? '',
      accountType: json['accountType']?.toString() ?? json['account_type']?.toString() ?? 'asset',
      parentId: json['parentId'] as int? ?? json['parent_id'] as int?,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? DateTime.now().toIso8601String())
          : null,
      children: json['children'] != null
          ? (json['children'] as List).map((j) => Account.fromJson(j as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'accountType': accountType,
      'parentId': parentId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Account copyWith({
    int? id,
    String? code,
    String? nameAr,
    String? nameEn,
    String? accountType,
    int? parentId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Account>? children,
  }) {
    return Account(
      id: id ?? this.id,
      code: code ?? this.code,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      accountType: accountType ?? this.accountType,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      children: children ?? this.children,
    );
  }
}
