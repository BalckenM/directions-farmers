import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/payroll/data/payroll_mock_data_source.dart';
import 'package:mobile_app/features/payroll/models/garnishee_order.dart';
import 'package:mobile_app/features/payroll/models/pay_structure.dart';
import 'package:mobile_app/features/payroll/models/payroll_employee.dart';
import 'package:mobile_app/features/payroll/services/payroll_engine.dart';

/// Sprint 6 — Garnishee & 25% deduction cap tests.
void main() {
  // ── Mock data source CRUD ─────────────────────────────────────────────────
  group('PayrollMockDataSource — garnishee CRUD', () {
    late PayrollMockDataSource ds;
    late GarnisheeOrder order;

    setUp(() {
      ds = PayrollMockDataSource();
      order = GarnisheeOrder(
        id: 'go1',
        employeeId: 'emp1',
        courtOrderRef: 'MAG/2025/0001',
        creditorName: 'ABC Finance',
        monthlyDeductionAmount: 500,
        totalOwed: 6000,
        amountDeducted: 0,
        status: GarnisheeStatus.active,
        createdAt: DateTime(2025, 1, 1),
      );
    });

    test('addGarnisheeOrder stores order and returns it', () {
      final added = ds.addGarnisheeOrder(order);
      expect(added.id, equals('go1'));
      expect(ds.getGarnisheeOrders(), hasLength(1));
    });

    test('getGarnisheeOrders filters by employeeId', () {
      ds.addGarnisheeOrder(order);
      ds.addGarnisheeOrder(order.copyWith(id: 'go2', employeeId: 'emp2'));
      expect(ds.getGarnisheeOrders(employeeId: 'emp1'), hasLength(1));
      expect(ds.getGarnisheeOrders(employeeId: 'emp2'), hasLength(1));
    });

    test('updateGarnisheeOrder persists changes', () {
      ds.addGarnisheeOrder(order);
      final updated = order.copyWith(
        amountDeducted: 500,
        status: GarnisheeStatus.active,
      );
      ds.updateGarnisheeOrder(updated);
      final fetched = ds.getGarnisheeOrders(employeeId: 'emp1').first;
      expect(fetched.amountDeducted, equals(500));
    });

    test('updateGarnisheeOrder throws for unknown id', () {
      expect(() => ds.updateGarnisheeOrder(order), throwsStateError);
    });
  });

  // ── GarnisheeOrder model ──────────────────────────────────────────────────
  group('GarnisheeOrder model', () {
    test('outstandingBalance clamps to 0 when fully paid', () {
      final o = GarnisheeOrder(
        id: 'go1',
        employeeId: 'e1',
        courtOrderRef: 'REF',
        creditorName: 'C',
        monthlyDeductionAmount: 100,
        totalOwed: 1000,
        amountDeducted: 1000,
        status: GarnisheeStatus.satisfied,
        createdAt: DateTime(2025),
      );
      expect(o.outstandingBalance, equals(0.0));
    });

    test('isActive false when status is satisfied', () {
      final o = GarnisheeOrder(
        id: 'go1',
        employeeId: 'e1',
        courtOrderRef: 'REF',
        creditorName: 'C',
        monthlyDeductionAmount: 100,
        totalOwed: 1000,
        amountDeducted: 1000,
        status: GarnisheeStatus.satisfied,
        createdAt: DateTime(2025),
      );
      expect(o.isActive, isFalse);
    });
  });

  // ── Engine 25% cap ────────────────────────────────────────────────────────
  group('PayrollEngine 25% deduction cap', () {
    late PayrollEmployee employee;
    late PayStructure payStructure;

    setUp(() {
      employee = PayrollEmployee(
        id: 'emp1',
        firstName: 'Cap',
        lastName: 'Test',
        idOrPassportNumber: '9001015009087',
        address: '1 Farm',
        nextOfKinName: 'Kin',
        nextOfKinPhone: '0821234567',
        status: EmploymentStatus.active,
        engagementType: EngagementType.permanent,
        occupationTitle: 'Worker',
        startDate: DateTime(2020, 1, 1),
        disbursementMethod: DisbursementMethod.bank,
        preferredLanguage: 'en',
        hasHousingBenefit: false,
        hasFoodBenefit: false,
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
      );
      payStructure = PayStructure(
        id: 'ps1',
        name: 'Standard',
        wageType: WageType.monthlySalary,
        baseRate: 10000,
        nmwaEnforced: false,
        createdAt: DateTime(2020, 1, 1),
      );
    });

    test('garnishee within cap passes through unchanged', () {
      // gross=10000, PAYE~1095, UIF=100 → net-after-statutory~8805, cap~2201
      // garnishee=500 < cap → no scaling
      final order = GarnisheeOrder(
        id: 'go1',
        employeeId: 'emp1',
        courtOrderRef: 'MAG/001',
        creditorName: 'Lender',
        monthlyDeductionAmount: 500,
        totalOwed: 6000,
        amountDeducted: 0,
        status: GarnisheeStatus.active,
        createdAt: DateTime(2025, 1, 1),
      );
      final engine = PayrollEngine();
      final result = engine.calculatePayRun(
        payRunId: 'pr1',
        payGroupId: 'pg1',
        periodStart: DateTime(2025, 3, 1),
        periodEnd: DateTime(2025, 3, 31),
        payDate: DateTime(2025, 3, 25),
        inputs: [
          EmployeePayInput(
            employee: employee,
            payStructure: payStructure,
            attendanceRecords: [],
            pieceworkLogs: [],
            deductionRules: [],
            salaryOverride: null,
            garnisheeOrders: [order],
          ),
        ],
      );
      final payslip = result.payslips.first;
      final garnisheeLine = payslip.deductions
          .where((d) => d.code.startsWith('GARNISHEE_'))
          .toList();
      expect(garnisheeLine, hasLength(1));
      expect(garnisheeLine.first.amount, equals(500.0));
    });

    test('garnishee exceeding 25% cap is scaled down and warning emitted', () {
      // gross=10000, statutory UIF+PAYE ~1195 → net-after-statutory ~8805, cap ~2201
      // garnishee=3000 > cap → scaled; warning emitted
      final bigOrder = GarnisheeOrder(
        id: 'go1',
        employeeId: 'emp1',
        courtOrderRef: 'MAG/002',
        creditorName: 'BigLender',
        monthlyDeductionAmount: 3000,
        totalOwed: 30000,
        amountDeducted: 0,
        status: GarnisheeStatus.active,
        createdAt: DateTime(2025, 1, 1),
      );
      final engine = PayrollEngine();
      final result = engine.calculatePayRun(
        payRunId: 'pr1',
        payGroupId: 'pg1',
        periodStart: DateTime(2025, 3, 1),
        periodEnd: DateTime(2025, 3, 31),
        payDate: DateTime(2025, 3, 25),
        inputs: [
          EmployeePayInput(
            employee: employee,
            payStructure: payStructure,
            attendanceRecords: [],
            pieceworkLogs: [],
            deductionRules: [],
            salaryOverride: null,
            garnisheeOrders: [bigOrder],
          ),
        ],
      );
      final payslip = result.payslips.first;
      final garnisheeLine = payslip.deductions
          .where((d) => d.code.startsWith('GARNISHEE_'))
          .toList();
      expect(garnisheeLine, hasLength(1));
      expect(garnisheeLine.first.amount, lessThan(3000.0));
      // Warning is surfaced as a compliance alert
      expect(
        result.complianceAlerts.any((a) => a.code == 'DEDUCTION_CAP_EXCEEDED'),
        isTrue,
      );
    });
  });
}
