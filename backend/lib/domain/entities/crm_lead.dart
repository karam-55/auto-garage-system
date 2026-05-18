class CrmLead {
  final int id;
  final String? customerId;
  final String? source;
  final String status;
  final double? estimatedValue;
  final DateTime? closingDate;
  final String? assignedTo;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CrmActivity> activities;

  CrmLead({
    required this.id,
    this.customerId,
    this.source,
    required this.status,
    this.estimatedValue,
    this.closingDate,
    this.assignedTo,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.activities = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'source': source,
      'status': status,
      'estimated_value': estimatedValue,
      'closing_date': closingDate?.toIso8601String(),
      'assigned_to': assignedTo,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }

  CrmLead copyWith({
    int? id,
    String? customerId,
    String? source,
    String? status,
    double? estimatedValue,
    DateTime? closingDate,
    String? assignedTo,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CrmActivity>? activities,
  }) {
    return CrmLead(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      source: source ?? this.source,
      status: status ?? this.status,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      closingDate: closingDate ?? this.closingDate,
      assignedTo: assignedTo ?? this.assignedTo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activities: activities ?? this.activities,
    );
  }
}

class CrmActivity {
  final int id;
  final int? leadId;
  final String? customerId;
  final String activityType;
  final DateTime activityDate;
  final String? summary;
  final String? createdBy;
  final DateTime createdAt;

  CrmActivity({
    required this.id,
    this.leadId,
    this.customerId,
    required this.activityType,
    required this.activityDate,
    this.summary,
    this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'customer_id': customerId,
      'activity_type': activityType,
      'activity_date': activityDate.toIso8601String(),
      'summary': summary,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CrmActivity copyWith({
    int? id,
    int? leadId,
    String? customerId,
    String? activityType,
    DateTime? activityDate,
    String? summary,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CrmActivity(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      customerId: customerId ?? this.customerId,
      activityType: activityType ?? this.activityType,
      activityDate: activityDate ?? this.activityDate,
      summary: summary ?? this.summary,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
