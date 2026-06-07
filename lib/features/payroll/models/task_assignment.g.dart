// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskAssignment _$TaskAssignmentFromJson(Map<String, dynamic> json) =>
    _TaskAssignment(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      date: DateTime.parse(json['date'] as String),
      shiftId: json['shiftId'] as String?,
      payrollCode: json['payrollCode'] as String,
      description: json['description'] as String,
      fieldOrArea: json['fieldOrArea'] as String?,
      status: $enumDecode(_$TaskAssignmentStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TaskAssignmentToJson(_TaskAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'date': instance.date.toIso8601String(),
      'shiftId': instance.shiftId,
      'payrollCode': instance.payrollCode,
      'description': instance.description,
      'fieldOrArea': instance.fieldOrArea,
      'status': _$TaskAssignmentStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TaskAssignmentStatusEnumMap = {
  TaskAssignmentStatus.assigned: 'assigned',
  TaskAssignmentStatus.inProgress: 'inProgress',
  TaskAssignmentStatus.completed: 'completed',
  TaskAssignmentStatus.cancelled: 'cancelled',
};
