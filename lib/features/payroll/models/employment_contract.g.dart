// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employment_contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmploymentContract _$EmploymentContractFromJson(Map<String, dynamic> json) =>
    _EmploymentContract(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      type: $enumDecode(_$ContractTypeEnumMap, json['type']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      jobDescription: json['jobDescription'] as String,
      grossMonthlySalary: (json['grossMonthlySalary'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'ZAR',
      status: $enumDecode(_$ContractStatusEnumMap, json['status']),
      signedAt: json['signedAt'] == null
          ? null
          : DateTime.parse(json['signedAt'] as String),
      signedByName: json['signedByName'] as String?,
      signatureImageBase64: json['signatureImageBase64'] as String?,
      pdfPath: json['pdfPath'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$EmploymentContractToJson(_EmploymentContract instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'type': _$ContractTypeEnumMap[instance.type]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'jobDescription': instance.jobDescription,
      'grossMonthlySalary': instance.grossMonthlySalary,
      'currency': instance.currency,
      'status': _$ContractStatusEnumMap[instance.status]!,
      'signedAt': instance.signedAt?.toIso8601String(),
      'signedByName': instance.signedByName,
      'signatureImageBase64': instance.signatureImageBase64,
      'pdfPath': instance.pdfPath,
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ContractTypeEnumMap = {
  ContractType.permanent: 'permanent',
  ContractType.fixedTerm: 'fixedTerm',
  ContractType.seasonal: 'seasonal',
  ContractType.casual: 'casual',
};

const _$ContractStatusEnumMap = {
  ContractStatus.draft: 'draft',
  ContractStatus.signed: 'signed',
  ContractStatus.expired: 'expired',
  ContractStatus.terminated: 'terminated',
};
