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

abstract class PayrollDataSource {
  // ── Employees ─────────────────────────────────────────────────────────────
  List<PayrollEmployee> getEmployees();
  PayrollEmployee? getEmployee(String id);
  PayrollEmployee addEmployee(PayrollEmployee employee);
  PayrollEmployee updateEmployee(PayrollEmployee employee);

  // ── Contracts ─────────────────────────────────────────────────────────────
  List<EmploymentContract> getContracts({String? employeeId});
  EmploymentContract? getContract(String id);
  EmploymentContract addContract(EmploymentContract contract);
  EmploymentContract updateContract(EmploymentContract contract);

  // ── Pay groups ─────────────────────────────────────────────────────────────
  List<PayGroup> getPayGroups();
  PayGroup addPayGroup(PayGroup group);
  PayGroup updatePayGroup(PayGroup group);

  // ── Pay structures ────────────────────────────────────────────────────────
  List<PayStructure> getPayStructures();
  PayStructure addPayStructure(PayStructure structure);
  PayStructure updatePayStructure(PayStructure structure);

  // ── Shifts / roster ────────────────────────────────────────────────────────
  List<Shift> getShifts({DateTime? weekStart, String? employeeId});
  Shift addShift(Shift shift);
  Shift updateShift(Shift shift);

  // ── Task assignments ───────────────────────────────────────────────────────
  List<TaskAssignment> getTaskAssignments({String? employeeId, DateTime? date});
  TaskAssignment addTaskAssignment(TaskAssignment task);
  TaskAssignment updateTaskAssignment(TaskAssignment task);

  // ── Attendance ─────────────────────────────────────────────────────────────
  List<AttendanceRecord> getAttendanceRecords({String? employeeId, DateTime? date, DateTime? fromDate, DateTime? toDate});
  AttendanceRecord addAttendanceRecord(AttendanceRecord record);
  AttendanceRecord updateAttendanceRecord(AttendanceRecord record);

  // ── Piecework ──────────────────────────────────────────────────────────────
  List<PieceworkLog> getPieceworkLogs({String? employeeId, DateTime? date, String? shiftId});
  PieceworkLog addPieceworkLog(PieceworkLog log);

  // ── Pay runs ───────────────────────────────────────────────────────────────
  List<PayRun> getPayRuns({String? payGroupId});
  PayRun? getPayRun(String id);
  PayRun calculatePayRun(String payGroupId, DateTime periodStart, DateTime periodEnd);
  PayRun approvePayRun(String id, String approverUserId);
  PayRun disbursePayRun(String id);

  // ── Payslips ───────────────────────────────────────────────────────────────
  List<Payslip> getPayslips({String? employeeId, String? payRunId});
  Payslip? getPayslip(String id);

  // ── Deduction rules ────────────────────────────────────────────────────────
  List<DeductionRule> getDeductionRules({String? employeeId});
  DeductionRule addDeductionRule(DeductionRule rule);
  DeductionRule updateDeductionRule(DeductionRule rule);

  // ── Garnishee orders (Sprint 6) ────────────────────────────────────────────
  List<GarnisheeOrder> getGarnisheeOrders({String? employeeId});
  GarnisheeOrder addGarnisheeOrder(GarnisheeOrder order);
  GarnisheeOrder updateGarnisheeOrder(GarnisheeOrder order);

  // ── Leave types ────────────────────────────────────────────────────────────
  List<LeaveType> getLeaveTypes();

  // ── Leave balances ─────────────────────────────────────────────────────────
  List<LeaveBalance> getLeaveBalances({String? employeeId});

  // ── Leave requests ─────────────────────────────────────────────────────────
  List<LeaveRequest> getLeaveRequests({String? employeeId, LeaveStatus? status});
  LeaveRequest addLeaveRequest(LeaveRequest request);
  LeaveRequest approveLeaveRequest(String id, String approverId);
  LeaveRequest rejectLeaveRequest(String id, String approverId, String reason);
  LeaveRequest cancelLeaveRequest(String id);

  // ── Payment transactions ───────────────────────────────────────────────────
  List<PaymentTransaction> getTransactions({String? payRunId, String? employeeId});

  // ── Compliance alerts ──────────────────────────────────────────────────────
  List<ComplianceAlert> getComplianceAlerts({bool includeResolved = false});
  ComplianceAlert resolveAlert(String id, String resolvedByUserId, String resolution);

  // ── Audit log ──────────────────────────────────────────────────────────────
  List<AuditLogEntry> getAuditLog({String? entityType, String? entityId, int limit = 100});

  // ── Incidents ──────────────────────────────────────────────────────────────
  List<IncidentRecord> getIncidents({String? employeeId});
  IncidentRecord addIncident(IncidentRecord incident);
  IncidentRecord updateIncident(IncidentRecord incident);

  // ── Communications ─────────────────────────────────────────────────────────
  List<CommunicationLog> getCommunicationLogs();
  CommunicationLog sendCommunication({
    required CommunicationChannel channel,
    required String templateCode,
    required String subject,
    required String body,
    required List<String> recipientEmployeeIds,
    required String sentByUserId,
  });
  // ── Soft-deletes / Terminations ─────────────────────────────────────────────────────
  PayrollEmployee terminateEmployee(String id, DateTime terminationDate, String reason);
  EmploymentContract voidContract(String id, String reason);
  bool deleteShift(String id);
  bool deleteTaskAssignment(String id);
  DeductionRule deactivateDeductionRule(String id);
  bool deletePieceworkLog(String id, String correctionReason);
  bool deleteLeaveRequest(String id);
  IncidentRecord deactivateIncident(String id);
  PayGroup deactivatePayGroup(String id);

  // ── Employer configuration ─────────────────────────────────────────────────────
  EmployerConfig getEmployerConfig();
  EmployerConfig updateEmployerConfig(EmployerConfig config);}
