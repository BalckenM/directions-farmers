// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piecework_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PieceworkLog _$PieceworkLogFromJson(Map<String, dynamic> json) =>
    _PieceworkLog(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      date: DateTime.parse(json['date'] as String),
      shiftId: json['shiftId'] as String?,
      payrollCode: json['payrollCode'] as String,
      unit: json['unit'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      ratePerUnit: (json['ratePerUnit'] as num).toDouble(),
      recordedByUserId: json['recordedByUserId'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PieceworkLogToJson(_PieceworkLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'date': instance.date.toIso8601String(),
      'shiftId': instance.shiftId,
      'payrollCode': instance.payrollCode,
      'unit': instance.unit,
      'quantity': instance.quantity,
      'ratePerUnit': instance.ratePerUnit,
      'recordedByUserId': instance.recordedByUserId,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
