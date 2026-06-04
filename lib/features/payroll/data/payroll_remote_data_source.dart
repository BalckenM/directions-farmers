import 'package:dio/dio.dart';
import 'package:mobile_app/features/payroll/data/payroll_data_source.dart';
import 'package:mobile_app/features/payroll/models/attendance_record.dart';
import 'package:mobile_app/features/payroll/models/audit_log_entry.dart';
import 'package:mobile_app/features/payroll/models/benefit_contribution.dart';
import 'package:mobile_app/features/payroll/models/communication_log.dart';
import 'package:mobile_app/features/payroll/models/compliance_alert.dart';
import 'package:mobile_app/features/payroll/models/deduction_rule.dart';
import 'package:mobile_app/features/payroll/models/employer_config.dart';
import 'package:mobile_app/features/payroll/models/employment_contract.dart';
import 'package:mobile_app/features/payroll/models/garnishee_order.dart';
import 'package:mobile_app/features/payroll/models/incident_record.dart';
import 'package:mobile_app/features/payroll/models/leave_balance.dart';
import 'package:mobile_app/features/payroll/models/leave_request.dart';
import 'package:mobile_app/features/payroll/models/leave_type.dart';
import 'package:mobile_app/features/payroll/models/pay_group.dart';
import 'package:mobile_app/features/payroll/models/pay_run.dart';
import 'package:mobile_app/features/payroll/models/pay_structure.dart';
import 'package:mobile_app/features/payroll/models/payment_transaction.dart';
import 'package:mobile_app/features/payroll/models/payroll_employee.dart';
import 'package:mobile_app/features/payroll/models/payslip.dart';
import 'package:mobile_app/features/payroll/models/piecework_log.dart';
import 'package:mobile_app/features/payroll/models/shift.dart';
import 'package:mobile_app/features/payroll/models/task_assignment.dart';
import 'package:mobile_app/features/payroll/models/worker_dispute.dart';

/// Remote (API) implementation of [PayrollDataSource].
///
/// Uses a write-through in-memory cache. Call [preload()] once at app start
/// to populate all caches from the server.
///
/// NOTE: The [PayrollDataSource] interface is synchronous. Write methods use
/// a best-effort sync wrapper. Migrate the interface to async in a future sprint.
class PayrollRemoteDataSource implements PayrollDataSource {
  PayrollRemoteDataSource(this._dio);

  final Dio _dio;

  // ── In-memory cache ────────────────────────────────────────────────────────
  final List<PayrollEmployee> _employees = [];
  final List<EmploymentContract> _contracts = [];
  final List<PayGroup> _payGroups = [];
  final List<PayStructure> _payStructures = [];
  final List<Shift> _shifts = [];
  final List<TaskAssignment> _tasks = [];
  final List<AttendanceRecord> _attendance = [];
  final List<PieceworkLog> _piecework = [];
  final List<PayRun> _payRuns = [];
  final List<Payslip> _payslips = [];
  final List<DeductionRule> _deductions = [];
  final List<GarnisheeOrder> _garnishees = [];
  final List<LeaveType> _leaveTypes = [];
  final List<LeaveBalance> _leaveBalances = [];
  final List<LeaveRequest> _leaveRequests = [];
  final List<PaymentTransaction> _transactions = [];
  final List<ComplianceAlert> _alerts = [];
  final List<AuditLogEntry> _auditLog = [];
  final List<IncidentRecord> _incidents = [];
  final List<CommunicationLog> _communications = [];
  final List<WorkerDispute> _disputes = [];
  final List<BenefitContribution> _benefitContributions = [];
  EmployerConfig? _employerConfig;

  // ── Preload ────────────────────────────────────────────────────────────────

  Future<void> preload() async {
    await Future.wait([
      _fetchList('/payroll/employees', _employees, PayrollEmployee.fromJson),
      _fetchList('/payroll/contracts', _contracts, EmploymentContract.fromJson),
      _fetchList('/payroll/pay-groups', _payGroups, PayGroup.fromJson),
      _fetchList(
        '/payroll/pay-structures',
        _payStructures,
        PayStructure.fromJson,
      ),
      _fetchList('/payroll/pay-runs', _payRuns, PayRun.fromJson),
      _fetchList('/payroll/payslips', _payslips, Payslip.fromJson),
      _fetchList('/payroll/deductions', _deductions, DeductionRule.fromJson),
      _fetchList(
        '/payroll/garnishee-orders',
        _garnishees,
        GarnisheeOrder.fromJson,
      ),
      _fetchList('/payroll/leave-types', _leaveTypes, LeaveType.fromJson),
      _fetchList(
        '/payroll/leave-balances',
        _leaveBalances,
        LeaveBalance.fromJson,
      ),
      _fetchList(
        '/payroll/leave-requests',
        _leaveRequests,
        LeaveRequest.fromJson,
      ),
      _fetchList(
        '/payroll/transactions',
        _transactions,
        PaymentTransaction.fromJson,
      ),
      _fetchList(
        '/payroll/compliance-alerts',
        _alerts,
        ComplianceAlert.fromJson,
      ),
      _fetchList('/payroll/audit-log', _auditLog, AuditLogEntry.fromJson),
      _fetchList('/payroll/incidents', _incidents, IncidentRecord.fromJson),
      _fetchList(
        '/payroll/communications',
        _communications,
        CommunicationLog.fromJson,
      ),
      _fetchList('/payroll/shifts', _shifts, Shift.fromJson),
      _fetchList('/payroll/task-assignments', _tasks, TaskAssignment.fromJson),
      _fetchList('/payroll/attendance', _attendance, AttendanceRecord.fromJson),
      _fetchList('/payroll/piecework', _piecework, PieceworkLog.fromJson),
      _fetchList('/payroll/worker-disputes', _disputes, WorkerDispute.fromJson),
      _fetchList(
        '/payroll/benefit-contributions',
        _benefitContributions,
        BenefitContribution.fromJson,
      ),
      _fetchEmployerConfig(),
    ]);
  }

  Future<void> _fetchEmployerConfig() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        '/payroll/employer-config',
      );
      if (resp.data != null) {
        _employerConfig = EmployerConfig.fromJson(resp.data!);
      }
    } on DioException catch (e) {
      assert(() {
        // ignore: avoid_print
        print('[Payroll] GET /payroll/employer-config failed: ${e.message}');
        return true;
      }());
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _fetchList<T>(
    String path,
    List<T> cache,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final resp = await _dio.get<List<dynamic>>(path);
      if (resp.data != null) {
        cache
          ..clear()
          ..addAll(resp.data!.cast<Map<String, dynamic>>().map(fromJson));
      }
    } on DioException catch (e) {
      assert(() {
        print('[Payroll] GET $path failed: ${e.message}');
        return true;
      }());
    }
  }

  Future<T> _post<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) f,
  ) async {
    final r = await _dio.post<Map<String, dynamic>>(path, data: body);
    return f(r.data!);
  }

  Future<T> _put<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) f,
  ) async {
    final r = await _dio.put<Map<String, dynamic>>(path, data: body);
    return f(r.data!);
  }

  Future<T> _patch<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) f,
  ) async {
    final r = await _dio.patch<Map<String, dynamic>>(path, data: body);
    return f(r.data!);
  }

  Future<void> _del(String path) => _dio.delete<void>(path);

  // Synchronous bridge — only resolves if the future is already complete
  // (e.g. resolved within the same microtask after a mock). For real async I/O
  // callers must await preload() and cache mutations will be applied async.
  T _sync<T>(Future<T> future) {
    T? result;
    Object? err;
    bool done = false;
    future.then(
      (v) {
        result = v;
        done = true;
      },
      onError: (e) {
        err = e;
        done = true;
      },
    );
    if (!done)
      throw StateError(
        'PayrollRemoteDataSource: sync write unavailable in async I/O context.',
      );
    if (err != null) throw err!;
    return result as T;
  }

  // ── Employees ──────────────────────────────────────────────────────────────
  @override
  List<PayrollEmployee> getEmployees() => List.unmodifiable(_employees);
  @override
  PayrollEmployee? getEmployee(String id) =>
      _employees.where((e) => e.id == id).firstOrNull;
  @override
  PayrollEmployee addEmployee(PayrollEmployee employee) {
    final future =
        _post(
          '/payroll/employees',
          employee.toJson(),
          PayrollEmployee.fromJson,
        ).then((s) {
          _employees.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  Future<Map<String, dynamic>> bulkImportEmployees(
    List<PayrollEmployee> employees,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/payroll/employees/import',
      data: {'employees': employees.map((e) => e.toJson()).toList()},
    );
    final result = response.data ?? {};
    // Update local cache with inserted rows
    final inserted = (result['rows'] as List<dynamic>? ?? [])
        .map((r) => PayrollEmployee.fromJson(r as Map<String, dynamic>))
        .toList();
    _employees.addAll(inserted);
    return result;
  }

  @override
  PayrollEmployee updateEmployee(PayrollEmployee employee) {
    final future =
        _put(
          '/payroll/employees/${employee.id}',
          employee.toJson(),
          PayrollEmployee.fromJson,
        ).then((s) {
          final i = _employees.indexWhere((e) => e.id == s.id);
          if (i >= 0)
            _employees[i] = s;
          else
            _employees.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Contracts ──────────────────────────────────────────────────────────────
  @override
  List<EmploymentContract> getContracts({String? employeeId}) {
    if (employeeId == null) return List.unmodifiable(_contracts);
    return _contracts.where((c) => c.employeeId == employeeId).toList();
  }

  @override
  EmploymentContract? getContract(String id) =>
      _contracts.where((c) => c.id == id).firstOrNull;
  @override
  EmploymentContract addContract(EmploymentContract contract) {
    final future =
        _post(
          '/payroll/contracts',
          contract.toJson(),
          EmploymentContract.fromJson,
        ).then((s) {
          _contracts.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  EmploymentContract updateContract(EmploymentContract contract) {
    final future =
        _put(
          '/payroll/contracts/${contract.id}',
          contract.toJson(),
          EmploymentContract.fromJson,
        ).then((s) {
          final i = _contracts.indexWhere((c) => c.id == s.id);
          if (i >= 0)
            _contracts[i] = s;
          else
            _contracts.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Pay groups ──────────────────────────────────────────────────────────────
  @override
  List<PayGroup> getPayGroups() => List.unmodifiable(_payGroups);
  @override
  PayGroup addPayGroup(PayGroup group) {
    final future =
        _post('/payroll/pay-groups', group.toJson(), PayGroup.fromJson).then((
          s,
        ) {
          _payGroups.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  PayGroup updatePayGroup(PayGroup group) {
    final future =
        _put(
          '/payroll/pay-groups/${group.id}',
          group.toJson(),
          PayGroup.fromJson,
        ).then((s) {
          final i = _payGroups.indexWhere((g) => g.id == s.id);
          if (i >= 0)
            _payGroups[i] = s;
          else
            _payGroups.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Pay structures ──────────────────────────────────────────────────────────
  @override
  List<PayStructure> getPayStructures() => List.unmodifiable(_payStructures);
  @override
  PayStructure addPayStructure(PayStructure structure) {
    final future =
        _post(
          '/payroll/pay-structures',
          structure.toJson(),
          PayStructure.fromJson,
        ).then((s) {
          _payStructures.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  PayStructure updatePayStructure(PayStructure structure) {
    final future =
        _put(
          '/payroll/pay-structures/${structure.id}',
          structure.toJson(),
          PayStructure.fromJson,
        ).then((s) {
          final i = _payStructures.indexWhere((p) => p.id == s.id);
          if (i >= 0)
            _payStructures[i] = s;
          else
            _payStructures.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Shifts (no fromJson — cache only, mutated in-memory) ───────────────────
  @override
  List<Shift> getShifts({DateTime? weekStart, String? employeeId}) {
    var list = _shifts.toList();
    if (employeeId != null)
      list = list.where((s) => s.employeeIds.contains(employeeId)).toList();
    if (weekStart != null) {
      final end = weekStart.add(const Duration(days: 7));
      list = list
          .where((s) => !s.date.isBefore(weekStart) && s.date.isBefore(end))
          .toList();
    }
    return list;
  }

  @override
  Shift addShift(Shift shift) {
    final future = _post('/payroll/shifts', shift.toJson(), Shift.fromJson)
        .then((s) {
          _shifts.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  Shift updateShift(Shift shift) {
    final future =
        _put(
          '/payroll/shifts/${shift.id}',
          shift.toJson(),
          Shift.fromJson,
        ).then((s) {
          final i = _shifts.indexWhere((e) => e.id == s.id);
          if (i >= 0)
            _shifts[i] = s;
          else
            _shifts.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Task assignments (no fromJson — in-memory) ──────────────────────────────
  @override
  List<TaskAssignment> getTaskAssignments({
    String? employeeId,
    DateTime? date,
  }) {
    var list = _tasks.toList();
    if (employeeId != null)
      list = list.where((t) => t.employeeId == employeeId).toList();
    if (date != null)
      list = list
          .where(
            (t) =>
                t.date.year == date.year &&
                t.date.month == date.month &&
                t.date.day == date.day,
          )
          .toList();
    return list;
  }

  @override
  TaskAssignment addTaskAssignment(TaskAssignment task) {
    final future =
        _post(
          '/payroll/task-assignments',
          task.toJson(),
          TaskAssignment.fromJson,
        ).then((s) {
          _tasks.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  TaskAssignment updateTaskAssignment(TaskAssignment task) {
    final future =
        _put(
          '/payroll/task-assignments/${task.id}',
          task.toJson(),
          TaskAssignment.fromJson,
        ).then((s) {
          final i = _tasks.indexWhere((t) => t.id == s.id);
          if (i >= 0)
            _tasks[i] = s;
          else
            _tasks.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Attendance (no fromJson — in-memory) ────────────────────────────────────
  @override
  List<AttendanceRecord> getAttendanceRecords({
    String? employeeId,
    DateTime? date,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    var list = _attendance.toList();
    if (employeeId != null)
      list = list.where((a) => a.employeeId == employeeId).toList();
    if (date != null)
      list = list
          .where(
            (a) =>
                a.date.year == date.year &&
                a.date.month == date.month &&
                a.date.day == date.day,
          )
          .toList();
    if (fromDate != null)
      list = list.where((a) => !a.date.isBefore(fromDate)).toList();
    if (toDate != null)
      list = list.where((a) => !a.date.isAfter(toDate)).toList();
    return list;
  }

  @override
  AttendanceRecord addAttendanceRecord(AttendanceRecord record) {
    final future =
        _post(
          '/payroll/attendance',
          record.toJson(),
          AttendanceRecord.fromJson,
        ).then((s) {
          _attendance.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  AttendanceRecord updateAttendanceRecord(AttendanceRecord record) {
    final future =
        _put(
          '/payroll/attendance/${record.id}',
          record.toJson(),
          AttendanceRecord.fromJson,
        ).then((s) {
          final i = _attendance.indexWhere((a) => a.id == s.id);
          if (i >= 0)
            _attendance[i] = s;
          else
            _attendance.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Piecework (no fromJson — in-memory) ─────────────────────────────────────
  @override
  List<PieceworkLog> getPieceworkLogs({
    String? employeeId,
    DateTime? date,
    String? shiftId,
  }) {
    var list = _piecework.toList();
    if (employeeId != null)
      list = list.where((p) => p.employeeId == employeeId).toList();
    if (shiftId != null)
      list = list.where((p) => p.shiftId == shiftId).toList();
    if (date != null)
      list = list
          .where(
            (p) =>
                p.date.year == date.year &&
                p.date.month == date.month &&
                p.date.day == date.day,
          )
          .toList();
    return list;
  }

  @override
  PieceworkLog addPieceworkLog(PieceworkLog log) {
    final future =
        _post('/payroll/piecework', log.toJson(), PieceworkLog.fromJson).then((
          s,
        ) {
          _piecework.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Pay runs ─────────────────────────────────────────────────────────────────
  @override
  List<PayRun> getPayRuns({String? payGroupId}) {
    if (payGroupId == null) return List.unmodifiable(_payRuns);
    return _payRuns.where((r) => r.payGroupId == payGroupId).toList();
  }

  @override
  PayRun? getPayRun(String id) => _payRuns.where((r) => r.id == id).firstOrNull;
  @override
  PayRun calculatePayRun(
    String payGroupId,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final future =
        _post('/payroll/pay-runs/calculate', {
          'payGroupId': payGroupId,
          'periodStart': periodStart.toIso8601String(),
          'periodEnd': periodEnd.toIso8601String(),
        }, PayRun.fromJson).then((s) {
          _payRuns.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  PayRun approvePayRun(String id, String approverUserId) {
    final future =
        _patch('/payroll/pay-runs/$id/approve', {
          'approverUserId': approverUserId,
        }, PayRun.fromJson).then((s) {
          final i = _payRuns.indexWhere((r) => r.id == s.id);
          if (i >= 0)
            _payRuns[i] = s;
          else
            _payRuns.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  PayRun disbursePayRun(String id) {
    final future = _patch('/payroll/pay-runs/$id/disburse', {}, PayRun.fromJson)
        .then((s) {
          final i = _payRuns.indexWhere((r) => r.id == s.id);
          if (i >= 0)
            _payRuns[i] = s;
          else
            _payRuns.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Payslips ─────────────────────────────────────────────────────────────────
  @override
  List<Payslip> getPayslips({String? employeeId, String? payRunId}) {
    var list = _payslips.toList();
    if (employeeId != null)
      list = list.where((p) => p.employeeId == employeeId).toList();
    if (payRunId != null)
      list = list.where((p) => p.payRunId == payRunId).toList();
    return list;
  }

  @override
  Payslip? getPayslip(String id) =>
      _payslips.where((p) => p.id == id).firstOrNull;

  // ── Deduction rules ──────────────────────────────────────────────────────────
  @override
  List<DeductionRule> getDeductionRules({String? employeeId}) {
    if (employeeId == null) return List.unmodifiable(_deductions);
    return _deductions
        .where(
          (d) =>
              d.employeeIds == null ||
              (d.employeeIds?.contains(employeeId) ?? false),
        )
        .toList();
  }

  @override
  DeductionRule addDeductionRule(DeductionRule rule) {
    final future =
        _post(
          '/payroll/deductions',
          rule.toJson(),
          DeductionRule.fromJson,
        ).then((s) {
          _deductions.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  DeductionRule updateDeductionRule(DeductionRule rule) {
    final future =
        _put(
          '/payroll/deductions/${rule.id}',
          rule.toJson(),
          DeductionRule.fromJson,
        ).then((s) {
          final i = _deductions.indexWhere((d) => d.id == s.id);
          if (i >= 0)
            _deductions[i] = s;
          else
            _deductions.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Garnishee orders ─────────────────────────────────────────────────────────
  @override
  List<GarnisheeOrder> getGarnisheeOrders({String? employeeId}) {
    if (employeeId == null) return List.unmodifiable(_garnishees);
    return _garnishees.where((g) => g.employeeId == employeeId).toList();
  }

  @override
  GarnisheeOrder addGarnisheeOrder(GarnisheeOrder order) {
    final future =
        _post(
          '/payroll/garnishee-orders',
          order.toJson(),
          GarnisheeOrder.fromJson,
        ).then((s) {
          _garnishees.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  GarnisheeOrder updateGarnisheeOrder(GarnisheeOrder order) {
    final future =
        _put(
          '/payroll/garnishee-orders/${order.id}',
          order.toJson(),
          GarnisheeOrder.fromJson,
        ).then((s) {
          final i = _garnishees.indexWhere((g) => g.id == s.id);
          if (i >= 0)
            _garnishees[i] = s;
          else
            _garnishees.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Leave types ──────────────────────────────────────────────────────────────
  @override
  List<LeaveType> getLeaveTypes() => List.unmodifiable(_leaveTypes);

  // ── Leave balances ───────────────────────────────────────────────────────────
  @override
  List<LeaveBalance> getLeaveBalances({String? employeeId}) {
    if (employeeId == null) return List.unmodifiable(_leaveBalances);
    return _leaveBalances.where((b) => b.employeeId == employeeId).toList();
  }

  // ── Leave requests ───────────────────────────────────────────────────────────
  @override
  List<LeaveRequest> getLeaveRequests({
    String? employeeId,
    LeaveStatus? status,
  }) {
    var list = _leaveRequests.toList();
    if (employeeId != null)
      list = list.where((r) => r.employeeId == employeeId).toList();
    if (status != null) list = list.where((r) => r.status == status).toList();
    return list;
  }

  @override
  LeaveRequest addLeaveRequest(LeaveRequest request) {
    final future =
        _post(
          '/payroll/leave-requests',
          request.toJson(),
          LeaveRequest.fromJson,
        ).then((s) {
          _leaveRequests.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  LeaveRequest approveLeaveRequest(String id, String approverId) {
    final future =
        _patch('/payroll/leave-requests/$id/approve', {
          'approverId': approverId,
        }, LeaveRequest.fromJson).then((s) {
          final i = _leaveRequests.indexWhere((r) => r.id == s.id);
          if (i >= 0)
            _leaveRequests[i] = s;
          else
            _leaveRequests.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  LeaveRequest rejectLeaveRequest(String id, String approverId, String reason) {
    final future =
        _patch('/payroll/leave-requests/$id/reject', {
          'approverId': approverId,
          'reason': reason,
        }, LeaveRequest.fromJson).then((s) {
          final i = _leaveRequests.indexWhere((r) => r.id == s.id);
          if (i >= 0)
            _leaveRequests[i] = s;
          else
            _leaveRequests.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  LeaveRequest cancelLeaveRequest(String id) {
    final future =
        _patch(
          '/payroll/leave-requests/$id/cancel',
          {},
          LeaveRequest.fromJson,
        ).then((s) {
          final i = _leaveRequests.indexWhere((r) => r.id == s.id);
          if (i >= 0)
            _leaveRequests[i] = s;
          else
            _leaveRequests.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Payment transactions ─────────────────────────────────────────────────────
  @override
  List<PaymentTransaction> getTransactions({
    String? payRunId,
    String? employeeId,
  }) {
    var list = _transactions.toList();
    if (payRunId != null)
      list = list.where((t) => t.payRunId == payRunId).toList();
    if (employeeId != null)
      list = list.where((t) => t.employeeId == employeeId).toList();
    return list;
  }

  @override
  Future<void> createTransaction(Map<String, dynamic> payload) async {
    await _dio.post<void>('/payroll/transactions', data: payload);
    // Refresh transactions cache
    await _fetchList(
      '/payroll/transactions',
      _transactions,
      PaymentTransaction.fromJson,
    );
  }

  // ── Compliance alerts ────────────────────────────────────────────────────────
  @override
  List<ComplianceAlert> getComplianceAlerts({bool includeResolved = false}) {
    if (includeResolved) return List.unmodifiable(_alerts);
    return _alerts.where((a) => !a.isResolved).toList();
  }

  @override
  ComplianceAlert resolveAlert(
    String id,
    String resolvedByUserId,
    String resolution,
  ) {
    final future =
        _patch('/payroll/compliance-alerts/$id/resolve', {
          'resolvedByUserId': resolvedByUserId,
          'resolution': resolution,
        }, ComplianceAlert.fromJson).then((s) {
          final i = _alerts.indexWhere((a) => a.id == s.id);
          if (i >= 0)
            _alerts[i] = s;
          else
            _alerts.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Audit log ────────────────────────────────────────────────────────────────
  @override
  List<AuditLogEntry> getAuditLog({
    String? entityType,
    String? entityId,
    int limit = 100,
  }) {
    var list = _auditLog.toList();
    if (entityType != null)
      list = list.where((a) => a.entityType == entityType).toList();
    if (entityId != null)
      list = list.where((a) => a.entityId == entityId).toList();
    return list.take(limit).toList();
  }

  // ── Incidents ────────────────────────────────────────────────────────────────
  @override
  List<IncidentRecord> getIncidents({String? employeeId}) {
    if (employeeId == null) return List.unmodifiable(_incidents);
    return _incidents.where((i) => i.employeeId == employeeId).toList();
  }

  @override
  IncidentRecord addIncident(IncidentRecord incident) {
    final future =
        _post(
          '/payroll/incidents',
          incident.toJson(),
          IncidentRecord.fromJson,
        ).then((s) {
          _incidents.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  IncidentRecord updateIncident(IncidentRecord incident) {
    final future =
        _put(
          '/payroll/incidents/${incident.id}',
          incident.toJson(),
          IncidentRecord.fromJson,
        ).then((s) {
          final i = _incidents.indexWhere((r) => r.id == s.id);
          if (i >= 0)
            _incidents[i] = s;
          else
            _incidents.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Communications ───────────────────────────────────────────────────────────
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
    final future =
        _post('/payroll/communications', {
          'channel': channel.name,
          'templateCode': templateCode,
          'subject': subject,
          'body': body,
          'recipientEmployeeIds': recipientEmployeeIds,
          'sentByUserId': sentByUserId,
        }, CommunicationLog.fromJson).then((s) {
          _communications.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Soft-deletes / Terminations ──────────────────────────────────────────────
  @override
  PayrollEmployee terminateEmployee(
    String id,
    DateTime terminationDate,
    String reason,
  ) {
    final future =
        _patch('/payroll/employees/$id/terminate', {
          'terminationDate': terminationDate.toIso8601String(),
          'reason': reason,
        }, PayrollEmployee.fromJson).then((s) {
          final i = _employees.indexWhere((e) => e.id == s.id);
          if (i >= 0)
            _employees[i] = s;
          else
            _employees.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  EmploymentContract voidContract(String id, String reason) {
    final future =
        _patch('/payroll/contracts/$id/void', {
          'reason': reason,
        }, EmploymentContract.fromJson).then((s) {
          final i = _contracts.indexWhere((c) => c.id == s.id);
          if (i >= 0)
            _contracts[i] = s;
          else
            _contracts.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  bool deleteShift(String id) {
    final future = _del('/payroll/shifts/$id').then((_) {
      _shifts.removeWhere((s) => s.id == id);
      return true;
    });
    return _sync(future);
  }

  @override
  bool deleteTaskAssignment(String id) {
    final future = _del('/payroll/task-assignments/$id').then((_) {
      _tasks.removeWhere((t) => t.id == id);
      return true;
    });
    return _sync(future);
  }

  @override
  DeductionRule deactivateDeductionRule(String id) {
    final future =
        _patch(
          '/payroll/deductions/$id/deactivate',
          {},
          DeductionRule.fromJson,
        ).then((s) {
          final i = _deductions.indexWhere((d) => d.id == s.id);
          if (i >= 0)
            _deductions[i] = s;
          else
            _deductions.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  bool deletePieceworkLog(String id, String correctionReason) {
    final future =
        _del(
          '/payroll/piecework/$id?reason=${Uri.encodeComponent(correctionReason)}',
        ).then((_) {
          _piecework.removeWhere((p) => p.id == id);
          return true;
        });
    return _sync(future);
  }

  @override
  bool deleteLeaveRequest(String id) {
    final future = _del('/payroll/leave-requests/$id').then((_) {
      _leaveRequests.removeWhere((r) => r.id == id);
      return true;
    });
    return _sync(future);
  }

  @override
  IncidentRecord deactivateIncident(String id) {
    final future =
        _patch(
          '/payroll/incidents/$id/deactivate',
          {},
          IncidentRecord.fromJson,
        ).then((s) {
          final i = _incidents.indexWhere((r) => r.id == s.id);
          if (i >= 0)
            _incidents[i] = s;
          else
            _incidents.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  PayGroup deactivatePayGroup(String id) {
    final future =
        _patch(
          '/payroll/pay-groups/$id/deactivate',
          {},
          PayGroup.fromJson,
        ).then((s) {
          final i = _payGroups.indexWhere((g) => g.id == s.id);
          if (i >= 0)
            _payGroups[i] = s;
          else
            _payGroups.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Employer configuration ──────────────────────────────────────────────────
  @override
  EmployerConfig getEmployerConfig() =>
      _employerConfig ?? EmployerConfig.defaultConfig;
  @override
  EmployerConfig updateEmployerConfig(EmployerConfig config) {
    final future =
        _put(
          '/payroll/employer-config',
          config.toJson(),
          EmployerConfig.fromJson,
        ).then((s) {
          _employerConfig = s;
          return s;
        });
    return _sync(future);
  }

  // ── Worker disputes ────────────────────────────────────────────────────────
  @override
  List<WorkerDispute> getDisputes({String? employeeId}) {
    if (employeeId == null) return List.unmodifiable(_disputes);
    return _disputes.where((d) => d.employeeId == employeeId).toList();
  }

  @override
  WorkerDispute fileDispute(WorkerDispute dispute) {
    final future =
        _post(
          '/payroll/worker-disputes',
          dispute.toJson(),
          WorkerDispute.fromJson,
        ).then((s) {
          _disputes.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  WorkerDispute updateDispute(WorkerDispute dispute) {
    final future =
        _put(
          '/payroll/worker-disputes/${dispute.id}',
          dispute.toJson(),
          WorkerDispute.fromJson,
        ).then((s) {
          final i = _disputes.indexWhere((d) => d.id == s.id);
          if (i >= 0)
            _disputes[i] = s;
          else
            _disputes.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  WorkerDispute resolveDispute(
    String id,
    String resolvedBy,
    String resolutionNote,
  ) {
    final future =
        _patch('/payroll/worker-disputes/$id/resolve', {
          'resolvedBy': resolvedBy,
          'resolutionNote': resolutionNote,
        }, WorkerDispute.fromJson).then((s) {
          final i = _disputes.indexWhere((d) => d.id == s.id);
          if (i >= 0)
            _disputes[i] = s;
          else
            _disputes.add(s);
          return s;
        });
    return _sync(future);
  }

  @override
  WorkerDispute dismissDispute(String id, String resolvedBy) {
    final future =
        _patch('/payroll/worker-disputes/$id/dismiss', {
          'resolvedBy': resolvedBy,
        }, WorkerDispute.fromJson).then((s) {
          final i = _disputes.indexWhere((d) => d.id == s.id);
          if (i >= 0)
            _disputes[i] = s;
          else
            _disputes.add(s);
          return s;
        });
    return _sync(future);
  }

  // ── Benefit contributions ──────────────────────────────────────────────────
  @override
  List<BenefitContribution> getBenefitContributions({String? employeeId}) {
    if (employeeId != null)
      return _benefitContributions
          .where((b) => b.employeeId == employeeId)
          .toList();
    return List.unmodifiable(_benefitContributions);
  }

  @override
  Future<BenefitContribution> addBenefitContribution(
    BenefitContribution contribution,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/payroll/benefit-contributions',
      data: contribution.toJson(),
    );
    final created = BenefitContribution.fromJson(response.data!);
    _benefitContributions.add(created);
    return created;
  }

  @override
  Future<BenefitContribution> updateBenefitContribution(
    BenefitContribution contribution,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/payroll/benefit-contributions/${contribution.id}',
      data: contribution.toJson(),
    );
    final updated = BenefitContribution.fromJson(response.data!);
    final i = _benefitContributions.indexWhere((b) => b.id == updated.id);
    if (i >= 0)
      _benefitContributions[i] = updated;
    else
      _benefitContributions.add(updated);
    return updated;
  }

  @override
  Future<void> deleteBenefitContribution(String id) async {
    await _dio.delete<void>('/payroll/benefit-contributions/$id');
    _benefitContributions.removeWhere((b) => b.id == id);
  }
}
