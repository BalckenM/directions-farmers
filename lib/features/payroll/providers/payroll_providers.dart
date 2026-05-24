import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/payroll_data_source.dart';
import '../data/payroll_mock_data_source.dart';
import '../data/payroll_repository.dart';
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

// ─── Dependency Injection ────────────────────────────────────────────────────

final payrollDataSourceProvider = Provider<PayrollDataSource>(
  (ref) => PayrollMockDataSource(),
);

final payrollRepositoryProvider = Provider<PayrollRepository>(
  (ref) => PayrollRepository(ref.watch(payrollDataSourceProvider)),
);

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
  // complianceAlertsProvider only returns open ones; this returns all
  return ref
      .watch(payrollRepositoryProvider)
      .getComplianceAlerts(includeResolved: true);
});

// ─── Employer configuration ───────────────────────────────────────────────────
// Override this provider at app startup or via settings to customise
// employer name / registration details.
final employerConfigProvider = Provider<EmployerConfig>((ref) {
  return EmployerConfig.defaultConfig;
});
