// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Shift _$ShiftFromJson(Map<String, dynamic> json) => _Shift(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  employeeIds: (json['employeeIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  taskCode: json['taskCode'] as String,
  fieldOrArea: json['fieldOrArea'] as String?,
  status: $enumDecode(_$ShiftStatusEnumMap, json['status']),
  supervisorId: json['supervisorId'] as String?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ShiftToJson(_Shift instance) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'employeeIds': instance.employeeIds,
  'taskCode': instance.taskCode,
  'fieldOrArea': instance.fieldOrArea,
  'status': _$ShiftStatusEnumMap[instance.status]!,
  'supervisorId': instance.supervisorId,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$ShiftStatusEnumMap = {
  ShiftStatus.planned: 'planned',
  ShiftStatus.inProgress: 'inProgress',
  ShiftStatus.completed: 'completed',
  ShiftStatus.cancelled: 'cancelled',
};
