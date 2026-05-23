import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../data/payroll_data_source.dart';
import '../models/attendance_record.dart';
import '../models/audit_log_entry.dart';
import '../models/communication_log.dart';
import '../models/compliance_alert.dart';
import '../models/deduction_rule.dart';
import '../models/employer_config.dart';
import '../models/employment_contract.dart';
import '../models/garnishee_order.dart';
import '../models/incident_record.dart';
import '../models/leave_balance.dart';
import '../models/leave_request.dart';
import '../models/leave_type.dart';
import '../models/pay_group.dart';
import '../models/pay_run.dart';
import '../models/pay_structure.dart';
import '../models/payment_transaction.dart';
import '../models/payroll_employee.dart';
import '../models/payslip.dart';
import '../models/piecework_log.dart';
import '../models/shift.dart';
import '../models/task_assignment.dart';

String _uid() =>
    DateTime.now().microsecondsSinceEpoch.toString() +
    Random().nextInt(99999).toString();

/// A [PayrollDataSource] that loads seed data from bundled JSON assets.
///
/// Call [init] before using any methods — it loads all 15 JSON files once.
class PayrollJsonDataSource implements PayrollDataSource {
  PayrollJsonDataSource();

  // ─── In-memory stores (populated by init) ─────────────────────────────────
  final List<PayrollEmployee> _employees = [];
  final List<EmploymentContract> _contracts = [];
  final List<PayGroup> _payGroups = [];
  final List<PayStructure> _payStructures = [];
  final List<PayRun> _payRuns = [];
  final List<Payslip> _payslips = [];
  final List<DeductionRule> _deductionRules = [];
  final List<LeaveType> _leaveTypes = [];
  final List<LeaveBalance> _leaveBalances = [];
  final List<LeaveRequest> _leaveRequests = [];
  final List<PaymentTransaction> _transactions = [];
  final List<ComplianceAlert> _alerts = [];
  final List<AuditLogEntry> _auditLog = [];
  final List<IncidentRecord> _incidents = [];
  final List<CommunicationLog> _communications = [];
  // Runtime-only (no JSON asset)
  final List<Shift> _shifts = [];
  final List<TaskAssignment> _tasks = [];
  final List<AttendanceRecord> _attendance = [];
  final List<PieceworkLog> _piecework = [];

  bool _initialised = false;

  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;
    await Future.wait([
      _load(
        'assets/mock_data/payroll/employees.json',
        (j) => _employees.addAll(
          (j as List).map(
            (e) => PayrollEmployee.fromJson(e as Map<String, dynamic>),
          ),
        ),
      ),
      _load(
        'assets/mock_data/payroll/contracts.json',
        (j) => _contracts.addAll(
          (j as List).map(
            (e) => EmploymentContract.fromJson(e as Map<String, dynamic>),
          ),
        ),
      ),
      _load(
        'assets/mock_data/payroll/pay_groups.json',
        (j) => _payGroups.addAll(
          (j as List).map((e) => PayGroup.fromJson(e as Map<String, dynamic>)),
        ),
      ),
      _load(
        'assets/mock_data/payroll/pay_structures.json',
        (j) => _payStructures.addAll(
          (j as List).map(
            (e) => PayStructure.fromJson(e as Map<String, dynamic>),
          ),
        ),
      ),
      _load(
        'assets/mock_data/payroll/pay_runs.json',
        (j) => _payRuns.addAll(
          (j as List).map((e) => PayRun.fromJson(e as Map<String, dynamic>)),
        ),
      ),
      _load(
        'assets/mock_data/payroll/payslips.json',
        (j) => _payslips.addAll(
          (j as List).map((e) => Payslip.fromJson(e as Map<String, dynamic>)),
        ),
      ),
      _load(
        'assets/mock_data/payroll/deduction_rules.json',
        (j) => _deductionRules.addAll(
          (j as List).map(
            (e) => DeductionRule.fromJson(e as Map<String, dynamic>),
          ),
        ),
      ),
      _load(
        'assets/mock_data/payroll/leave_types.json',
        (j) => _leaveTypes.addAll(
          (j as List).map((e) => LeaveType.fromJson(e as Map<String, dynamic>)),
        ),
      ),
      _load(
        'assets/mock_data/payroll/leave_balances.json',
        (j) => _leaveBalances.addAll(
          (j as List).map(
            (e) => LeaveBalance.fromJson(e as Map<String, dynamic>),
          ),
        ),
      ),
      _load(
        'assets/mock_data/payroll/leave_requests.json',
        (j) => _leaveRequests.addAll(
          (j as List).map(
            (e) => LeaveRequest.fromJson(e as Map<String, dynamic>),
          ),
        ),
      ),
      _load(
        'assets/mock_data/payroll/payment_transactions.json',
        (j) => _transactions.addAll(
          (j as List).map(
            (e) => PaymentTransaction.fromJson(e as Map<String, dynamic>),
          ),
        ),
      ),
      _load(
        'assets/mock_data/payroll/compliance_alerts.json',
        (j) => _alerts.addAll(
          (j as List).map(
            (e) => ComplianceAlert.fromJson(e as Map<String, dynamic>),
          ),
        ),
      ),
      _load(
        'assets/mock_data/payroll/audit_log.json',
        (j) => _auditLog.addAll(
          (j as List).map(
            (e) => AuditLogEntry.fromJson(e as Map<String, dynamic>),
          ),
        ),
      ),
      _load(
        'assets/mock_data/payroll/incidents.json',
        (j) => _incidents.addAll(
          (j as List).map(
            (e) => IncidentRecord.fromJson(e as Map<String, dynamic>),
          ),
        ),
      ),
      _load(
        'assets/mock_data/payroll/communications.json',
        (j) => _communications.addAll(
          (j as List).map(
            (e) => CommunicationLog.fromJson(e as Map<String, dynamic>),
          ),
        ),
      ),
    ]);
  }

  Future<void> _load(String assetPath, void Function(dynamic) populate) async {
    final raw = await rootBundle.loadString(assetPath);
    populate(jsonDecode(raw));
  }

  // ─── Employees ─────────────────────────────────────────────────────────────
  @override
  List<PayrollEmployee> getEmployees() => List.unmodifiable(_employees);

  @override
  PayrollEmployee? getEmployee(String id) =>
      _employees.where((e) => e.id == id).firstOrNull;

  @override
  PayrollEmployee addEmployee(PayrollEmployee employee) {
    _employees.add(employee);
    return employee;
  }

  @override
  PayrollEmployee updateEmployee(PayrollEmployee employee) {
    final i = _employees.indexWhere((e) => e.id == employee.id);
    if (i != -1) _employees[i] = employee;
    return employee;
  }

  // ─── Contracts ─────────────────────────────────────────────────────────────
  @override
  List<EmploymentContract> getContracts({String? employeeId}) => _contracts
      .where((c) => employeeId == null || c.employeeId == employeeId)
      .toList();

  @override
  EmploymentContract? getContract(String id) =>
      _contracts.where((c) => c.id == id).firstOrNull;

  @override
  EmploymentContract addContract(EmploymentContract contract) {
    _contracts.add(contract);
    return contract;
  }

  @override
  EmploymentContract updateContract(EmploymentContract contract) {
    final i = _contracts.indexWhere((c) => c.id == contract.id);
    if (i != -1) _contracts[i] = contract;
    return contract;
  }

  // ─── Pay groups ─────────────────────────────────────────────────────────────
  @override
  List<PayGroup> getPayGroups() => List.unmodifiable(_payGroups);

  @override
  PayGroup addPayGroup(PayGroup group) {
    _payGroups.add(group);
    return group;
  }

  @override
  PayGroup updatePayGroup(PayGroup group) {
    final i = _payGroups.indexWhere((g) => g.id == group.id);
    if (i != -1) _payGroups[i] = group;
    return group;
  }

  // ─── Pay structures ────────────────────────────────────────────────────────
  @override
  List<PayStructure> getPayStructures() => List.unmodifiable(_payStructures);

  @override
  PayStructure addPayStructure(PayStructure structure) {
    _payStructures.add(structure);
    return structure;
  }

  @override
  PayStructure updatePayStructure(PayStructure structure) {
    final i = _payStructures.indexWhere((s) => s.id == structure.id);
    if (i != -1) _payStructures[i] = structure;
    return structure;
  }

  // ─── Shifts ────────────────────────────────────────────────────────────────
  @override
  List<Shift> getShifts({DateTime? weekStart, String? employeeId}) =>
      _shifts.where((s) {
        if (employeeId != null && !s.employeeIds.contains(employeeId))
          return false;
        return true;
      }).toList();

  @override
  Shift addShift(Shift shift) {
    _shifts.add(shift);
    return shift;
  }

  @override
  Shift updateShift(Shift shift) {
    final i = _shifts.indexWhere((s) => s.id == shift.id);
    if (i != -1) _shifts[i] = shift;
    return shift;
  }

  // ─── Task assignments ───────────────────────────────────────────────────────
  @override
  List<TaskAssignment> getTaskAssignments({
    String? employeeId,
    DateTime? date,
  }) => _tasks
      .where((t) => employeeId == null || t.employeeId == employeeId)
      .toList();

  @override
  TaskAssignment addTaskAssignment(TaskAssignment task) {
    _tasks.add(task);
    return task;
  }

  @override
  TaskAssignment updateTaskAssignment(TaskAssignment task) {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) _tasks[i] = task;
    return task;
  }

  // ─── Attendance ─────────────────────────────────────────────────────────────
  @override
  List<AttendanceRecord> getAttendanceRecords({
    String? employeeId,
    DateTime? date,
    DateTime? fromDate,
    DateTime? toDate,
  }) => _attendance.where((a) {
    if (employeeId != null && a.employeeId != employeeId) return false;
    return true;
  }).toList();

  @override
  AttendanceRecord addAttendanceRecord(AttendanceRecord record) {
    _attendance.add(record);
    return record;
  }

  @override
  AttendanceRecord updateAttendanceRecord(AttendanceRecord record) {
    final i = _attendance.indexWhere((a) => a.id == record.id);
    if (i != -1) _attendance[i] = record;
    return record;
  }

  // ─── Piecework ──────────────────────────────────────────────────────────────
  @override
  List<PieceworkLog> getPieceworkLogs({
    String? employeeId,
    DateTime? date,
    String? shiftId,
  }) => _piecework
      .where((p) => employeeId == null || p.employeeId == employeeId)
      .toList();

  @override
  PieceworkLog addPieceworkLog(PieceworkLog log) {
    _piecework.add(log);
    return log;
  }

  // ─── Pay runs ───────────────────────────────────────────────────────────────
  @override
  List<PayRun> getPayRuns({String? payGroupId}) => _payRuns
      .where((r) => payGroupId == null || r.payGroupId == payGroupId)
      .toList();

  @override
  PayRun? getPayRun(String id) => _payRuns.where((r) => r.id == id).firstOrNull;

  @override
  PayRun calculatePayRun(
    String payGroupId,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final run = PayRun(
      id: _uid(),
      payGroupId: payGroupId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      payDate: periodEnd.add(const Duration(days: 2)),
      status: PayRunStatus.calculated,
      totalGross: 0,
      totalDeductions: 0,
      totalNet: 0,
      employeeCount: 0,
      complianceAlertIds: [],
      lineItems: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _payRuns.add(run);
    return run;
  }

  @override
  PayRun approvePayRun(String id, String approverUserId) {
    final i = _payRuns.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('PayRun $id not found');
    final updated = _payRuns[i].copyWith(
      status: PayRunStatus.approved,
      approvedByUserId: approverUserId,
      approvedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _payRuns[i] = updated;
    return updated;
  }

  @override
  PayRun disbursePayRun(String id) {
    final i = _payRuns.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('PayRun $id not found');
    final updated = _payRuns[i].copyWith(
      status: PayRunStatus.disbursed,
      disbursedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _payRuns[i] = updated;
    return updated;
  }

  // ─── Payslips ───────────────────────────────────────────────────────────────
  @override
  List<Payslip> getPayslips({String? employeeId, String? payRunId}) =>
      _payslips.where((s) {
        if (employeeId != null && s.employeeId != employeeId) return false;
        if (payRunId != null && s.payRunId != payRunId) return false;
        return true;
      }).toList();

  @override
  Payslip? getPayslip(String id) =>
      _payslips.where((s) => s.id == id).firstOrNull;

  // ─── Deduction rules ────────────────────────────────────────────────────────
  @override
  List<DeductionRule> getDeductionRules({String? employeeId}) =>
      _deductionRules.where((d) {
        if (!d.isActive) return false;
        if (employeeId != null &&
            d.employeeIds != null &&
            !d.employeeIds!.contains(employeeId)) {
          return false;
        }
        return true;
      }).toList();

  @override
  DeductionRule addDeductionRule(DeductionRule rule) {
    _deductionRules.add(rule);
    return rule;
  }

  @override
  DeductionRule updateDeductionRule(DeductionRule rule) {
    final i = _deductionRules.indexWhere((d) => d.id == rule.id);
    if (i != -1) _deductionRules[i] = rule;
    return rule;
  }

  // ── Garnishee orders (Sprint 6) ────────────────────────────────────────────
  final List<GarnisheeOrder> _garnisheeOrders = [];

  @override
  List<GarnisheeOrder> getGarnisheeOrders({String? employeeId}) {
    if (employeeId == null) return List.unmodifiable(_garnisheeOrders);
    return _garnisheeOrders.where((o) => o.employeeId == employeeId).toList();
  }

  @override
  GarnisheeOrder addGarnisheeOrder(GarnisheeOrder order) {
    _garnisheeOrders.add(order);
    return order;
  }

  @override
  GarnisheeOrder updateGarnisheeOrder(GarnisheeOrder order) {
    final idx = _garnisheeOrders.indexWhere((o) => o.id == order.id);
    if (idx < 0) throw StateError('GarnisheeOrder ${order.id} not found');
    _garnisheeOrders[idx] = order;
    return order;
  }

  // ─── Leave types ────────────────────────────────────────────────────────────
  @override
  List<LeaveType> getLeaveTypes() => List.unmodifiable(_leaveTypes);

  // ─── Leave balances ─────────────────────────────────────────────────────────
  @override
  List<LeaveBalance> getLeaveBalances({String? employeeId}) => _leaveBalances
      .where((b) => employeeId == null || b.employeeId == employeeId)
      .toList();

  // ─── Leave requests ─────────────────────────────────────────────────────────
  @override
  List<LeaveRequest> getLeaveRequests({
    String? employeeId,
    LeaveStatus? status,
  }) => _leaveRequests.where((r) {
    if (employeeId != null && r.employeeId != employeeId) return false;
    if (status != null && r.status != status) return false;
    return true;
  }).toList();

  @override
  LeaveRequest addLeaveRequest(LeaveRequest request) {
    _leaveRequests.add(request);
    return request;
  }

  @override
  LeaveRequest approveLeaveRequest(String id, String approverId) {
    final i = _leaveRequests.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('LeaveRequest $id not found');
    final updated = _leaveRequests[i].copyWith(
      status: LeaveStatus.approved,
      reviewedByUserId: approverId,
      reviewedAt: DateTime.now(),
    );
    _leaveRequests[i] = updated;
    return updated;
  }

  @override
  LeaveRequest rejectLeaveRequest(String id, String approverId, String reason) {
    final i = _leaveRequests.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('LeaveRequest $id not found');
    final updated = _leaveRequests[i].copyWith(
      status: LeaveStatus.rejected,
      reviewedByUserId: approverId,
      reviewedAt: DateTime.now(),
      rejectionReason: reason,
    );
    _leaveRequests[i] = updated;
    return updated;
  }

  @override
  LeaveRequest cancelLeaveRequest(String id) {
    final i = _leaveRequests.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('LeaveRequest $id not found');
    final updated = _leaveRequests[i].copyWith(status: LeaveStatus.cancelled);
    _leaveRequests[i] = updated;
    return updated;
  }

  // ─── Payment transactions ───────────────────────────────────────────────────
  @override
  List<PaymentTransaction> getTransactions({
    String? payRunId,
    String? employeeId,
  }) => _transactions.where((t) {
    if (payRunId != null && t.payRunId != payRunId) return false;
    if (employeeId != null && t.employeeId != employeeId) return false;
    return true;
  }).toList();

  // ─── Compliance alerts ──────────────────────────────────────────────────────
  @override
  List<ComplianceAlert> getComplianceAlerts({bool includeResolved = false}) =>
      _alerts.where((a) => includeResolved || !a.isResolved).toList();

  @override
  ComplianceAlert resolveAlert(
    String id,
    String resolvedByUserId,
    String resolution,
  ) {
    final i = _alerts.indexWhere((a) => a.id == id);
    if (i == -1) throw StateError('ComplianceAlert $id not found');
    final updated = _alerts[i].copyWith(
      isResolved: true,
      resolvedByUserId: resolvedByUserId,
      resolvedAt: DateTime.now(),
      resolution: resolution,
    );
    _alerts[i] = updated;
    return updated;
  }

  // ─── Audit log ──────────────────────────────────────────────────────────────
  @override
  List<AuditLogEntry> getAuditLog({
    String? entityType,
    String? entityId,
    int limit = 100,
  }) => _auditLog
      .where((e) {
        if (entityType != null && e.entityType != entityType) return false;
        if (entityId != null && e.entityId != entityId) return false;
        return true;
      })
      .take(limit)
      .toList();

  // ─── Incidents ──────────────────────────────────────────────────────────────
  @override
  List<IncidentRecord> getIncidents({String? employeeId}) => _incidents
      .where((i) => employeeId == null || i.employeeId == employeeId)
      .toList();

  @override
  IncidentRecord addIncident(IncidentRecord incident) {
    _incidents.add(incident);
    return incident;
  }

  @override
  IncidentRecord updateIncident(IncidentRecord incident) {
    final i = _incidents.indexWhere((r) => r.id == incident.id);
    if (i != -1) _incidents[i] = incident;
    return incident;
  }

  // ─── Communications ─────────────────────────────────────────────────────────
  @override
  List<CommunicationLog> getCommunicationLogs() =>
      List.unmodifiable(_communications);

  @override
  CommunicationLog sendCommunication({
    required CommunicationChannel channel,
    required String templateCode,
    required String subject,
    required String body,
    required List<String> recipientEmployeeIds,
    required String sentByUserId,
  }) {
    final log = CommunicationLog(
      id: _uid(),
      channel: channel,
      templateCode: templateCode,
      subject: subject,
      body: body,
      recipientEmployeeIds: recipientEmployeeIds,
      sentByUserId: sentByUserId,
      deliveredCount: recipientEmployeeIds.length,
      failedCount: 0,
      sentAt: DateTime.now(),
    );
    _communications.add(log);
    return log;
  }

  // ─── Terminations / soft-deletes ────────────────────────────────────────────
  @override
  PayrollEmployee terminateEmployee(
    String id,
    DateTime terminationDate,
    String reason,
  ) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx < 0) throw StateError('Employee $id not found');
    final updated = _employees[idx].copyWith(
      status: EmploymentStatus.terminated,
      endDate: terminationDate,
    );
    _employees[idx] = updated;
    return updated;
  }

  @override
  EmploymentContract voidContract(String id, String reason) {
    final idx = _contracts.indexWhere((c) => c.id == id);
    if (idx < 0) throw StateError('Contract $id not found');
    final updated = _contracts[idx].copyWith(status: ContractStatus.terminated);
    _contracts[idx] = updated;
    return updated;
  }

  @override
  bool deleteShift(String id) {
    final idx = _shifts.indexWhere((s) => s.id == id);
    if (idx < 0) return false;
    _shifts.removeAt(idx);
    return true;
  }

  @override
  bool deleteTaskAssignment(String id) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx < 0) return false;
    _tasks.removeAt(idx);
    return true;
  }

  @override
  DeductionRule deactivateDeductionRule(String id) {
    final idx = _deductionRules.indexWhere((r) => r.id == id);
    if (idx < 0) throw StateError('DeductionRule $id not found');
    final updated = _deductionRules[idx].copyWith(isActive: false);
    _deductionRules[idx] = updated;
    return updated;
  }

  @override
  bool deletePieceworkLog(String id, String correctionReason) {
    final idx = _piecework.indexWhere((l) => l.id == id);
    if (idx < 0) return false;
    _piecework.removeAt(idx);
    return true;
  }

  @override
  bool deleteLeaveRequest(String id) {
    final idx = _leaveRequests.indexWhere((r) => r.id == id);
    if (idx < 0) return false;
    _leaveRequests.removeAt(idx);
    return true;
  }

  @override
  IncidentRecord deactivateIncident(String id) {
    final idx = _incidents.indexWhere((i) => i.id == id);
    if (idx < 0) throw StateError('IncidentRecord $id not found');
    final updated = _incidents[idx].copyWith(status: IncidentStatus.closed);
    _incidents[idx] = updated;
    return updated;
  }

  @override
  PayGroup deactivatePayGroup(String id) {
    final idx = _payGroups.indexWhere((g) => g.id == id);
    if (idx < 0) throw StateError('PayGroup $id not found');
    final updated = _payGroups[idx].copyWith(isActive: false);
    _payGroups[idx] = updated;
    return updated;
  }

  // ─── Employer configuration ──────────────────────────────────────────────────
  EmployerConfig _employerConfig = EmployerConfig.defaultConfig;

  @override
  EmployerConfig getEmployerConfig() => _employerConfig;

  @override
  EmployerConfig updateEmployerConfig(EmployerConfig config) {
    _employerConfig = config;
    return _employerConfig;
  }
}
