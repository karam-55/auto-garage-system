class CrmActivity {
  final int? id;
  final int leadId;
  final String customerId;
  final String activityType; // call, email, meeting, note
  final String description;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  CrmActivity({
    this.id,
    required this.leadId,
    required this.customerId,
    required this.activityType,
    required this.description,
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  CrmActivity copyWith({
    int? id,
    int? leadId,
    String? customerId,
    String? activityType,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return CrmActivity(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      customerId: customerId ?? this.customerId,
      activityType: activityType ?? this.activityType,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'customer_id': customerId,
      'activity_type': activityType,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
    };
  }

  factory CrmActivity.fromJson(Map<String, dynamic> json) {
    return CrmActivity(
      id: json['id'] as int?,
      leadId: json['lead_id'] as int,
      customerId: json['customer_id'] as String,
      activityType: json['activity_type'] as String,
      description: json['description'] as String,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      createdBy: json['created_by'] as String?,
    );
  }
}
