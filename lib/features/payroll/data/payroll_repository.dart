import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/payroll_data_source.dart';
import '../data/payroll_mock_data_source.dart';
import '../data/payroll_remote_data_source.dart';
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

class PayrollRepository {
  PayrollRepository(this._source);

  final PayrollDataSource _source;

  // ── Employees ──────────────────────────────────────────────────────────────
  List<PayrollEmployee> getEmployees() => _source.getEmployees();
  PayrollEmployee? getEmployee(String id) => _source.getEmployee(id);
  PayrollEmployee addEmployee(PayrollEmployee e) => _source.addEmployee(e);
  PayrollEmployee updateEmployee(PayrollEmployee e) =>
      _source.updateEmployee(e);

  // ── Contracts ──────────────────────────────────────────────────────────────
  List<EmploymentContract> getContracts({String? employeeId}) =>
      _source.getContracts(employeeId: employeeId);
  EmploymentContract? getContract(String id) => _source.getContract(id);
  EmploymentContract addContract(EmploymentContract c) =>
      _source.addContract(c);
  EmploymentContract updateContract(EmploymentContract c) =>
      _source.updateContract(c);

  // ── Pay groups ─────────────────────────────────────────────────────────────
  List<PayGroup> getPayGroups() => _source.getPayGroups();
  PayGroup addPayGroup(PayGroup g) => _source.addPayGroup(g);
  PayGroup updatePayGroup(PayGroup g) => _source.updatePayGroup(g);

  // ── Pay structures ─────────────────────────────────────────────────────────
  List<PayStructure> getPayStructures() => _source.getPayStructures();
  PayStructure addPayStructure(PayStructure s) => _source.addPayStructure(s);
  PayStructure updatePayStructure(PayStructure s) =>
      _source.updatePayStructure(s);

  // ── Shifts ────────────────────────────────────────────────────────────────
  List<Shift> getShifts({DateTime? weekStart, String? employeeId}) =>
      _source.getShifts(weekStart: weekStart, employeeId: employeeId);
  Shift addShift(Shift s) => _source.addShift(s);
  Shift updateShift(Shift s) => _source.updateShift(s);

  // ── Tasks ─────────────────────────────────────────────────────────────────
  List<TaskAssignment> getTaskAssignments({
    String? employeeId,
    DateTime? date,
  }) => _source.getTaskAssignments(employeeId: employeeId, date: date);
  TaskAssignment addTaskAssignment(TaskAssignment t) =>
      _source.addTaskAssignment(t);
  TaskAssignment updateTaskAssignment(TaskAssignment t) =>
      _source.updateTaskAssignment(t);

  // ── Attendance ────────────────────────────────────────────────────────────
  List<AttendanceRecord> getAttendanceRecords({
    String? employeeId,
    DateTime? date,
    DateTime? fromDate,
    DateTime? toDate,
  }) => _source.getAttendanceRecords(
    employeeId: employeeId,
    date: date,
    fromDate: fromDate,
    toDate: toDate,
  );
  AttendanceRecord addAttendanceRecord(AttendanceRecord r) =>
      _source.addAttendanceRecord(r);
  AttendanceRecord updateAttendanceRecord(AttendanceRecord r) =>
      _source.updateAttendanceRecord(r);

  // ── Piecework ─────────────────────────────────────────────────────────────
  List<PieceworkLog> getPieceworkLogs({
    String? employeeId,
    DateTime? date,
    String? shiftId,
  }) => _source.getPieceworkLogs(
    employeeId: employeeId,
    date: date,
    shiftId: shiftId,
  );
  PieceworkLog addPieceworkLog(PieceworkLog l) => _source.addPieceworkLog(l);

  // ── Pay runs ──────────────────────────────────────────────────────────────
  List<PayRun> getPayRuns({String? payGroupId}) =>
      _source.getPayRuns(payGroupId: payGroupId);
  PayRun? getPayRun(String id) => _source.getPayRun(id);
  PayRun calculatePayRun(
    String payGroupId,
    DateTime periodStart,
    DateTime periodEnd,
  ) => _source.calculatePayRun(payGroupId, periodStart, periodEnd);
  PayRun approvePayRun(String id, String approverUserId) =>
      _source.approvePayRun(id, approverUserId);
  PayRun disbursePayRun(String id) => _source.disbursePayRun(id);

  // ── Payslips ──────────────────────────────────────────────────────────────
  List<Payslip> getPayslips({String? employeeId, String? payRunId}) =>
      _source.getPayslips(employeeId: employeeId, payRunId: payRunId);
  Payslip? getPayslip(String id) => _source.getPayslip(id);

  // ── Garnishee orders ─────────────────────────────────────────────────────
  List<GarnisheeOrder> getGarnisheeOrders({String? employeeId}) =>
      _source.getGarnisheeOrders(employeeId: employeeId);
  GarnisheeOrder addGarnisheeOrder(GarnisheeOrder order) =>
      _source.addGarnisheeOrder(order);
  GarnisheeOrder updateGarnisheeOrder(GarnisheeOrder order) =>
      _source.updateGarnisheeOrder(order);

  // ── Deduction rules ───────────────────────────────────────────────────────
  List<DeductionRule> getDeductionRules({String? employeeId}) =>
      _source.getDeductionRules(employeeId: employeeId);
  DeductionRule addDeductionRule(DeductionRule r) =>
      _source.addDeductionRule(r);
  DeductionRule updateDeductionRule(DeductionRule r) =>
      _source.updateDeductionRule(r);

  // ── Leave ─────────────────────────────────────────────────────────────────
  List<LeaveType> getLeaveTypes() => _source.getLeaveTypes();
  List<LeaveBalance> getLeaveBalances({String? employeeId}) =>
      _source.getLeaveBalances(employeeId: employeeId);
  List<LeaveRequest> getLeaveRequests({
    String? employeeId,
    LeaveStatus? status,
  }) => _source.getLeaveRequests(employeeId: employeeId, status: status);
  LeaveRequest addLeaveRequest(LeaveRequest r) => _source.addLeaveRequest(r);
  LeaveRequest approveLeaveRequest(String id, String approverId) =>
      _source.approveLeaveRequest(id, approverId);
  LeaveRequest rejectLeaveRequest(
    String id,
    String approverId,
    String reason,
  ) => _source.rejectLeaveRequest(id, approverId, reason);
  LeaveRequest cancelLeaveRequest(String id) => _source.cancelLeaveRequest(id);

  // ── Transactions ──────────────────────────────────────────────────────────
  List<PaymentTransaction> getTransactions({
    String? payRunId,
    String? employeeId,
  }) => _source.getTransactions(payRunId: payRunId, employeeId: employeeId);

  // ── Compliance ────────────────────────────────────────────────────────────
  List<ComplianceAlert> getComplianceAlerts({bool includeResolved = false}) =>
      _source.getComplianceAlerts(includeResolved: includeResolved);
  ComplianceAlert resolveAlert(
    String id,
    String resolvedByUserId,
    String resolution,
  ) => _source.resolveAlert(id, resolvedByUserId, resolution);

  // ── Audit ─────────────────────────────────────────────────────────────────
  List<AuditLogEntry> getAuditLog({
    String? entityType,
    String? entityId,
    int limit = 100,
  }) => _source.getAuditLog(
    entityType: entityType,
    entityId: entityId,
    limit: limit,
  );

  // ── Incidents ─────────────────────────────────────────────────────────────
  List<IncidentRecord> getIncidents({String? employeeId}) =>
      _source.getIncidents(employeeId: employeeId);
  IncidentRecord addIncident(IncidentRecord i) => _source.addIncident(i);
  IncidentRecord updateIncident(IncidentRecord i) => _source.updateIncident(i);

  // ── Communications ────────────────────────────────────────────────────────
  List<CommunicationLog> getCommunicationLogs() =>
      _source.getCommunicationLogs();
  CommunicationLog sendCommunication({
    required CommunicationChannel channel,
    required String templateCode,
    required String subject,
    required String body,
    required List<String> recipientEmployeeIds,
    required String sentByUserId,
  }) => _source.sendCommunication(
    channel: channel,
    templateCode: templateCode,
    subject: subject,
    body: body,
    recipientEmployeeIds: recipientEmployeeIds,
    sentByUserId: sentByUserId,
  );

  // ── Soft-deletes / Terminations ──────────────────────────────────────────────
  PayrollEmployee terminateEmployee(
    String id,
    DateTime terminationDate,
    String reason,
  ) => _source.terminateEmployee(id, terminationDate, reason);
  EmploymentContract voidContract(String id, String reason) =>
      _source.voidContract(id, reason);
  bool deleteShift(String id) => _source.deleteShift(id);
  bool deleteTaskAssignment(String id) => _source.deleteTaskAssignment(id);
  DeductionRule deactivateDeductionRule(String id) =>
      _source.deactivateDeductionRule(id);
  bool deletePieceworkLog(String id, String correctionReason) =>
      _source.deletePieceworkLog(id, correctionReason);
  bool deleteLeaveRequest(String id) => _source.deleteLeaveRequest(id);
  IncidentRecord deactivateIncident(String id) =>
      _source.deactivateIncident(id);
  PayGroup deactivatePayGroup(String id) => _source.deactivatePayGroup(id);

  // ── Employer configuration ────────────────────────────────────────────────────
  EmployerConfig getEmployerConfig() => _source.getEmployerConfig();
  EmployerConfig updateEmployerConfig(EmployerConfig config) =>
      _source.updateEmployerConfig(config);
}

// ─── Providers ────────────────────────────────────────────────────────────────

/// Set USE_MOCK_DATA=false in your run config / CI environment to
/// use the real API backend instead of in-memory mock data.
const _useMock = bool.fromEnvironment('USE_MOCK_DATA', defaultValue: true);

final payrollDataSourceProvider = Provider<PayrollDataSource>((ref) {
  if (_useMock) return PayrollMockDataSource();
  return PayrollRemoteDataSource();
});

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  return PayrollRepository(ref.watch(payrollDataSourceProvider));
});
