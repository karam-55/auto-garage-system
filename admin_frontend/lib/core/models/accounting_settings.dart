class AccountingSettings {
  final int revenueServiceAccountId;
  final int revenuePartsAccountId;
  final int cogsPartsAccountId;
  final int inventoryAccountId;
  final int cashAccountId;
  final int receivableAccountId;
  final int payableAccountId;
  final double? vatPercentage;

  AccountingSettings({
    required this.revenueServiceAccountId,
    required this.revenuePartsAccountId,
    required this.cogsPartsAccountId,
    required this.inventoryAccountId,
    required this.cashAccountId,
    required this.receivableAccountId,
    required this.payableAccountId,
    this.vatPercentage,
  });

  factory AccountingSettings.fromJson(Map<String, dynamic> json) {
    return AccountingSettings(
      revenueServiceAccountId: json['revenue_service_account_id'] as int,
      revenuePartsAccountId: json['revenue_parts_account_id'] as int,
      cogsPartsAccountId: json['cogs_parts_account_id'] as int,
      inventoryAccountId: json['inventory_account_id'] as int,
      cashAccountId: json['cash_account_id'] as int,
      receivableAccountId: json['receivable_account_id'] as int,
      payableAccountId: json['payable_account_id'] as int,
      vatPercentage: json['vat_percentage'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue_service_account_id': revenueServiceAccountId,
      'revenue_parts_account_id': revenuePartsAccountId,
      'cogs_parts_account_id': cogsPartsAccountId,
      'inventory_account_id': inventoryAccountId,
      'cash_account_id': cashAccountId,
      'receivable_account_id': receivableAccountId,
      'payable_account_id': payableAccountId,
      'vat_percentage': vatPercentage,
    };
  }

  AccountingSettings copyWith({
    int? revenueServiceAccountId,
    int? revenuePartsAccountId,
    int? cogsPartsAccountId,
    int? inventoryAccountId,
    int? cashAccountId,
    int? receivableAccountId,
    int? payableAccountId,
    double? vatPercentage,
  }) {
    return AccountingSettings(
      revenueServiceAccountId: revenueServiceAccountId ?? this.revenueServiceAccountId,
      revenuePartsAccountId: revenuePartsAccountId ?? this.revenuePartsAccountId,
      cogsPartsAccountId: cogsPartsAccountId ?? this.cogsPartsAccountId,
      inventoryAccountId: inventoryAccountId ?? this.inventoryAccountId,
      cashAccountId: cashAccountId ?? this.cashAccountId,
      receivableAccountId: receivableAccountId ?? this.receivableAccountId,
      payableAccountId: payableAccountId ?? this.payableAccountId,
      vatPercentage: vatPercentage ?? this.vatPercentage,
    );
  }
}
