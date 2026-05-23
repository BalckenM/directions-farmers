// Sprint 1 — Payroll Engine Compliance Tests
// Covers: BCEA §34 deduction floor, SDL levy, ETI credit, COIDA contribution.

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/features/payroll/models/attendance_record.dart';
import 'package:mobile_app/features/payroll/models/payroll_employee.dart'
    show
        DisbursementMethod,
        EmploymentStatus,
        EngagementType,
        PayrollEmployee;
import 'package:mobile_app/features/payroll/models/deduction_rule.dart';
import 'package:mobile_app/features/payroll/models/pay_structure.dart';

import 'package:mobile_app/features/payroll/services/payroll_engine.dart';

// ─── Shared helpers ──────────────────────────────────────────────────────────

const _engine = PayrollEngine();

PayrollEmployee _makeEmployee({
  String id = 'emp_test',
  DateTime? dateOfBirth,
  DateTime? startDate,
}) {
  return PayrollEmployee(
    id: id,
    firstName: 'Test',
    lastName: 'Worker',
    idOrPassportNumber: '9001015009087',
    address: '1 Farm Road',
    nextOfKinName: 'Jane Worker',
    nextOfKinPhone: '0821234567',
    status: EmploymentStatus.active,
    engagementType: EngagementType.permanent,
    occupationTitle: 'Farm Worker',
    startDate: startDate ?? DateTime(2023, 1, 1),
    disbursementMethod: DisbursementMethod.bank,
    preferredLanguage: 'en',
    hasHousingBenefit: false,
    hasFoodBenefit: false,
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
    dateOfBirth: dateOfBirth,
  );
}

PayStructure _makePayStructure({
  WageType wageType = WageType.monthlySalary,
  double baseRate = 5000.0,
  bool nmwaEnforced = true,
}) {
  return PayStructure(
    id: 'ps_test',
    name: 'Test Structure',
    wageType: wageType,
    baseRate: baseRate,
    nmwaEnforced: nmwaEnforced,
    createdAt: DateTime(2023, 1, 1),
  );
}

AttendanceRecord _presentDay(DateTime date, {double hoursWorked = 8.0}) {
  return AttendanceRecord(
    id: 'ar_${date.toIso8601String()}',
    employeeId: 'emp_test',
    date: date,
    status: AttendanceStatus.present,
    hoursWorked: hoursWorked,
    recordedByUserId: 'system',
    method: AttendanceMethod.manual,
    createdAt: date,
  );
}

/// Generate a list of 26 working days in Jan 2025
List<AttendanceRecord> _januaryAttendance({double hoursPerDay = 8.0}) {
  final days = <AttendanceRecord>[];
  final start = DateTime(2025, 1, 1);
  for (var d = 0; d < 31; d++) {
    final date = start.add(Duration(days: d));
    if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
      days.add(_presentDay(date, hoursWorked: hoursPerDay));
    }
  }
  return days;
}

EmployeePayInput _makeInput({
  required PayrollEmployee emp,
  required PayStructure ps,
  List<DeductionRule> rules = const [],
  double? salaryOverride,
  List<AttendanceRecord>? attendance,
}) {
  return EmployeePayInput(
    employee: emp,
    payStructure: ps,
    attendanceRecords: attendance ?? _januaryAttendance(),
    pieceworkLogs: const [],
    deductionRules: rules,
    salaryOverride: salaryOverride,
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ── 1. BCEA §34 deduction floor ──────────────────────────────────────────
  group('BCEA §34 deduction floor', () {
    test('fires nmwaBreach when deductions push net below NMWA floor', () {
      final emp = _makeEmployee();
      final ps = _makePayStructure(baseRate: 4500.0, nmwaEnforced: true);

      // A massive voluntary deduction that pushes net below NMWA monthly floor
      final bigDeduction = DeductionRule(
        id: 'dr_big',
        code: 'LOAN_BIG',
        label: 'Big Loan',
        type: DeductionType.voluntary,
        basis: DeductionBasis.fixedAmount,
        value: 3000.0, // will sink net well below ~R4409
        isActive: true,
        createdAt: DateTime(2023, 1, 1),
      );

      final input = _makeInput(emp: emp, ps: ps, rules: [bigDeduction]);
      final result = _engine.calculatePayRun(
        payRunId: 'pr_floor_test',
        payGroupId: 'pg_test',
        periodStart: DateTime(2025, 1, 1),
        periodEnd: DateTime(2025, 1, 31),
        payDate: DateTime(2025, 1, 31),
        inputs: [input],
      );

      expect(result.complianceAlerts.any((a) => a.code == 'NMWA_BREACH'), isTrue,
          reason: 'Should have NMWA_BREACH alert when deductions breach BCEA §34 floor');
    });

    test('no breach when deductions are modest and net stays above floor', () {
      final emp = _makeEmployee();
      final ps = _makePayStructure(baseRate: 12000.0);

      final input = _makeInput(emp: emp, ps: ps);
      final result = _engine.calculatePayRun(
        payRunId: 'pr_no_breach',
        payGroupId: 'pg_test',
        periodStart: DateTime(2025, 1, 1),
        periodEnd: DateTime(2025, 1, 31),
        payDate: DateTime(2025, 1, 31),
        inputs: [input],
      );

      final breachAlerts = result.complianceAlerts.where((a) => a.code == 'NMWA_BREACH').toList();
      expect(breachAlerts, isEmpty,
          reason: 'No breach alert expected when net pay exceeds NMWA floor');
    });
  });

  // ── 2. SDL levy ───────────────────────────────────────────────────────────
  group('SDL levy', () {
    test('SDL is applied when annualised payroll exceeds R500,000 threshold', () {
      // One employee on R50,000/month = R600,000 annualised — above R500k
      final emp = _makeEmployee();
      final ps = _makePayStructure(baseRate: 50000.0);

      final input = _makeInput(emp: emp, ps: ps);
      final result = _engine.calculatePayRun(
        payRunId: 'pr_sdl_above',
        payGroupId: 'pg_test',
        periodStart: DateTime(2025, 1, 1),
        periodEnd: DateTime(2025, 1, 31),
        payDate: DateTime(2025, 1, 31),
        inputs: [input],
      );

      // SDL = 1% of grossPay for this period
      final sdl = result.payRun.sdlContribution;
      expect(sdl, greaterThan(0),
          reason: 'SDL must be > 0 when annualised payroll exceeds R500,000');
      expect(sdl, closeTo(50000.0 * 0.01, 5.0),
          reason: 'SDL should be approximately 1% of gross pay');
    });

    test('SDL is zero when annualised payroll is below R500,000 threshold', () {
      // R3,000/month × 12 = R36,000 — well below R500k
      final emp = _makeEmployee();
      final ps = _makePayStructure(baseRate: 3000.0);

      final input = _makeInput(emp: emp, ps: ps);
      final result = _engine.calculatePayRun(
        payRunId: 'pr_sdl_below',
        payGroupId: 'pg_test',
        periodStart: DateTime(2025, 1, 1),
        periodEnd: DateTime(2025, 1, 31),
        payDate: DateTime(2025, 1, 31),
        inputs: [input],
      );

      expect(result.payRun.sdlContribution, equals(0.0),
          reason: 'SDL must be 0.0 when annualised payroll is below the R500,000 threshold');
    });
  });

  // ── 3. ETI credit ─────────────────────────────────────────────────────────
  group('ETI (Employment Tax Incentive)', () {
    // Age: 25, start month = month 6 of employment (within 1-12 window) → R1,500
    test('computeEti returns R1500 in month 6 for qualifying employee', () {
      final periodStart = DateTime(2025, 6, 1);
      final emp = _makeEmployee(
        dateOfBirth: DateTime(2000, 1, 15), // age 25 at June 2025
        startDate: DateTime(2025, 1, 1),    // 6 months employed
      );

      final credit = PayrollEngine.computeEti(
        emp: emp,
        monthlySalary: 4000.0,
        periodStart: periodStart,
      );

      expect(credit, equals(1500.0),
          reason: 'Month 6 in first year should yield R1,500 ETI credit');
    });

    // Same employee, month 14 (second year window) → R750
    test('computeEti returns R750 in month 14 for qualifying employee', () {
      final periodStart = DateTime(2026, 3, 1);
      final emp = _makeEmployee(
        dateOfBirth: DateTime(2000, 1, 15),
        startDate: DateTime(2025, 1, 1), // 14 months employed by Mar 2026
      );

      final credit = PayrollEngine.computeEti(
        emp: emp,
        monthlySalary: 4000.0,
        periodStart: periodStart,
      );

      expect(credit, equals(750.0),
          reason: 'Month 14 (second year) should yield R750 ETI credit');
    });

    test('computeEti returns 0 when salary exceeds R6,500 cap', () {
      final emp = _makeEmployee(
        dateOfBirth: DateTime(2000, 1, 15),
        startDate: DateTime(2025, 1, 1),
      );

      final credit = PayrollEngine.computeEti(
        emp: emp,
        monthlySalary: 7000.0,
        periodStart: DateTime(2025, 6, 1),
      );

      expect(credit, equals(0.0),
          reason: 'Salary above R6,500 should disqualify ETI');
    });

    test('computeEti returns 0 when employee has no dateOfBirth', () {
      final emp = _makeEmployee(dateOfBirth: null);
      final credit = PayrollEngine.computeEti(
        emp: emp,
        monthlySalary: 4000.0,
        periodStart: DateTime(2025, 6, 1),
      );
      expect(credit, equals(0.0));
    });
  });

  // ── 4. COIDA contribution ─────────────────────────────────────────────────
  group('COIDA assessment contribution', () {
    test('computeCoida applies 1.25% to annual earnings', () {
      const monthlyGross = 10000.0;
      final coida = PayrollEngine.computeCoida(monthlyGross * 12);
      // 10000 × 12 × 1.25% = 1500.00
      expect(coida, closeTo(1500.0, 0.01),
          reason: 'COIDA should be 1.25% of annualised earnings');
    });

    test('computeCoida caps at annual ceiling R484,200', () {
      // Earnings far above ceiling
      final coida = PayrollEngine.computeCoida(1_000_000.0);
      final expected = SaStatutory.coidaAnnualCeiling * SaStatutory.coidaDefaultRate;
      expect(coida, closeTo(expected, 0.01),
          reason: 'COIDA must be capped at the annual earnings ceiling of R484,200');
    });

    test('computeCoida result surfaced in PayRun after calculatePayRun', () {
      final emp = _makeEmployee();
      final ps = _makePayStructure(baseRate: 10000.0);

      final result = _engine.calculatePayRun(
        payRunId: 'pr_coida_test',
        payGroupId: 'pg_test',
        periodStart: DateTime(2025, 1, 1),
        periodEnd: DateTime(2025, 1, 31),
        payDate: DateTime(2025, 1, 31),
        inputs: [_makeInput(emp: emp, ps: ps)],
      );

      expect(result.payRun.totalCoidaContribution, greaterThan(0),
          reason: 'totalCoidaContribution should be populated in PayRun');
    });
  });
}
