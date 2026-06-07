// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayGroup _$PayGroupFromJson(Map<String, dynamic> json) => _PayGroup(
  id: json['id'] as String,
  name: json['name'] as String,
  frequency: $enumDecode(_$PayFrequencyEnumMap, json['frequency']),
  payDayOffset: (json['payDayOffset'] as num).toInt(),
  description: json['description'] as String?,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PayGroupToJson(_PayGroup instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'frequency': _$PayFrequencyEnumMap[instance.frequency]!,
  'payDayOffset': instance.payDayOffset,
  'description': instance.description,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$PayFrequencyEnumMap = {
  PayFrequency.weekly: 'weekly',
  PayFrequency.biweekly: 'biweekly',
  PayFrequency.monthly: 'monthly',
  PayFrequency.daily: 'daily',
};
