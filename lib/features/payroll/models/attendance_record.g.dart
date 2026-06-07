// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    _AttendanceRecord(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      date: DateTime.parse(json['date'] as String),
      status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
      clockInTime: json['clockInTime'] as String?,
      clockOutTime: json['clockOutTime'] as String?,
      recordedByUserId: json['recordedByUserId'] as String,
      method: $enumDecode(_$AttendanceMethodEnumMap, json['method']),
      hoursWorked: (json['hoursWorked'] as num?)?.toDouble(),
      overtimeHours: (json['overtimeHours'] as num?)?.toDouble(),
      nightShiftHours: (json['nightShiftHours'] as num?)?.toDouble(),
      shiftId: json['shiftId'] as String?,
      leaveRequestId: json['leaveRequestId'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AttendanceRecordToJson(_AttendanceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'date': instance.date.toIso8601String(),
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'clockInTime': instance.clockInTime,
      'clockOutTime': instance.clockOutTime,
      'recordedByUserId': instance.recordedByUserId,
      'method': _$AttendanceMethodEnumMap[instance.method]!,
      'hoursWorked': instance.hoursWorked,
      'overtimeHours': instance.overtimeHours,
      'nightShiftHours': instance.nightShiftHours,
      'shiftId': instance.shiftId,
      'leaveRequestId': instance.leaveRequestId,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.present: 'present',
  AttendanceStatus.absent: 'absent',
  AttendanceStatus.late: 'late',
  AttendanceStatus.onLeave: 'onLeave',
  AttendanceStatus.halfDay: 'halfDay',
  AttendanceStatus.publicHoliday: 'publicHoliday',
};

const _$AttendanceMethodEnumMap = {
  AttendanceMethod.manual: 'manual',
  AttendanceMethod.gps: 'gps',
  AttendanceMethod.qrCode: 'qrCode',
  AttendanceMethod.biometric: 'biometric',
};
