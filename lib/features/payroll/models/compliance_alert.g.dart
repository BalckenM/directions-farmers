// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compliance_alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ComplianceAlert _$ComplianceAlertFromJson(Map<String, dynamic> json) =>
    _ComplianceAlert(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: $enumDecode(_$ComplianceSeverityEnumMap, json['severity']),
      employeeId: json['employeeId'] as String?,
      payRunId: json['payRunId'] as String?,
      isResolved: json['isResolved'] as bool,
      resolvedByUserId: json['resolvedByUserId'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolution: json['resolution'] as String?,
      raisedAt: DateTime.parse(json['raisedAt'] as String),
    );

Map<String, dynamic> _$ComplianceAlertToJson(_ComplianceAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'severity': _$ComplianceSeverityEnumMap[instance.severity]!,
      'employeeId': instance.employeeId,
      'payRunId': instance.payRunId,
      'isResolved': instance.isResolved,
      'resolvedByUserId': instance.resolvedByUserId,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolution': instance.resolution,
      'raisedAt': instance.raisedAt.toIso8601String(),
    };

const _$ComplianceSeverityEnumMap = {
  ComplianceSeverity.critical: 'critical',
  ComplianceSeverity.warning: 'warning',
  ComplianceSeverity.info: 'info',
};
