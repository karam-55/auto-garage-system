// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mechanic_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MechanicAssignment _$MechanicAssignmentFromJson(Map<String, dynamic> json) =>
    MechanicAssignment(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      mechanicUserId: json['mechanicUserId'] as String,
      status: $enumDecode(_$MechanicAssignmentStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MechanicAssignmentToJson(MechanicAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'mechanicUserId': instance.mechanicUserId,
      'status': _$MechanicAssignmentStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'assignedAt': instance.assignedAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$MechanicAssignmentStatusEnumMap = {
  MechanicAssignmentStatus.ASSIGNED: 'ASSIGNED',
  MechanicAssignmentStatus.IN_PROGRESS: 'IN_PROGRESS',
  MechanicAssignmentStatus.WAITING_PARTS: 'WAITING_PARTS',
  MechanicAssignmentStatus.READY: 'READY',
  MechanicAssignmentStatus.DELIVERED: 'DELIVERED',
};
