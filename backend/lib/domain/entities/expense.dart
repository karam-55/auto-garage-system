class Expense {
  final int id;
  final DateTime expenseDate;
  final int accountId;
  final double amount;
  final String? description;
  final String? paymentMethod;
  final String? attachmentUrl;
  final int? journalEntryId;
  final String? createdBy;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.expenseDate,
    required this.accountId,
    required this.amount,
    this.description,
    this.paymentMethod,
    this.attachmentUrl,
    this.journalEntryId,
    this.createdBy,
    required this.createdAt,
  });

  Expense copyWith({
    int? id,
    DateTime? expenseDate,
    int? accountId,
    double? amount,
    String? description,
    String? paymentMethod,
    String? attachmentUrl,
    int? journalEntryId,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      expenseDate: expenseDate ?? this.expenseDate,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_date': expenseDate.toIso8601String(),
      'account_id': accountId,
      'amount': amount,
      'description': description,
      'payment_method': paymentMethod,
      'attachment_url': attachmentUrl,
      'journal_entry_id': journalEntryId,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      expenseDate: DateTime.parse(json['expense_date'] as String),
      accountId: json['account_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      paymentMethod: json['payment_method'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      journalEntryId: json['journal_entry_id'] as int?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
