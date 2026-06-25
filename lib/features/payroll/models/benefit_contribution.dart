// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'benefit_contribution.freezed.dart';
part 'benefit_contribution.g.dart';

enum BenefitType { pension, provident, medicalAid, retirementAnnuity }

extension BenefitTypeX on BenefitType {
  String get label => switch (this) {
    BenefitType.pension => 'Pension Fund',
    BenefitType.provident => 'Provident Fund',
    BenefitType.medicalAid => 'Medical Aid',
    BenefitType.retirementAnnuity => 'Retirement Annuity',
  };
  String get sarsCode => switch (this) {
    BenefitType.pension => '4001',
    BenefitType.provident => '4003',
    BenefitType.medicalAid => '4005',
    BenefitType.retirementAnnuity => '4006',
  };
  String get payslipCode => switch (this) {
    BenefitType.pension => 'PENSION_EE',
    BenefitType.provident => 'PROVIDENT_EE',
    BenefitType.medicalAid => 'MEDICAL_AID_EE',
    BenefitType.retirementAnnuity => 'RA_EE',
  };
}

@freezed
abstract class BenefitContribution with _$BenefitContribution {
  const factory BenefitContribution({
    required String id,
    required String employeeId,
    required BenefitType type,
    required double employeeAmount,
    required double employerAmount,
    required DateTime effectiveFrom,
    DateTime? effectiveTo,
    String? fundName,
    String? memberNumber,
  }) = _BenefitContribution;

  factory BenefitContribution.fromJson(Map<String, dynamic> json) {
    double numOf(dynamic v) => v == null
        ? 0.0
        : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
    final now = DateTime.now().toIso8601String();
    final rawType = (json['benefit_type'] ?? json['type'] ?? '').toString();
    final typeStr = switch (rawType.toLowerCase()) {
      'pension' || 'pension_fund' => 'pension',
      'provident' || 'provident_fund' => 'provident',
      'medical_aid' || 'medicalaid' || 'medical' => 'medicalAid',
      'retirement_annuity' ||
      'ra' ||
      'retirementannuity' => 'retirementAnnuity',
      _ => 'pension',
    };
    return _$BenefitContributionFromJson(<String, dynamic>{
      'id': json['id']?.toString() ?? '',
      'employeeId':
          (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
      'type': typeStr,
      'employeeAmount': numOf(
        json['employee_amount'] ??
            json['employee_contribution'] ??
            json['employeeAmount'],
      ),
      'employerAmount': numOf(
        json['employer_amount'] ??
            json['employer_contribution'] ??
            json['employerAmount'],
      ),
      'effectiveFrom': (json['effective_from'] ?? json['effectiveFrom'] ?? now)
          .toString(),
      'effectiveTo': (json['effective_to'] ?? json['effectiveTo'])?.toString(),
      'fundName': (json['fund_name'] ?? json['fundName'])?.toString(),
      'memberNumber': (json['member_number'] ?? json['memberNumber'])
          ?.toString(),
    });
  }
}
