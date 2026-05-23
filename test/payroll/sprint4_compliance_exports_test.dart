import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/payroll/models/employer_config.dart';
import 'package:mobile_app/features/payroll/models/pay_run.dart';
import 'package:mobile_app/features/payroll/models/payroll_employee.dart';
import 'package:mobile_app/features/payroll/models/payslip.dart';
import 'package:mobile_app/features/payroll/services/emp201_export_service.dart';
import 'package:mobile_app/features/payroll/services/uif_export_service.dart';

PayrollEmployee _mkEmployee() => PayrollEmployee(
  id: 'emp1',
  firstName: 'Jane',
  lastName: 'Farmer',
  idOrPassportNumber: '9001015009087',
  address: '1 Farm Rd',
  nextOfKinName: 'John Farmer',
  nextOfKinPhone: '0821234567',
  status: EmploymentStatus.active,
  engagementType: EngagementType.permanent,
  occupationTitle: 'Field Worker',
  payGroupId: 'pg1',
  startDate: DateTime(2020, 1, 1),
  disbursementMethod: DisbursementMethod.bank,
  preferredLanguage: 'en',
  hasHousingBenefit: false,
  hasFoodBenefit: false,
  createdAt: DateTime(2020, 1, 1),
  updatedAt: DateTime(2020, 1, 1),
);

Payslip _mkPayslip() => Payslip(
  id: 'ps1',
  payRunId: 'pr1',
  employeeId: 'emp1',
  periodStart: DateTime(2025, 3, 1),
  periodEnd: DateTime(2025, 3, 31),
  payDate: DateTime(2025, 3, 25),
  basicWage: 8000,
  overtimePay: 0,
  holidayPay: 0,
  inKindHousing: 0,
  inKindFood: 0,
  otherEarnings: 0,
  grossPay: 8000,
  deductions: [
    PayslipDeductionLine(
      code: 'UIF_EE',
      description: 'UIF EE',
      amount: 80,
      isStatutory: true,
    ),
    PayslipDeductionLine(
      code: 'PAYE',
      description: 'PAYE',
      amount: 600,
      isStatutory: true,
    ),
  ],
  totalDeductions: 680,
  netPay: 7320,
  leaveBalanceSnapshot: {},
  payslipNumber: '202503-emp1',
  createdAt: DateTime(2025, 3, 25),
);

PayRun _mkPayRun() => PayRun(
  id: 'pr1',
  payGroupId: 'pg1',
  periodStart: DateTime(2025, 3, 1),
  periodEnd: DateTime(2025, 3, 31),
  payDate: DateTime(2025, 3, 25),
  status: PayRunStatus.approved,
  employeeCount: 1,
  totalGross: 8000,
  totalDeductions: 680,
  totalNet: 7320,
  etiCredit: 0,
  complianceAlertIds: [],
  lineItems: [],
  createdAt: DateTime(2025, 3, 1),
  updatedAt: DateTime(2025, 3, 1),
);

void main() {
  final config = EmployerConfig(
    name: 'Test Farm (Pty) Ltd',
    registrationNumber: '2021/123456/07',
    uifReferenceNumber: 'UIF-TEST-001',
    payeNumber: '7012345678',
  );

  final employee = _mkEmployee();
  final payslip = _mkPayslip();
  final payRun = _mkPayRun();

  // ── UIF UI-19 tests ───────────────────────────────────────────────────────
  group('UifExportService', () {
    test('generateUi19Csv includes header row', () {
      final csv = UifExportService.generateUi19Csv(
        payslips: [payslip],
        employees: [employee],
        config: config,
        period: '2025-03',
      );
      expect(csv, contains('Employer Ref'));
      expect(csv, contains('Employee ID'));
      expect(csv, contains('Gross Remuneration'));
    });

    test('generateUi19Csv contains correct employer UIF reference', () {
      final csv = UifExportService.generateUi19Csv(
        payslips: [payslip],
        employees: [employee],
        config: config,
        period: '2025-03',
      );
      expect(csv, contains(config.uifReferenceNumber));
    });

    test('generateUi19Csv computes UIF as 1% of gross (gross <= cap)', () {
      final csv = UifExportService.generateUi19Csv(
        payslips: [payslip],
        employees: [employee],
        config: config,
        period: '2025-03',
      );
      // UIF EE = 8000 * 0.01 = 80.00 (from payslip deduction); ER = 80.00
      expect(csv, contains('80.00'));
    });

    test('filenameFor produces correct format', () {
      final name = UifExportService.filenameFor(config, DateTime(2025, 3, 1));
      expect(name, startsWith('UI-19_2025-03_'));
      expect(name, endsWith('.csv'));
    });
  });

  // ── EMP201 tests ──────────────────────────────────────────────────────────
  group('Emp201ExportService', () {
    late Map<String, dynamic> result;

    setUp(() {
      result = Emp201ExportService.generateEmp201(
        payRun: payRun,
        payslips: [payslip],
        config: config,
      );
    });

    test('contains all required SARS keys', () {
      for (final key in [
        'employerRef',
        'employerName',
        'uifReference',
        'period',
        'totalGrossRemuneration',
        'paye4102',
        'sdlEmployer',
        'uifEmployee4141',
        'uifEmployer4142',
        'etiCredit',
        'totalLiability',
      ]) {
        expect(result, contains(key), reason: 'Missing key: $key');
      }
    });

    test('employerRef is PAYE number', () {
      expect(result['employerRef'], equals(config.payeNumber));
    });

    test('paye4102 matches payslip PAYE deduction', () {
      expect(result['paye4102'], equals(600.0));
    });

    test('uifEmployee4141 matches payslip UIF_EE deduction', () {
      expect(result['uifEmployee4141'], equals(80.0));
    });

    test('uifEmployer4142 mirrors employee UIF', () {
      expect(result['uifEmployer4142'], equals(result['uifEmployee4141']));
    });

    test('sdlEmployer is 0 when annualised payroll <= 500k threshold', () {
      // 8000 * 12 = 96000 < 500000
      expect(result['sdlEmployer'], equals(0.0));
    });

    test('sdlEmployer is non-zero when annualised payroll > 500k', () {
      // gross = 50000 → 50000 * 12 = 600000 > 500000
      final bigPayslip = Payslip(
        id: 'ps2',
        payRunId: 'pr2',
        employeeId: 'emp1',
        periodStart: DateTime(2025, 3, 1),
        periodEnd: DateTime(2025, 3, 31),
        payDate: DateTime(2025, 3, 25),
        basicWage: 50000,
        overtimePay: 0,
        holidayPay: 0,
        inKindHousing: 0,
        inKindFood: 0,
        otherEarnings: 0,
        grossPay: 50000,
        deductions: [],
        totalDeductions: 0,
        netPay: 50000,
        leaveBalanceSnapshot: {},
        payslipNumber: '202503-emp1',
        createdAt: DateTime(2025, 3, 25),
      );
      final bigRun = payRun.copyWith(id: 'pr2', totalGross: 50000);
      final res = Emp201ExportService.generateEmp201(
        payRun: bigRun,
        payslips: [bigPayslip],
        config: config,
      );
      expect(res['sdlEmployer'], greaterThan(0));
    });

    test('totalLiability = PAYE + UIF_EE + UIF_ER + SDL - ETI', () {
      final expected =
          (result['paye4102'] as double) +
          (result['uifEmployee4141'] as double) +
          (result['uifEmployer4142'] as double) +
          (result['sdlEmployer'] as double) -
          (result['etiCredit'] as double);
      expect(result['totalLiability'], closeTo(expected, 0.01));
    });
  });
}
