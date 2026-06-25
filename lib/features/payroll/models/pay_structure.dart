// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pay_structure.freezed.dart';
part 'pay_structure.g.dart';

enum WageType { monthlySalary, hourlyRate, dailyRate, piecework }

@freezed
abstract class PayStructure with _$PayStructure {
  const PayStructure._();

  const factory PayStructure({
    required String id,
    required String name,
    required WageType wageType,
    required double baseRate,
    @Default(true) bool nmwaEnforced,
    @Default(1.5) double overtimeMultiplier,
    @Default(2.0) double sundayMultiplier,
    @Default(2.0) double publicHolidayMultiplier,
    String? pieceworkUnit,
    double? pieceworkMinUnitsPerDay,
    required DateTime createdAt,
  }) = _PayStructure;

  factory PayStructure.fromJson(Map<String, dynamic> json) {
    const wageTypeMap = {
      'monthly_salary': 'monthlySalary',
      'hourly_rate': 'hourlyRate',
      'daily_rate': 'dailyRate',
      'piecework': 'piecework',
    };
    final now = DateTime.now().toIso8601String();
    return _$PayStructureFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'wageType':
          wageTypeMap[json['wage_type']] ?? json['wageType'] ?? 'monthlySalary',
      'baseRate':
          (json['base_rate'] as num?)?.toDouble() ??
          (json['baseRate'] as num?)?.toDouble() ??
          0.0,
      'nmwaEnforced': json['nmwa_enforced'] ?? json['nmwaEnforced'] ?? true,
      'overtimeMultiplier':
          (json['overtime_multiplier'] as num?)?.toDouble() ??
          (json['overtimeMultiplier'] as num?)?.toDouble() ??
          1.5,
      'sundayMultiplier':
          (json['sunday_multiplier'] as num?)?.toDouble() ??
          (json['sundayMultiplier'] as num?)?.toDouble() ??
          2.0,
      'publicHolidayMultiplier':
          (json['public_holiday_multiplier'] as num?)?.toDouble() ??
          (json['publicHolidayMultiplier'] as num?)?.toDouble() ??
          2.0,
      'pieceworkUnit': json['piecework_unit'] ?? json['pieceworkUnit'],
      'pieceworkMinUnitsPerDay':
          (json['piecework_min_units_per_day'] as num?)?.toDouble() ??
          (json['pieceworkMinUnitsPerDay'] as num?)?.toDouble(),
      'createdAt': json['created_at'] ?? json['createdAt'] ?? now,
    });
  }

  String get wageTypeLabel => switch (wageType) {
    WageType.monthlySalary => 'Monthly Salary',
    WageType.hourlyRate => 'Hourly Rate',
    WageType.dailyRate => 'Daily Rate',
    WageType.piecework => 'Piecework',
  };
}
