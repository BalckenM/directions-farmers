// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_dispute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkerDispute _$WorkerDisputeFromJson(Map<String, dynamic> json) =>
    _WorkerDispute(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      type: $enumDecode(_$DisputeTypeEnumMap, json['type']),
      status: $enumDecode(_$DisputeStatusEnumMap, json['status']),
      description: json['description'] as String,
      filedAt: DateTime.parse(json['filedAt'] as String),
      relatedPayRunId: json['relatedPayRunId'] as String?,
      relatedPayslipId: json['relatedPayslipId'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedBy: json['resolvedBy'] as String?,
      resolutionNote: json['resolutionNote'] as String?,
    );

Map<String, dynamic> _$WorkerDisputeToJson(_WorkerDispute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'type': _$DisputeTypeEnumMap[instance.type]!,
      'status': _$DisputeStatusEnumMap[instance.status]!,
      'description': instance.description,
      'filedAt': instance.filedAt.toIso8601String(),
      'relatedPayRunId': instance.relatedPayRunId,
      'relatedPayslipId': instance.relatedPayslipId,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolvedBy': instance.resolvedBy,
      'resolutionNote': instance.resolutionNote,
    };

const _$DisputeTypeEnumMap = {
  DisputeType.payDiscrepancy: 'payDiscrepancy',
  DisputeType.leaveBalance: 'leaveBalance',
  DisputeType.overtimePay: 'overtimePay',
  DisputeType.deductionQuery: 'deductionQuery',
  DisputeType.other: 'other',
};

const _$DisputeStatusEnumMap = {
  DisputeStatus.open: 'open',
  DisputeStatus.underReview: 'underReview',
  DisputeStatus.resolved: 'resolved',
  DisputeStatus.dismissed: 'dismissed',
};
