// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaveBalance _$LeaveBalanceFromJson(Map<String, dynamic> json) =>
    _LeaveBalance(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      leaveTypeId: json['leaveTypeId'] as String,
      leaveTypeCode: json['leaveTypeCode'] as String,
      leaveTypeName: json['leaveTypeName'] as String,
      totalEntitled: (json['totalEntitled'] as num).toDouble(),
      taken: (json['taken'] as num).toDouble(),
      pending: (json['pending'] as num).toDouble(),
      asOfDate: DateTime.parse(json['asOfDate'] as String),
    );

Map<String, dynamic> _$LeaveBalanceToJson(_LeaveBalance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'leaveTypeId': instance.leaveTypeId,
      'leaveTypeCode': instance.leaveTypeCode,
      'leaveTypeName': instance.leaveTypeName,
      'totalEntitled': instance.totalEntitled,
      'taken': instance.taken,
      'pending': instance.pending,
      'asOfDate': instance.asOfDate.toIso8601String(),
    };
