class AccountType {
  final String value;

  const AccountType(this.value);

  static const asset = AccountType('asset');
  static const liability = AccountType('liability');
  static const equity = AccountType('equity');
  static const revenue = AccountType('revenue');
  static const expense = AccountType('expense');
  static const cogs = AccountType('cogs');

  static AccountType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'asset':
        return asset;
      case 'liability':
        return liability;
      case 'equity':
        return equity;
      case 'revenue':
        return revenue;
      case 'expense':
        return expense;
      case 'cogs':
        return cogs;
      default:
        throw ArgumentError('Invalid AccountType: $value');
    }
  }

  @override
  String toString() => value;
}

class Account {
  final int id;
  final String code;
  final String nameAr;
  final String nameEn;
  final int? parentId;
  final AccountType accountType;
  final bool isActive;
  final DateTime createdAt;

  Account({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    this.parentId,
    required this.accountType,
    required this.isActive,
    required this.createdAt,
  });

  Account copyWith({
    int? id,
    String? code,
    String? nameAr,
    String? nameEn,
    int? parentId,
    AccountType? accountType,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      code: code ?? this.code,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      parentId: parentId ?? this.parentId,
      accountType: accountType ?? this.accountType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name_ar': nameAr,
      'name_en': nameEn,
      'parent_id': parentId,
      'account_type': accountType.value,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as int,
      code: json['code'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      parentId: json['parent_id'] as int?,
      accountType: AccountType.fromString(json['account_type'] as String),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
