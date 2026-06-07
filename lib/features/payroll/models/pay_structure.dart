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

  factory PayStructure.fromJson(Map<String, dynamic> json) =>
      _$PayStructureFromJson(json);

  String get wageTypeLabel => switch (wageType) {
        WageType.monthlySalary => 'Monthly Salary',
        WageType.hourlyRate => 'Hourly Rate',
        WageType.dailyRate => 'Daily Rate',
        WageType.piecework => 'Piecework',
      };
}
