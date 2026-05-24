// Benefit contribution model — medical aid, pension, provident fund,
// and retirement annuity with their SARS source/deduction codes.

// ─── Benefit types ────────────────────────────────────────────────────────────

enum BenefitType {
  /// Employee pension fund contribution. SARS deduction code 4001.
  pension,

  /// Employee provident fund contribution. SARS deduction code 4003.
  provident,

  /// Medical aid contribution (employee portion). SARS deduction code 4005.
  medicalAid,

  /// Retirement annuity fund. SARS deduction code 4006.
  retirementAnnuity,
}

extension BenefitTypeX on BenefitType {
  /// Short display label.
  String get label => switch (this) {
        BenefitType.pension          => 'Pension Fund',
        BenefitType.provident        => 'Provident Fund',
        BenefitType.medicalAid       => 'Medical Aid',
        BenefitType.retirementAnnuity => 'Retirement Annuity',
      };

  /// SARS IRP5 deduction code.
  String get sarsCode => switch (this) {
        BenefitType.pension           => '4001',
        BenefitType.provident         => '4003',
        BenefitType.medicalAid        => '4005',
        BenefitType.retirementAnnuity => '4006',
      };

  /// Payslip deduction line code (used as [PayslipDeductionLine.code]).
  String get payslipCode => switch (this) {
        BenefitType.pension           => 'PENSION_EE',
        BenefitType.provident         => 'PROVIDENT_EE',
        BenefitType.medicalAid        => 'MEDICAL_AID_EE',
        BenefitType.retirementAnnuity => 'RA_EE',
      };
}

// ─── Contribution model ───────────────────────────────────────────────────────

/// A single benefit contribution for one employee in one pay period.
class BenefitContribution {
  const BenefitContribution({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.employeeAmount,
    required this.employerAmount,
    required this.effectiveFrom,
    this.effectiveTo,
    this.fundName,
    this.memberNumber,
  });

  final String id;
  final String employeeId;
  final BenefitType type;

  /// Employee deduction amount per pay period (monthly).
  final double employeeAmount;

  /// Employer contribution per pay period (monthly). May be 0.
  final double employerAmount;

  final DateTime effectiveFrom;
  final DateTime? effectiveTo;

  /// Name of the fund or scheme (e.g. "Discovery Health Standard Plan").
  final String? fundName;

  /// Member/scheme number for payslip reference.
  final String? memberNumber;

  double get totalAmount => employeeAmount + employerAmount;

  bool isActiveOn(DateTime date) {
    if (date.isBefore(effectiveFrom)) return false;
    if (effectiveTo != null && date.isAfter(effectiveTo!)) return false;
    return true;
  }

  BenefitContribution copyWith({
    String? id,
    String? employeeId,
    BenefitType? type,
    double? employeeAmount,
    double? employerAmount,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    String? fundName,
    String? memberNumber,
  }) =>
      BenefitContribution(
        id: id ?? this.id,
        employeeId: employeeId ?? this.employeeId,
        type: type ?? this.type,
        employeeAmount: employeeAmount ?? this.employeeAmount,
        employerAmount: employerAmount ?? this.employerAmount,
        effectiveFrom: effectiveFrom ?? this.effectiveFrom,
        effectiveTo: effectiveTo ?? this.effectiveTo,
        fundName: fundName ?? this.fundName,
        memberNumber: memberNumber ?? this.memberNumber,
      );

  factory BenefitContribution.fromJson(Map<String, dynamic> json) =>
      BenefitContribution(
        id: json['id'] as String,
        employeeId: json['employeeId'] as String,
        type: BenefitType.values.byName(json['type'] as String),
        employeeAmount: (json['employeeAmount'] as num).toDouble(),
        employerAmount: (json['employerAmount'] as num).toDouble(),
        effectiveFrom: DateTime.parse(json['effectiveFrom'] as String),
        effectiveTo: json['effectiveTo'] != null
            ? DateTime.parse(json['effectiveTo'] as String)
            : null,
        fundName: json['fundName'] as String?,
        memberNumber: json['memberNumber'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'type': type.name,
        'employeeAmount': employeeAmount,
        'employerAmount': employerAmount,
        'effectiveFrom': effectiveFrom.toIso8601String(),
        'effectiveTo': effectiveTo?.toIso8601String(),
        'fundName': fundName,
        'memberNumber': memberNumber,
      };
}
