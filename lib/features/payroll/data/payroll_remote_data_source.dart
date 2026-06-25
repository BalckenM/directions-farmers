import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/utils/logger.dart';
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
/// Normalises a raw leave-type JSON object from the backend before passing
/// it to the freezed [LeaveType.fromJson]. The backend may send:
///   • `id` as int instead of String
///   • snake_case keys (`annual_entitlement_days`) instead of camelCase
///   • `is_paid`, `requires_approval` instead of camelCase
LeaveType _leaveTypeFromJson(Map<String, dynamic> raw) {
  final m = <String, dynamic>{
    'id': raw['id']?.toString() ?? '',
    'code': raw['code']?.toString() ?? '',
    'name': raw['name']?.toString() ?? '',
    'annualEntitlementDays':
        (raw['annualEntitlementDays'] ?? raw['annual_entitlement_days'] ?? 0)
            is String
        ? double.tryParse(
                (raw['annualEntitlementDays'] ?? raw['annual_entitlement_days'])
                    .toString(),
              ) ??
              0.0
        : ((raw['annualEntitlementDays'] ?? raw['annual_entitlement_days'] ?? 0)
                  as num)
              .toDouble(),
    'isPaid': raw['isPaid'] ?? raw['is_paid'] ?? false,
    'requiresApproval':
        raw['requiresApproval'] ?? raw['requires_approval'] ?? false,
    'colorHex': raw['colorHex'] ?? raw['color_hex'],
    'description': raw['description'],
  };
  return LeaveType.fromJson(m);
}

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

  /// groupId → list of employee IDs that are members of that group.
  final Map<String, List<String>> _groupMemberships = {};

  // ── Preload ────────────────────────────────────────────────────────────────

  /// Phase 1 — loads only the data needed to render the hub dashboard.
  /// Call this first; the UI unblocks as soon as it completes (~8 API calls).
  Future<void> preloadCritical() => Future.wait([
    _fetchAllPaginated('/employees', _employees, PayrollEmployee.fromJson),
    Future.wait([
      _fetchList('/payroll-groups', _payGroups, PayGroup.fromJson),
      _fetchMemberships(),
    ]).then((_) {
      if (_payGroups.isEmpty) {
        AppLogger.warning(
          'GET /payroll-groups returned 0 groups — check permissions '
          '(payroll:view) and company_id filter on the backend.',
          tag: 'Payroll',
        );
      } else {
        AppLogger.info(
          'GET /payroll-groups → ${_payGroups.length} group(s) loaded.',
          tag: 'Payroll',
        );
      }
    }),
    _fetchList(
      '/payroll/pay-structures',
      _payStructures,
      PayStructure.fromJson,
    ),
    _fetchList('/payroll?limit=100', _payRuns, PayRun.fromJson),
    _fetchList(
      '/payroll/compliance-alerts?limit=200',
      _alerts,
      ComplianceAlert.fromJson,
    ),
    _fetchList('/leave', _leaveRequests, LeaveRequest.fromJson),
    _fetchList('/leave/balances', _leaveBalances, LeaveBalance.fromJson),
    _fetchEmployerConfig(),
  ]);

  /// Phase 2 — loads secondary data (contracts, payslips, attendance, etc.)
  /// in the background after the UI is already visible.
  Future<void> preloadBackground() => Future.wait([
    _fetchAllPaginated(
      '/payroll/contracts',
      _contracts,
      EmploymentContract.fromJson,
    ),
    _fetchList('/payslips?limit=200', _payslips, Payslip.fromJson),
    _fetchList('/payroll/deductions', _deductions, DeductionRule.fromJson),
    _fetchList(
      '/payroll/garnishee-orders',
      _garnishees,
      GarnisheeOrder.fromJson,
    ),
    _fetchList('/leave/types/list', _leaveTypes, _leaveTypeFromJson),
    _fetchList(
      '/payroll/transactions?limit=200',
      _transactions,
      PaymentTransaction.fromJson,
    ),
    _fetchList('/audit', _auditLog, AuditLogEntry.fromJson),
    _fetchList('/payroll/incidents', _incidents, IncidentRecord.fromJson),
    _fetchList(
      '/payroll/communications',
      _communications,
      CommunicationLog.fromJson,
    ),
    _fetchList('/attendance/shifts', _shifts, Shift.fromJson),
    _fetchList('/payroll/task-assignments', _tasks, TaskAssignment.fromJson),
    _fetchAllPaginated(
      '/attendance/records',
      _attendance,
      AttendanceRecord.fromJson,
    ),
    _fetchList('/payroll/piecework', _piecework, PieceworkLog.fromJson),
    _fetchList('/payroll/worker-disputes', _disputes, WorkerDispute.fromJson),
    _fetchList(
      '/benefits/enrolments/list',
      _benefitContributions,
      BenefitContribution.fromJson,
    ),
  ]);

  /// Convenience: runs critical then background. Used by full-reload scenarios.
  Future<void> preload() async {
    await preloadCritical();
    preloadBackground(); // fire-and-forget: secondary data loads after UI shows
  }

  Future<void> _fetchEmployerConfig() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        '/payroll/employer-config',
      );
      if (resp.data != null) {
        final d = resp.data!['data'] as Map<String, dynamic>? ?? resp.data!;
        _employerConfig = EmployerConfig.fromJson(d);
      }
    } on DioException catch (e) {
      _logDioError('GET', '/payroll/employer-config', e);
    } catch (e, st) {
      AppLogger.error(
        'GET /payroll/employer-config failed',
        tag: 'Payroll',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _fetchMemberships() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        '/payroll-groups/memberships',
      );
      if (resp.data == null) return;
      final list =
          (resp.data!['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      _groupMemberships.clear();
      for (final m in list) {
        final gId = m['payroll_group_id']?.toString() ?? '';
        final eId = m['employee_id']?.toString() ?? '';
        if (gId.isEmpty || eId.isEmpty) continue;
        _groupMemberships.putIfAbsent(gId, () => []).add(eId);
      }
    } on DioException catch (e) {
      _logDioError('GET', '/payroll-groups/memberships', e);
    } catch (e, st) {
      AppLogger.error(
        'GET /payroll-groups/memberships failed',
        tag: 'Payroll',
        error: e,
        stackTrace: st,
      );
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Logs a DioException with full detail: status code, server message, and
  /// the raw response body so the exact backend error is visible in the
  /// in-app debug console AND the terminal.
  void _logDioError(String method, String path, DioException e) {
    final status = e.response?.statusCode ?? 'no-response';
    final serverMsg = (() {
      final data = e.response?.data;
      if (data is Map) {
        final err = data['error'];
        if (err is Map) return err['message'] ?? err.toString();
        return data.toString();
      }
      return data?.toString() ?? e.message ?? 'unknown';
    })();
    AppLogger.error(
      '$method $path → $status | $serverMsg',
      tag: 'Payroll',
      error: e,
    );
  }

  Future<void> _fetchList<T>(
    String path,
    List<T> cache,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final resp = await _dio.get<Map<String, dynamic>>(path);
        if (resp.data != null) {
          final raw = (resp.data!['data'] as List<dynamic>?) ?? [];
          cache
            ..clear()
            ..addAll(raw.cast<Map<String, dynamic>>().map(fromJson));
        }
        return;
      } on DioException catch (e) {
        if (e.response?.statusCode == 429 && attempt < 2) {
          await Future<void>.delayed(Duration(seconds: (attempt + 1) * 2));
          continue;
        }
        _logDioError('GET', path, e);
        return;
      } catch (e, st) {
        AppLogger.error(
          'GET $path failed',
          tag: 'Payroll',
          error: e,
          stackTrace: st,
        );
        return;
      }
    }
  }

  /// Paginated fetch: loads ALL records page-by-page without blocking the UI.
  /// Uses large page size to minimize request count and retries on 429.
  Future<void> _fetchAllPaginated<T>(
    String basePath,
    List<T> cache,
    T Function(Map<String, dynamic>) fromJson, {
    int pageSize = 500,
  }) async {
    cache.clear();
    int page = 1;
    int retries = 0;
    const maxRetries = 3;
    while (true) {
      final separator = basePath.contains('?') ? '&' : '?';
      final path = '$basePath${separator}page=$page&limit=$pageSize';
      try {
        final resp = await _dio.get<Map<String, dynamic>>(path);
        if (resp.data == null) break;
        final list = (resp.data!['data'] as List<dynamic>?) ?? [];
        if (list.isEmpty) break;
        cache.addAll(list.cast<Map<String, dynamic>>().map(fromJson));
        final total = resp.data!['total'] as int? ?? list.length;
        if (cache.length >= total || list.length < pageSize) break;
        page++;
        retries = 0;
      } on DioException catch (e) {
        if (e.response?.statusCode == 429 && retries < maxRetries) {
          retries++;
          await Future<void>.delayed(Duration(seconds: retries * 2));
          continue; // retry same page
        }
        _logDioError('GET', path, e);
        break;
      } catch (e, st) {
        AppLogger.error(
          'GET $path failed',
          tag: 'Payroll',
          error: e,
          stackTrace: st,
        );
        break;
      }
    }
  }

  Future<T> _post<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) f, {
    Duration? timeout,
  }) async {
    try {
      final options = timeout != null
          ? Options(receiveTimeout: timeout, sendTimeout: timeout)
          : null;
      final r = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
        options: options,
      );
      final d = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
      return f(d);
    } on DioException catch (e) {
      _logDioError('POST', path, e);
      rethrow;
    }
  }

  Future<T> _put<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) f,
  ) async {
    try {
      final r = await _dio.put<Map<String, dynamic>>(path, data: body);
      final d = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
      return f(d);
    } on DioException catch (e) {
      _logDioError('PUT', path, e);
      rethrow;
    }
  }

  Future<T> _patch<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) f,
  ) async {
    try {
      final r = await _dio.patch<Map<String, dynamic>>(path, data: body);
      final d = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
      return f(d);
    } on DioException catch (e) {
      _logDioError('PATCH', path, e);
      rethrow;
    }
  }

  Future<void> _del(String path) async {
    try {
      await _dio.delete<void>(path);
    } on DioException catch (e) {
      _logDioError('DELETE', path, e);
      rethrow;
    }
  }

  // ── Employees ──────────────────────────────────────────────────────────────

  /// Maps a [PayrollEmployee] to the snake_case body shape expected by the backend.
  Map<String, dynamic> _employeeToBody(PayrollEmployee e) => {
    'name': e.fullName,
    'role': 'employee',
    'job_title': e.occupationTitle,
    'start_date': e.startDate.toIso8601String().split('T').first,
    if (e.endDate != null)
      'end_date': e.endDate!.toIso8601String().split('T').first,
    if (e.email != null) 'email': e.email,
    if (e.phone != null) 'phone': e.phone,
    'address': e.address,
    'national_id': e.idOrPassportNumber,
    'emergency_contact': {'name': e.nextOfKinName, 'phone': e.nextOfKinPhone},
    'employment_status': e.status.name,
    'agr_employment_type': e.engagementType.name,
    if (e.bankName != null) 'bank_name': e.bankName,
    if (e.bankAccountNumber != null) 'bank_account_no': e.bankAccountNumber,
    if (e.bankBranchCode != null) 'bank_branch': e.bankBranchCode,
    'agr_housing_provided': e.hasHousingBenefit,
    if (e.housingValuePerMonth != null)
      'agr_housing_value': e.housingValuePerMonth,
    'agr_meals_provided': e.hasFoodBenefit,
    if (e.foodValuePerMonth != null)
      'agr_meals_daily_value': e.foodValuePerMonth,
    if (e.dateOfBirth != null)
      'date_of_birth': e.dateOfBirth!.toIso8601String().split('T').first,
    // gross_salary required by backend; not in Flutter model — default 0
    'gross_salary': 0,
  };

  @override
  List<PayrollEmployee> getEmployees() => List.unmodifiable(_employees);
  @override
  PayrollEmployee? getEmployee(String id) =>
      _employees.where((e) => e.id == id).firstOrNull;
  @override
  Future<PayrollEmployee> addEmployee(PayrollEmployee employee) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/employees',
      data: _employeeToBody(employee),
    );
    // Backend returns {data: {user: {...}, employee: {...}}}
    final d = r.data!['data'] as Map<String, dynamic>? ?? r.data!;
    final empData = d['employee'] as Map<String, dynamic>? ?? d;
    final merged = <String, dynamic>{
      ...empData,
      if (d.containsKey('user')) 'user': d['user'],
    };
    final s = PayrollEmployee.fromJson(merged);
    _employees.add(s);
    return s;
  }

  @override
  Future<Map<String, dynamic>> bulkImportEmployees(
    List<PayrollEmployee> employees,
  ) async {
    // Backend expects a CSV file upload (multipart), not a JSON array.
    final buffer = StringBuffer();
    buffer.writeln(
      'name,email,employee_no,job_title,start_date,gross_salary,phone',
    );
    for (final e in employees) {
      final safeName = e.fullName.replaceAll('"', '""');
      buffer.writeln(
        '"$safeName",${e.email ?? ''},,' // employee_no left blank
        '"${e.occupationTitle}",'
        '${e.startDate.toIso8601String().split('T').first},'
        '0,${e.phone ?? ''}',
      );
    }
    final file = MultipartFile.fromBytes(
      utf8.encode(buffer.toString()),
      filename: 'import.csv',
      contentType: DioMediaType('text', 'csv'),
    );
    final response = await _dio.post<Map<String, dynamic>>(
      '/employees/import',
      data: FormData.fromMap({'file': file}),
    );
    return response.data ?? {};
  }

  @override
  Future<PayrollEmployee> updateEmployee(PayrollEmployee employee) async {
    final r = await _dio.put<Map<String, dynamic>>(
      '/employees/${employee.id}',
      data: _employeeToBody(employee),
    );
    final d = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    final s = PayrollEmployee.fromJson(d);
    final i = _employees.indexWhere((e) => e.id == s.id);
    if (i >= 0) {
      _employees[i] = s;
    } else {
      _employees.add(s);
    }
    return s;
  }

  @override
  Future<String> uploadProfileImage(String employeeId, String filePath) async {
    final MultipartFile file;
    if (kIsWeb) {
      // On web, filePath is a blob URL from image_picker_for_web.
      // We need to read it as bytes via XFile.
      final xfile = XFile(filePath);
      final bytes = await xfile.readAsBytes();
      file = MultipartFile.fromBytes(
        bytes,
        filename: xfile.name.isNotEmpty ? xfile.name : 'profile.jpg',
      );
    } else {
      file = await MultipartFile.fromFile(filePath);
    }
    final formData = FormData.fromMap({'photo': file});
    await _dio.post<void>('/employees/$employeeId/photo', data: formData);
    // Backend returns {photo_upload_id: N}; serve photo via GET /employees/:id/photo
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/$'), '');
    final imageUrl = '$baseUrl/employees/$employeeId/photo';
    final i = _employees.indexWhere((e) => e.id == employeeId);
    if (i >= 0) {
      _employees[i] = _employees[i].copyWith(profileImageUrl: imageUrl);
    }
    return imageUrl;
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
  Future<EmploymentContract> addContract(EmploymentContract contract) async {
    final s = await _post(
      '/payroll/contracts',
      contract.toJson(),
      EmploymentContract.fromJson,
    );
    _contracts.add(s);
    return s;
  }

  @override
  Future<EmploymentContract> updateContract(EmploymentContract contract) async {
    final s = await _put(
      '/payroll/contracts/${contract.id}',
      contract.toJson(),
      EmploymentContract.fromJson,
    );
    final i = _contracts.indexWhere((c) => c.id == s.id);
    if (i >= 0) {
      _contracts[i] = s;
    } else {
      _contracts.add(s);
    }
    return s;
  }

  // ── Pay groups ──────────────────────────────────────────────────────────────
  @override
  List<PayGroup> getPayGroups() => List.unmodifiable(_payGroups);

  @override
  List<String> getGroupMemberIds(String groupId) =>
      List.unmodifiable(_groupMemberships[groupId] ?? const []);

  @override
  Future<PayGroup> addPayGroup(PayGroup group) async {
    final s = await _post('/payroll-groups', {
      'name': group.name,
      'pay_frequency': group.frequency.name,
      'pay_day': group.payDayOffset,
      if (group.description != null) 'description': group.description,
    }, PayGroup.fromJson);
    _payGroups.add(s);
    return s;
  }

  @override
  Future<PayGroup> updatePayGroup(PayGroup group) async {
    final s = await _put('/payroll-groups/${group.id}', {
      'name': group.name,
      'pay_frequency': group.frequency.name,
      'pay_day': group.payDayOffset,
      if (group.description != null) 'description': group.description,
      'is_active': group.isActive,
    }, PayGroup.fromJson);
    final i = _payGroups.indexWhere((g) => g.id == s.id);
    if (i >= 0) {
      _payGroups[i] = s;
    } else {
      _payGroups.add(s);
    }
    return s;
  }

  // ── Pay structures ──────────────────────────────────────────────────────────
  @override
  List<PayStructure> getPayStructures() => List.unmodifiable(_payStructures);
  @override
  Future<PayStructure> addPayStructure(PayStructure structure) async {
    final s = await _post(
      '/payroll/pay-structures',
      structure.toJson(),
      PayStructure.fromJson,
    );
    _payStructures.add(s);
    return s;
  }

  @override
  Future<PayStructure> updatePayStructure(PayStructure structure) async {
    final s = await _put(
      '/payroll/pay-structures/${structure.id}',
      structure.toJson(),
      PayStructure.fromJson,
    );
    final i = _payStructures.indexWhere((p) => p.id == s.id);
    if (i >= 0) {
      _payStructures[i] = s;
    } else {
      _payStructures.add(s);
    }
    return s;
  }

  // ── Shifts (no fromJson — cache only, mutated in-memory) ───────────────────
  @override
  List<Shift> getShifts({DateTime? weekStart, String? employeeId}) {
    var list = _shifts.toList();
    if (employeeId != null) {
      list = list.where((s) => s.employeeIds.contains(employeeId)).toList();
    }
    if (weekStart != null) {
      final end = weekStart.add(const Duration(days: 7));
      list = list
          .where((s) => !s.date.isBefore(weekStart) && s.date.isBefore(end))
          .toList();
    }
    return list;
  }

  @override
  Future<Shift> addShift(Shift shift) async {
    final s = await _post('/attendance/shifts', shift.toJson(), Shift.fromJson);
    _shifts.add(s);
    return s;
  }

  @override
  Future<Shift> updateShift(Shift shift) async {
    final s = await _patch(
      '/attendance/shifts/${shift.id}',
      shift.toJson(),
      Shift.fromJson,
    );
    final i = _shifts.indexWhere((e) => e.id == s.id);
    if (i >= 0) {
      _shifts[i] = s;
    } else {
      _shifts.add(s);
    }
    return s;
  }

  // ── Task assignments (no fromJson — in-memory) ──────────────────────────────
  @override
  List<TaskAssignment> getTaskAssignments({
    String? employeeId,
    DateTime? date,
  }) {
    var list = _tasks.toList();
    if (employeeId != null) {
      list = list.where((t) => t.employeeId == employeeId).toList();
    }
    if (date != null) {
      list = list
          .where(
            (t) =>
                t.date.year == date.year &&
                t.date.month == date.month &&
                t.date.day == date.day,
          )
          .toList();
    }
    return list;
  }

  @override
  Future<TaskAssignment> addTaskAssignment(TaskAssignment task) async {
    final s = await _post(
      '/payroll/task-assignments',
      task.toJson(),
      TaskAssignment.fromJson,
    );
    _tasks.add(s);
    return s;
  }

  @override
  Future<TaskAssignment> updateTaskAssignment(TaskAssignment task) async {
    final s = await _put(
      '/payroll/task-assignments/${task.id}',
      task.toJson(),
      TaskAssignment.fromJson,
    );
    final i = _tasks.indexWhere((t) => t.id == s.id);
    if (i >= 0) {
      _tasks[i] = s;
    } else {
      _tasks.add(s);
    }
    return s;
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
    if (employeeId != null) {
      list = list.where((a) => a.employeeId == employeeId).toList();
    }
    if (date != null) {
      list = list
          .where(
            (a) =>
                a.date.year == date.year &&
                a.date.month == date.month &&
                a.date.day == date.day,
          )
          .toList();
    }
    if (fromDate != null) {
      list = list.where((a) => !a.date.isBefore(fromDate)).toList();
    }
    if (toDate != null) {
      list = list.where((a) => !a.date.isAfter(toDate)).toList();
    }
    return list;
  }

  @override
  Future<AttendanceRecord> addAttendanceRecord(AttendanceRecord record) async {
    final s = await _post(
      '/attendance/records',
      record.toJson(),
      AttendanceRecord.fromJson,
    );
    _attendance.add(s);
    return s;
  }

  @override
  Future<AttendanceRecord> updateAttendanceRecord(
    AttendanceRecord record,
  ) async {
    final s = await _patch(
      '/attendance/records/${record.id}',
      record.toJson(),
      AttendanceRecord.fromJson,
    );
    final i = _attendance.indexWhere((a) => a.id == s.id);
    if (i >= 0) {
      _attendance[i] = s;
    } else {
      _attendance.add(s);
    }
    return s;
  }

  // ── Piecework (no fromJson — in-memory) ─────────────────────────────────────
  @override
  List<PieceworkLog> getPieceworkLogs({
    String? employeeId,
    DateTime? date,
    String? shiftId,
  }) {
    var list = _piecework.toList();
    if (employeeId != null) {
      list = list.where((p) => p.employeeId == employeeId).toList();
    }
    if (shiftId != null) {
      list = list.where((p) => p.shiftId == shiftId).toList();
    }
    if (date != null) {
      list = list
          .where(
            (p) =>
                p.date.year == date.year &&
                p.date.month == date.month &&
                p.date.day == date.day,
          )
          .toList();
    }
    return list;
  }

  @override
  Future<PieceworkLog> addPieceworkLog(PieceworkLog log) async {
    final s = await _post(
      '/payroll/piecework',
      log.toJson(),
      PieceworkLog.fromJson,
    );
    _piecework.add(s);
    return s;
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
  Future<PayRun> calculatePayRun(
    String payGroupId,
    DateTime periodStart,
    DateTime periodEnd, {
    DateTime? payDate,
  }) async {
    // Backend requires period_label, period_start, period_end.
    // group_ids is an optional filter array (not pay_group_id).
    final start = periodStart.toIso8601String().substring(0, 10);
    final end = periodEnd.toIso8601String().substring(0, 10);
    final label =
        '${periodStart.year}-${periodStart.month.toString().padLeft(2, '0')}';
    final s = await _post(
      '/payroll/run',
      {
        'period_label': label,
        'period_start': start,
        'period_end': end,
        'group_ids': [payGroupId],
      },
      PayRun.fromJson,
      timeout: AppConstants.apiLongTimeout,
    );
    _payRuns.add(s);
    return s;
  }

  @override
  Future<PayRun> completePayRun(String id) async {
    // PATCH /:id/complete — moves draft → completed (required before approve)
    final s = await _patch('/payroll/$id/complete', {}, PayRun.fromJson);
    final i = _payRuns.indexWhere((r) => r.id == s.id);
    if (i >= 0) {
      _payRuns[i] = s;
    } else {
      _payRuns.add(s);
    }
    return s;
  }

  @override
  Future<PayRun> approvePayRun(String id, String approverUserId) async {
    // Backend uses req.user.id — no approverUserId needed in body.
    // Run must be in 'completed' status first (call completePayRun first).
    final s = await _patch('/payroll/$id/approve', {}, PayRun.fromJson);
    final i = _payRuns.indexWhere((r) => r.id == s.id);
    if (i >= 0) {
      _payRuns[i] = s;
    } else {
      _payRuns.add(s);
    }
    return s;
  }

  @override
  Future<PayRun> disbursePayRun(String id) async {
    final s = await _patch('/payroll/$id/pay', {}, PayRun.fromJson);
    final i = _payRuns.indexWhere((r) => r.id == s.id);
    if (i >= 0) {
      _payRuns[i] = s;
    } else {
      _payRuns.add(s);
    }
    return s;
  }

  @override
  Future<PayRun> rejectPayRun(String id, {String? reason}) async {
    final body = reason != null
        ? <String, dynamic>{'reason': reason}
        : <String, dynamic>{};
    final s = await _patch('/payroll/$id/reject', body, PayRun.fromJson);
    final i = _payRuns.indexWhere((r) => r.id == s.id);
    if (i >= 0) {
      _payRuns[i] = s;
    } else {
      _payRuns.add(s);
    }
    return s;
  }

  @override
  Future<PayRun> cancelPayRun(String id, {String? reason}) async {
    final body = reason != null
        ? <String, dynamic>{'reason': reason}
        : <String, dynamic>{};
    final s = await _patch('/payroll/$id/cancel', body, PayRun.fromJson);
    final i = _payRuns.indexWhere((r) => r.id == s.id);
    if (i >= 0) {
      _payRuns[i] = s;
    } else {
      _payRuns.add(s);
    }
    return s;
  }

  @override
  Future<PayRun> recalculatePayRun(String id) async {
    final s = await _patch('/payroll/$id/recalculate', {}, PayRun.fromJson);
    final i = _payRuns.indexWhere((r) => r.id == s.id);
    if (i >= 0) {
      _payRuns[i] = s;
    } else {
      _payRuns.add(s);
    }
    return s;
  }

  // ── Payslips ─────────────────────────────────────────────────────────────────
  @override
  List<Payslip> getPayslips({String? employeeId, String? payRunId}) {
    var list = _payslips.toList();
    if (employeeId != null) {
      list = list.where((p) => p.employeeId == employeeId).toList();
    }
    if (payRunId != null) {
      list = list.where((p) => p.payRunId == payRunId).toList();
    }
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
  Future<DeductionRule> addDeductionRule(DeductionRule rule) async {
    final s = await _post(
      '/payroll/deductions',
      rule.toJson(),
      DeductionRule.fromJson,
    );
    _deductions.add(s);
    return s;
  }

  @override
  Future<DeductionRule> updateDeductionRule(DeductionRule rule) async {
    final s = await _put(
      '/payroll/deductions/${rule.id}',
      rule.toJson(),
      DeductionRule.fromJson,
    );
    final i = _deductions.indexWhere((d) => d.id == s.id);
    if (i >= 0) {
      _deductions[i] = s;
    } else {
      _deductions.add(s);
    }
    return s;
  }

  // ── Garnishee orders ─────────────────────────────────────────────────────────
  @override
  List<GarnisheeOrder> getGarnisheeOrders({String? employeeId}) {
    if (employeeId == null) return List.unmodifiable(_garnishees);
    return _garnishees.where((g) => g.employeeId == employeeId).toList();
  }

  @override
  @override
  Future<GarnisheeOrder> addGarnisheeOrder(GarnisheeOrder order) async {
    final s = await _post(
      '/payroll/garnishee-orders',
      order.toJson(),
      GarnisheeOrder.fromJson,
    );
    _garnishees.add(s);
    return s;
  }

  @override
  Future<GarnisheeOrder> updateGarnisheeOrder(GarnisheeOrder order) async {
    final s = await _put(
      '/payroll/garnishee-orders/${order.id}',
      order.toJson(),
      GarnisheeOrder.fromJson,
    );
    final i = _garnishees.indexWhere((g) => g.id == s.id);
    if (i >= 0) {
      _garnishees[i] = s;
    } else {
      _garnishees.add(s);
    }
    return s;
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
    if (employeeId != null) {
      list = list.where((r) => r.employeeId == employeeId).toList();
    }
    if (status != null) list = list.where((r) => r.status == status).toList();
    return list;
  }

  @override
  Future<LeaveRequest> addLeaveRequest(LeaveRequest request) async {
    final s = await _post('/leave', {
      'employee_id': request.employeeId,
      'leave_type_id': request.leaveTypeId,
      'start_date': request.startDate.toIso8601String().split('T').first,
      'end_date': request.endDate.toIso8601String().split('T').first,
      'days': request.daysRequested,
      if (request.reason.isNotEmpty) 'reason': request.reason,
    }, LeaveRequest.fromJson);
    _leaveRequests.add(s);
    return s;
  }

  @override
  Future<LeaveRequest> approveLeaveRequest(String id, String approverId) async {
    // Backend uses req.user.id — approverId is ignored
    final s = await _patch('/leave/$id/approve', {}, LeaveRequest.fromJson);
    final i = _leaveRequests.indexWhere((r) => r.id == s.id);
    if (i >= 0) {
      _leaveRequests[i] = s;
    } else {
      _leaveRequests.add(s);
    }
    return s;
  }

  @override
  Future<LeaveRequest> rejectLeaveRequest(
    String id,
    String approverId,
    String reason,
  ) async {
    final s = await _patch('/leave/$id/reject', {
      'reason': reason,
    }, LeaveRequest.fromJson);
    final i = _leaveRequests.indexWhere((r) => r.id == s.id);
    if (i >= 0) {
      _leaveRequests[i] = s;
    } else {
      _leaveRequests.add(s);
    }
    return s;
  }

  @override
  Future<LeaveRequest> cancelLeaveRequest(String id) async {
    // Backend uses DELETE /leave/:id — no cancel endpoint
    final idx = _leaveRequests.indexWhere((r) => r.id == id);
    final existing = idx >= 0 ? _leaveRequests[idx] : null;
    await _del('/leave/$id');
    _leaveRequests.removeWhere((r) => r.id == id);
    return existing?.copyWith(status: LeaveStatus.cancelled) ??
        (throw StateError('LeaveRequest $id not found in cache'));
  }

  // ── Payment transactions ─────────────────────────────────────────────────────
  @override
  List<PaymentTransaction> getTransactions({
    String? payRunId,
    String? employeeId,
  }) {
    var list = _transactions.toList();
    if (payRunId != null) {
      list = list.where((t) => t.payRunId == payRunId).toList();
    }
    if (employeeId != null) {
      list = list.where((t) => t.employeeId == employeeId).toList();
    }
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

  /// Re-fetches compliance alerts from the API (used by the compliance screen
  /// to get the full set including resolved, without waiting for preload).
  Future<void> refreshComplianceAlerts({
    bool includeResolved = false,
  }) => _fetchList(
    '/payroll/compliance-alerts?limit=200${includeResolved ? '&includeResolved=true' : ''}',
    _alerts,
    ComplianceAlert.fromJson,
  );

  @override
  Future<ComplianceAlert> resolveAlert(
    String id,
    String resolvedByUserId,
    String resolution,
  ) async {
    final s = await _patch('/payroll/compliance-alerts/$id/resolve', {
      'resolvedByUserId': resolvedByUserId,
      'resolution': resolution,
    }, ComplianceAlert.fromJson);
    final i = _alerts.indexWhere((a) => a.id == s.id);
    if (i >= 0) {
      _alerts[i] = s;
    } else {
      _alerts.add(s);
    }
    return s;
  }

  // ── Audit log ────────────────────────────────────────────────────────────────
  @override
  List<AuditLogEntry> getAuditLog({
    String? entityType,
    String? entityId,
    int limit = 100,
  }) {
    var list = _auditLog.toList();
    if (entityType != null) {
      list = list.where((a) => a.entityType == entityType).toList();
    }
    if (entityId != null) {
      list = list.where((a) => a.entityId == entityId).toList();
    }
    return list.take(limit).toList();
  }

  // ── Incidents ────────────────────────────────────────────────────────────────
  @override
  List<IncidentRecord> getIncidents({String? employeeId}) {
    if (employeeId == null) return List.unmodifiable(_incidents);
    return _incidents.where((i) => i.employeeId == employeeId).toList();
  }

  @override
  Future<IncidentRecord> addIncident(IncidentRecord incident) async {
    final s = await _post(
      '/payroll/incidents',
      incident.toJson(),
      IncidentRecord.fromJson,
    );
    _incidents.add(s);
    return s;
  }

  @override
  Future<IncidentRecord> updateIncident(IncidentRecord incident) async {
    final s = await _put(
      '/payroll/incidents/${incident.id}',
      incident.toJson(),
      IncidentRecord.fromJson,
    );
    final i = _incidents.indexWhere((r) => r.id == s.id);
    if (i >= 0) {
      _incidents[i] = s;
    } else {
      _incidents.add(s);
    }
    return s;
  }

  // ── Communications ───────────────────────────────────────────────────────────
  @override
  List<CommunicationLog> getCommunicationLogs() =>
      List.unmodifiable(_communications);
  @override
  Future<CommunicationLog> sendCommunication({
    required CommunicationChannel channel,
    required String templateCode,
    required String subject,
    required String body,
    required List<String> recipientEmployeeIds,
    required String sentByUserId,
  }) async {
    final s = await _post('/payroll/communications', {
      'channel': channel.name,
      'templateCode': templateCode,
      'subject': subject,
      'body': body,
      'recipientEmployeeIds': recipientEmployeeIds,
      'sentByUserId': sentByUserId,
    }, CommunicationLog.fromJson);
    _communications.add(s);
    return s;
  }

  // ── Soft-deletes / Terminations ──────────────────────────────────────────────
  @override
  Future<PayrollEmployee> terminateEmployee(
    String id,
    DateTime terminationDate,
    String reason,
  ) async {
    final r = await _dio.put<Map<String, dynamic>>(
      '/employees/$id',
      data: {
        'employment_status': 'terminated',
        'end_date': terminationDate.toIso8601String().split('T').first,
        'separation_reason': reason,
      },
    );
    final d = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    final s = PayrollEmployee.fromJson(d);
    final i = _employees.indexWhere((e) => e.id == s.id);
    if (i >= 0) {
      _employees[i] = s;
    } else {
      _employees.add(s);
    }
    return s;
  }

  @override
  Future<EmploymentContract> voidContract(String id, String reason) async {
    final s = await _patch('/payroll/contracts/$id/void', {
      'reason': reason,
    }, EmploymentContract.fromJson);
    final i = _contracts.indexWhere((c) => c.id == s.id);
    if (i >= 0) {
      _contracts[i] = s;
    } else {
      _contracts.add(s);
    }
    return s;
  }

  @override
  Future<bool> deleteShift(String id) async {
    await _del('/attendance/shifts/$id');
    _shifts.removeWhere((s) => s.id == id);
    return true;
  }

  @override
  Future<bool> deleteTaskAssignment(String id) async {
    await _del('/payroll/task-assignments/$id');
    _tasks.removeWhere((t) => t.id == id);
    return true;
  }

  @override
  Future<DeductionRule> deactivateDeductionRule(String id) async {
    final s = await _patch(
      '/payroll/deductions/$id/deactivate',
      {},
      DeductionRule.fromJson,
    );
    final i = _deductions.indexWhere((d) => d.id == s.id);
    if (i >= 0) {
      _deductions[i] = s;
    } else {
      _deductions.add(s);
    }
    return s;
  }

  @override
  Future<bool> deletePieceworkLog(String id, String correctionReason) async {
    await _del(
      '/payroll/piecework/$id?reason=${Uri.encodeComponent(correctionReason)}',
    );
    _piecework.removeWhere((p) => p.id == id);
    return true;
  }

  @override
  Future<bool> deleteLeaveRequest(String id) async {
    await _del('/leave/$id');
    _leaveRequests.removeWhere((r) => r.id == id);
    return true;
  }

  @override
  Future<IncidentRecord> deactivateIncident(String id) async {
    final s = await _patch(
      '/payroll/incidents/$id/deactivate',
      {},
      IncidentRecord.fromJson,
    );
    final i = _incidents.indexWhere((r) => r.id == s.id);
    if (i >= 0) {
      _incidents[i] = s;
    } else {
      _incidents.add(s);
    }
    return s;
  }

  @override
  Future<PayGroup> deactivatePayGroup(String id) async {
    // Backend has no /deactivate — uses DELETE instead.
    // We remove from backend and mark inactive in local cache.
    await _del('/payroll-groups/$id');
    final idx = _payGroups.indexWhere((g) => g.id == id);
    if (idx >= 0) {
      final deactivated = _payGroups[idx].copyWith(isActive: false);
      _payGroups[idx] = deactivated;
      return deactivated;
    }
    throw StateError('PayGroup $id not found in cache');
  }

  // ── Employer configuration ──────────────────────────────────────────────────
  @override
  EmployerConfig getEmployerConfig() =>
      _employerConfig ?? EmployerConfig.defaultConfig;
  @override
  Future<EmployerConfig> updateEmployerConfig(EmployerConfig config) async {
    final s = await _put(
      '/payroll/employer-config',
      config.toJson(),
      EmployerConfig.fromJson,
    );
    _employerConfig = s;
    return s;
  }

  // ── Worker disputes ────────────────────────────────────────────────────────
  @override
  List<WorkerDispute> getDisputes({String? employeeId}) {
    if (employeeId == null) return List.unmodifiable(_disputes);
    return _disputes.where((d) => d.employeeId == employeeId).toList();
  }

  @override
  Future<WorkerDispute> fileDispute(WorkerDispute dispute) async {
    final s = await _post(
      '/payroll/worker-disputes',
      dispute.toJson(),
      WorkerDispute.fromJson,
    );
    _disputes.add(s);
    return s;
  }

  @override
  Future<WorkerDispute> updateDispute(WorkerDispute dispute) async {
    final s = await _put(
      '/payroll/worker-disputes/${dispute.id}',
      dispute.toJson(),
      WorkerDispute.fromJson,
    );
    final i = _disputes.indexWhere((d) => d.id == s.id);
    if (i >= 0) {
      _disputes[i] = s;
    } else {
      _disputes.add(s);
    }
    return s;
  }

  @override
  Future<WorkerDispute> resolveDispute(
    String id,
    String resolvedBy,
    String resolutionNote,
  ) async {
    final s = await _patch('/payroll/worker-disputes/$id/resolve', {
      'resolvedBy': resolvedBy,
      'resolutionNote': resolutionNote,
    }, WorkerDispute.fromJson);
    final i = _disputes.indexWhere((d) => d.id == s.id);
    if (i >= 0) {
      _disputes[i] = s;
    } else {
      _disputes.add(s);
    }
    return s;
  }

  @override
  Future<WorkerDispute> dismissDispute(String id, String resolvedBy) async {
    final s = await _patch('/payroll/worker-disputes/$id/dismiss', {
      'resolvedBy': resolvedBy,
    }, WorkerDispute.fromJson);
    final i = _disputes.indexWhere((d) => d.id == s.id);
    if (i >= 0) {
      _disputes[i] = s;
    } else {
      _disputes.add(s);
    }
    return s;
  }

  // ── Benefit contributions ──────────────────────────────────────────────────
  @override
  List<BenefitContribution> getBenefitContributions({String? employeeId}) {
    if (employeeId != null) {
      return _benefitContributions
          .where((b) => b.employeeId == employeeId)
          .toList();
    }
    return List.unmodifiable(_benefitContributions);
  }

  @override
  Future<BenefitContribution> addBenefitContribution(
    BenefitContribution contribution,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/benefits/enrolments',
      data: contribution.toJson(),
    );
    final d =
        (response.data!['data'] as Map<String, dynamic>?) ?? response.data!;
    final created = BenefitContribution.fromJson(d);
    _benefitContributions.add(created);
    return created;
  }

  @override
  Future<BenefitContribution> updateBenefitContribution(
    BenefitContribution contribution,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/benefits/enrolments/${contribution.id}',
      data: contribution.toJson(),
    );
    final d =
        (response.data!['data'] as Map<String, dynamic>?) ?? response.data!;
    final updated = BenefitContribution.fromJson(d);
    final i = _benefitContributions.indexWhere((b) => b.id == updated.id);
    if (i >= 0) {
      _benefitContributions[i] = updated;
    } else {
      _benefitContributions.add(updated);
    }
    return updated;
  }

  @override
  Future<void> deleteBenefitContribution(String id) async {
    await _dio.delete<void>('/benefits/enrolments/$id');
    _benefitContributions.removeWhere((b) => b.id == id);
  }
}
