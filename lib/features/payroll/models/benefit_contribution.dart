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

  factory BenefitContribution.fromJson(Map<String, dynamic> json) =>
      _$BenefitContributionFromJson(json);
}
