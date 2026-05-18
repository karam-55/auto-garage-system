class JournalEntry {
  final int id;
  final DateTime date;
  final String reference;
  final String description;
  final List<JournalLine> lines;
  final String sourceType;
  final String? sourceId;
  final DateTime createdAt;
  final int? createdBy;
  final DateTime? updatedAt;

  JournalEntry({
    required this.id,
    required this.date,
    required this.reference,
    required this.description,
    required this.lines,
    required this.sourceType,
    this.sourceId,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      reference: json['reference'] as String,
      description: json['description'] as String,
      lines: (json['lines'] as List).map((j) => JournalLine.fromJson(j as Map<String, dynamic>)).toList(),
      sourceType: json['sourceType'] as String,
      sourceId: json['sourceId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as int?,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'reference': reference,
      'description': description,
      'lines': lines.map((l) => l.toJson()).toList(),
      'sourceType': sourceType,
      'sourceId': sourceId,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  double get totalDebit => lines.fold(0.0, (sum, line) => sum + line.debit);
  double get totalCredit => lines.fold(0.0, (sum, line) => sum + line.credit);
}

class JournalLine {
  final int id;
  final int accountId;
  final String accountName;
  final double debit;
  final double credit;
  final String? description;

  JournalLine({
    required this.id,
    required this.accountId,
    required this.accountName,
    required this.debit,
    required this.credit,
    this.description,
  });

  factory JournalLine.fromJson(Map<String, dynamic> json) {
    return JournalLine(
      id: json['id'] as int,
      accountId: json['accountId'] as int,
      accountName: json['accountName'] as String? ?? json['account_name'] as String? ?? '',
      debit: (json['debit'] as num).toDouble(),
      credit: (json['credit'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'debit': debit,
      'credit': credit,
      'description': description,
    };
  }
}
