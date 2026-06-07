// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_contribution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BenefitContribution _$BenefitContributionFromJson(Map<String, dynamic> json) =>
    _BenefitContribution(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      type: $enumDecode(_$BenefitTypeEnumMap, json['type']),
      employeeAmount: (json['employeeAmount'] as num).toDouble(),
      employerAmount: (json['employerAmount'] as num).toDouble(),
      effectiveFrom: DateTime.parse(json['effectiveFrom'] as String),
      effectiveTo: json['effectiveTo'] == null
          ? null
          : DateTime.parse(json['effectiveTo'] as String),
      fundName: json['fundName'] as String?,
      memberNumber: json['memberNumber'] as String?,
    );

Map<String, dynamic> _$BenefitContributionToJson(
  _BenefitContribution instance,
) => <String, dynamic>{
  'id': instance.id,
  'employeeId': instance.employeeId,
  'type': _$BenefitTypeEnumMap[instance.type]!,
  'employeeAmount': instance.employeeAmount,
  'employerAmount': instance.employerAmount,
  'effectiveFrom': instance.effectiveFrom.toIso8601String(),
  'effectiveTo': instance.effectiveTo?.toIso8601String(),
  'fundName': instance.fundName,
  'memberNumber': instance.memberNumber,
};

const _$BenefitTypeEnumMap = {
  BenefitType.pension: 'pension',
  BenefitType.provident: 'provident',
  BenefitType.medicalAid: 'medicalAid',
  BenefitType.retirementAnnuity: 'retirementAnnuity',
};
