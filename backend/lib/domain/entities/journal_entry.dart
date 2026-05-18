class JournalEntry {
  final int id;
  final DateTime entryDate;
  final String? reference;
  final String? description;
  final bool isReversing;
  final DateTime? reversingDate;
  final bool isReversed;
  final String? createdBy;
  final DateTime createdAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final int? fiscalPeriodId;

  JournalEntry({
    required this.id,
    required this.entryDate,
    this.reference,
    this.description,
    required this.isReversing,
    this.reversingDate,
    required this.isReversed,
    this.createdBy,
    required this.createdAt,
    this.approvedBy,
    this.approvedAt,
    this.fiscalPeriodId,
  });

  JournalEntry copyWith({
    int? id,
    DateTime? entryDate,
    String? reference,
    String? description,
    bool? isReversing,
    DateTime? reversingDate,
    bool? isReversed,
    String? createdBy,
    DateTime? createdAt,
    String? approvedBy,
    DateTime? approvedAt,
    int? fiscalPeriodId,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      entryDate: entryDate ?? this.entryDate,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      isReversing: isReversing ?? this.isReversing,
      reversingDate: reversingDate ?? this.reversingDate,
      isReversed: isReversed ?? this.isReversed,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      fiscalPeriodId: fiscalPeriodId ?? this.fiscalPeriodId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entry_date': entryDate.toIso8601String(),
      'reference': reference,
      'description': description,
      'is_reversing': isReversing,
      'reversing_date': reversingDate?.toIso8601String(),
      'is_reversed': isReversed,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'fiscal_period_id': fiscalPeriodId,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as int,
      entryDate: DateTime.parse(json['entry_date'] as String),
      reference: json['reference'] as String?,
      description: json['description'] as String?,
      isReversing: json['is_reversing'] as bool? ?? false,
      reversingDate: json['reversing_date'] != null 
          ? DateTime.parse(json['reversing_date'] as String) 
          : null,
      isReversed: json['is_reversed'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] != null 
          ? DateTime.parse(json['approved_at'] as String) 
          : null,
      fiscalPeriodId: json['fiscal_period_id'] as int?,
    );
  }
}
