import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/payroll/data/payroll_data_source.dart';
import 'package:mobile_app/features/payroll/data/payroll_remote_data_source.dart';
import 'package:mobile_app/features/payroll/data/payroll_repository.dart';
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

// ─── Dependency Injection ────────────────────────────────────────────────────

class _LoadState {
  const _LoadState({required this.source, required this.ready, this.error});
  final PayrollDataSource source;
  final bool ready;
  final String? error;
}

class _PayrollLoaderNotifier extends Notifier<_LoadState> {
  @override
  _LoadState build() {
    final source = PayrollRemoteDataSource(ref.read(apiDioProvider));
    // Phase 1: load only hub-critical data → unblock the UI as soon as possible.
    source
        .preloadCritical()
        .then((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            state = _LoadState(source: source, ready: true);
            // Directly refresh all downstream data providers now that the cache
            // is populated.  addPostFrameCallback fires in postFrameCallbacks
            // phase (after buildScope), so setState on ProviderScope is safe.
            refreshPayrollProviders(ref);
            // Phase 2: load secondary data silently in the background.
            source.preloadBackground().catchError((_) {
              /* non-fatal */
            });
          });
        })
        .catchError((Object err) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            state = _LoadState(
              source: source,
              ready: true,
              error: err.toString(),
            );
            refreshPayrollProviders(ref);
            source.preloadBackground().catchError((_) {
              /* non-fatal */
            });
          });
        });
    return _LoadState(source: source, ready: false);
  }
}

final _payrollLoaderProvider =
    NotifierProvider<_PayrollLoaderNotifier, _LoadState>(
      _PayrollLoaderNotifier.new,
    );

final payrollDataSourceProvider = Provider<PayrollDataSource>(
  (ref) => ref.watch(_payrollLoaderProvider.select((s) => s.source)),
);

// ─── Stable repository singleton ─────────────────────────────────────────────
// Internal keepAlive provider — never disposed, never invalidated directly.
// payrollRepositoryProvider reads this to return the SAME PayrollRepository
// instance on every rebuild.  When prev == next (reference equality), Riverpod
// skips _notifyListeners(), so no watch-listener cascade fires and no
// invalidateSelf() → scheduleProviderRefresh() → setState(ProviderScope) call
// can happen during a Flutter build frame.
final _payrollRepositoryInstanceProvider = Provider<PayrollRepository>((ref) {
  ref.keepAlive();
  return PayrollRepository(ref.read(payrollDataSourceProvider));
});

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  // Always returns the same PayrollRepository instance (reference equality).
  // Because prev == next, Riverpod skips _notifyListeners on every rebuild,
  // preventing the 20+ watch-listener cascade that triggers
  // "setState() called during build" via ConsumerStatefulWidget ticker-resume.
  //
  // IMPORTANT: Do NOT call refreshPayrollProviders(ref) from here.
  // This provider's `ref` is a dependency of every downstream data provider
  // (employeesProvider, payRunsProvider, …).  Calling ref.invalidate on any
  // of those from THIS ref causes CircularDependencyError in debug mode.
  // Action/sync providers call refreshPayrollProviders(ref) using their own
  // Notifier ref, which is NOT in the downstream dependency chain.
  return ref.read(_payrollRepositoryInstanceProvider);
});

/// `true` once the initial API preload has finished (success or partial).
/// Use this to gate loading spinners: show shimmer while false, content when true.
final payrollReadyProvider = Provider<bool>((ref) {
  return ref.watch(_payrollLoaderProvider).ready;
});

/// Non-null when preload completed with a fatal error (e.g. network down).
final payrollLoadErrorProvider = Provider<String?>((ref) {
  return ref.watch(_payrollLoaderProvider).error;
});

// ─── Employees ────────────────────────────────────────────────────────────────

final employeesProvider = Provider<List<PayrollEmployee>>((ref) {
  return ref.watch(payrollRepositoryProvider).getEmployees();
});

final employeeProvider = Provider.family<PayrollEmployee?, String>((ref, id) {
  return ref.watch(payrollRepositoryProvider).getEmployee(id);
});

final activeEmployeesProvider = Provider<List<PayrollEmployee>>((ref) {
  return ref.watch(employeesProvider).where((e) => e.isActive).toList();
});

// ─── Contracts ────────────────────────────────────────────────────────────────

final contractsProvider = Provider.family<List<EmploymentContract>, String?>((
  ref,
  employeeId,
) {
  return ref
      .watch(payrollRepositoryProvider)
      .getContracts(employeeId: employeeId);
});

// ─── Pay groups ───────────────────────────────────────────────────────────────

final payGroupsProvider = Provider<List<PayGroup>>((ref) {
  return ref.watch(payrollRepositoryProvider).getPayGroups();
});

final activePayGroupsProvider = Provider<List<PayGroup>>((ref) {
  return ref.watch(payGroupsProvider).where((g) => g.isActive).toList();
});

/// Returns the employee IDs that are members of [groupId], then filters
/// the in-memory employee list.  Rebuilds automatically when the repository
/// is invalidated (e.g. after calculatePayRun or addPayGroup).
final employeesForGroupProvider =
    Provider.family<List<PayrollEmployee>, String>((ref, groupId) {
      final repo = ref.watch(payrollRepositoryProvider);
      final memberIds = repo.getGroupMemberIds(groupId).toSet();
      if (memberIds.isEmpty) return const [];
      return repo
          .getEmployees()
          .where((e) => memberIds.contains(e.id))
          .toList();
    });

// ─── Pay structures ───────────────────────────────────────────────────────────

final payStructuresProvider = Provider<List<PayStructure>>((ref) {
  return ref.watch(payrollRepositoryProvider).getPayStructures();
});

// ─── Shifts ───────────────────────────────────────────────────────────────────

class ShiftFilter {
  const ShiftFilter({this.weekStart, this.employeeId});
  final DateTime? weekStart;
  final String? employeeId;
}

final shiftsProvider = Provider.family<List<Shift>, ShiftFilter>((ref, filter) {
  return ref
      .watch(payrollRepositoryProvider)
      .getShifts(weekStart: filter.weekStart, employeeId: filter.employeeId);
});

// ─── Task assignments ─────────────────────────────────────────────────────────

class TaskFilter {
  const TaskFilter({this.employeeId, this.date});
  final String? employeeId;
  final DateTime? date;
}

final taskAssignmentsProvider =
    Provider.family<List<TaskAssignment>, TaskFilter>((ref, filter) {
      return ref
          .watch(payrollRepositoryProvider)
          .getTaskAssignments(employeeId: filter.employeeId, date: filter.date);
    });

// ─── Attendance ───────────────────────────────────────────────────────────────

class AttendanceFilter {
  const AttendanceFilter({
    this.employeeId,
    this.date,
    this.fromDate,
    this.toDate,
  });
  final String? employeeId;
  final DateTime? date;
  final DateTime? fromDate;
  final DateTime? toDate;
}

final attendanceProvider =
    Provider.family<List<AttendanceRecord>, AttendanceFilter>((ref, filter) {
      return ref
          .watch(payrollRepositoryProvider)
          .getAttendanceRecords(
            employeeId: filter.employeeId,
            date: filter.date,
            fromDate: filter.fromDate,
            toDate: filter.toDate,
          );
    });

// ─── Piecework ────────────────────────────────────────────────────────────────

class PieceworkFilter {
  const PieceworkFilter({this.employeeId, this.date, this.shiftId});
  final String? employeeId;
  final DateTime? date;
  final String? shiftId;
}

final pieceworkLogsProvider =
    Provider.family<List<PieceworkLog>, PieceworkFilter>((ref, filter) {
      return ref
          .watch(payrollRepositoryProvider)
          .getPieceworkLogs(
            employeeId: filter.employeeId,
            date: filter.date,
            shiftId: filter.shiftId,
          );
    });

// ─── Pay runs ─────────────────────────────────────────────────────────────────

final payRunsProvider = Provider.family<List<PayRun>, String?>((
  ref,
  payGroupId,
) {
  return ref
      .watch(payrollRepositoryProvider)
      .getPayRuns(payGroupId: payGroupId);
});

final allPayRunsProvider = Provider<List<PayRun>>((ref) {
  return ref.watch(payRunsProvider(null));
});

final payRunProvider = Provider.family<PayRun?, String>((ref, id) {
  return ref.watch(payrollRepositoryProvider).getPayRun(id);
});

// ─── Payslips ─────────────────────────────────────────────────────────────────

class PayslipFilter {
  const PayslipFilter({this.employeeId, this.payRunId});
  final String? employeeId;
  final String? payRunId;
}

final payslipsProvider = Provider.family<List<Payslip>, PayslipFilter>((
  ref,
  filter,
) {
  return ref
      .watch(payrollRepositoryProvider)
      .getPayslips(employeeId: filter.employeeId, payRunId: filter.payRunId);
});

// ─── Garnishee orders ────────────────────────────────────────────────────────

final garnisheeOrdersProvider = Provider.family<List<GarnisheeOrder>, String?>((
  ref,
  employeeId,
) {
  return ref
      .watch(payrollRepositoryProvider)
      .getGarnisheeOrders(employeeId: employeeId);
});

final allGarnisheeOrdersProvider = Provider<List<GarnisheeOrder>>((ref) {
  return ref.watch(garnisheeOrdersProvider(null));
});

final garnisheeByIdProvider = Provider.family<GarnisheeOrder?, String>((
  ref,
  id,
) {
  return ref
      .watch(allGarnisheeOrdersProvider)
      .where((o) => o.id == id)
      .firstOrNull;
});

// ─── Deduction rules ──────────────────────────────────────────────────────────

final deductionRulesProvider = Provider.family<List<DeductionRule>, String?>((
  ref,
  employeeId,
) {
  return ref
      .watch(payrollRepositoryProvider)
      .getDeductionRules(employeeId: employeeId);
});

// ─── Leave ────────────────────────────────────────────────────────────────────

final leaveTypesProvider = Provider<List<LeaveType>>((ref) {
  return ref.watch(payrollRepositoryProvider).getLeaveTypes();
});

final leaveBalancesProvider = Provider.family<List<LeaveBalance>, String?>((
  ref,
  employeeId,
) {
  return ref
      .watch(payrollRepositoryProvider)
      .getLeaveBalances(employeeId: employeeId);
});

class LeaveRequestFilter {
  const LeaveRequestFilter({this.employeeId, this.status});
  final String? employeeId;
  final LeaveStatus? status;
}

final leaveRequestsProvider =
    Provider.family<List<LeaveRequest>, LeaveRequestFilter>((ref, filter) {
      return ref
          .watch(payrollRepositoryProvider)
          .getLeaveRequests(
            employeeId: filter.employeeId,
            status: filter.status,
          );
    });

final pendingLeaveRequestsProvider = Provider<List<LeaveRequest>>((ref) {
  return ref.watch(
    leaveRequestsProvider(
      const LeaveRequestFilter(status: LeaveStatus.pending),
    ),
  );
});

// ─── Compliance alerts ────────────────────────────────────────────────────────

final complianceAlertsProvider = Provider<List<ComplianceAlert>>((ref) {
  return ref.watch(payrollRepositoryProvider).getComplianceAlerts();
});

final openComplianceAlertsCountProvider = Provider<int>((ref) {
  return ref.watch(complianceAlertsProvider).where((a) => a.isOpen).length;
});

final criticalAlertsProvider = Provider<List<ComplianceAlert>>((ref) {
  return ref
      .watch(complianceAlertsProvider)
      .where((a) => a.severity == ComplianceSeverity.critical && a.isOpen)
      .toList();
});

// ─── Incidents ────────────────────────────────────────────────────────────────

final incidentsProvider = Provider.family<List<IncidentRecord>, String?>((
  ref,
  employeeId,
) {
  return ref
      .watch(payrollRepositoryProvider)
      .getIncidents(employeeId: employeeId);
});

// ─── Summary stats ────────────────────────────────────────────────────────────

class PayrollDashboardStats {
  const PayrollDashboardStats({
    required this.totalActiveEmployees,
    required this.permanentCount,
    required this.seasonalCount,
    required this.casualCount,
    required this.pendingLeaveRequests,
    required this.openAlerts,
    required this.criticalAlerts,
    required this.latestPayRun,
  });

  final int totalActiveEmployees;
  final int permanentCount;
  final int seasonalCount;
  final int casualCount;
  final int pendingLeaveRequests;
  final int openAlerts;
  final int criticalAlerts;
  final PayRun? latestPayRun;
}

final payrollDashboardStatsProvider = Provider<PayrollDashboardStats>((ref) {
  final employees = ref.watch(activeEmployeesProvider);
  final pendingLeave = ref.watch(pendingLeaveRequestsProvider);
  final alerts = ref.watch(complianceAlertsProvider);
  final payRuns = List.of(ref.watch(allPayRunsProvider))
    ..sort((a, b) => b.payDate.compareTo(a.payDate));

  return PayrollDashboardStats(
    totalActiveEmployees: employees.length,
    permanentCount: employees
        .where((e) => e.engagementType == EngagementType.permanent)
        .length,
    seasonalCount: employees
        .where((e) => e.engagementType == EngagementType.seasonal)
        .length,
    casualCount: employees
        .where((e) => e.engagementType == EngagementType.casual)
        .length,
    pendingLeaveRequests: pendingLeave.length,
    openAlerts: alerts.where((a) => a.isOpen).length,
    criticalAlerts: alerts
        .where((a) => a.severity == ComplianceSeverity.critical && a.isOpen)
        .length,
    latestPayRun: payRuns.isNotEmpty ? payRuns.first : null,
  );
});

// ─── Audit log ────────────────────────────────────────────────────────────────

class AuditLogFilter {
  const AuditLogFilter({this.entityType, this.entityId, this.limit = 200});
  final String? entityType;
  final String? entityId;
  final int limit;
}

final auditLogProvider = Provider.family<List<AuditLogEntry>, AuditLogFilter>((
  ref,
  filter,
) {
  return ref
      .watch(payrollRepositoryProvider)
      .getAuditLog(
        entityType: filter.entityType,
        entityId: filter.entityId,
        limit: filter.limit,
      );
});

final allAuditLogProvider = Provider<List<AuditLogEntry>>((ref) {
  return ref.watch(auditLogProvider(const AuditLogFilter()));
});

// ─── Payment transactions ─────────────────────────────────────────────────────

class TransactionFilter {
  const TransactionFilter({this.payRunId, this.employeeId});
  final String? payRunId;
  final String? employeeId;
}

final transactionsProvider =
    Provider.family<List<PaymentTransaction>, TransactionFilter>((ref, filter) {
      return ref
          .watch(payrollRepositoryProvider)
          .getTransactions(
            payRunId: filter.payRunId,
            employeeId: filter.employeeId,
          );
    });

final allTransactionsProvider = Provider<List<PaymentTransaction>>((ref) {
  return ref.watch(transactionsProvider(const TransactionFilter()));
});

// ─── Communications ───────────────────────────────────────────────────────────

final communicationsProvider = Provider<List<CommunicationLog>>((ref) {
  return ref.watch(payrollRepositoryProvider).getCommunicationLogs();
});

// ─── Incidents (additional filter provider) ───────────────────────────────────

final allIncidentsProvider = Provider<List<IncidentRecord>>((ref) {
  return ref.watch(incidentsProvider(null));
});

final openIncidentsProvider = Provider<List<IncidentRecord>>((ref) {
  return ref.watch(allIncidentsProvider).where((i) => i.isOpen).toList();
});

final incidentByIdProvider = Provider.family<IncidentRecord?, String>((
  ref,
  id,
) {
  return ref.watch(allIncidentsProvider).where((i) => i.id == id).firstOrNull;
});

// ─── All compliance alerts (including resolved) ───────────────────────────────

final allComplianceAlertsProvider = Provider<List<ComplianceAlert>>((ref) {
  // no extra watch needed — inherits from complianceAlertsProvider
  return ref
      .watch(payrollRepositoryProvider)
      .getComplianceAlerts(includeResolved: true);
});

// ─── Employer configuration ───────────────────────────────────────────────────
// Reads the employer config from the remote data source (fetched during preload).
final employerConfigProvider = Provider<EmployerConfig>((ref) {
  return ref.watch(payrollRepositoryProvider).getEmployerConfig();
});
// ─── Benefit contributions ────────────────────────────────────────────────
final benefitContributionsProvider = Provider<List<BenefitContribution>>((ref) {
  return ref.watch(payrollRepositoryProvider).getBenefitContributions();
});

final benefitContributionsByEmployeeProvider =
    Provider.family<List<BenefitContribution>, String>((ref, employeeId) {
      return ref
          .watch(payrollRepositoryProvider)
          .getBenefitContributions(employeeId: employeeId);
    });

// ─── Refresh helper ───────────────────────────────────────────────────────────
/// Invalidates every payroll data provider so widgets re-read the in-memory
/// cache.  Safe to call from addPostFrameCallback, Future.microtask, and
/// user-action Notifier methods — i.e. any context that is NOT a Flutter build
/// phase (SchedulerPhase.persistentCallbacks).
///
/// After the first ref.invalidate call ProviderScope is already dirty
/// (_dirty = true), so all subsequent calls inside this function are no-ops
/// (scheduleRefresh skips the setState call).  The cost is therefore a single
/// extra Flutter frame, not N frames.
void refreshPayrollProviders(Ref ref) {
  // ── leaf providers (direct repo readers) ──────────────────────────────────
  ref.invalidate(employeesProvider);
  ref.invalidate(employeeProvider);
  ref.invalidate(contractsProvider);
  ref.invalidate(payGroupsProvider);
  ref.invalidate(employeesForGroupProvider);
  ref.invalidate(payStructuresProvider);
  ref.invalidate(shiftsProvider);
  ref.invalidate(taskAssignmentsProvider);
  ref.invalidate(attendanceProvider);
  ref.invalidate(pieceworkLogsProvider);
  ref.invalidate(payRunsProvider);
  ref.invalidate(payRunProvider);
  ref.invalidate(payslipsProvider);
  ref.invalidate(garnisheeOrdersProvider);
  ref.invalidate(deductionRulesProvider);
  ref.invalidate(leaveTypesProvider);
  ref.invalidate(leaveBalancesProvider);
  ref.invalidate(leaveRequestsProvider);
  ref.invalidate(complianceAlertsProvider);
  ref.invalidate(incidentsProvider);
  ref.invalidate(auditLogProvider);
  ref.invalidate(transactionsProvider);
  ref.invalidate(communicationsProvider);
  ref.invalidate(allComplianceAlertsProvider);
  ref.invalidate(employerConfigProvider);
  ref.invalidate(benefitContributionsProvider);
  ref.invalidate(benefitContributionsByEmployeeProvider);
  // ── composite / derived providers ─────────────────────────────────────────
  ref.invalidate(activeEmployeesProvider);
  ref.invalidate(activePayGroupsProvider);
  ref.invalidate(allGarnisheeOrdersProvider);
  ref.invalidate(garnisheeByIdProvider);
  ref.invalidate(allPayRunsProvider);
  ref.invalidate(pendingLeaveRequestsProvider);
  ref.invalidate(openComplianceAlertsCountProvider);
  ref.invalidate(criticalAlertsProvider);
  ref.invalidate(payrollDashboardStatsProvider);
  ref.invalidate(allAuditLogProvider);
  ref.invalidate(allTransactionsProvider);
  ref.invalidate(allIncidentsProvider);
  ref.invalidate(openIncidentsProvider);
  ref.invalidate(incidentByIdProvider);
}
