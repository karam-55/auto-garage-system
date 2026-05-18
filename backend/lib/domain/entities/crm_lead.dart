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
    );
  }
}
