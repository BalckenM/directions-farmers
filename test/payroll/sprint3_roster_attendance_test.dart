// Sprint 3 — Roster & Attendance Full Flow Tests
// Covers: shift add/retrieve, piecework log add/retrieve, and
// weekly pay run producing non-zero basicWage for hourly + daily workers
// (seeded data: May 4–15, 2026; payGroup: pg_weekly).

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/features/payroll/data/payroll_mock_data_source.dart';
import 'package:mobile_app/features/payroll/data/payroll_repository.dart';
import 'package:mobile_app/features/payroll/models/piecework_log.dart';
import 'package:mobile_app/features/payroll/models/shift.dart';

void main() {
  // ── 5. Roster — shift CRUD on mock data source ───────────────────────────
  group('Roster — shift add and retrieve', () {
    test('addShift persists a new shift and getShifts returns it', () {
      final source = PayrollMockDataSource();
      final repo = PayrollRepository(source);

      final newShift = Shift(
        id: 'sh_test_001',
        date: DateTime(2026, 5, 18),
        startTime: '07:00',
        endTime: '15:00',
        employeeIds: ['emp_thabo', 'emp_nomsa'],
        taskCode: 'HARVESTING',
        fieldOrArea: 'Block A',
        status: ShiftStatus.planned,
        createdAt: DateTime(2026, 5, 17),
      );

      repo.addShift(newShift);

      final shifts = repo.getShifts();
      expect(
        shifts.any((s) => s.id == 'sh_test_001'),
        isTrue,
        reason: 'addShift must persist and getShifts must return the new shift',
      );
    });

    test('getShifts filtered by employeeId only returns matching shifts', () {
      final source = PayrollMockDataSource();
      final repo = PayrollRepository(source);

      const targetEmpId = 'emp_sipho';
      final shifts = repo.getShifts(employeeId: targetEmpId);

      for (final s in shifts) {
        expect(
          s.employeeIds.contains(targetEmpId),
          isTrue,
          reason: 'Filtered shifts should all contain the target employeeId',
        );
      }
    });
  });

  // ── 6. Piecework — log add and retrieve ──────────────────────────────────
  group('Piecework — log add and retrieve', () {
    test('addPieceworkLog persists log and getPieceworkLogs returns it', () {
      final source = PayrollMockDataSource();
      final repo = PayrollRepository(source);

      final log = PieceworkLog(
        id: 'pw_test_001',
        employeeId: 'emp_thabo',
        date: DateTime(2026, 5, 18),
        payrollCode: 'GRAPE_PICK',
        unit: 'kg',
        quantity: 50.0,
        ratePerUnit: 1.80,
        recordedByUserId: 'user_admin',
        createdAt: DateTime(2026, 5, 18),
      );

      repo.addPieceworkLog(log);

      final logs = repo.getPieceworkLogs(employeeId: 'emp_thabo');
      expect(
        logs.any((l) => l.id == 'pw_test_001'),
        isTrue,
        reason: 'addPieceworkLog must persist and getPieceworkLogs must return it',
      );
    });

    test('PieceworkLog.totalEarnings equals quantity × ratePerUnit', () {
      final log = PieceworkLog(
        id: 'pw_test_calc',
        employeeId: 'emp_thabo',
        date: DateTime(2026, 5, 18),
        payrollCode: 'APPLE_PICK',
        unit: 'crates',
        quantity: 20.0,
        ratePerUnit: 12.50,
        recordedByUserId: 'user_admin',
        createdAt: DateTime(2026, 5, 18),
      );

      expect(
        log.totalEarnings,
        closeTo(250.0, 0.001),
        reason: '20 crates × R12.50 should equal R250.00',
      );
    });
  });

  // ── 7. Pay run — seeded weekly data produces non-zero basicWage ──────────
  group('Weekly pay run — seeded May 2026 data', () {
    late PayrollRepository repo;

    setUp(() {
      repo = PayrollRepository(PayrollMockDataSource());
    });

    test('emp_thabo (hourly NMWA) has basicWage > 0 for May 4–15 2026', () {
      final payRun = repo.calculatePayRun(
        'pg_weekly',
        DateTime(2026, 5, 4),
        DateTime(2026, 5, 15),
      );
      final payslips = repo.getPayslips(payRunId: payRun.id);

      final payslip = payslips.firstWhere(
        (p) => p.employeeId == 'emp_thabo',
        orElse: () => throw TestFailure(
          'No payslip found for emp_thabo in pg_weekly pay run',
        ),
      );

      expect(
        payslip.basicWage,
        greaterThan(0),
        reason: 'Hourly NMWA worker with attendance should earn > R0 basic wage',
      );
    });

    test('emp_ayanda (daily R220) has basicWage > 0 for May 4–15 2026', () {
      final payRun = repo.calculatePayRun(
        'pg_weekly',
        DateTime(2026, 5, 4),
        DateTime(2026, 5, 15),
      );
      final payslips = repo.getPayslips(payRunId: payRun.id);

      final payslip = payslips.firstWhere(
        (p) => p.employeeId == 'emp_ayanda',
        orElse: () => throw TestFailure(
          'No payslip found for emp_ayanda in pg_weekly pay run',
        ),
      );

      expect(
        payslip.basicWage,
        greaterThan(0),
        reason: 'Daily-rate worker with attendance should earn > R0 basic wage',
      );
    });

    test('pay run contains payslips for all pg_weekly active employees', () {
      final payRun = repo.calculatePayRun(
        'pg_weekly',
        DateTime(2026, 5, 4),
        DateTime(2026, 5, 15),
      );
      final payslips = repo.getPayslips(payRunId: payRun.id);

      const expectedIds = [
        'emp_thabo', 'emp_nomsa', 'emp_bongani', 'emp_ayanda', 'emp_lindiwe',
      ];

      for (final empId in expectedIds) {
        expect(
          payslips.any((p) => p.employeeId == empId),
          isTrue,
          reason: 'Pay run should produce a payslip for $empId',
        );
      }
    });

    test('all weekly payslips have non-negative netPay', () {
      final payRun = repo.calculatePayRun(
        'pg_weekly',
        DateTime(2026, 5, 4),
        DateTime(2026, 5, 15),
      );
      final payslips = repo.getPayslips(payRunId: payRun.id);

      for (final payslip in payslips) {
        expect(
          payslip.netPay,
          greaterThanOrEqualTo(0),
          reason: 'netPay for ${payslip.employeeId} must not be negative',
        );
      }
    });
  });
}