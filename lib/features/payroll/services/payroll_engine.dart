// ignore_for_file: prefer_const_constructors
// Pure-Dart payroll calculation engine — no Flutter imports.
// Implements SA farm statutory rules (BCEA / NMWA / UIF / PAYE).

import 'dart:math' show min, max;

import '../models/attendance_record.dart';
import '../models/compliance_alert.dart';
import '../models/deduction_rule.dart';
import '../models/garnishee_order.dart';
import '../models/leave_type.dart';
import '../models/pay_run.dart';
import '../models/pay_structure.dart';
import '../models/payroll_employee.dart';
import '../models/payslip.dart';
import '../models/piecework_log.dart';

// ─── SA Statutory Constants (2025 / 2026 tax year) ───────────────────────────
class SaStatutory {
  const SaStatutory._();

  /// NMWA farm sector hourly rate — R25.42/hr (GN R4174 of 2025, effective 1 March 2025)
  /// Update when the 2026 gazette is published (expected March 2026).
  static const double nmwaHourly = 25.42;

  /// NMWA monthly equivalent at 173.33 hrs/month
  static const double nmwaMonthly = nmwaHourly * 173.33;

  /// NMWA daily equivalent at 8 hrs/day
  static const double nmwaDaily = nmwaHourly * 8.0;

  /// UIF contribution rate (both employee & employer)
  static const double uifRate = 0.01; // 1%

  /// UIF monthly remuneration ceiling (per annum R213,193 ÷ 12)
  static const double uifMonthlyCap = 17_747.46;

  /// Maximum monthly UIF deduction per employee (1% of cap)
  static const double uifMaxMonthly = uifMonthlyCap * uifRate;

  // ─── PAYE tables: 2025/2026 individuals ─────────────────────────────────
  /// Annual income threshold below which no PAYE is due (under-65)
  static const double payeThresholdAnnual = 95_750.0;

  /// Primary rebate (under-65)
  static const double payePrimaryRebate = 17_235.0;

  /// Secondary rebate — age 65 – 74. 2025/2026 tax year.
  static const double payeSecondaryRebate = 9_444.0;

  /// Tertiary rebate — age 75+. 2025/2026 tax year.
  static const double payeTertiaryRebate = 3_145.0;

  /// Annual income threshold — no PAYE due (age 65 – 74). 2025/2026.
  static const double payeThreshold65 = 148_217.0;

  /// Annual income threshold — no PAYE due (age 75+). 2025/2026.
  static const double payeThreshold75 = 165_689.0;

  // Tax bracket boundaries and marginal rates (under-65)
  static const List<_TaxBracket> _brackets = [
    _TaxBracket(floor: 0, ceiling: 237_100, baseTax: 0, marginalRate: 0.18),
    _TaxBracket(
      floor: 237_100,
      ceiling: 370_500,
      baseTax: 42_678,
      marginalRate: 0.26,
    ),
    _TaxBracket(
      floor: 370_500,
      ceiling: 512_800,
      baseTax: 77_362,
      marginalRate: 0.31,
    ),
    _TaxBracket(
      floor: 512_800,
      ceiling: 673_000,
      baseTax: 121_475,
      marginalRate: 0.36,
    ),
    _TaxBracket(
      floor: 673_000,
      ceiling: 857_900,
      baseTax: 179_147,
      marginalRate: 0.39,
    ),
    _TaxBracket(
      floor: 857_900,
      ceiling: 1_817_000,
      baseTax: 251_258,
      marginalRate: 0.41,
    ),
    _TaxBracket(
      floor: 1_817_000,
      ceiling: double.infinity,
      baseTax: 644_489,
      marginalRate: 0.45,
    ),
  ];

  /// Compute annual PAYE for an individual given [annualGross].
  ///
  /// Applies age-appropriate rebates when [dateOfBirth] is supplied:
  ///  • under 65  → primary rebate only (R17,235)
  ///  • 65 – 74   → primary + secondary (R26,679 total)
  ///  • 75+        → primary + secondary + tertiary (R29,824 total)
  ///
  /// [assessmentDate] is used to determine age; defaults to today.
  static double computeAnnualPaye(
    double annualGross, {
    DateTime? dateOfBirth,
    DateTime? assessmentDate,
  }) {
    final int age = dateOfBirth != null
        ? _ageAt(dateOfBirth, assessmentDate ?? DateTime.now())
        : 0;
    final double threshold;
    final double totalRebate;
    if (age >= 75) {
      threshold = payeThreshold75;
      totalRebate =
          payePrimaryRebate + payeSecondaryRebate + payeTertiaryRebate;
    } else if (age >= 65) {
      threshold = payeThreshold65;
      totalRebate = payePrimaryRebate + payeSecondaryRebate;
    } else {
      threshold = payeThresholdAnnual;
      totalRebate = payePrimaryRebate;
    }
    if (annualGross <= threshold) return 0.0;
    double grossTax = 0.0;
    for (final bracket in _brackets) {
      if (annualGross <= bracket.floor) break;
      final taxable = min(annualGross, bracket.ceiling) - bracket.floor;
      grossTax = bracket.baseTax + taxable * bracket.marginalRate;
      if (annualGross <= bracket.ceiling) break;
    }
    final netTax = grossTax - totalRebate;
    return max(0.0, netTax);
  }

  /// Monthly PAYE from monthly gross.
  /// Pass [dateOfBirth] to apply the correct age rebate.
  static double computeMonthlyPaye(
    double monthlyGross, {
    DateTime? dateOfBirth,
    DateTime? assessmentDate,
  }) {
    return computeAnnualPaye(
          monthlyGross * 12,
          dateOfBirth: dateOfBirth,
          assessmentDate: assessmentDate,
        ) /
        12;
  }

  // ─── BCEA overtime multipliers ──────────────────────────────────────────
  /// Hours beyond 9 per day (or 45 per week) — ordinary overtime
  static const double overtimeMultiplier = 1.5;

  /// Sunday work
  static const double sundayMultiplier = 2.0;

  /// Public holiday work
  static const double publicHolidayMultiplier = 2.0;

  // ─── SDL (Skills Development Levy) ───────────────────────────────────────
  /// Employer levy: 1% of monthly leviable payroll.
  static const double sdlRate = 0.01;

  /// Annual payroll threshold below which SDL is exempt (R500,000).
  static const double sdlAnnualThreshold = 500_000.0;

  // ─── COIDA (Compensation for Occupational Injuries & Diseases) ───────────
  /// Default assessment rate for agricultural employers (farming sector, 1.25%).
  static const double coidaDefaultRate = 0.0125;

  /// Annual earnings ceiling for COIDA assessment (2023/24).
  static const double coidaAnnualCeiling = 484_200.0;

  // ─── ETI (Employment Tax Incentive) thresholds ───────────────────────────
  /// Minimum monthly salary for ETI eligibility.
  static const double etiMinMonthlySalary = 2_000.0;

  /// Maximum monthly salary for ETI eligibility.
  static const double etiMaxMonthlySalary = 6_500.0;

  // ─── ETI sliding scale mid-point ─────────────────────────────────────────
  /// Salary midpoint for ETI sliding scale (above this, credit tapers to R0).
  static const double etiMidSalary = 4_500.0;

  // ─── BCEA §17 night shift allowance ─────────────────────────────────────
  /// Night shift premium rate — 10% of ordinary hourly rate (BCEA §17).
  static const double nightShiftPremiumRate = 0.10;

  // ─── Age calculation helper ──────────────────────────────────────────────
  /// Returns the completed age of a person born on [dob] as of [at].
  static int _ageAt(DateTime dob, DateTime at) {
    int age = at.year - dob.year;
    if (at.month < dob.month || (at.month == dob.month && at.day < dob.day)) {
      age--;
    }
    return max(0, age.toDouble()).toInt();
  }

  // ─── COIDA calculation helpers ───────────────────────────────────────────

  /// Compute the total annual COIDA assessment for the whole payroll.
  ///
  /// [annualPayroll] is the sum of all employee annual earnings subject to
  /// COIDA. Each employee's earnings are capped at [coidaAnnualCeiling]
  /// individually *before* summing, so pass the pre-capped total here.
  static double computeCoidaAnnualAssessment(double annualPayroll) {
    return annualPayroll * coidaDefaultRate;
  }

  /// Compute the COIDA contribution for a single employee for one month.
  ///
  /// Annualises [monthlyEarnings], applies the [coidaAnnualCeiling] cap, then
  /// divides by 12 to get the monthly provision amount.
  static double computeMonthlyCoida(double monthlyEarnings) {
    final annualEarnings = monthlyEarnings * 12;
    final cappedAnnual = min(annualEarnings, coidaAnnualCeiling);
    return (cappedAnnual * coidaDefaultRate) / 12;
  }
}

class _TaxBracket {
  const _TaxBracket({
    required this.floor,
    required this.ceiling,
    required this.baseTax,
    required this.marginalRate,
  });
  final double floor;
  final double ceiling;
  final double baseTax;
  final double marginalRate;
}

// ─── Calculation inputs for a single employee within a period ────────────────
class EmployeePayInput {
  const EmployeePayInput({
    required this.employee,
    required this.payStructure,
    required this.attendanceRecords,
    required this.pieceworkLogs,
    required this.deductionRules,
    required this.salaryOverride,
    this.garnisheeOrders = const [],
  });

  final PayrollEmployee employee;
  final PayStructure payStructure;
  final List<AttendanceRecord> attendanceRecords;
  final List<PieceworkLog> pieceworkLogs;
  final List<DeductionRule> deductionRules;

  /// Override the base rate when the employee has a personal contract salary
  final double? salaryOverride;

  /// Active garnishee orders for this employee (court-ordered deductions).
  final List<GarnisheeOrder> garnisheeOrders;
}

// ─── Calculation result for a single employee ───────────────────────────────
class EmployeePayResult {
  const EmployeePayResult({
    required this.payslip,
    required this.uifEmployerContribution,
    required this.etiCredit,
    required this.coidaContribution,
    required this.warnings,
    required this.nmwaBreach,
  });

  final Payslip payslip;
  final double uifEmployerContribution;

  /// Monthly ETI credit reducing employer PAYE liability (0.0 if not qualifying).
  final double etiCredit;

  /// Annualised COIDA contribution for this employee.
  final double coidaContribution;
  final List<String> warnings;
  final bool nmwaBreach;
}

// ─── Retroactive back-pay calculator ─────────────────────────────────────────

/// Computes the gross retroactive pay owed when a wage rate has been
/// increased and the increase must be applied to prior periods.
abstract final class BackpayCalculator {
  /// Compute back-pay from a *rate-based* wage change (hourly or daily).
  ///
  /// * [oldRate] — the rate that was actually paid.
  /// * [newRate] — the rate that should have been applied (must be > [oldRate]).
  /// * [periodsAffected] — number of pay periods (e.g. weeks or months) the
  ///   increase is applied retroactively to.
  /// * [unitsPerPeriod] — hours or days worked in each affected period.
  ///
  /// Returns the total gross back-pay amount (0.0 if [newRate] ≤ [oldRate]).
  static double computeRetroactivePay({
    required double oldRate,
    required double newRate,
    required int periodsAffected,
    required double unitsPerPeriod,
  }) {
    if (newRate <= oldRate) return 0.0;
    return (newRate - oldRate) * unitsPerPeriod * periodsAffected;
  }

  /// Compute back-pay from a *monthly-salary* change.
  ///
  /// * [oldMonthly] — monthly salary that was paid.
  /// * [newMonthly] — monthly salary that should have been paid.
  /// * [monthsAffected] — number of months to apply retroactively.
  ///
  /// Returns the total gross back-pay (0.0 if [newMonthly] ≤ [oldMonthly]).
  static double computeRetroactiveMonthlySalary({
    required double oldMonthly,
    required double newMonthly,
    required int monthsAffected,
  }) {
    if (newMonthly <= oldMonthly) return 0.0;
    return (newMonthly - oldMonthly) * monthsAffected;
  }

  /// Compute PAYE on a lump-sum back-pay using the "spread-over-period"
  /// method — adds the back-pay pro-rated over the affected months to the
  /// current monthly gross, computes PAYE, then subtracts the base PAYE.
  ///
  /// [currentMonthlyGross] — normal monthly gross before back-pay.
  /// [totalBackpay] — total lump-sum back-pay to be paid.
  /// [monthsAffected] — number of months the back-pay relates to.
  ///
  /// Returns the additional PAYE tax due on the lump sum.
  static double computeBackpayPaye({
    required double currentMonthlyGross,
    required double totalBackpay,
    required int monthsAffected,
  }) {
    final normalPaye = SaStatutory.computeMonthlyPaye(currentMonthlyGross);
    final monthlyBackpay = monthsAffected > 0
        ? totalBackpay / monthsAffected
        : totalBackpay;
    final adjustedPaye = SaStatutory.computeMonthlyPaye(
      currentMonthlyGross + monthlyBackpay,
    );
    final additionalMonthlyPaye = max(0.0, adjustedPaye - normalPaye);
    return additionalMonthlyPaye * (monthsAffected > 0 ? monthsAffected : 1);
  }
}

// ─── Pay-run result ──────────────────────────────────────────────────────────
class PayRunCalculationResult {
  const PayRunCalculationResult({
    required this.payRun,
    required this.payslips,
    required this.complianceAlerts,
  });

  final PayRun payRun;
  final List<Payslip> payslips;
  final List<ComplianceAlert> complianceAlerts;
}

// ─── Leave carry-over result ──────────────────────────────────────────────────
class LeaveCarryOverResult {
  const LeaveCarryOverResult({
    required this.carryOverDays,
    required this.excessDays,
    required this.excessPayout,
  });

  /// Days that will carry over into the next cycle (≤ policy cap).
  final double carryOverDays;

  /// Excess days beyond the cap.
  final double excessDays;

  /// Monetary payout for excess days (0 when [payoutExcess] is false).
  final double excessPayout;
}

// ─── Termination benefits calculator (BCEA §37 / §40 / §41) ─────────────────
class TerminationCalculator {
  const TerminationCalculator();

  /// BCEA §40: leave payout — outstanding leave days paid at daily rate.
  /// [dailyRate] = monthlyGross / 21.75 (SA average working days/month).
  static double computeLeavePayout({
    required double monthlyGross,
    required double outstandingLeaveDays,
  }) {
    if (outstandingLeaveDays <= 0 || monthlyGross <= 0) return 0.0;
    final dailyRate = monthlyGross / 21.75;
    return double.parse((dailyRate * outstandingLeaveDays).toStringAsFixed(2));
  }

  /// BCEA §41: severance pay — 1 week's wages per completed year of service.
  /// Only applicable for dismissal for operational requirements (retrenchment).
  /// [weeklyWage] = monthlyGross × 12 / 52.
  static double computeSeverancePay({
    required double monthlyGross,
    required DateTime startDate,
    required DateTime terminationDate,
  }) {
    final years = _completedYears(startDate, terminationDate);
    if (years <= 0) return 0.0;
    final weeklyWage = (monthlyGross * 12) / 52;
    return double.parse((weeklyWage * years).toStringAsFixed(2));
  }

  /// BCEA §37: notice pay — based on length of service.
  /// < 6 months → 1 week; 6–12 months → 2 weeks; > 12 months → 4 weeks.
  static double computeNoticePay({
    required double monthlyGross,
    required DateTime startDate,
    required DateTime terminationDate,
  }) {
    final months = _completedMonths(startDate, terminationDate);
    final int noticeWeeks;
    if (months < 6) {
      noticeWeeks = 1;
    } else if (months < 12) {
      noticeWeeks = 2;
    } else {
      noticeWeeks = 4;
    }
    final weeklyWage = (monthlyGross * 12) / 52;
    return double.parse((weeklyWage * noticeWeeks).toStringAsFixed(2));
  }

  /// Returns a summary of all termination benefits.
  static Map<String, double> computeAll({
    required double monthlyGross,
    required double outstandingLeaveDays,
    required DateTime startDate,
    required DateTime terminationDate,
    bool includeSeverance = true,
  }) {
    return {
      'leavePayout': computeLeavePayout(
        monthlyGross: monthlyGross,
        outstandingLeaveDays: outstandingLeaveDays,
      ),
      'noticePay': computeNoticePay(
        monthlyGross: monthlyGross,
        startDate: startDate,
        terminationDate: terminationDate,
      ),
      if (includeSeverance)
        'severancePay': computeSeverancePay(
          monthlyGross: monthlyGross,
          startDate: startDate,
          terminationDate: terminationDate,
        ),
    };
  }

  static int _completedYears(DateTime start, DateTime end) {
    int years = end.year - start.year;
    if (end.month < start.month ||
        (end.month == start.month && end.day < start.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  static int _completedMonths(DateTime start, DateTime end) {
    final months = (end.year - start.year) * 12 + (end.month - start.month);
    return months < 0 ? 0 : months;
  }
}

// ─── The Engine ──────────────────────────────────────────────────────────────
class PayrollEngine {
  const PayrollEngine();

  // ─── Static helpers: Leave accrual ──────────────────────────────────────

  /// Accrue leave days for an employee based on [completedMonths] of service.
  ///
  /// Per-month accrual = `leaveType.annualEntitlementDays / 12`.
  /// Result is capped at [maxCarryOver] when supplied (typical SA BCEA
  /// practice: annual leave carry-over capped at 36 days).
  ///
  /// Returns days accrued, rounded to 4 decimal places.
  static double accrueLeave({
    required PayrollEmployee employee,
    required LeaveType leaveType,
    required int completedMonths,
    double? maxCarryOver,
  }) {
    if (completedMonths <= 0) return 0.0;
    final perMonth = leaveType.annualEntitlementDays / 12.0;
    final raw = perMonth * completedMonths;
    final capped = (maxCarryOver != null && raw > maxCarryOver)
        ? maxCarryOver
        : raw;
    return double.parse(capped.toStringAsFixed(4));
  }

  /// BCEA s20 alternative accrual: 1 day annual leave per 17 days worked.
  /// Use this for shift / casual workers paid by attendance.
  static double bcea20DaysWorkedAccrual(int daysWorked) {
    if (daysWorked <= 0) return 0.0;
    return double.parse((daysWorked / 17.0).toStringAsFixed(4));
  }

  // ─── Leave monetization & carry-over enforcement ────────────────────────

  /// Compute the monetary value of leave days (e.g. for termination payout).
  /// Uses 21.75 average working days/month as per SA practice.
  static double computeLeaveMonetaryValue({
    required double monthlyGross,
    required double leaveDays,
  }) {
    if (leaveDays <= 0 || monthlyGross <= 0) return 0.0;
    final dailyRate = monthlyGross / 21.75;
    return double.parse((dailyRate * leaveDays).toStringAsFixed(2));
  }

  /// Enforce BCEA leave carry-over cap at cycle end.
  ///
  /// Returns [LeaveCarryOverResult] with days carried over, excess days, and
  /// monetary payout for excess (when [payoutExcess] is true).
  static LeaveCarryOverResult enforceLeaveCarryOver({
    required double accruedDays,
    required double maxCarryOver,
    required double monthlyGross,
    bool payoutExcess = false,
  }) {
    if (accruedDays <= maxCarryOver) {
      return LeaveCarryOverResult(
        carryOverDays: accruedDays,
        excessDays: 0,
        excessPayout: 0,
      );
    }
    final excess = accruedDays - maxCarryOver;
    final payout = payoutExcess
        ? computeLeaveMonetaryValue(
            monthlyGross: monthlyGross,
            leaveDays: excess,
          )
        : 0.0;
    return LeaveCarryOverResult(
      carryOverDays: maxCarryOver,
      excessDays: double.parse(excess.toStringAsFixed(4)),
      excessPayout: payout,
    );
  }

  // ─── Static helpers: SDL, COIDA, ETI ────────────────────────────────────

  /// Compute COIDA annual assessment for one employee.
  /// [annualEarnings] is capped at [SaStatutory.coidaAnnualCeiling].
  static double computeCoida(
    double annualEarnings, {
    double riskRate = SaStatutory.coidaDefaultRate,
  }) {
    final capped = annualEarnings.clamp(0.0, SaStatutory.coidaAnnualCeiling);
    return double.parse((capped * riskRate).toStringAsFixed(2));
  }

  /// Compute monthly ETI credit for a qualifying employee.
  /// Returns 0.0 when the employee does not qualify.
  ///
  /// Rules (SARS ETI Act, amended 2024):
  /// - Employee age 18–29 at [periodStart]
  /// - Monthly salary R2,000 – R6,500
  /// - Employment months 1–24 with this employer
  static double computeEti({
    required PayrollEmployee emp,
    required double monthlySalary,
    required DateTime periodStart,
  }) {
    // Date of birth required
    final dob = emp.dateOfBirth;
    if (dob == null) return 0.0;

    // Age at start of pay period
    int age = periodStart.year - dob.year;
    if (periodStart.month < dob.month ||
        (periodStart.month == dob.month && periodStart.day < dob.day)) {
      age--;
    }
    if (age < 18 || age > 29) return 0.0;

    // Salary range
    if (monthlySalary < SaStatutory.etiMinMonthlySalary ||
        monthlySalary > SaStatutory.etiMaxMonthlySalary) {
      return 0.0;
    }

    // Months of employment (1-indexed)
    final monthsEmployed =
        (periodStart.year - emp.startDate.year) * 12 +
        (periodStart.month - emp.startDate.month) +
        1;
    if (monthsEmployed < 1 || monthsEmployed > 24) return 0.0;

    // SARS ETI sliding scale (post-2022 ETI Act amendment):
    //   Months 1–12:  R2,001–R4,500 → R1,500 fixed
    //                 R4,501–R6,500 → R1,500 − 75% × (wage − R4,500) tapering to R0
    //   Months 13–24: all amounts halved
    final double baseCredit;
    if (monthlySalary <= SaStatutory.etiMidSalary) {
      baseCredit = 1_500.0;
    } else {
      baseCredit = max(
        0.0,
        1_500.0 - 0.75 * (monthlySalary - SaStatutory.etiMidSalary),
      );
    }
    return double.parse(
      (monthsEmployed <= 12 ? baseCredit : baseCredit / 2).toStringAsFixed(2),
    );
  }

  // ─── Main entry: calculate a pay run from a list of employee inputs ─────────
  PayRunCalculationResult calculatePayRun({
    required String payRunId,
    required String payGroupId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime payDate,
    required List<EmployeePayInput> inputs,
  }) {
    final payslips = <Payslip>[];
    final alerts = <ComplianceAlert>[];
    double totalGross = 0;
    double totalDed = 0;
    double totalNet = 0;
    double totalEti = 0;
    double totalCoida = 0;

    for (final input in inputs) {
      final result = _calculateEmployee(
        payRunId: payRunId,
        periodStart: periodStart,
        periodEnd: periodEnd,
        payDate: payDate,
        input: input,
      );

      payslips.add(result.payslip);
      totalGross += result.payslip.grossPay;
      totalDed += result.payslip.totalDeductions;
      totalNet += result.payslip.netPay;
      totalEti += result.etiCredit;
      totalCoida += result.coidaContribution;

      // ETI qualifying employee info alert (first calculation)
      if (result.etiCredit > 0) {
        alerts.add(
          ComplianceAlert(
            id: 'ca_eti_${payRunId}_${input.employee.id}',
            code: 'ETI_QUALIFYING_EMPLOYEE',
            title:
                '${input.employee.firstName} ${input.employee.lastName}: ETI credit R${result.etiCredit.toStringAsFixed(2)}',
            description:
                'Employee qualifies for Employment Tax Incentive. '
                'Monthly ETI credit of R${result.etiCredit.toStringAsFixed(2)} '
                'reduces employer PAYE liability.',
            severity: ComplianceSeverity.info,
            employeeId: input.employee.id,
            payRunId: payRunId,
            isResolved: false,
            raisedAt: DateTime.now(),
          ),
        );
      }

      for (final w in result.warnings) {
        final isNmwa = result.nmwaBreach && w.contains('BCEA');
        final isCap = w.contains('DEDUCTION_CAP_EXCEEDED');
        final code = isNmwa
            ? 'NMWA_BREACH'
            : (isCap ? 'DEDUCTION_CAP_EXCEEDED' : 'PAY_WARNING');
        alerts.add(
          ComplianceAlert(
            id: 'ca_${payRunId}_${input.employee.id}_${alerts.length}',
            code: code,
            title: '${input.employee.firstName} ${input.employee.lastName}: $w',
            description: w,
            severity: isNmwa
                ? ComplianceSeverity.critical
                : ComplianceSeverity.warning,
            employeeId: input.employee.id,
            isResolved: false,
            raisedAt: DateTime.now(),
          ),
        );
      }
    }

    // SDL: 1% of monthly gross if annualised payroll > R500k
    final annualisedPayroll = totalGross * 12;
    final sdl = annualisedPayroll > SaStatutory.sdlAnnualThreshold
        ? _round2(totalGross * SaStatutory.sdlRate)
        : 0.0;

    final payRun = PayRun(
      id: payRunId,
      payGroupId: payGroupId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      payDate: payDate,
      status: PayRunStatus.calculated,
      totalGross: _round2(totalGross),
      totalDeductions: _round2(totalDed),
      totalNet: _round2(totalNet),
      employeeCount: inputs.length,
      complianceAlertIds: alerts.map((a) => a.id).toList(),
      lineItems: [],
      sdlContribution: sdl,
      etiCredit: _round2(totalEti),
      totalCoidaContribution: _round2(totalCoida),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return PayRunCalculationResult(
      payRun: payRun,
      payslips: payslips,
      complianceAlerts: alerts,
    );
  }

  // ─── Per-employee calculation ────────────────────────────────────────────
  EmployeePayResult _calculateEmployee({
    required String payRunId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime payDate,
    required EmployeePayInput input,
  }) {
    final emp = input.employee;
    final ps = input.payStructure;
    final warnings = <String>[];
    bool nmwaBreach = false;

    // 1. Compute base / period pay
    double basicWage = 0;
    double overtimePay = 0;
    double holidayPay = 0;
    double pieceworkEarnings = 0;

    switch (ps.wageType) {
      case WageType.monthlySalary:
        basicWage = input.salaryOverride ?? ps.baseRate;
        // Check NMWA monthly floor
        if (basicWage < SaStatutory.nmwaMonthly && ps.nmwaEnforced) {
          warnings.add(
            'Monthly salary R${basicWage.toStringAsFixed(2)} '
            'is below NMWA floor R${SaStatutory.nmwaMonthly.toStringAsFixed(2)}.',
          );
          nmwaBreach = true;
        }

      case WageType.hourlyRate:
        final effectiveRate = input.salaryOverride ?? ps.baseRate;
        // Check NMWA hourly floor
        if (effectiveRate < SaStatutory.nmwaHourly && ps.nmwaEnforced) {
          warnings.add(
            'Hourly rate R$effectiveRate is below NMWA R${SaStatutory.nmwaHourly}.',
          );
          nmwaBreach = true;
        }
        for (final rec in input.attendanceRecords) {
          if (!rec.isPresent) continue;
          final hours = rec.hoursWorked ?? 0.0;
          final otHours = rec.overtimeHours ?? 0.0;
          basicWage += (hours - otHours) * effectiveRate;
          overtimePay += _computeOvertimePay(rec, effectiveRate, ps);
        }

      case WageType.dailyRate:
        final effectiveRate = input.salaryOverride ?? ps.baseRate;
        final dailyHourlyEquiv = effectiveRate / 8.0;
        if (dailyHourlyEquiv < SaStatutory.nmwaHourly && ps.nmwaEnforced) {
          warnings.add(
            'Daily rate R$effectiveRate implies R${dailyHourlyEquiv.toStringAsFixed(2)}/hr '
            '— below NMWA R${SaStatutory.nmwaHourly}.',
          );
          nmwaBreach = true;
        }
        final daysWorked = input.attendanceRecords
            .where((r) => r.isPresent)
            .length;
        basicWage = daysWorked * effectiveRate;

      case WageType.piecework:
        // Piecework earnings
        for (final log in input.pieceworkLogs) {
          pieceworkEarnings += log.totalEarnings;
        }
        // NMWA floor: total hours worked × NMWA_hourly — must not pay less
        final totalHours = input.attendanceRecords
            .where((r) => r.isPresent)
            .fold(0.0, (s, r) => s + (r.hoursWorked ?? 0.0));
        final nmwaFloor = totalHours * SaStatutory.nmwaHourly;
        if (pieceworkEarnings < nmwaFloor && ps.nmwaEnforced && nmwaFloor > 0) {
          warnings.add(
            'Piecework earnings R${pieceworkEarnings.toStringAsFixed(2)} '
            'fall below NMWA floor R${nmwaFloor.toStringAsFixed(2)}. '
            'Top-up applied automatically.',
          );
          nmwaBreach = true;
          pieceworkEarnings = nmwaFloor; // NMWA top-up
        }
        basicWage = pieceworkEarnings;
    }

    // 2. Holiday pay from attendance records marked publicHoliday
    for (final rec in input.attendanceRecords) {
      if (rec.status == AttendanceStatus.publicHoliday && rec.isPresent) {
        final hours = rec.hoursWorked ?? 8.0;
        final rate = _effectiveHourlyRate(ps, input.salaryOverride);
        if (rate > 0) {
          holidayPay +=
              hours * rate * (SaStatutory.publicHolidayMultiplier - 1.0);
        }
      }
    }

    // 3. In-kind benefits (added to taxable gross per BCEA)
    final inKindHousing = emp.hasHousingBenefit
        ? (emp.housingValuePerMonth ?? 0.0)
        : 0.0;
    final inKindFood = emp.hasFoodBenefit
        ? (emp.foodValuePerMonth ?? 0.0)
        : 0.0;

    // 3b. Night shift premium (BCEA §17: 10% of ordinary rate for nightShiftHours)
    double nightShiftPay = 0.0;
    for (final rec in input.attendanceRecords) {
      if (!rec.isPresent) continue;
      final nsHours = rec.nightShiftHours ?? 0.0;
      if (nsHours > 0) {
        final rate = _effectiveHourlyRate(ps, input.salaryOverride);
        nightShiftPay += nsHours * rate * SaStatutory.nightShiftPremiumRate;
      }
    }

    final grossPay = _round2(
      basicWage +
          overtimePay +
          holidayPay +
          inKindHousing +
          inKindFood +
          nightShiftPay,
    );

    // 4. Deductions
    final deductionLines = _computeDeductions(
      employeeId: emp.id,
      grossPay: grossPay,
      rules: input.deductionRules,
      garnisheeOrders: input.garnisheeOrders,
      warnings: warnings,
      dateOfBirth: emp.dateOfBirth,
      periodStart: periodStart,
    );
    final totalDeductions = _round2(
      deductionLines.fold(0.0, (s, d) => s + d.amount),
    );

    // 5. UIF employer contribution (reported, not deducted from employee)
    final uifEmployerContrib = _round2(
      min(grossPay, SaStatutory.uifMonthlyCap) * SaStatutory.uifRate,
    );

    final netPay = _round2(grossPay - totalDeductions);

    // 6. BCEA §34 — net pay floor (cash net must not fall below NMWA floor)
    final totalHoursForFloor = input.attendanceRecords
        .where((r) => r.isPresent)
        .fold(0.0, (s, r) => s + (r.hoursWorked ?? 0.0));
    final nmwaFloorNet = ps.wageType == WageType.monthlySalary
        ? SaStatutory.nmwaMonthly
        : totalHoursForFloor * SaStatutory.nmwaHourly;
    // Cash net = netPay minus in-kind benefits (in-kind already included in grossPay)
    final cashNet = netPay - inKindHousing - inKindFood;
    if (nmwaFloorNet > 0 && cashNet < nmwaFloorNet && ps.nmwaEnforced) {
      warnings.add(
        'BCEA §34 deduction floor breach: cash net pay '
        'R${cashNet.toStringAsFixed(2)} is below NMWA floor '
        'R${nmwaFloorNet.toStringAsFixed(2)}. Review deductions.',
      );
      nmwaBreach = true;
    }

    // 7. ETI credit
    final etiCredit = computeEti(
      emp: emp,
      monthlySalary: grossPay,
      periodStart: periodStart,
    );

    // 8. COIDA (annualised per employee)
    final coidaContrib = computeCoida(grossPay * 12);

    final payslip = Payslip(
      id: 'ps_${payRunId}_${emp.id}',
      payRunId: payRunId,
      employeeId: emp.id,
      periodStart: periodStart,
      periodEnd: periodEnd,
      payDate: payDate,
      basicWage: _round2(basicWage),
      overtimePay: _round2(overtimePay),
      holidayPay: _round2(holidayPay),
      inKindHousing: _round2(inKindHousing),
      inKindFood: _round2(inKindFood),
      otherEarnings: _round2(
        (pieceworkEarnings > 0 && ps.wageType != WageType.piecework
                ? pieceworkEarnings
                : 0) +
            nightShiftPay,
      ),
      grossPay: grossPay,
      deductions: deductionLines,
      totalDeductions: totalDeductions,
      netPay: netPay,
      leaveBalanceSnapshot: {},
      payslipNumber: _payslipNumber(periodStart, emp.id),
      createdAt: DateTime.now(),
    );

    return EmployeePayResult(
      payslip: payslip,
      uifEmployerContribution: uifEmployerContrib,
      etiCredit: _round2(etiCredit),
      coidaContribution: coidaContrib,
      warnings: warnings,
      nmwaBreach: nmwaBreach,
    );
  }

  // ─── Overtime calculation (BCEA s10) ────────────────────────────────────
  double _computeOvertimePay(
    AttendanceRecord rec,
    double hourlyRate,
    PayStructure ps,
  ) {
    if (rec.overtimeHours == null || rec.overtimeHours! <= 0) return 0.0;
    final otHours = rec.overtimeHours!;
    final isSunday = rec.date.weekday == DateTime.sunday;

    if (rec.status == AttendanceStatus.publicHoliday)
      return 0.0; // handled separately
    if (isSunday) {
      return otHours * hourlyRate * (SaStatutory.sundayMultiplier - 1.0);
    }
    return otHours * hourlyRate * (SaStatutory.overtimeMultiplier - 1.0);
  }

  // ─── Deduction computation ───────────────────────────────────────────────
  List<PayslipDeductionLine> _computeDeductions({
    required String employeeId,
    required double grossPay,
    required List<DeductionRule> rules,
    List<GarnisheeOrder> garnisheeOrders = const [],
    List<String>? warnings,
    DateTime? dateOfBirth,
    DateTime? periodStart,
  }) {
    final lines = <PayslipDeductionLine>[];

    // UIF Employee 1% — always applied regardless of rules list
    final uifBase = min(grossPay, SaStatutory.uifMonthlyCap);
    lines.add(
      PayslipDeductionLine(
        code: 'UIF_EE',
        description: 'UIF (Employee 1%)',
        amount: _round2(uifBase * SaStatutory.uifRate),
        isStatutory: true,
      ),
    );

    // PAYE (age-appropriate rebates applied when dateOfBirth is available)
    final monthlyPaye = SaStatutory.computeMonthlyPaye(
      grossPay,
      dateOfBirth: dateOfBirth,
      assessmentDate: periodStart,
    );
    if (monthlyPaye > 0) {
      lines.add(
        PayslipDeductionLine(
          code: 'PAYE',
          description: 'PAYE Income Tax',
          amount: _round2(monthlyPaye),
          isStatutory: true,
        ),
      );
    }

    // Voluntary / benefit rules from deduction rules list
    for (final rule in rules) {
      if (!rule.isActive) continue;
      if (rule.code == 'UIF_EE' || rule.code == 'UIF_ER' || rule.code == 'PAYE')
        continue; // already handled
      if (rule.employeeIds != null && !rule.employeeIds!.contains(employeeId))
        continue;

      double amount;
      if (rule.basis == DeductionBasis.fixedAmount) {
        amount = rule.value;
      } else {
        // percentage
        amount = grossPay * (rule.value / 100.0);
      }
      if (rule.cappedAt != null) {
        amount = min(amount, rule.cappedAt!);
      }

      lines.add(
        PayslipDeductionLine(
          code: rule.code,
          description: rule.label,
          amount: _round2(amount),
          isStatutory: rule.type == DeductionType.statutory,
        ),
      );
    }

    // Garnishee orders — BCEA §34: voluntary + garnishee capped at 25% of net-after-statutory
    final statutory = lines.fold(
      0.0,
      (s, l) => s + (l.isStatutory ? l.amount : 0.0),
    );
    final netAfterStatutory = _round2(grossPay - statutory);
    final cap = _round2(netAfterStatutory * 0.25);
    final activeGarnishees = garnisheeOrders.where((o) => o.isActive).toList();
    if (activeGarnishees.isNotEmpty) {
      final voluntary = lines.fold(
        0.0,
        (s, l) => s + (l.isStatutory ? 0.0 : l.amount),
      );
      double garnisheeTotal = activeGarnishees.fold(
        0.0,
        (s, o) => s + o.monthlyDeductionAmount,
      );
      final available = _round2(max(0.0, cap - voluntary));
      if (garnisheeTotal > available) {
        warnings?.add(
          'DEDUCTION_CAP_EXCEEDED: garnishee R${garnisheeTotal.toStringAsFixed(2)} '
          'reduced to R${available.toStringAsFixed(2)} (25% BCEA cap)',
        );
        // Scale each order proportionally
        for (final order in activeGarnishees) {
          final scaled = garnisheeTotal > 0
              ? _round2(
                  order.monthlyDeductionAmount * available / garnisheeTotal,
                )
              : 0.0;
          lines.add(
            PayslipDeductionLine(
              code: 'GARNISHEE_${order.id}',
              description:
                  'Court Order (${order.courtOrderRef}) — ${order.creditorName} [capped]',
              amount: scaled,
              isStatutory: false,
            ),
          );
        }
      } else {
        for (final order in activeGarnishees) {
          lines.add(
            PayslipDeductionLine(
              code: 'GARNISHEE_${order.id}',
              description:
                  'Court Order (${order.courtOrderRef}) — ${order.creditorName}',
              amount: _round2(order.monthlyDeductionAmount),
              isStatutory: false,
            ),
          );
        }
      }
    }

    return lines;
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  double _effectiveHourlyRate(PayStructure ps, double? override) {
    switch (ps.wageType) {
      case WageType.hourlyRate:
        return override ?? ps.baseRate;
      case WageType.dailyRate:
        return (override ?? ps.baseRate) / 8.0;
      case WageType.monthlySalary:
        return (override ?? ps.baseRate) / 173.33;
      case WageType.piecework:
        return SaStatutory.nmwaHourly; // fallback
    }
  }

  static double _round2(double v) => double.parse(v.toStringAsFixed(2));

  static String _payslipNumber(DateTime periodStart, String employeeId) {
    final mm = periodStart.month.toString().padLeft(2, '0');
    return '${periodStart.year}$mm-$employeeId';
  }

  // ─── Pre-payroll sanity check ─────────────────────────────────────────────
  /// Returns a list of human-readable warnings that should be shown to the
  /// user before they confirm the pay run calculation.
  List<String> prePayrollChecks({
    required List<EmployeePayInput> inputs,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final issues = <String>[];
    final periodDays = periodEnd.difference(periodStart).inDays + 1;

    for (final input in inputs) {
      final emp = input.employee;
      final name = '${emp.firstName} ${emp.lastName}';

      // Missing bank details for bank-disbursement employees
      if (emp.disbursementMethod == DisbursementMethod.bank &&
          (emp.bankAccountNumber == null || emp.bankAccountNumber!.isEmpty)) {
        issues.add('$name: no bank account — payment will fail.');
      }

      // No attendance records in period
      if (input.payStructure.wageType != WageType.monthlySalary &&
          input.attendanceRecords.isEmpty) {
        issues.add(
          '$name: no attendance records for period '
          '${periodStart.toIso8601String().substring(0, 10)} – '
          '${periodEnd.toIso8601String().substring(0, 10)}.',
        );
      }

      // Expired contract
      if (emp.endDate != null && emp.endDate!.isBefore(periodEnd)) {
        issues.add(
          '$name: contract ended ${emp.endDate!.toIso8601String().substring(0, 10)}.',
        );
      }

      // Piecework with no logs
      if (input.payStructure.wageType == WageType.piecework &&
          input.pieceworkLogs.isEmpty) {
        issues.add(
          '$name: piecework structure but no piecework logs in period.',
        );
      }

      // Unexpectedly high overtime (>20% of period days)
      final totalOt = input.attendanceRecords.fold(
        0.0,
        (s, r) => s + (r.overtimeHours ?? 0.0),
      );
      if (totalOt > periodDays * 2) {
        issues.add(
          '$name: ${totalOt.toStringAsFixed(1)} overtime hours seem unusually high.',
        );
      }
    }

    return issues;
  }
}
