// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmployerConfig _$EmployerConfigFromJson(Map<String, dynamic> json) =>
    _EmployerConfig(
      id: json['id'] as String?,
      farmOwnerId: json['farmOwnerId'] as String?,
      name: json['name'] as String,
      companyName: json['companyName'] as String?,
      registrationNumber: json['registrationNumber'] as String,
      payeNumber: json['payeNumber'] as String,
      taxNumber: json['taxNumber'] as String?,
      uifReferenceNumber: json['uifReferenceNumber'] as String,
      uifNumber: json['uifNumber'] as String?,
      sdlNumber: json['sdlNumber'] as String?,
      payDay: (json['payDay'] as num?)?.toInt() ?? 25,
      overtimeMultiplier:
          (json['overtimeMultiplier'] as num?)?.toDouble() ?? 1.5,
      currency: json['currency'] as String? ?? 'ZAR',
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EmployerConfigToJson(_EmployerConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'farmOwnerId': instance.farmOwnerId,
      'name': instance.name,
      'companyName': instance.companyName,
      'registrationNumber': instance.registrationNumber,
      'payeNumber': instance.payeNumber,
      'taxNumber': instance.taxNumber,
      'uifReferenceNumber': instance.uifReferenceNumber,
      'uifNumber': instance.uifNumber,
      'sdlNumber': instance.sdlNumber,
      'payDay': instance.payDay,
      'overtimeMultiplier': instance.overtimeMultiplier,
      'currency': instance.currency,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
