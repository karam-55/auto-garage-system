class SalaryPayment {
  final int id;
  final String userId;
  final DateTime monthYear;
  final double baseSalary;
  final int workingDays;
  final double bonuses;
  final double deductions;
  final double netSalary;
  final DateTime? paymentDate;
  final bool isPaid;
  final int? journalEntryId;

  SalaryPayment({
    required this.id,
    required this.userId,
    required this.monthYear,
    required this.baseSalary,
    required this.workingDays,
    required this.bonuses,
    required this.deductions,
    required this.netSalary,
    this.paymentDate,
    required this.isPaid,
    this.journalEntryId,
  });

  SalaryPayment copyWith({
    int? id,
    String? userId,
    DateTime? monthYear,
    double? baseSalary,
    int? workingDays,
    double? bonuses,
    double? deductions,
    double? netSalary,
    DateTime? paymentDate,
    bool? isPaid,
    int? journalEntryId,
  }) {
    return SalaryPayment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthYear: monthYear ?? this.monthYear,
      baseSalary: baseSalary ?? this.baseSalary,
      workingDays: workingDays ?? this.workingDays,
      bonuses: bonuses ?? this.bonuses,
      deductions: deductions ?? this.deductions,
      netSalary: netSalary ?? this.netSalary,
      paymentDate: paymentDate ?? this.paymentDate,
      isPaid: isPaid ?? this.isPaid,
      journalEntryId: journalEntryId ?? this.journalEntryId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'month_year': monthYear.toIso8601String(),
      'base_salary': baseSalary,
      'working_days': workingDays,
      'bonuses': bonuses,
      'deductions': deductions,
      'net_salary': netSalary,
      'payment_date': paymentDate?.toIso8601String(),
      'is_paid': isPaid,
      'journal_entry_id': journalEntryId,
    };
  }

  factory SalaryPayment.fromJson(Map<String, dynamic> json) {
    return SalaryPayment(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      monthYear: DateTime.parse(json['month_year'] as String),
      baseSalary: (json['base_salary'] as num).toDouble(),
      workingDays: json['working_days'] as int,
      bonuses: (json['bonuses'] as num?)?.toDouble() ?? 0,
      deductions: (json['deductions'] as num?)?.toDouble() ?? 0,
      netSalary: (json['net_salary'] as num).toDouble(),
      paymentDate: json['payment_date'] != null 
          ? DateTime.parse(json['payment_date'] as String) 
          : null,
      isPaid: json['is_paid'] as bool? ?? false,
      journalEntryId: json['journal_entry_id'] as int?,
    );
  }
}
