class CompanySettings {
  final int id;
  final String companyName;
  final String? companyLogoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CompanySettings({
    required this.id,
    required this.companyName,
    this.companyLogoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      id: json['id'] as int,
      companyName: json['companyName'] as String,
      companyLogoUrl: json['companyLogoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'companyLogoUrl': companyLogoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CompanySettings copyWith({
    int? id,
    String? companyName,
    String? companyLogoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanySettings(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
