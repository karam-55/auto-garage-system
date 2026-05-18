class EmployeeContract {
  final int id;
  final String userId;
  final String contractType;
  final DateTime startDate;
  final DateTime? endDate;
  final double? baseSalary;
  final String? benefits;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeContract({
    required this.id,
    required this.userId,
    required this.contractType,
    required this.startDate,
    this.endDate,
    this.baseSalary,
    this.benefits,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeContract.fromJson(Map<String, dynamic> json) {
    return EmployeeContract(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      contractType: json['contract_type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      baseSalary: json['base_salary'] != null
          ? (json['base_salary'] as num).toDouble()
          : null,
      benefits: json['benefits'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'contract_type': contractType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'base_salary': baseSalary,
      'benefits': benefits,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
