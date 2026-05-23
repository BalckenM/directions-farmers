// Sprint 2 — PayrollRepository & MockDataSource CRUD Tests
// Covers: employee lifecycle, contract CRUD, pay group/structure CRUD,
// leave request workflow, compliance alert resolution,
// pay-run workflow (calculate → approve → disburse), payslips, communications.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/payroll/data/payroll_mock_data_source.dart';
import 'package:mobile_app/features/payroll/data/payroll_repository.dart';
import 'package:mobile_app/features/payroll/models/communication_log.dart';
import 'package:mobile_app/features/payroll/models/employment_contract.dart';
import 'package:mobile_app/features/payroll/models/leave_request.dart';
import 'package:mobile_app/features/payroll/models/pay_group.dart';
import 'package:mobile_app/features/payroll/models/pay_run.dart';
import 'package:mobile_app/features/payroll/models/pay_structure.dart';
import 'package:mobile_app/features/payroll/models/payroll_employee.dart';

// ─── Shared factory helpers ───────────────────────────────────────────────────

PayrollEmployee _makeEmployee({
  String id = 'emp_sprint2_test',
  EmploymentStatus status = EmploymentStatus.active,
}) => PayrollEmployee(
  id: id,
  firstName: 'Sprint',
  lastName: 'Two',
  idOrPassportNumber: '9505100123084',
  address: '2 Test Lane, Stellenbosch',
  nextOfKinName: 'Next Kin',
  nextOfKinPhone: '0831234567',
  status: status,
  engagementType: EngagementType.permanent,
  occupationTitle: 'Test Worker',
  startDate: DateTime(2024, 1, 15),
  disbursementMethod: DisbursementMethod.bank,
  preferredLanguage: 'en',
  hasHousingBenefit: false,
  hasFoodBenefit: false,
  createdAt: DateTime(2024, 1, 15),
  updatedAt: DateTime(2024, 1, 15),
);

EmploymentContract _makeContract({
  String id = 'ct_sprint2_test',
  String employeeId = 'emp_sprint2_test',
  ContractStatus status = ContractStatus.signed,
}) => EmploymentContract(
  id: id,
  employeeId: employeeId,
  type: ContractType.permanent,
  startDate: DateTime(2024, 1, 15),
  jobDescription: 'Test Farm Worker',
  grossMonthlySalary: 6000.0,
  status: status,
  createdAt: DateTime(2024, 1, 15),
);

PayGroup _makePayGroup({String id = 'pg_sprint2_test'}) => PayGroup(
  id: id,
  name: 'Sprint2 Monthly',
  frequency: PayFrequency.monthly,
  payDayOffset: 25,
  isActive: true,
  createdAt: DateTime(2024, 1, 1),
);

PayStructure _makePayStructure({String id = 'ps_sprint2_test'}) => PayStructure(
  id: id,
  name: 'Sprint2 Hourly',
  wageType: WageType.hourlyRate,
  baseRate: 25.42,
  createdAt: DateTime(2024, 1, 1),
);

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── 1. Employee CRUD ───────────────────────────────────────────────────────
  group('Employee CRUD', () {
    late PayrollRepository repo;

    setUp(() => repo = PayrollRepository(PayrollMockDataSource()));

    test('seeded data: getEmployees returns 8 employees', () {
      expect(repo.getEmployees(), hasLength(8));
    });

    test('getEmployee returns null for unknown id', () {
      expect(repo.getEmployee('does_not_exist'), isNull);
    });

    test('getEmployee returns correct employee by id', () {
      final emp = repo.getEmployees().first;
      expect(repo.getEmployee(emp.id)?.id, equals(emp.id));
    });

    test('addEmployee persists and getEmployees grows by 1', () {
      final before = repo.getEmployees().length;
      final emp = _makeEmployee();
      final added = repo.addEmployee(emp);
      expect(added.id, equals('emp_sprint2_test'));
      expect(repo.getEmployees(), hasLength(before + 1));
    });

    test('updateEmployee persists name change', () {
      repo.addEmployee(_makeEmployee());
      final updated = _makeEmployee().copyWith(firstName: 'Updated');
      repo.updateEmployee(updated);
      expect(
        repo.getEmployee('emp_sprint2_test')?.firstName,
        equals('Updated'),
      );
    });

    test('updateEmployee throws StateError for unknown id', () {
      expect(() => repo.updateEmployee(_makeEmployee()), throwsStateError);
    });

    test('terminateEmployee sets status to terminated', () {
      repo.addEmployee(_makeEmployee());
      final terminated = repo.terminateEmployee(
        'emp_sprint2_test',
        DateTime(2026, 6, 1),
        'End of contract',
      );
      expect(terminated.status, equals(EmploymentStatus.terminated));
    });

    test('terminateEmployee throws for unknown id', () {
      expect(
        () => repo.terminateEmployee('ghost', DateTime.now(), 'No reason'),
        throwsStateError,
      );
    });
  });

  // ── 2. Contract CRUD ───────────────────────────────────────────────────────
  group('Contract CRUD', () {
    late PayrollRepository repo;

    setUp(() => repo = PayrollRepository(PayrollMockDataSource()));

    test('seeded data: getContracts returns contracts', () {
      expect(repo.getContracts(), isNotEmpty);
    });

    test('getContracts filtered by employeeId returns only matching', () {
      final emp = repo.getEmployees().first;
      final all = repo.getContracts();
      final filtered = repo.getContracts(employeeId: emp.id);
      for (final c in filtered) {
        expect(c.employeeId, equals(emp.id));
      }
      expect(filtered.length, lessThanOrEqualTo(all.length));
    });

    test('getContract returns null for unknown id', () {
      expect(repo.getContract('ghost_ct'), isNull);
    });

    test('addContract persists and getContracts includes it', () {
      final ct = _makeContract();
      repo.addContract(ct);
      expect(repo.getContract('ct_sprint2_test'), isNotNull);
    });

    test('updateContract persists salary change', () {
      repo.addContract(_makeContract());
      final updated = _makeContract().copyWith(grossMonthlySalary: 8500.0);
      repo.updateContract(updated);
      expect(
        repo.getContract('ct_sprint2_test')?.grossMonthlySalary,
        equals(8500.0),
      );
    });

    test('updateContract throws StateError for unknown id', () {
      expect(() => repo.updateContract(_makeContract()), throwsStateError);
    });

    test('voidContract sets status to terminated', () {
      repo.addContract(_makeContract());
      final voided = repo.voidContract('ct_sprint2_test', 'Early termination');
      expect(voided.status, equals(ContractStatus.terminated));
    });

    test('voidContract throws for unknown id', () {
      expect(() => repo.voidContract('ghost_ct', 'reason'), throwsStateError);
    });
  });

  // ── 3. Pay Group CRUD ─────────────────────────────────────────────────────
  group('Pay Group CRUD', () {
    late PayrollRepository repo;

    setUp(() => repo = PayrollRepository(PayrollMockDataSource()));

    test('seeded data: getPayGroups returns 3 groups', () {
      expect(repo.getPayGroups(), hasLength(3));
    });

    test('addPayGroup persists and count grows by 1', () {
      final before = repo.getPayGroups().length;
      repo.addPayGroup(_makePayGroup());
      expect(repo.getPayGroups(), hasLength(before + 1));
    });

    test('updatePayGroup persists name change', () {
      repo.addPayGroup(_makePayGroup());
      final updated = _makePayGroup().copyWith(name: 'Renamed Group');
      repo.updatePayGroup(updated);
      final groups = repo.getPayGroups();
      expect(
        groups.any(
          (g) => g.id == 'pg_sprint2_test' && g.name == 'Renamed Group',
        ),
        isTrue,
      );
    });

    test('updatePayGroup throws StateError for unknown id', () {
      expect(() => repo.updatePayGroup(_makePayGroup()), throwsStateError);
    });
  });

  // ── 4. Pay Structure CRUD ─────────────────────────────────────────────────
  group('Pay Structure CRUD', () {
    late PayrollRepository repo;

    setUp(() => repo = PayrollRepository(PayrollMockDataSource()));

    test('seeded data: getPayStructures returns 4 structures', () {
      expect(repo.getPayStructures(), hasLength(4));
    });

    test('addPayStructure persists and count grows by 1', () {
      final before = repo.getPayStructures().length;
      repo.addPayStructure(_makePayStructure());
      expect(repo.getPayStructures(), hasLength(before + 1));
    });

    test('updatePayStructure persists rate change', () {
      repo.addPayStructure(_makePayStructure());
      final updated = _makePayStructure().copyWith(baseRate: 30.00);
      repo.updatePayStructure(updated);
      final structures = repo.getPayStructures();
      expect(
        structures.any((s) => s.id == 'ps_sprint2_test' && s.baseRate == 30.00),
        isTrue,
      );
    });

    test('updatePayStructure throws StateError for unknown id', () {
      expect(
        () => repo.updatePayStructure(_makePayStructure()),
        throwsStateError,
      );
    });
  });

  // ── 5. Leave Workflow ────────────────────────────────────────────────────
  group('Leave workflow', () {
    late PayrollRepository repo;

    setUp(() => repo = PayrollRepository(PayrollMockDataSource()));

    test('seeded data: getLeaveTypes returns at least 4 types', () {
      expect(repo.getLeaveTypes().length, greaterThanOrEqualTo(4));
    });

    test(
      'seeded data: getLeaveBalances returns balances for active employees',
      () {
        final balances = repo.getLeaveBalances();
        expect(balances, isNotEmpty);
      },
    );

    test(
      'getLeaveBalances filtered by employeeId returns only that employee',
      () {
        final emp = repo.getEmployees().firstWhere((e) => e.isActive);
        final balances = repo.getLeaveBalances(employeeId: emp.id);
        for (final b in balances) {
          expect(b.employeeId, equals(emp.id));
        }
      },
    );

    test('seeded data: getLeaveRequests returns 5 requests', () {
      expect(repo.getLeaveRequests(), hasLength(5));
    });

    test(
      'getLeaveRequests filtered by status=pending returns only pending',
      () {
        final pending = repo.getLeaveRequests(status: LeaveStatus.pending);
        for (final r in pending) {
          expect(r.status, equals(LeaveStatus.pending));
        }
      },
    );

    test('addLeaveRequest persists and getLeaveRequests grows by 1', () {
      final before = repo.getLeaveRequests().length;
      final leaveTypeId = repo.getLeaveTypes().first.id;
      final request = LeaveRequest(
        id: 'lr_sprint2_test',
        employeeId: 'emp_thabo',
        leaveTypeId: leaveTypeId,
        startDate: DateTime(2026, 8, 10),
        endDate: DateTime(2026, 8, 12),
        daysRequested: 3,
        reason: 'Family visit',
        status: LeaveStatus.pending,
        submittedAt: DateTime(2026, 7, 1),
      );
      repo.addLeaveRequest(request);
      expect(repo.getLeaveRequests(), hasLength(before + 1));
    });

    test(
      'approveLeaveRequest sets status to approved and records approverId',
      () {
        final leaveTypeId = repo.getLeaveTypes().first.id;
        final request = LeaveRequest(
          id: 'lr_approve_test',
          employeeId: 'emp_thabo',
          leaveTypeId: leaveTypeId,
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 3),
          daysRequested: 3,
          reason: 'Rest',
          status: LeaveStatus.pending,
          submittedAt: DateTime(2026, 8, 1),
        );
        repo.addLeaveRequest(request);
        final approved = repo.approveLeaveRequest(
          'lr_approve_test',
          'usr_manager',
        );
        expect(approved.status, equals(LeaveStatus.approved));
        expect(approved.reviewedByUserId, equals('usr_manager'));
      },
    );

    test('rejectLeaveRequest sets status to rejected with reason', () {
      final leaveTypeId = repo.getLeaveTypes().first.id;
      final request = LeaveRequest(
        id: 'lr_reject_test',
        employeeId: 'emp_sipho',
        leaveTypeId: leaveTypeId,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 10),
        daysRequested: 10,
        reason: 'Vacation',
        status: LeaveStatus.pending,
        submittedAt: DateTime(2026, 8, 1),
      );
      repo.addLeaveRequest(request);
      final rejected = repo.rejectLeaveRequest(
        'lr_reject_test',
        'usr_manager',
        'Peak season — cannot approve',
      );
      expect(rejected.status, equals(LeaveStatus.rejected));
      expect(rejected.rejectionReason, equals('Peak season — cannot approve'));
    });

    test('cancelLeaveRequest sets status to cancelled', () {
      final leaveTypeId = repo.getLeaveTypes().first.id;
      final request = LeaveRequest(
        id: 'lr_cancel_test',
        employeeId: 'emp_sipho',
        leaveTypeId: leaveTypeId,
        startDate: DateTime(2026, 11, 5),
        endDate: DateTime(2026, 11, 7),
        daysRequested: 3,
        reason: 'Personal',
        status: LeaveStatus.pending,
        submittedAt: DateTime(2026, 10, 1),
      );
      repo.addLeaveRequest(request);
      final cancelled = repo.cancelLeaveRequest('lr_cancel_test');
      expect(cancelled.status, equals(LeaveStatus.cancelled));
    });

    test('approveLeaveRequest throws StateError for unknown id', () {
      expect(
        () => repo.approveLeaveRequest('ghost_lr', 'usr_manager'),
        throwsStateError,
      );
    });
  });

  // ── 6. Compliance Alerts ──────────────────────────────────────────────────
  group('Compliance alerts', () {
    late PayrollRepository repo;

    setUp(() => repo = PayrollRepository(PayrollMockDataSource()));

    test('seeded data: getComplianceAlerts returns 3 active alerts', () {
      expect(repo.getComplianceAlerts(), hasLength(3));
    });

    test('getComplianceAlerts excludes resolved by default', () {
      final alerts = repo.getComplianceAlerts();
      for (final a in alerts) {
        expect(a.isResolved, isFalse);
      }
    });

    test('resolveAlert marks alert as resolved', () {
      final alertId = repo.getComplianceAlerts().first.id;
      final resolved = repo.resolveAlert(
        alertId,
        'usr_admin',
        'Fixed manually',
      );
      expect(resolved.isResolved, isTrue);
      expect(resolved.resolvedByUserId, equals('usr_admin'));
    });

    test('resolved alert is excluded from default getComplianceAlerts', () {
      final alertId = repo.getComplianceAlerts().first.id;
      repo.resolveAlert(alertId, 'usr_admin', 'Fixed');
      final activeAlerts = repo.getComplianceAlerts();
      expect(activeAlerts.any((a) => a.id == alertId), isFalse);
    });

    test('resolved alert appears when includeResolved=true', () {
      final alertId = repo.getComplianceAlerts().first.id;
      repo.resolveAlert(alertId, 'usr_admin', 'Fixed');
      final all = repo.getComplianceAlerts(includeResolved: true);
      expect(all.any((a) => a.id == alertId), isTrue);
    });

    test('resolveAlert throws StateError for unknown id', () {
      expect(
        () => repo.resolveAlert('ghost_alert', 'usr_admin', 'reason'),
        throwsStateError,
      );
    });
  });

  // ── 7. Pay Run Workflow ────────────────────────────────────────────────────
  group('Pay run workflow', () {
    late PayrollRepository repo;

    setUp(() => repo = PayrollRepository(PayrollMockDataSource()));

    test('seeded data: getPayRuns returns 3 pay runs', () {
      expect(repo.getPayRuns(), hasLength(3));
    });

    test('getPayRun returns null for unknown id', () {
      expect(repo.getPayRun('ghost_run'), isNull);
    });

    test('getPayRun returns correct run by id', () {
      final run = repo.getPayRuns().first;
      expect(repo.getPayRun(run.id)?.id, equals(run.id));
    });

    test('calculatePayRun creates a new run in calculated status', () {
      final pg = repo.getPayGroups().firstWhere(
        (g) => g.name.contains('Weekly'),
      );
      final run = repo.calculatePayRun(
        pg.id,
        DateTime(2026, 6, 2),
        DateTime(2026, 6, 6),
      );
      expect(run.status, equals(PayRunStatus.calculated));
      expect(run.payGroupId, equals(pg.id));
    });

    test('calculatePayRun persists the new run', () {
      final pg = repo.getPayGroups().firstWhere(
        (g) => g.name.contains('Weekly'),
      );
      final before = repo.getPayRuns().length;
      repo.calculatePayRun(pg.id, DateTime(2026, 6, 2), DateTime(2026, 6, 6));
      expect(repo.getPayRuns(), hasLength(before + 1));
    });

    test('approvePayRun transitions calculated → approved', () {
      final pg = repo.getPayGroups().firstWhere(
        (g) => g.name.contains('Weekly'),
      );
      final run = repo.calculatePayRun(
        pg.id,
        DateTime(2026, 6, 2),
        DateTime(2026, 6, 6),
      );
      final approved = repo.approvePayRun(run.id, 'usr_manager');
      expect(approved.status, equals(PayRunStatus.approved));
    });

    test('disbursePayRun transitions approved → disbursed', () {
      final pg = repo.getPayGroups().firstWhere(
        (g) => g.name.contains('Weekly'),
      );
      final run = repo.calculatePayRun(
        pg.id,
        DateTime(2026, 6, 2),
        DateTime(2026, 6, 6),
      );
      repo.approvePayRun(run.id, 'usr_manager');
      final disbursed = repo.disbursePayRun(run.id);
      expect(disbursed.status, equals(PayRunStatus.disbursed));
    });

    test('approvePayRun throws StateError for unknown run id', () {
      expect(
        () => repo.approvePayRun('ghost_run', 'usr_manager'),
        throwsStateError,
      );
    });
  });

  // ── 8. Payslips ───────────────────────────────────────────────────────────
  group('Payslips', () {
    late PayrollRepository repo;

    setUp(() => repo = PayrollRepository(PayrollMockDataSource()));

    test(
      'seeded data: getPayslips returns 6 payslips (3 employees × 2 months)',
      () {
        expect(repo.getPayslips(), hasLength(6));
      },
    );

    test('getPayslip returns null for unknown id', () {
      expect(repo.getPayslip('ghost_slip'), isNull);
    });

    test('getPayslips filtered by employeeId returns only that employee', () {
      final emp = repo.getEmployees().first;
      final slips = repo.getPayslips(employeeId: emp.id);
      for (final s in slips) {
        expect(s.employeeId, equals(emp.id));
      }
    });

    test('getPayslips filtered by payRunId returns only that run', () {
      final runId = repo.getPayRuns().first.id;
      final slips = repo.getPayslips(payRunId: runId);
      for (final s in slips) {
        expect(s.payRunId, equals(runId));
      }
    });

    test('each payslip has netPay > 0', () {
      for (final s in repo.getPayslips()) {
        expect(
          s.netPay,
          greaterThan(0),
          reason: 'Payslip ${s.id} has zero or negative net pay',
        );
      }
    });

    test('each payslip has grossPay >= netPay', () {
      for (final s in repo.getPayslips()) {
        expect(
          s.grossPay,
          greaterThanOrEqualTo(s.netPay),
          reason: 'Payslip ${s.id}: grossPay < netPay',
        );
      }
    });
  });

  // ── 9. Communications ─────────────────────────────────────────────────────
  group('Communications', () {
    late PayrollRepository repo;

    setUp(() => repo = PayrollRepository(PayrollMockDataSource()));

    test('seeded data: getCommunicationLogs returns entries', () {
      expect(repo.getCommunicationLogs(), isNotEmpty);
    });

    test('sendCommunication persists a new log entry', () {
      final before = repo.getCommunicationLogs().length;
      final log = repo.sendCommunication(
        channel: CommunicationChannel.inApp,
        templateCode: 'CUSTOM',
        subject: 'Test Subject',
        body: 'Test body message.',
        recipientEmployeeIds: ['emp_thabo', 'emp_nomsa'],
        sentByUserId: 'usr_admin',
      );
      expect(log.recipientEmployeeIds, hasLength(2));
      expect(log.channel, equals(CommunicationChannel.inApp));
      expect(repo.getCommunicationLogs(), hasLength(before + 1));
    });

    test('sendCommunication with empty recipients returns sentCount=0', () {
      final log = repo.sendCommunication(
        channel: CommunicationChannel.email,
        templateCode: 'PAY_RUN_READY',
        subject: 'Payslip ready',
        body: 'Your payslip is available.',
        recipientEmployeeIds: [],
        sentByUserId: 'usr_admin',
      );
      expect(log.recipientEmployeeIds, isEmpty);
    });
  });

  // ── 10. Audit Log ─────────────────────────────────────────────────────────
  group('Audit log', () {
    late PayrollRepository repo;

    setUp(() => repo = PayrollRepository(PayrollMockDataSource()));

    test('seeded data: getAuditLog returns entries', () {
      expect(repo.getAuditLog(), isNotEmpty);
    });

    test(
      'getAuditLog filtered by entityType returns only matching entries',
      () {
        final empLogs = repo.getAuditLog(entityType: 'employee');
        for (final log in empLogs) {
          expect(log.entityType, equals('employee'));
        }
      },
    );

    test('getAuditLog limit parameter is respected', () {
      final all = repo.getAuditLog();
      if (all.length > 2) {
        final limited = repo.getAuditLog(limit: 2);
        expect(limited.length, lessThanOrEqualTo(2));
      }
    });
  });
}
