// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garnishee_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GarnisheeOrder _$GarnisheeOrderFromJson(Map<String, dynamic> json) =>
    _GarnisheeOrder(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      courtOrderRef: json['courtOrderRef'] as String,
      creditorName: json['creditorName'] as String,
      monthlyDeductionAmount: (json['monthlyDeductionAmount'] as num)
          .toDouble(),
      totalOwed: (json['totalOwed'] as num).toDouble(),
      amountDeducted: (json['amountDeducted'] as num).toDouble(),
      status: $enumDecode(_$GarnisheeStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      satisfiedAt: json['satisfiedAt'] == null
          ? null
          : DateTime.parse(json['satisfiedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$GarnisheeOrderToJson(_GarnisheeOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'courtOrderRef': instance.courtOrderRef,
      'creditorName': instance.creditorName,
      'monthlyDeductionAmount': instance.monthlyDeductionAmount,
      'totalOwed': instance.totalOwed,
      'amountDeducted': instance.amountDeducted,
      'status': _$GarnisheeStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'satisfiedAt': instance.satisfiedAt?.toIso8601String(),
      'notes': instance.notes,
    };

const _$GarnisheeStatusEnumMap = {
  GarnisheeStatus.active: 'active',
  GarnisheeStatus.satisfied: 'satisfied',
  GarnisheeStatus.suspended: 'suspended',
  GarnisheeStatus.cancelled: 'cancelled',
};
