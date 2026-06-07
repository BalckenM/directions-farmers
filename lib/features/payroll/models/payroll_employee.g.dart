// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayrollEmployee _$PayrollEmployeeFromJson(Map<String, dynamic> json) =>
    _PayrollEmployee(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      idOrPassportNumber: json['idOrPassportNumber'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String,
      nextOfKinName: json['nextOfKinName'] as String,
      nextOfKinPhone: json['nextOfKinPhone'] as String,
      status: $enumDecode(_$EmploymentStatusEnumMap, json['status']),
      engagementType: $enumDecode(
        _$EngagementTypeEnumMap,
        json['engagementType'],
      ),
      occupationTitle: json['occupationTitle'] as String,
      payGroupId: json['payGroupId'] as String?,
      payStructureId: json['payStructureId'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      bankName: json['bankName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankBranchCode: json['bankBranchCode'] as String?,
      disbursementMethod: $enumDecode(
        _$DisbursementMethodEnumMap,
        json['disbursementMethod'],
      ),
      preferredLanguage: json['preferredLanguage'] as String,
      hasHousingBenefit: json['hasHousingBenefit'] as bool,
      housingValuePerMonth: (json['housingValuePerMonth'] as num?)?.toDouble(),
      hasFoodBenefit: json['hasFoodBenefit'] as bool,
      foodValuePerMonth: (json['foodValuePerMonth'] as num?)?.toDouble(),
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PayrollEmployeeToJson(_PayrollEmployee instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'idOrPassportNumber': instance.idOrPassportNumber,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'nextOfKinName': instance.nextOfKinName,
      'nextOfKinPhone': instance.nextOfKinPhone,
      'status': _$EmploymentStatusEnumMap[instance.status]!,
      'engagementType': _$EngagementTypeEnumMap[instance.engagementType]!,
      'occupationTitle': instance.occupationTitle,
      'payGroupId': instance.payGroupId,
      'payStructureId': instance.payStructureId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'bankName': instance.bankName,
      'bankAccountNumber': instance.bankAccountNumber,
      'bankBranchCode': instance.bankBranchCode,
      'disbursementMethod':
          _$DisbursementMethodEnumMap[instance.disbursementMethod]!,
      'preferredLanguage': instance.preferredLanguage,
      'hasHousingBenefit': instance.hasHousingBenefit,
      'housingValuePerMonth': instance.housingValuePerMonth,
      'hasFoodBenefit': instance.hasFoodBenefit,
      'foodValuePerMonth': instance.foodValuePerMonth,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'profileImageUrl': instance.profileImageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$EmploymentStatusEnumMap = {
  EmploymentStatus.active: 'active',
  EmploymentStatus.inactive: 'inactive',
  EmploymentStatus.terminated: 'terminated',
};

const _$EngagementTypeEnumMap = {
  EngagementType.permanent: 'permanent',
  EngagementType.seasonal: 'seasonal',
  EngagementType.casual: 'casual',
  EngagementType.contractor: 'contractor',
};

const _$DisbursementMethodEnumMap = {
  DisbursementMethod.bank: 'bank',
  DisbursementMethod.cash: 'cash',
  DisbursementMethod.mtnEwallet: 'mtnEwallet',
  DisbursementMethod.orangeMoney: 'orangeMoney',
};
