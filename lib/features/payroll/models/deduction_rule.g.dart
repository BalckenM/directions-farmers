// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deduction_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeductionRule _$DeductionRuleFromJson(Map<String, dynamic> json) =>
    _DeductionRule(
      id: json['id'] as String,
      code: json['code'] as String,
      label: json['label'] as String,
      type: $enumDecode(_$DeductionTypeEnumMap, json['type']),
      basis: $enumDecode(_$DeductionBasisEnumMap, json['basis']),
      value: (json['value'] as num).toDouble(),
      cappedAt: (json['cappedAt'] as num?)?.toDouble(),
      employeeIds: (json['employeeIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DeductionRuleToJson(_DeductionRule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'label': instance.label,
      'type': _$DeductionTypeEnumMap[instance.type]!,
      'basis': _$DeductionBasisEnumMap[instance.basis]!,
      'value': instance.value,
      'cappedAt': instance.cappedAt,
      'employeeIds': instance.employeeIds,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$DeductionTypeEnumMap = {
  DeductionType.statutory: 'statutory',
  DeductionType.voluntary: 'voluntary',
  DeductionType.benefit: 'benefit',
  DeductionType.garnishee: 'garnishee',
};

const _$DeductionBasisEnumMap = {
  DeductionBasis.percentage: 'percentage',
  DeductionBasis.fixedAmount: 'fixedAmount',
};
