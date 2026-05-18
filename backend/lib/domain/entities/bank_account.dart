class BankAccount {
  final int id;
  final String accountName;
  final String? accountNumber;
  final String? bankName;
  final double initialBalance;
  final double currentBalance;
  final bool isActive;
  final int? accountId;

  BankAccount({
    required this.id,
    required this.accountName,
    this.accountNumber,
    this.bankName,
    required this.initialBalance,
    required this.currentBalance,
    required this.isActive,
    this.accountId,
  });

  BankAccount copyWith({
    int? id,
    String? accountName,
    String? accountNumber,
    String? bankName,
    double? initialBalance,
    double? currentBalance,
    bool? isActive,
    int? accountId,
  }) {
    return BankAccount(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      accountId: accountId ?? this.accountId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_name': accountName,
      'account_number': accountNumber,
      'bank_name': bankName,
      'initial_balance': initialBalance,
      'current_balance': currentBalance,
      'is_active': isActive,
      'account_id': accountId,
    };
  }

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as int,
      accountName: json['account_name'] as String,
      accountNumber: json['account_number'] as String?,
      bankName: json['bank_name'] as String?,
      initialBalance: (json['initial_balance'] as num).toDouble(),
      currentBalance: (json['current_balance'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      accountId: json['account_id'] as int?,
    );
  }
}
