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

abstract class PayrollDataSource {
  // ── Employees ─────────────────────────────────────────────────────────────
  List<PayrollEmployee> getEmployees();
  PayrollEmployee? getEmployee(String id);
  Future<PayrollEmployee> addEmployee(PayrollEmployee employee);
  Future<PayrollEmployee> updateEmployee(PayrollEmployee employee);
  Future<String> uploadProfileImage(String employeeId, String filePath);
  Future<Map<String, dynamic>> bulkImportEmployees(
    List<PayrollEmployee> employees,
  );

  // ── Contracts ─────────────────────────────────────────────────────────────
  List<EmploymentContract> getContracts({String? employeeId});
  EmploymentContract? getContract(String id);
  Future<EmploymentContract> addContract(EmploymentContract contract);
  Future<EmploymentContract> updateContract(EmploymentContract contract);

  // ── Pay groups ─────────────────────────────────────────────────────────────
  List<PayGroup> getPayGroups();
  List<String> getGroupMemberIds(String groupId);
  Future<PayGroup> addPayGroup(PayGroup group);
  Future<PayGroup> updatePayGroup(PayGroup group);

  // ── Pay structures ────────────────────────────────────────────────────────
  List<PayStructure> getPayStructures();
  Future<PayStructure> addPayStructure(PayStructure structure);
  Future<PayStructure> updatePayStructure(PayStructure structure);

  // ── Shifts / roster ────────────────────────────────────────────────────────
  List<Shift> getShifts({DateTime? weekStart, String? employeeId});
  Future<Shift> addShift(Shift shift);
  Future<Shift> updateShift(Shift shift);

  // ── Task assignments ───────────────────────────────────────────────────────
  List<TaskAssignment> getTaskAssignments({String? employeeId, DateTime? date});
  Future<TaskAssignment> addTaskAssignment(TaskAssignment task);
  Future<TaskAssignment> updateTaskAssignment(TaskAssignment task);

  // ── Attendance ─────────────────────────────────────────────────────────────
  List<AttendanceRecord> getAttendanceRecords({
    String? employeeId,
    DateTime? date,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<AttendanceRecord> addAttendanceRecord(AttendanceRecord record);
  Future<AttendanceRecord> updateAttendanceRecord(AttendanceRecord record);

  // ── Piecework ──────────────────────────────────────────────────────────────
  List<PieceworkLog> getPieceworkLogs({
    String? employeeId,
    DateTime? date,
    String? shiftId,
  });
  Future<PieceworkLog> addPieceworkLog(PieceworkLog log);

  // ── Pay runs ───────────────────────────────────────────────────────────────
  List<PayRun> getPayRuns({String? payGroupId});
  PayRun? getPayRun(String id);
  Future<PayRun> calculatePayRun(
    String payGroupId,
    DateTime periodStart,
    DateTime periodEnd, {
    DateTime? payDate,
  });
  Future<PayRun> completePayRun(String id);
  Future<PayRun> approvePayRun(String id, String approverUserId);
  Future<PayRun> disbursePayRun(String id);
  Future<PayRun> rejectPayRun(String id, {String? reason});
  Future<PayRun> cancelPayRun(String id, {String? reason});
  Future<PayRun> recalculatePayRun(String id);

  // ── Payslips ───────────────────────────────────────────────────────────────
  List<Payslip> getPayslips({String? employeeId, String? payRunId});
  Payslip? getPayslip(String id);

  // ── Deduction rules ────────────────────────────────────────────────────────
  List<DeductionRule> getDeductionRules({String? employeeId});
  Future<DeductionRule> addDeductionRule(DeductionRule rule);
  Future<DeductionRule> updateDeductionRule(DeductionRule rule);

  // ── Garnishee orders (Sprint 6) ────────────────────────────────────────────
  List<GarnisheeOrder> getGarnisheeOrders({String? employeeId});
  Future<GarnisheeOrder> addGarnisheeOrder(GarnisheeOrder order);
  Future<GarnisheeOrder> updateGarnisheeOrder(GarnisheeOrder order);

  // ── Leave types ────────────────────────────────────────────────────────────
  List<LeaveType> getLeaveTypes();

  // ── Leave balances ─────────────────────────────────────────────────────────
  List<LeaveBalance> getLeaveBalances({String? employeeId});

  // ── Leave requests ─────────────────────────────────────────────────────────
  List<LeaveRequest> getLeaveRequests({
    String? employeeId,
    LeaveStatus? status,
  });
  Future<LeaveRequest> addLeaveRequest(LeaveRequest request);
  Future<LeaveRequest> approveLeaveRequest(String id, String approverId);
  Future<LeaveRequest> rejectLeaveRequest(
    String id,
    String approverId,
    String reason,
  );
  Future<LeaveRequest> cancelLeaveRequest(String id);

  // ── Payment transactions ───────────────────────────────────────────────────
  List<PaymentTransaction> getTransactions({
    String? payRunId,
    String? employeeId,
  });
  Future<void> createTransaction(Map<String, dynamic> payload);

  // ── Compliance alerts ──────────────────────────────────────────────────────
  List<ComplianceAlert> getComplianceAlerts({bool includeResolved = false});
  Future<ComplianceAlert> resolveAlert(
    String id,
    String resolvedByUserId,
    String resolution,
  );

  // ── Audit log ──────────────────────────────────────────────────────────────
  List<AuditLogEntry> getAuditLog({
    String? entityType,
    String? entityId,
    int limit = 100,
  });

  // ── Incidents ──────────────────────────────────────────────────────────────
  List<IncidentRecord> getIncidents({String? employeeId});
  Future<IncidentRecord> addIncident(IncidentRecord incident);
  Future<IncidentRecord> updateIncident(IncidentRecord incident);

  // ── Communications ─────────────────────────────────────────────────────────
  List<CommunicationLog> getCommunicationLogs();
  Future<CommunicationLog> sendCommunication({
    required CommunicationChannel channel,
    required String templateCode,
    required String subject,
    required String body,
    required List<String> recipientEmployeeIds,
    required String sentByUserId,
  });
  // ── Soft-deletes / Terminations ─────────────────────────────────────────────────────
  Future<PayrollEmployee> terminateEmployee(
    String id,
    DateTime terminationDate,
    String reason,
  );
  Future<EmploymentContract> voidContract(String id, String reason);
  Future<bool> deleteShift(String id);
  Future<bool> deleteTaskAssignment(String id);
  Future<DeductionRule> deactivateDeductionRule(String id);
  Future<bool> deletePieceworkLog(String id, String correctionReason);
  Future<bool> deleteLeaveRequest(String id);
  Future<IncidentRecord> deactivateIncident(String id);
  Future<PayGroup> deactivatePayGroup(String id);

  // ── Employer configuration ─────────────────────────────────────────────────────
  EmployerConfig getEmployerConfig();
  Future<EmployerConfig> updateEmployerConfig(EmployerConfig config);

  // ── Worker disputes ────────────────────────────────────────────────────────
  List<WorkerDispute> getDisputes({String? employeeId});
  Future<WorkerDispute> fileDispute(WorkerDispute dispute);
  Future<WorkerDispute> updateDispute(WorkerDispute dispute);
  Future<WorkerDispute> resolveDispute(
    String id,
    String resolvedBy,
    String resolutionNote,
  );
  Future<WorkerDispute> dismissDispute(String id, String resolvedBy);

  // ── Benefit contributions ──────────────────────────────────────────────────
  List<BenefitContribution> getBenefitContributions({String? employeeId});
  Future<BenefitContribution> addBenefitContribution(
    BenefitContribution contribution,
  );
  Future<BenefitContribution> updateBenefitContribution(
    BenefitContribution contribution,
  );
  Future<void> deleteBenefitContribution(String id);
}
