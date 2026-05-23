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
      id: (json['id'] as num?)?.toInt() ?? 0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      reference: json['reference']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      lines: (json['lines'] as List?)?.map((j) => JournalLine.fromJson(j as Map<String, dynamic>)).toList() ?? [],
      sourceType: json['sourceType']?.toString() ?? '',
      sourceId: json['sourceId']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      createdBy: (json['createdBy'] as num?)?.toInt(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
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
      id: (json['id'] as num?)?.toInt() ?? 0,
      accountId: (json['accountId'] as num?)?.toInt() ?? 0,
      accountName: json['accountName']?.toString() ?? json['account_name']?.toString() ?? '',
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString(),
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
