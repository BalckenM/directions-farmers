// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_structure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayStructure _$PayStructureFromJson(Map<String, dynamic> json) =>
    _PayStructure(
      id: json['id'] as String,
      name: json['name'] as String,
      wageType: $enumDecode(_$WageTypeEnumMap, json['wageType']),
      baseRate: (json['baseRate'] as num).toDouble(),
      nmwaEnforced: json['nmwaEnforced'] as bool? ?? true,
      overtimeMultiplier:
          (json['overtimeMultiplier'] as num?)?.toDouble() ?? 1.5,
      sundayMultiplier: (json['sundayMultiplier'] as num?)?.toDouble() ?? 2.0,
      publicHolidayMultiplier:
          (json['publicHolidayMultiplier'] as num?)?.toDouble() ?? 2.0,
      pieceworkUnit: json['pieceworkUnit'] as String?,
      pieceworkMinUnitsPerDay: (json['pieceworkMinUnitsPerDay'] as num?)
          ?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PayStructureToJson(_PayStructure instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'wageType': _$WageTypeEnumMap[instance.wageType]!,
      'baseRate': instance.baseRate,
      'nmwaEnforced': instance.nmwaEnforced,
      'overtimeMultiplier': instance.overtimeMultiplier,
      'sundayMultiplier': instance.sundayMultiplier,
      'publicHolidayMultiplier': instance.publicHolidayMultiplier,
      'pieceworkUnit': instance.pieceworkUnit,
      'pieceworkMinUnitsPerDay': instance.pieceworkMinUnitsPerDay,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$WageTypeEnumMap = {
  WageType.monthlySalary: 'monthlySalary',
  WageType.hourlyRate: 'hourlyRate',
  WageType.dailyRate: 'dailyRate',
  WageType.piecework: 'piecework',
};
