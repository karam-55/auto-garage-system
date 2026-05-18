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

  factory CrmLead.fromJson(Map<String, dynamic> json) {
    return CrmLead(
      id: json['id'] as int,
      customerId: json['customer_id'] as String?,
      source: json['source'] as String?,
      status: json['status'] as String,
      estimatedValue: json['estimated_value'] != null
          ? (json['estimated_value'] as num).toDouble()
          : null,
      closingDate: json['closing_date'] != null
          ? DateTime.parse(json['closing_date'] as String)
          : null,
      assignedTo: json['assigned_to'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => CrmActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

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
      'activities': activities.map((e) => e.toJson()).toList(),
    };
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

  factory CrmActivity.fromJson(Map<String, dynamic> json) {
    return CrmActivity(
      id: json['id'] as int,
      leadId: json['lead_id'] as int?,
      customerId: json['customer_id'] as String?,
      activityType: json['activity_type'] as String,
      activityDate: DateTime.parse(json['activity_date'] as String),
      summary: json['summary'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

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
}
