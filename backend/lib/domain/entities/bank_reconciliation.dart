class BankReconciliation {
  final int id;
  final int bankAccountId;
  final DateTime statementDate;
  final double statementBalance;
  final double? reconciledBalance;
  final bool isDone;
  final DateTime createdAt;

  BankReconciliation({
    required this.id,
    required this.bankAccountId,
    required this.statementDate,
    required this.statementBalance,
    this.reconciledBalance,
    required this.isDone,
    required this.createdAt,
  });

  BankReconciliation copyWith({
    int? id,
    int? bankAccountId,
    DateTime? statementDate,
    double? statementBalance,
    double? reconciledBalance,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return BankReconciliation(
      id: id ?? this.id,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      statementDate: statementDate ?? this.statementDate,
      statementBalance: statementBalance ?? this.statementBalance,
      reconciledBalance: reconciledBalance ?? this.reconciledBalance,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_account_id': bankAccountId,
      'statement_date': statementDate.toIso8601String(),
      'statement_balance': statementBalance,
      'reconciled_balance': reconciledBalance,
      'is_done': isDone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BankReconciliation.fromJson(Map<String, dynamic> json) {
    return BankReconciliation(
      id: json['id'] as int,
      bankAccountId: json['bank_account_id'] as int,
      statementDate: DateTime.parse(json['statement_date'] as String),
      statementBalance: (json['statement_balance'] as num).toDouble(),
      reconciledBalance: json['reconciled_balance'] != null 
          ? (json['reconciled_balance'] as num).toDouble() 
          : null,
      isDone: json['is_done'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ReconciliationLine {
  final int id;
  final int reconciliationId;
  final int journalLineId;
  final bool isMatched;

  ReconciliationLine({
    required this.id,
    required this.reconciliationId,
    required this.journalLineId,
    required this.isMatched,
  });

  ReconciliationLine copyWith({
    int? id,
    int? reconciliationId,
    int? journalLineId,
    bool? isMatched,
  }) {
    return ReconciliationLine(
      id: id ?? this.id,
      reconciliationId: reconciliationId ?? this.reconciliationId,
      journalLineId: journalLineId ?? this.journalLineId,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reconciliation_id': reconciliationId,
      'journal_line_id': journalLineId,
      'is_matched': isMatched,
    };
  }

  factory ReconciliationLine.fromJson(Map<String, dynamic> json) {
    return ReconciliationLine(
      id: json['id'] as int,
      reconciliationId: json['reconciliation_id'] as int,
      journalLineId: json['journal_line_id'] as int,
      isMatched: json['is_matched'] as bool? ?? true,
    );
  }
}
