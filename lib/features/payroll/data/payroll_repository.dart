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

class PayrollRepository {
  PayrollRepository(this._source);


  final PayrollDataSource _source;

  // -- Employees
  List<PayrollEmployee> getEmployees() => _source.getEmployees();
  PayrollEmployee? getEmployee(String id) => _source.getEmployee(id);
  Future<PayrollEmployee> addEmployee(PayrollEmployee e) => _source.addEmployee(e);
  Future<Map<String, dynamic>> bulkImportEmployees(List<PayrollEmployee> employees) =>
      _source.bulkImportEmployees(employees);
  Future<PayrollEmployee> updateEmployee(PayrollEmployee e) => _source.updateEmployee(e);
  Future<String> uploadProfileImage(String employeeId, String filePath) =>
      _source.uploadProfileImage(employeeId, filePath);
  Future<PayrollEmployee> terminateEmployee(String id, DateTime terminationDate, String reason) =>
      _source.terminateEmployee(id, terminationDate, reason);

  // -- Contracts
  List<EmploymentContract> getContracts({String? employeeId}) =>
      _source.getContracts(employeeId: employeeId);
  EmploymentContract? getContract(String id) => _source.getContract(id);
  Future<EmploymentContract> addContract(EmploymentContract c) => _source.addContract(c);
  Future<EmploymentContract> updateContract(EmploymentContract c) => _source.updateContract(c);
  Future<EmploymentContract> voidContract(String id, String reason) =>
      _source.voidContract(id, reason);

  // -- Pay groups
  List<PayGroup> getPayGroups() => _source.getPayGroups();
  Future<PayGroup> addPayGroup(PayGroup g) => _source.addPayGroup(g);
  Future<PayGroup> updatePayGroup(PayGroup g) => _source.updatePayGroup(g);
  Future<PayGroup> deactivatePayGroup(String id) => _source.deactivatePayGroup(id);

  // -- Pay structures
  List<PayStructure> getPayStructures() => _source.getPayStructures();
  Future<PayStructure> addPayStructure(PayStructure s) => _source.addPayStructure(s);
  Future<PayStructure> updatePayStructure(PayStructure s) => _source.updatePayStructure(s);

  // -- Shifts
  List<Shift> getShifts({DateTime? weekStart, String? employeeId}) =>
      _source.getShifts(weekStart: weekStart, employeeId: employeeId);
  Future<Shift> addShift(Shift s) => _source.addShift(s);
  Future<Shift> updateShift(Shift s) => _source.updateShift(s);
  Future<bool> deleteShift(String id) => _source.deleteShift(id);

  // -- Tasks
  List<TaskAssignment> getTaskAssignments({String? employeeId, DateTime? date}) =>
      _source.getTaskAssignments(employeeId: employeeId, date: date);
  Future<TaskAssignment> addTaskAssignment(TaskAssignment t) => _source.addTaskAssignment(t);
  Future<TaskAssignment> updateTaskAssignment(TaskAssignment t) => _source.updateTaskAssignment(t);
  Future<bool> deleteTaskAssignment(String id) => _source.deleteTaskAssignment(id);

  // -- Attendance
  List<AttendanceRecord> getAttendanceRecords({
    String? employeeId,
    DateTime? date,
    DateTime? fromDate,
    DateTime? toDate,
  }) => _source.getAttendanceRecords(
    employeeId: employeeId, date: date, fromDate: fromDate, toDate: toDate,
  );
  Future<AttendanceRecord> addAttendanceRecord(AttendanceRecord r) =>
      _source.addAttendanceRecord(r);
  Future<AttendanceRecord> updateAttendanceRecord(AttendanceRecord r) =>
      _source.updateAttendanceRecord(r);

  // -- Piecework
  List<PieceworkLog> getPieceworkLogs({String? employeeId, DateTime? date, String? shiftId}) =>
      _source.getPieceworkLogs(employeeId: employeeId, date: date, shiftId: shiftId);
  Future<PieceworkLog> addPieceworkLog(PieceworkLog l) => _source.addPieceworkLog(l);
  Future<bool> deletePieceworkLog(String id, String correctionReason) =>
      _source.deletePieceworkLog(id, correctionReason);

  // -- Pay runs
  List<PayRun> getPayRuns({String? payGroupId}) => _source.getPayRuns(payGroupId: payGroupId);
  PayRun? getPayRun(String id) => _source.getPayRun(id);
  Future<PayRun> calculatePayRun(String payGroupId, DateTime periodStart, DateTime periodEnd, {DateTime? payDate}) =>
      _source.calculatePayRun(payGroupId, periodStart, periodEnd, payDate: payDate);
  Future<PayRun> approvePayRun(String id, String approverUserId) =>
      _source.approvePayRun(id, approverUserId);
  Future<PayRun> disbursePayRun(String id) => _source.disbursePayRun(id);

  // -- Payslips
  List<Payslip> getPayslips({String? employeeId, String? payRunId}) =>
      _source.getPayslips(employeeId: employeeId, payRunId: payRunId);
  Payslip? getPayslip(String id) => _source.getPayslip(id);

  // -- Garnishee orders
  List<GarnisheeOrder> getGarnisheeOrders({String? employeeId}) =>
      _source.getGarnisheeOrders(employeeId: employeeId);
  Future<GarnisheeOrder> addGarnisheeOrder(GarnisheeOrder order) =>
      _source.addGarnisheeOrder(order);
  Future<GarnisheeOrder> updateGarnisheeOrder(GarnisheeOrder order) =>
      _source.updateGarnisheeOrder(order);

  // -- Deduction rules
  List<DeductionRule> getDeductionRules({String? employeeId}) =>
      _source.getDeductionRules(employeeId: employeeId);
  Future<DeductionRule> addDeductionRule(DeductionRule r) => _source.addDeductionRule(r);
  Future<DeductionRule> updateDeductionRule(DeductionRule r) => _source.updateDeductionRule(r);
  Future<DeductionRule> deactivateDeductionRule(String id) =>
      _source.deactivateDeductionRule(id);

  // -- Leave
  List<LeaveType> getLeaveTypes() => _source.getLeaveTypes();
  List<LeaveBalance> getLeaveBalances({String? employeeId}) =>
      _source.getLeaveBalances(employeeId: employeeId);
  List<LeaveRequest> getLeaveRequests({String? employeeId, LeaveStatus? status}) =>
      _source.getLeaveRequests(employeeId: employeeId, status: status);
  Future<LeaveRequest> addLeaveRequest(LeaveRequest r) => _source.addLeaveRequest(r);
  Future<LeaveRequest> approveLeaveRequest(String id, String approverId) =>
      _source.approveLeaveRequest(id, approverId);
  Future<LeaveRequest> rejectLeaveRequest(String id, String approverId, String reason) =>
      _source.rejectLeaveRequest(id, approverId, reason);
  Future<LeaveRequest> cancelLeaveRequest(String id) => _source.cancelLeaveRequest(id);
  Future<bool> deleteLeaveRequest(String id) => _source.deleteLeaveRequest(id);

  // -- Transactions
  List<PaymentTransaction> getTransactions({String? payRunId, String? employeeId}) =>
      _source.getTransactions(payRunId: payRunId, employeeId: employeeId);
  Future<void> createTransaction(Map<String, dynamic> payload) =>
      _source.createTransaction(payload);

  // -- Compliance
  List<ComplianceAlert> getComplianceAlerts({bool includeResolved = false}) =>
      _source.getComplianceAlerts(includeResolved: includeResolved);
  Future<ComplianceAlert> resolveAlert(String id, String resolvedByUserId, String resolution) =>
      _source.resolveAlert(id, resolvedByUserId, resolution);

  // -- Audit
  List<AuditLogEntry> getAuditLog({String? entityType, String? entityId, int limit = 100}) =>
      _source.getAuditLog(entityType: entityType, entityId: entityId, limit: limit);

  // -- Incidents
  List<IncidentRecord> getIncidents({String? employeeId}) =>
      _source.getIncidents(employeeId: employeeId);
  Future<IncidentRecord> addIncident(IncidentRecord i) => _source.addIncident(i);
  Future<IncidentRecord> updateIncident(IncidentRecord i) => _source.updateIncident(i);
  Future<IncidentRecord> deactivateIncident(String id) => _source.deactivateIncident(id);

  // -- Communications
  List<CommunicationLog> getCommunicationLogs() => _source.getCommunicationLogs();
  Future<CommunicationLog> sendCommunication({
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

  // -- Employer configuration
  EmployerConfig getEmployerConfig() => _source.getEmployerConfig();
  Future<EmployerConfig> updateEmployerConfig(EmployerConfig config) =>
      _source.updateEmployerConfig(config);

  // -- Worker disputes
  List<WorkerDispute> getDisputes({String? employeeId}) =>
      _source.getDisputes(employeeId: employeeId);
  Future<WorkerDispute> fileDispute(WorkerDispute dispute) => _source.fileDispute(dispute);
  Future<WorkerDispute> updateDispute(WorkerDispute dispute) => _source.updateDispute(dispute);
  Future<WorkerDispute> resolveDispute(String id, String resolvedBy, String resolutionNote) =>
      _source.resolveDispute(id, resolvedBy, resolutionNote);
  Future<WorkerDispute> dismissDispute(String id, String resolvedBy) =>
      _source.dismissDispute(id, resolvedBy);

  // -- Benefit contributions
  List<BenefitContribution> getBenefitContributions({String? employeeId}) =>
      _source.getBenefitContributions(employeeId: employeeId);
  Future<BenefitContribution> addBenefitContribution(BenefitContribution contribution) =>
      _source.addBenefitContribution(contribution);
  Future<BenefitContribution> updateBenefitContribution(BenefitContribution contribution) =>
      _source.updateBenefitContribution(contribution);
  Future<void> deleteBenefitContribution(String id) =>
      _source.deleteBenefitContribution(id);
}