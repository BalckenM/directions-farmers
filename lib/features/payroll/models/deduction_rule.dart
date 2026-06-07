// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'deduction_rule.freezed.dart';
part 'deduction_rule.g.dart';

enum DeductionType { statutory, voluntary, benefit, garnishee }
enum DeductionBasis { percentage, fixedAmount }

@freezed
abstract class DeductionRule with _$DeductionRule {
  const DeductionRule._();

  const factory DeductionRule({
    required String id,
    required String code,
    required String label,
    required DeductionType type,
    required DeductionBasis basis,
    required double value,
    double? cappedAt,
    List<String>? employeeIds,
    required bool isActive,
    required DateTime createdAt,
  }) = _DeductionRule;

  factory DeductionRule.fromJson(Map<String, dynamic> json) =>
      _$DeductionRuleFromJson(json);

  String get typeLabel => switch (type) {
        DeductionType.statutory => 'Statutory',
        DeductionType.voluntary => 'Voluntary',
        DeductionType.benefit => 'Benefit',
        DeductionType.garnishee => 'Garnishee',
      };
}
