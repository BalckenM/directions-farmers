// Riverpod StateNotifier providers for all mutating payroll actions.
// Screens call these via `ref.read(xxxNotifierProvider.notifier).method(...)`.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/payroll_repository.dart';
import 'payroll_providers.dart';
import '../models/attendance_record.dart';
import '../models/compliance_alert.dart';
import '../models/deduction_rule.dart';
import '../models/employer_config.dart';
import '../models/employment_contract.dart';
import '../models/garnishee_order.dart';
import '../models/incident_record.dart';
import '../models/leave_request.dart';
import '../models/pay_group.dart';
import '../models/pay_run.dart';
import '../models/pay_structure.dart';
import '../models/payroll_employee.dart';
import '../models/piecework_log.dart';
import '../models/shift.dart';
import '../models/communication_log.dart';
import '../models/task_assignment.dart';

// ─── Generic async action result ─────────────────────────────────────────────
sealed class ActionResult<T> {}

class ActionSuccess<T> extends ActionResult<T> {
  ActionSuccess(this.value);
  final T value;
}

class ActionFailure<T> extends ActionResult<T> {
  ActionFailure(this.message);
  final String message;
}

// ─── Pay Run notifier ─────────────────────────────────────────────────────────
class PayRunNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<PayRun?> calculatePayRun({
    required String payGroupId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    state = const AsyncValue.loading();
    try {
      final run = _repo.calculatePayRun(payGroupId, periodStart, periodEnd);
      // Invalidate pay-run reads so screens auto-refresh
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return run;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<PayRun?> approvePayRun(
    String payRunId, {
    String approverId = 'usr_manager',
  }) async {
    state = const AsyncValue.loading();
    try {
      final run = _repo.approvePayRun(payRunId, approverId);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return run;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<PayRun?> disbursePayRun(String payRunId) async {
    state = const AsyncValue.loading();
    try {
      final run = _repo.disbursePayRun(payRunId);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return run;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final payRunNotifierProvider =
    NotifierProvider<PayRunNotifier, AsyncValue<void>>(PayRunNotifier.new);

// ─── Attendance notifier ───────────────────────────────────────────────────────
class AttendanceNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<AttendanceRecord?> clockIn({
    required String employeeId,
    required DateTime date,
    required String clockInTime,
    required AttendanceMethod method,
    String? notes,
    String supervisorId = 'usr_manager',
  }) async {
    state = const AsyncValue.loading();
    try {
      final rec = _repo.addAttendanceRecord(
        AttendanceRecord(
          id: 'att_${employeeId}_${date.millisecondsSinceEpoch}',
          employeeId: employeeId,
          date: date,
          status: AttendanceStatus.present,
          clockInTime: clockInTime,
          recordedByUserId: supervisorId,
          method: method,
          notes: notes,
          createdAt: DateTime.now(),
        ),
      );
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return rec;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<AttendanceRecord?> clockOut({
    required String attendanceId,
    required String clockOutTime,
    required double hoursWorked,
    double? overtimeHours,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(payrollRepositoryProvider);
      final all = repo.getAttendanceRecords();
      final rec = all.firstWhere((r) => r.id == attendanceId);
      final updated = rec.copyWith(
        clockOutTime: clockOutTime,
        hoursWorked: hoursWorked,
        overtimeHours: overtimeHours,
        notes: notes ?? rec.notes,
      );
      final saved = _repo.updateAttendanceRecord(updated);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<AttendanceRecord?> markAbsent({
    required String employeeId,
    required DateTime date,
    required AttendanceStatus reason,
    String? notes,
    String supervisorId = 'usr_manager',
  }) async {
    state = const AsyncValue.loading();
    try {
      final rec = _repo.addAttendanceRecord(
        AttendanceRecord(
          id: 'att_${employeeId}_${date.millisecondsSinceEpoch}',
          employeeId: employeeId,
          date: date,
          status: reason,
          recordedByUserId: supervisorId,
          method: AttendanceMethod.manual,
          notes: notes,
          createdAt: DateTime.now(),
        ),
      );
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return rec;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> resolveException({
    required AttendanceRecord record,
    required AttendanceStatus resolvedStatus,
    String note = '',
  }) async {
    state = const AsyncValue.loading();
    try {
      final updated = record.copyWith(
        status: resolvedStatus,
        recordedByUserId: 'usr_manager',
        notes: note.isNotEmpty ? note : record.notes,
      );
      _repo.updateAttendanceRecord(updated);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final attendanceNotifierProvider =
    NotifierProvider<AttendanceNotifier, AsyncValue<void>>(
      AttendanceNotifier.new,
    );

// ─── Leave notifier ───────────────────────────────────────────────────────────
class LeaveNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<LeaveRequest?> submitRequest({
    required String employeeId,
    required String leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required double daysRequested,
    required String reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      final req = _repo.addLeaveRequest(
        LeaveRequest(
          id: 'lr_${employeeId}_${DateTime.now().millisecondsSinceEpoch}',
          employeeId: employeeId,
          leaveTypeId: leaveTypeId,
          startDate: startDate,
          endDate: endDate,
          daysRequested: daysRequested,
          reason: reason,
          status: LeaveStatus.pending,
          submittedAt: DateTime.now(),
        ),
      );
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return req;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<LeaveRequest?> approve(
    String requestId, {
    String approverId = 'usr_manager',
  }) async {
    state = const AsyncValue.loading();
    try {
      final req = _repo.approveLeaveRequest(requestId, approverId);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return req;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<LeaveRequest?> reject(
    String requestId,
    String reason, {
    String approverId = 'usr_manager',
  }) async {
    state = const AsyncValue.loading();
    try {
      final req = _repo.rejectLeaveRequest(requestId, approverId, reason);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return req;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<LeaveRequest?> cancel(String requestId) async {
    state = const AsyncValue.loading();
    try {
      final req = _repo.cancelLeaveRequest(requestId);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return req;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deleteRequest(String id) async {
    state = const AsyncValue.loading();
    try {
      final ok = _repo.deleteLeaveRequest(id);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return ok;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final leaveNotifierProvider = NotifierProvider<LeaveNotifier, AsyncValue<void>>(
  LeaveNotifier.new,
);

// ─── Deduction notifier ───────────────────────────────────────────────────────
class DeductionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<DeductionRule?> addRule(DeductionRule rule) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.addDeductionRule(rule);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<DeductionRule?> updateRule(DeductionRule rule) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.updateDeductionRule(rule);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deactivate(String id) async {
    state = const AsyncValue.loading();
    try {
      _repo.deactivateDeductionRule(id);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final deductionNotifierProvider =
    NotifierProvider<DeductionNotifier, AsyncValue<void>>(
      DeductionNotifier.new,
    );

// ─── Employee notifier ────────────────────────────────────────────────────────
class EmployeeNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<PayrollEmployee?> add(PayrollEmployee employee) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.addEmployee(employee);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<PayrollEmployee?> update(PayrollEmployee employee) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.updateEmployee(employee);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<PayrollEmployee?> terminate(
    String id,
    DateTime terminationDate,
    String reason,
  ) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.terminateEmployee(id, terminationDate, reason);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final employeeNotifierProvider =
    NotifierProvider<EmployeeNotifier, AsyncValue<void>>(EmployeeNotifier.new);

// ─── Contract notifier ────────────────────────────────────────────────────────
class ContractNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<EmploymentContract?> add(EmploymentContract contract) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.addContract(contract);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<EmploymentContract?> update(EmploymentContract contract) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.updateContract(contract);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<EmploymentContract?> voidContract(String id, String reason) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.voidContract(id, reason);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final contractNotifierProvider =
    NotifierProvider<ContractNotifier, AsyncValue<void>>(ContractNotifier.new);

// ─── Pay Group notifier ───────────────────────────────────────────────────────
class PayGroupNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<PayGroup?> add(PayGroup group) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.addPayGroup(group);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<PayGroup?> update(PayGroup group) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.updatePayGroup(group);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deactivate(String id) async {
    state = const AsyncValue.loading();
    try {
      _repo.deactivatePayGroup(id);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final payGroupNotifierProvider =
    NotifierProvider<PayGroupNotifier, AsyncValue<void>>(PayGroupNotifier.new);

// ─── Task Assignment notifier ─────────────────────────────────────────────────────
class TaskAssignmentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<TaskAssignment?> add(TaskAssignment task) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.addTaskAssignment(task);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<TaskAssignment?> update(TaskAssignment task) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.updateTaskAssignment(task);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      final ok = _repo.deleteTaskAssignment(id);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return ok;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final taskAssignmentNotifierProvider =
    NotifierProvider<TaskAssignmentNotifier, AsyncValue<void>>(
      TaskAssignmentNotifier.new,
    );

// ─── Pay Structure notifier ───────────────────────────────────────────────────
class PayStructureNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<PayStructure?> add(PayStructure structure) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.addPayStructure(structure);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<PayStructure?> update(PayStructure structure) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.updatePayStructure(structure);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final payStructureNotifierProvider =
    NotifierProvider<PayStructureNotifier, AsyncValue<void>>(
      PayStructureNotifier.new,
    );

// ─── Shift / Roster notifier ──────────────────────────────────────────────────
class ShiftNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<Shift?> add(Shift shift) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.addShift(shift);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Shift?> update(Shift shift) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.updateShift(shift);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      final ok = _repo.deleteShift(id);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return ok;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final shiftNotifierProvider = NotifierProvider<ShiftNotifier, AsyncValue<void>>(
  ShiftNotifier.new,
);

// ─── Piecework notifier ──────────────────────────────────────────────────────────────
class PieceworkNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<PieceworkLog?> addLog(PieceworkLog log) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.addPieceworkLog(log);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deleteLog(String id, String correctionReason) async {
    state = const AsyncValue.loading();
    try {
      final ok = _repo.deletePieceworkLog(id, correctionReason);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return ok;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final pieceworkNotifierProvider =
    NotifierProvider<PieceworkNotifier, AsyncValue<void>>(
      PieceworkNotifier.new,
    );

// ─── Employer Config notifier ───────────────────────────────────────────────────────
class EmployerConfigNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  EmployerConfig getConfig() => _repo.getEmployerConfig();

  Future<EmployerConfig?> updateConfig(EmployerConfig config) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.updateEmployerConfig(config);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final employerConfigNotifierProvider =
    NotifierProvider<EmployerConfigNotifier, AsyncValue<void>>(
      EmployerConfigNotifier.new,
    );

// ─── Garnishee Order notifier ────────────────────────────────────────────────────────
class GarnisheeNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<GarnisheeOrder?> add(GarnisheeOrder order) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.addGarnisheeOrder(order);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<GarnisheeOrder?> update(GarnisheeOrder order) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.updateGarnisheeOrder(order);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final garnisheeNotifierProvider =
    NotifierProvider<GarnisheeNotifier, AsyncValue<void>>(
      GarnisheeNotifier.new,
    );

// ─── Incident notifier ─────────────────────────────────────────────────────────────────
class IncidentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<IncidentRecord?> add(IncidentRecord incident) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.addIncident(incident);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<IncidentRecord?> update(IncidentRecord incident) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.updateIncident(incident);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deactivate(String id) async {
    state = const AsyncValue.loading();
    try {
      _repo.deactivateIncident(id);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final incidentNotifierProvider =
    NotifierProvider<IncidentNotifier, AsyncValue<void>>(IncidentNotifier.new);

// ─── Compliance Alert notifier ───────────────────────────────────────────────────────
class ComplianceAlertNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<ComplianceAlert?> resolve(
    String id,
    String resolvedByUserId,
    String resolution,
  ) async {
    state = const AsyncValue.loading();
    try {
      final saved = _repo.resolveAlert(id, resolvedByUserId, resolution);
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final complianceAlertNotifierProvider =
    NotifierProvider<ComplianceAlertNotifier, AsyncValue<void>>(
      ComplianceAlertNotifier.new,
    );

// ─── Communication notifier ──────────────────────────────────────────────────
class CommunicationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  PayrollRepository get _repo => ref.read(payrollRepositoryProvider);

  Future<CommunicationLog?> send({
    required CommunicationChannel channel,
    required String templateCode,
    required String subject,
    required String body,
    required List<String> recipientEmployeeIds,
    String sentByUserId = 'usr_manager',
  }) async {
    state = const AsyncValue.loading();
    try {
      final log = _repo.sendCommunication(
        channel: channel,
        templateCode: templateCode,
        subject: subject,
        body: body,
        recipientEmployeeIds: recipientEmployeeIds,
        sentByUserId: sentByUserId,
      );
      ref.invalidate(payrollRepositoryProvider);
      state = const AsyncValue.data(null);
      return log;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final communicationNotifierProvider =
    NotifierProvider<CommunicationNotifier, AsyncValue<void>>(
      CommunicationNotifier.new,
    );
