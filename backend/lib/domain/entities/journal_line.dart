class JournalLine {
  final int id;
  final int entryId;
  final int accountId;
  final double debit;
  final double credit;
  final String? description;
  final String? sourceType;
  final String? sourceId;

  JournalLine({
    required this.id,
    required this.entryId,
    required this.accountId,
    required this.debit,
    required this.credit,
    this.description,
    this.sourceType,
    this.sourceId,
  });

  JournalLine copyWith({
    int? id,
    int? entryId,
    int? accountId,
    double? debit,
    double? credit,
    String? description,
    String? sourceType,
    String? sourceId,
  }) {
    return JournalLine(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      accountId: accountId ?? this.accountId,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      description: description ?? this.description,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entry_id': entryId,
      'account_id': accountId,
      'debit': debit,
      'credit': credit,
      'description': description,
      'source_type': sourceType,
      'source_id': sourceId,
    };
  }

  factory JournalLine.fromJson(Map<String, dynamic> json) {
    return JournalLine(
      id: json['id'] as int,
      entryId: json['entry_id'] as int,
      accountId: json['account_id'] as int,
      debit: (json['debit'] as num).toDouble(),
      credit: (json['credit'] as num).toDouble(),
      description: json['description'] as String?,
      sourceType: json['source_type'] as String?,
      sourceId: json['source_id'] as String?,
    );
  }
}
