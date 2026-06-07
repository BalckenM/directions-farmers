// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaveType _$LeaveTypeFromJson(Map<String, dynamic> json) => _LeaveType(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  annualEntitlementDays: (json['annualEntitlementDays'] as num).toDouble(),
  isPaid: json['isPaid'] as bool,
  requiresApproval: json['requiresApproval'] as bool,
  colorHex: json['colorHex'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$LeaveTypeToJson(_LeaveType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'annualEntitlementDays': instance.annualEntitlementDays,
      'isPaid': instance.isPaid,
      'requiresApproval': instance.requiresApproval,
      'colorHex': instance.colorHex,
      'description': instance.description,
    };
