class CrmActivity {
  final int id;
  final int leadId;
  final String type;
  final String description;
  final DateTime activityDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CrmActivity({
    required this.id,
    required this.leadId,
    required this.type,
    required this.description,
    required this.activityDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CrmActivity.fromJson(Map<String, dynamic> json) {
    return CrmActivity(
      id: json['id'] as int,
      leadId: json['lead_id'] as int,
      type: json['type'] as String,
      description: json['description'] as String,
      activityDate: DateTime.parse(json['activity_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'type': type,
      'description': description,
      'activity_date': activityDate.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
