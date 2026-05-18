class PayrollSettings {
  final int id;
  final int monthlyWorkDays;
  final int salaryPaymentDay;

  PayrollSettings({
    required this.id,
    required this.monthlyWorkDays,
    required this.salaryPaymentDay,
  });

  PayrollSettings copyWith({
    int? id,
    int? monthlyWorkDays,
    int? salaryPaymentDay,
  }) {
    return PayrollSettings(
      id: id ?? this.id,
      monthlyWorkDays: monthlyWorkDays ?? this.monthlyWorkDays,
      salaryPaymentDay: salaryPaymentDay ?? this.salaryPaymentDay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthly_work_days': monthlyWorkDays,
      'salary_payment_day': salaryPaymentDay,
    };
  }

  factory PayrollSettings.fromJson(Map<String, dynamic> json) {
    return PayrollSettings(
      id: json['id'] as int,
      monthlyWorkDays: json['monthly_work_days'] as int? ?? 30,
      salaryPaymentDay: json['salary_payment_day'] as int? ?? 28,
    );
  }
}
