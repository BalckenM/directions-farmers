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

  factory DeductionRule.fromJson(Map<String, dynamic> json) {
    const basisMap = {
      'percentage': 'percentage',
      'fixed_amount': 'fixedAmount',
    };
    final now = DateTime.now().toIso8601String();
    return _$DeductionRuleFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'isActive': json['is_active'] ?? json['isActive'] ?? true,
      'cappedAt':
          (json['capped_at'] as num?)?.toDouble() ??
          (json['cappedAt'] as num?)?.toDouble(),
      'employeeIds': (json['employee_ids'] ?? json['employeeIds'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      'basis': basisMap[json['basis']] ?? json['basis'] ?? 'fixedAmount',
      'createdAt': json['created_at'] ?? json['createdAt'] ?? now,
    });
  }

  String get typeLabel => switch (type) {
    DeductionType.statutory => 'Statutory',
    DeductionType.voluntary => 'Voluntary',
    DeductionType.benefit => 'Benefit',
    DeductionType.garnishee => 'Garnishee',
  };
}
