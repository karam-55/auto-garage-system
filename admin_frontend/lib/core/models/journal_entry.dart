class JournalEntry {
  final int id;
  final DateTime date;
  final String? reference;
  final String? description;
  final List<JournalLine> lines;
  final String? sourceType;
  final String? sourceId;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final bool isReversing;
  final DateTime? reversingDate;
  final bool isReversed;
  final String? approvedBy;
  final DateTime? approvedAt;
  final int? fiscalPeriodId;

  JournalEntry({
    required this.id,
    required this.date,
    this.reference,
    this.description,
    required this.lines,
    this.sourceType,
    this.sourceId,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.isReversing = false,
    this.reversingDate,
    this.isReversed = false,
    this.approvedBy,
    this.approvedAt,
    this.fiscalPeriodId,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase (API) and snake_case (legacy)
    final dateStr = json['entryDate']?.toString() ?? json['date']?.toString() ?? json['entry_date']?.toString() ?? '';
    final createdAtStr = json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '';
    final updatedAtStr = json['updatedAt']?.toString() ?? json['updated_at']?.toString();
    final reversingDateStr = json['reversingDate']?.toString() ?? json['reversing_date']?.toString();
    final approvedAtStr = json['approvedAt']?.toString() ?? json['approved_at']?.toString();
    
    return JournalEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      date: DateTime.tryParse(dateStr) ?? DateTime.now(),
      reference: json['reference']?.toString(),
      description: json['description']?.toString(),
      lines: (json['lines'] as List?)?.map((j) => JournalLine.fromJson(j as Map<String, dynamic>)).toList() ?? [],
      sourceType: json['sourceType']?.toString() ?? json['source_type']?.toString(),
      sourceId: json['sourceId']?.toString() ?? json['source_id']?.toString(),
      createdAt: DateTime.tryParse(createdAtStr) ?? DateTime.now(),
      createdBy: json['createdBy']?.toString() ?? json['created_by']?.toString(),
      updatedAt: updatedAtStr != null ? DateTime.tryParse(updatedAtStr) : null,
      isReversing: json['isReversing'] ?? json['is_reversing'] ?? false,
      reversingDate: reversingDateStr != null ? DateTime.tryParse(reversingDateStr) : null,
      isReversed: json['isReversed'] ?? json['is_reversed'] ?? false,
      approvedBy: json['approvedBy']?.toString() ?? json['approved_by']?.toString(),
      approvedAt: approvedAtStr != null ? DateTime.tryParse(approvedAtStr) : null,
      fiscalPeriodId: (json['fiscalPeriodId'] as num?)?.toInt() ?? (json['fiscal_period_id'] as num?)?.toInt(),
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
  final int? entryId;
  final int accountId;
  final String? accountName;
  final double debit;
  final double credit;
  final String? description;
  final String? sourceType;
  final String? sourceId;

  JournalLine({
    required this.id,
    this.entryId,
    required this.accountId,
    this.accountName,
    required this.debit,
    required this.credit,
    this.description,
    this.sourceType,
    this.sourceId,
  });

  factory JournalLine.fromJson(Map<String, dynamic> json) {
    return JournalLine(
      id: (json['id'] as num?)?.toInt() ?? 0,
      entryId: (json['entryId'] as num?)?.toInt() ?? (json['entry_id'] as num?)?.toInt(),
      accountId: (json['accountId'] as num?)?.toInt() ?? (json['account_id'] as num?)?.toInt() ?? 0,
      accountName: json['accountName']?.toString() ?? json['account_name']?.toString(),
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString(),
      sourceType: json['sourceType']?.toString() ?? json['source_type']?.toString(),
      sourceId: json['sourceId']?.toString() ?? json['source_id']?.toString(),
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
