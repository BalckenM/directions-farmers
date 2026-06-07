import 'dart:convert';

import 'package:mobile_app/core/database/app_database.dart';
import 'package:mobile_app/features/payroll/models/attendance_record.dart';
import 'package:mobile_app/features/payroll/models/compliance_alert.dart';
import 'package:mobile_app/features/payroll/models/leave_balance.dart';
import 'package:mobile_app/features/payroll/models/leave_request.dart';
import 'package:mobile_app/features/payroll/models/pay_group.dart';
import 'package:mobile_app/features/payroll/models/pay_run.dart';
import 'package:mobile_app/features/payroll/models/payroll_employee.dart';
import 'package:mobile_app/features/payroll/models/payslip.dart';

/// Provides read/write access to the payroll offline cache tables.
///
/// All methods are intentionally thin — they serialise/deserialise JSON and
/// delegate storage to Drift.  Business logic lives in the repository.
class PayrollLocalDataSource {
  const PayrollLocalDataSource(this._db);

  final AppDatabase _db;

  // ── PayrollEmployee ────────────────────────────────────────────────────────

  Future<List<PayrollEmployee>> getEmployees() async {
    final rows = await _db.select(_db.cachedPayrollEmployees).get();
    return rows
        .map(
          (r) => PayrollEmployee.fromJson(
            jsonDecode(r.json) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> upsertEmployees(List<PayrollEmployee> employees) =>
      _db.transaction(() async {
        for (final e in employees) {
          await _db
              .into(_db.cachedPayrollEmployees)
              .insertOnConflictUpdate(
                CachedPayrollEmployeesCompanion.insert(
                  id: e.id,
                  json: jsonEncode(e.toJson()),
                ),
              );
        }
      });

  // ── PayRun ─────────────────────────────────────────────────────────────────

  Future<List<PayRun>> getPayRuns() async {
    final rows = await _db.select(_db.cachedPayRuns).get();
    return rows
        .map((r) => PayRun.fromJson(jsonDecode(r.json) as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertPayRuns(List<PayRun> runs) => _db.transaction(() async {
    for (final r in runs) {
      await _db
          .into(_db.cachedPayRuns)
          .insertOnConflictUpdate(
            CachedPayRunsCompanion.insert(
              id: r.id,
              json: jsonEncode(r.toJson()),
            ),
          );
    }
  });

  // ── Payslip ────────────────────────────────────────────────────────────────

  Future<List<Payslip>> getPayslips() async {
    final rows = await _db.select(_db.cachedPayslips).get();
    return rows
        .map(
          (r) => Payslip.fromJson(jsonDecode(r.json) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> upsertPayslips(List<Payslip> payslips) =>
      _db.transaction(() async {
        for (final p in payslips) {
          await _db
              .into(_db.cachedPayslips)
              .insertOnConflictUpdate(
                CachedPayslipsCompanion.insert(
                  id: p.id,
                  json: jsonEncode(p.toJson()),
                ),
              );
        }
      });

  // ── LeaveRequest ───────────────────────────────────────────────────────────

  Future<List<LeaveRequest>> getLeaveRequests() async {
    final rows = await _db.select(_db.cachedLeaveRequests).get();
    return rows
        .map(
          (r) =>
              LeaveRequest.fromJson(jsonDecode(r.json) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> upsertLeaveRequests(List<LeaveRequest> requests) =>
      _db.transaction(() async {
        for (final r in requests) {
          await _db
              .into(_db.cachedLeaveRequests)
              .insertOnConflictUpdate(
                CachedLeaveRequestsCompanion.insert(
                  id: r.id,
                  json: jsonEncode(r.toJson()),
                ),
              );
        }
      });

  // ── LeaveBalance ───────────────────────────────────────────────────────────

  Future<List<LeaveBalance>> getLeaveBalances() async {
    final rows = await _db.select(_db.cachedLeaveBalances).get();
    return rows
        .map(
          (r) =>
              LeaveBalance.fromJson(jsonDecode(r.json) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> upsertLeaveBalances(List<LeaveBalance> balances) =>
      _db.transaction(() async {
        for (final b in balances) {
          final key = '${b.employeeId}_${b.leaveTypeId}';
          await _db
              .into(_db.cachedLeaveBalances)
              .insertOnConflictUpdate(
                CachedLeaveBalancesCompanion.insert(
                  id: key,
                  json: jsonEncode(b.toJson()),
                ),
              );
        }
      });

  // ── AttendanceRecord ───────────────────────────────────────────────────────

  Future<List<AttendanceRecord>> getAttendanceRecords() async {
    final rows = await _db.select(_db.cachedAttendanceRecords).get();
    return rows
        .map(
          (r) => AttendanceRecord.fromJson(
            jsonDecode(r.json) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> upsertAttendanceRecords(List<AttendanceRecord> records) =>
      _db.transaction(() async {
        for (final r in records) {
          await _db
              .into(_db.cachedAttendanceRecords)
              .insertOnConflictUpdate(
                CachedAttendanceRecordsCompanion.insert(
                  id: r.id,
                  json: jsonEncode(r.toJson()),
                ),
              );
        }
      });

  // ── ComplianceAlert ────────────────────────────────────────────────────────

  Future<List<ComplianceAlert>> getComplianceAlerts() async {
    final rows = await _db.select(_db.cachedComplianceAlerts).get();
    return rows
        .map(
          (r) => ComplianceAlert.fromJson(
            jsonDecode(r.json) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> upsertComplianceAlerts(List<ComplianceAlert> alerts) =>
      _db.transaction(() async {
        for (final a in alerts) {
          await _db
              .into(_db.cachedComplianceAlerts)
              .insertOnConflictUpdate(
                CachedComplianceAlertsCompanion.insert(
                  id: a.id,
                  json: jsonEncode(a.toJson()),
                ),
              );
        }
      });

  // ── PayGroup ───────────────────────────────────────────────────────────────

  Future<List<PayGroup>> getPayGroups() async {
    final rows = await _db.select(_db.cachedPayGroups).get();
    return rows
        .map(
          (r) => PayGroup.fromJson(jsonDecode(r.json) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> upsertPayGroups(List<PayGroup> groups) =>
      _db.transaction(() async {
        for (final g in groups) {
          await _db
              .into(_db.cachedPayGroups)
              .insertOnConflictUpdate(
                CachedPayGroupsCompanion.insert(
                  id: g.id,
                  json: jsonEncode(g.toJson()),
                ),
              );
        }
      });

  // ── Utilities ──────────────────────────────────────────────────────────────

  /// Wipe all payroll cache tables (e.g. on logout).
  Future<void> clearAll() => _db.transaction(() async {
    await _db.delete(_db.cachedPayrollEmployees).go();
    await _db.delete(_db.cachedPayRuns).go();
    await _db.delete(_db.cachedPayslips).go();
    await _db.delete(_db.cachedLeaveRequests).go();
    await _db.delete(_db.cachedLeaveBalances).go();
    await _db.delete(_db.cachedAttendanceRecords).go();
    await _db.delete(_db.cachedComplianceAlerts).go();
    await _db.delete(_db.cachedPayGroups).go();
  });
}
