# 4Directions Farm — Agriculture Payroll Module
## Full Plan: Functional Scope + Flutter Technical Implementation

> **Last updated:** May 2026  
> **Status:** Planning — no code exists yet; ready to implement Phase 1  
> **SA Compliance baseline:** BCEA, LRA, UIF Act, Income Tax Act, COIDA, NMWA (National Minimum Wage Act)

---

# PART 1 — Functional & Compliance Scope

---

## 1. User Management & Security
User Roles:
Owner/Farmer
Payroll Manager
Supervisor/Team Lead
Worker (self-service access)
Auditor (external/internal, read-only)
Permission Matrix: Role-based access to features, logs, and sensitive data.
Two-Factor Authentication: Optional for Owner/Admin.
Comprehensive Audit Trail: Log ALL data mutation, approvals, communication/outreach sent.
2. Employee/Worker Data Management
Data Entities:
Personal Info (ID/Passport, Address, Dependents)
Employment Details (Status, Occupation, Engagement Type)
Contract Info (Contract Type, Start/End Date, Terms, Offboarding Reason)
Bulk Import/Export: Excel/CSV/sync from farm ERP systems.
Active/Inactive Record Handling: Preserve historic employment data for compliance retention.
3. Contract & Onboarding Flows
Smart Contract Generator:
Custom contract creation (template, auto-fill, e-signature).
Track contract amendments and renewals, store PDFs.
Snapshot Data Logging: Retain each contract version with timestamp.
4. Roster & Task Assignment
Shift Planning UI:
Daily, weekly, and seasonal roster boards.
Assign by group, skill, crop, or team.
Task Sheet Integration:
Job cards linked to payroll code.
Field-specific tracking.
Dynamic Adjustments: Handle real-time changes due to weather, emergencies, and adjust payroll entries automatically.
5. Time & Attendance Collection
Mechanisms:
Biometric integration (optional fingerprint scanner, for larger farms).
PIN/Token, Mobile clock-in, USSD support.
Supervisor overrides for illiterate/technologically limited workers.
Offline Mode with Sync:
Store offline, auto-sync when signal returns.
Exception Handling: Track missed punches, lateness, absences with reason codes and workflow for correction/approval.
6. Pay Structure Calculation
A. Wage Configuration
Support for hourly, daily, piecework, yield-based, mix (e.g., guaranteed + incentive).
Rate escalators on length of service or upskilling.
Minimum wage enforcement/alerting engine; never allows payout < legal minimum.
B. Overtime, Shift, and Premiums
Overtime auto-flag, holiday/special rate calculation per labor law.
Support for split shifts, compound overtime, and public holiday rules.
C. Deductions Engine
Legally compliant deduction rules (UIF, PAYE, loans, housing, tools, uniforms).
Validation of each deduction (never > allowed % of gross; itemized on payslip).
Dynamic deduction templates per farm.
D. Non-monetary Compensation
Value-in-kind (accommodation, food) as per BCEA, monetary equivalent in payslip, impact on minimum wage check.
7. Leave & Entitlements (Automation)
Accrual Engines: Configurable for multiple leave types (annual, sick, maternity, family, special, compensation for work on public holidays).
Leave Approval Workflow: Multi-level, with audit log and communication trail.
Statutory Caps and Balances: Warn/admin lock if trying to over-deduct/take.
Special Mechanisms: Automatic conversion of excess leave (e.g., payout, carry-over as per company policy or compliance).
8. Compliance, Statutory Reporting & Law Engine
SA Wage Compliance Monitor:
Periodical checks, real-time validation, and report generation if non-compliance detected.
Highlight affected employees, reason, and remedial next steps.
UIF Management:
Real-time calculation, returns, export to UI-19/UIF e-filing.
SARS Integrations:
PAYE auto-calc, bracket management, reconciliation, EMP forms, IRP5 generation, auto-flag for short-term/seasonal exclusion.
COIDA (Compensation Fund):
Track contributions, returns, incident log.
9. Payroll Processing Workflow
Roster/tasks complete → attendance → output (piece/shift/task) → supervisor approval.
Calculation run: wager, AI-based legal check, deduction application.
Pre-payroll report: show summary, warnings, highlight issues.
Multiple pay groups/frequencies (weekly, monthly, bi-weekly, team/department/crop).
Payroll Approval: Multi-signatory options before release.
Bulk/Individual Disbursement: Bank batch, cash, mobile money (MTN, eWallet), full EFT integration.
Payslip Generation:
PDF, SMS/WhatsApp push (summarized pay slip), secure portal download.
Payslips in local language with compliance requirements (detailed breakdown, leave balance, all deduction line-items, employer info).
10. Employee Self-Service Portal
View: Historical payslips, leave balances, clock-in records.
Request/Dispute: Submit leave, payroll discrepancies, or incorrect attendance; full workflow for supervisor/HR back-office resolution.
Notice Alerts: Wage updates, policy changes, law announcements in UI/local language.
11. Communication System
Bulk SMS/WhatsApp Integration: Notices (payment, leave, law changes).
Custom Message Templates: For appointment, warnings, termination, legal postings.
12. Reporting & Analytics
Standard: Compliance status, payroll cost by team/crop/period, absenteeism, productivity.
Custom Reports: Builder for advanced users.
Data Export: PDF, Excel, CSV, SARS/UIF formats.
Automated Archive: 5+ years regulatory retention with granular access logs.
13. Integrations & APIs
Accounting Packages: (Sage, Xero, QuickBooks) via API or csv/xml.
Agricultural Management Systems: HR/ERP plug-ins.
Financial Institutions & Mobile Money: Batch file or API integration for seamless payment.
Gov Systems: UIF, SARS, COIDA, Home Affairs verification where possible.
14. Localization & Accessibility
Multi-Language UI & Payslips: Major local languages.
Low-bandwidth/USSD Mode: Essential for rural use.
Accessibility: Large button sizes, voice/audio for illiterate users, dark mode.
15. Advanced Legal/Regulatory Features
Auto-Law Update: System checks for new wage/legal rules daily, updates rates, and alerts admin/farmer.
Worker Rights & Info Section: In-app posters, mandatory legal info.
Document Templates: BCEA-compliant forms, warning/discipline letters, certificates of service.
Incident Logging: Track labor incidents, investigations, outcomes for compliance/legal defense.
Example Workflow (End-to-End)
Onboard Worker: Upload/enter all data; sign digital BCEA-compliant contract.
Roster & Assign Tasks: Create by field/crop/team; push to worker phone/portal.
Collect Attendance: Mobile, biometric, or supervisor logs; offline if needed; GPS/geofence check.
Work Done: Log output (e.g., kg picked); supervisor validates.
Leave/Admin Events: Requests & supervisor approvals inline.
Payroll Calculation: Validate against legal minimums, overtime, special rates, and all deductions.
Pre-Payroll Sanity Check: Alerts for issues, compliance.
Approval: Multi-level, with logs.
Disburse Payroll: Bank, cash, or mobile methods; auto-create payment files.
Payslip Delivery: Secure portal, WhatsApp/SMS, printable PDF.
Statutory Export: UIF/SARS/COIDA with archiving, compliance dashboard.
Technical & Data Model Notes
Entities: Employee, PayGroup, Shift, Task, PayRun, Payslip, Deduction, LeaveType, Group/Team, AttendanceRecord, Incident, Contract, Communication, AuditLog.
APIs: REST, Webhook for outbound integration, USSD endpoint.
Security: Full PII compliance, field-level encryption, audit log, GDPR/POPIA alignment as applicable.
Deployment: On-premise/farm server or cloud-hosted for distributed farmers.
Performance: Local caching/processing for intermittent network.
Special Legal Edge Cases to Cover
Payment in kind (food, housing), must always show cash equivalence on payslip.
Seasonal workers’ threshold for tax/leave/UIF.
Multi-crop/field assignment for piecework — split wages by activity.
Worker status on housing/transport provided by employer (deduction validation).
Retroactive legal changes (wage increases) and requirement for backpay.
This scope is suitable for an enterprise-level, fully compliant agri-payroll management system, operational for the unique needs of South African farmers.

If you need sample data models, database schema, UI wireframes, or architectural recommendations, ask for those sections.

---

# PART 2 — Flutter Technical Implementation Plan

---

## Architecture Overview

Follows the established 4Directions repository-interface pattern. No screen or provider changes when the real backend is wired — only the provider wiring changes.

```
lib/features/payroll/
├── data/
│   ├── payroll_data_source.dart          — abstract interface (all method signatures)
│   ├── payroll_mock_data_source.dart     — typed Dart objects; no JSON, no rootBundle
│   ├── payroll_remote_data_source.dart   — Dio HTTP stub; throws UnimplementedError
│   └── payroll_repository.dart           — takes PayrollDataSource via constructor
├── models/
│   ├── payroll_employee.dart
│   ├── employment_contract.dart
│   ├── pay_group.dart
│   ├── pay_structure.dart
│   ├── shift.dart
│   ├── attendance_record.dart
│   ├── task_assignment.dart
│   ├── piecework_log.dart
│   ├── pay_run.dart
│   ├── payslip.dart
│   ├── deduction_rule.dart
│   ├── leave_type.dart
│   ├── leave_request.dart
│   ├── leave_balance.dart
│   ├── payment_transaction.dart
│   ├── audit_log_entry.dart
│   ├── compliance_alert.dart
│   ├── incident_record.dart
│   └── communication_log.dart
├── providers/
│   └── payroll_providers.dart
└── screens/
    ├── payroll_hub_screen.dart
    ├── employees/
    ├── contracts/
    ├── roster/
    ├── attendance/
    ├── pay_structures/
    ├── pay_runs/
    ├── payslips/
    ├── leave/
    ├── deductions/
    ├── pay_groups/
    ├── compliance/
    ├── disbursements/
    ├── communications/
    ├── reports/
    ├── audit/
    └── incidents/
```

---

## Data Models (Dart)

### `PayrollEmployee`
```dart
class PayrollEmployee {
  final String id;
  final String firstName;
  final String lastName;
  final String idOrPassportNumber;       // SA ID or passport
  final String? phone;
  final String? email;
  final String address;
  final String nextOfKinName;
  final String nextOfKinPhone;
  final EmploymentStatus status;         // active | inactive | terminated
  final EngagementType engagementType;   // permanent | seasonal | casual | contractor
  final String occupationTitle;
  final String? payGroupId;
  final String? payStructureId;
  final DateTime startDate;
  final DateTime? endDate;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankBranchCode;
  final DisbursementMethod disbursementMethod; // bank | cash | mtn_ewallet | orange_money
  final String preferredLanguage;        // en | zu | xh | af | st | tn
  final bool hasHousingBenefit;
  final double? housingValuePerMonth;
  final bool hasFoodBenefit;
  final double? foodValuePerMonth;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName => '$firstName $lastName';
  bool get isActive => status == EmploymentStatus.active;
}

enum EmploymentStatus { active, inactive, terminated }
enum EngagementType { permanent, seasonal, casual, contractor }
enum DisbursementMethod { bank, cash, mtnEwallet, orangeMoney }
```

### `EmploymentContract`
```dart
class EmploymentContract {
  final String id;
  final String employeeId;
  final ContractType type;               // permanent | fixed_term | seasonal | casual
  final DateTime startDate;
  final DateTime? endDate;
  final String jobDescription;
  final double grossMonthlySalary;       // or hourly rate depending on pay structure
  final String currency;                 // ZAR
  final ContractStatus status;           // draft | signed | expired | terminated
  final DateTime? signedAt;
  final String? signedByName;
  final String? pdfPath;                 // local path or CDN URL
  final int version;                     // for amendment tracking
  final DateTime createdAt;
}

enum ContractType { permanent, fixedTerm, seasonal, casual }
enum ContractStatus { draft, signed, expired, terminated }
```

### `PayGroup`
```dart
class PayGroup {
  final String id;
  final String name;                     // e.g. "Weekly Casual", "Monthly Staff"
  final PayFrequency frequency;          // weekly | biweekly | monthly | fortnightly
  final int payDayOfWeek;               // for weekly: 0=Mon … 6=Sun
  final int? payDayOfMonth;             // for monthly: 1–31
  final String currency;
  final List<String> employeeIds;
}

enum PayFrequency { weekly, biweekly, fortnightly, monthly }
```

### `PayStructure`
```dart
class PayStructure {
  final String id;
  final String name;
  final WageType wageType;               // hourly | daily | piecework | yield_based | mixed
  final double baseRate;                 // ZAR per hour/day/unit
  final String? baseRateUnit;            // 'hour' | 'day' | 'kg' | 'crate' | 'row'
  final double? guaranteedMinimum;       // for mixed type
  final double? incentiveRateAboveTarget;
  final double targetUnitsPerDay;        // for piecework
  final bool enforceNmwa;               // always true for SA compliance
  final double overtimeMultiplier;       // 1.5 standard, 2.0 Sunday/PH
  final double sundayMultiplier;
  final double publicHolidayMultiplier;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
}

enum WageType { hourly, daily, piecework, yieldBased, mixed }
```

### `Shift`
```dart
class Shift {
  final String id;
  final DateTime date;
  final String? employeeId;             // null = unassigned slot
  final String? teamId;
  final String fieldOrArea;
  final String? taskCode;               // linked to TaskAssignment
  final DateTime startTime;
  final DateTime endTime;
  final ShiftStatus status;             // planned | confirmed | completed | cancelled
  final String? notes;
}

enum ShiftStatus { planned, confirmed, completed, cancelled }
```

### `AttendanceRecord`
```dart
class AttendanceRecord {
  final String id;
  final String employeeId;
  final String? shiftId;
  final DateTime date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final double hoursWorked;             // computed or manually entered
  final AttendanceMethod method;        // mobile | pin | biometric | supervisor | ussd
  final AttendanceStatus status;        // present | absent | late | half_day | leave
  final String? absenceReasonCode;      // sick | annual | uif | awol | personal
  final bool supervisorOverride;
  final String? supervisorId;
  final String? geofenceZone;           // GPS zone if available
  final bool isApproved;
  final DateTime recordedAt;
}

enum AttendanceMethod { mobile, pin, biometric, supervisor, ussd }
enum AttendanceStatus { present, absent, late, halfDay, leave }
```

### `PieceworkLog`
```dart
class PieceworkLog {
  final String id;
  final String employeeId;
  final String shiftId;
  final DateTime date;
  final String activityCode;            // e.g. 'apple_picking', 'grape_pruning'
  final String unit;                    // kg | crate | row | bunch
  final double unitsCompleted;
  final double ratePerUnit;             // ZAR
  final double grossEarning;            // computed: unitsCompleted × ratePerUnit
  final String? supervisorId;
  final bool isVerified;
  final String? notes;
}
```

### `PayRun`
```dart
class PayRun {
  final String id;
  final String payGroupId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime payDate;
  final PayRunStatus status;            // draft | calculated | pending_approval | approved | disbursed
  final List<PayslipLineItem> lineItems;// summary per employee
  final double totalGross;
  final double totalDeductions;
  final double totalNet;
  final List<ComplianceAlert> warnings; // pre-payroll issues
  final List<String> approverIds;
  final List<String> approvedByIds;
  final DateTime? approvedAt;
  final DateTime createdAt;
}

enum PayRunStatus { draft, calculated, pendingApproval, approved, disbursed }

class PayslipLineItem {
  final String employeeId;
  final String employeeName;
  final double gross;
  final double uif;
  final double paye;
  final double otherDeductions;
  final double net;
  final bool hasComplianceIssue;
}
```

### `Payslip`
```dart
class Payslip {
  final String id;
  final String employeeId;
  final String payRunId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime payDate;
  // Earnings
  final double basicWage;
  final double overtimePay;
  final double holidayPay;
  final double incentivePay;
  final double valueInKindHousing;      // BCEA in-kind equivalence
  final double valueInKindFood;
  final double grossPay;
  // Deductions (each is a named line item)
  final List<PayslipDeductionLine> deductions;
  final double totalDeductions;
  // Net
  final double netPay;
  // Leave balances (printed on slip)
  final double annualLeaveBalance;
  final double sickLeaveBalance;
  // Metadata
  final String? pdfPath;
  final bool deliveredBySms;
  final bool deliveredByWhatsapp;
  final bool viewedByEmployee;
  final DateTime generatedAt;
}

class PayslipDeductionLine {
  final String code;                    // UIF | PAYE | LOAN | HOUSING | TOOLS | UNIFORM
  final String label;
  final double amount;
  final bool isEmployerContribution;
}
```

### `DeductionRule`
```dart
class DeductionRule {
  final String id;
  final String code;
  final String label;
  final DeductionType type;             // statutory | voluntary | benefit | loan
  final DeductionBasis basis;           // percentage | fixed_amount
  final double value;                   // % or ZAR
  final double? maxPercentOfGross;      // cap validation
  final double? maxAmountPerPeriod;
  final bool isEmployeeDeduction;
  final bool isEmployerContribution;
  final String? linkedEmployeeId;       // null = applies to all in group
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
}

enum DeductionType { statutory, voluntary, benefit, loan }
enum DeductionBasis { percentage, fixedAmount }
```

### `LeaveType`
```dart
class LeaveType {
  final String id;
  final String code;                    // annual | sick | maternity | family | phwork | special
  final String label;
  final double accrualDaysPerYear;
  final double maxCarryOver;
  final bool isPaid;
  final bool requiresDocumentation;     // e.g. sick note
  final int maxConsecutiveDaysWithoutApproval;
}
```

### `LeaveRequest`
```dart
class LeaveRequest {
  final String id;
  final String employeeId;
  final String leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final double daysRequested;
  final String? reason;
  final LeaveStatus status;             // pending | approved | rejected | cancelled
  final String? approvedByEmployeeId;
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime? resolvedAt;
}

enum LeaveStatus { pending, approved, rejected, cancelled }
```

### `LeaveBalance`
```dart
class LeaveBalance {
  final String id;
  final String employeeId;
  final String leaveTypeId;
  final double accrued;
  final double used;
  final double pending;                 // requested but not yet approved
  final double available;              // accrued - used - pending
  final DateTime asOfDate;
}
```

### `PaymentTransaction`
```dart
class PaymentTransaction {
  final String id;
  final String payRunId;
  final String employeeId;
  final double amount;
  final String currency;
  final DisbursementMethod method;
  final TransactionStatus status;       // pending | processing | completed | failed
  final String? referenceNumber;
  final String? bankName;
  final String? accountNumber;
  final DateTime initiatedAt;
  final DateTime? completedAt;
  final String? failureReason;
}

enum TransactionStatus { pending, processing, completed, failed }
```

### `ComplianceAlert`
```dart
class ComplianceAlert {
  final String id;
  final ComplianceSeverity severity;    // critical | warning | info
  final String code;                    // NMWA_BREACH | UIF_MISSING | PAYE_SHORTFALL | CONTRACT_EXPIRED
  final String description;
  final String? affectedEmployeeId;
  final String? affectedPayRunId;
  final String remediationSteps;
  final bool isResolved;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
}

enum ComplianceSeverity { critical, warning, info }
```

### `AuditLogEntry`
```dart
class AuditLogEntry {
  final String id;
  final String actorId;
  final String actorName;
  final String entityType;              // employee | payrun | payslip | contract | leave | deduction
  final String entityId;
  final String action;                  // create | update | delete | approve | reject | view | export
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final String? ipAddress;
  final DateTime timestamp;
}
```

### `IncidentRecord`
```dart
class IncidentRecord {
  final String id;
  final String employeeId;
  final IncidentType type;              // disciplinary | grievance | injury | dispute | dismissal
  final String description;
  final DateTime incidentDate;
  final IncidentStatus status;          // open | under_investigation | resolved | escalated
  final String? outcome;
  final List<String> documentPaths;
  final String? investigatingOfficerId;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
}

enum IncidentType { disciplinary, grievance, injury, dispute, dismissal }
enum IncidentStatus { open, underInvestigation, resolved, escalated }
```

### `CommunicationLog`
```dart
class CommunicationLog {
  final String id;
  final CommunicationChannel channel;   // sms | whatsapp | email | in_app
  final String templateCode;
  final String subject;
  final String body;
  final List<String> recipientEmployeeIds;
  final int sentCount;
  final int failedCount;
  final String sentByUserId;
  final DateTime sentAt;
}

enum CommunicationChannel { sms, whatsapp, email, inApp }
```

---

## Data Source Interface — `PayrollDataSource`

```dart
abstract class PayrollDataSource {
  // Employees
  List<PayrollEmployee> getEmployees();
  PayrollEmployee? getEmployee(String id);
  PayrollEmployee addEmployee(PayrollEmployee employee);
  PayrollEmployee updateEmployee(PayrollEmployee employee);

  // Contracts
  List<EmploymentContract> getContracts({String? employeeId});
  EmploymentContract? getContract(String id);
  EmploymentContract addContract(EmploymentContract contract);
  EmploymentContract updateContract(EmploymentContract contract);

  // Pay Groups & Structures
  List<PayGroup> getPayGroups();
  PayGroup addPayGroup(PayGroup group);
  List<PayStructure> getPayStructures();
  PayStructure addPayStructure(PayStructure structure);

  // Roster & Tasks
  List<Shift> getRoster({DateTime? weekStart});
  Shift addShift(Shift shift);
  Shift updateShift(Shift shift);
  List<TaskAssignment> getTaskAssignments({String? employeeId, DateTime? date});
  TaskAssignment addTaskAssignment(TaskAssignment task);

  // Attendance
  List<AttendanceRecord> getAttendance({String? employeeId, DateTime? date});
  AttendanceRecord addAttendanceRecord(AttendanceRecord record);
  AttendanceRecord updateAttendanceRecord(AttendanceRecord record);

  // Piecework
  List<PieceworkLog> getPieceworkLogs({String? employeeId, String? shiftId});
  PieceworkLog addPieceworkLog(PieceworkLog log);

  // Pay Runs & Payslips
  List<PayRun> getPayRuns();
  PayRun? getPayRun(String id);
  PayRun calculatePayRun(String payGroupId, DateTime periodStart, DateTime periodEnd);
  PayRun approvePayRun(String id, String approverUserId);
  List<Payslip> getPayslips({String? employeeId, String? payRunId});
  Payslip? getPayslip(String id);

  // Leave
  List<LeaveType> getLeaveTypes();
  List<LeaveBalance> getLeaveBalances({String? employeeId});
  List<LeaveRequest> getLeaveRequests({String? employeeId, LeaveStatus? status});
  LeaveRequest addLeaveRequest(LeaveRequest request);
  LeaveRequest approveLeaveRequest(String id, String approverId);
  LeaveRequest rejectLeaveRequest(String id, String reason);

  // Deductions
  List<DeductionRule> getDeductionRules({String? employeeId});
  DeductionRule addDeductionRule(DeductionRule rule);
  DeductionRule updateDeductionRule(DeductionRule rule);

  // Compliance
  List<ComplianceAlert> getComplianceAlerts({bool includeResolved = false});
  ComplianceAlert resolveComplianceAlert(String id, String resolution);

  // Disbursements
  List<PaymentTransaction> getDisbursements({String? payRunId, String? employeeId});

  // Audit
  List<AuditLogEntry> getAuditLog({String? entityType, String? entityId, int limit = 100});

  // Incidents
  List<IncidentRecord> getIncidents({String? employeeId});
  IncidentRecord addIncident(IncidentRecord incident);
  IncidentRecord updateIncident(IncidentRecord incident);

  // Communications
  List<CommunicationLog> getCommunicationLogs();
  CommunicationLog sendCommunication({
    required CommunicationChannel channel,
    required String templateCode,
    required String subject,
    required String body,
    required List<String> recipientEmployeeIds,
    required String sentByUserId,
  });
}
```

Total interface methods: **42 methods**

---

## Providers — `payroll_providers.dart`

```dart
// Repository
final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  final source = AppConstants.useMockData
      ? PayrollMockDataSource()
      : PayrollRemoteDataSource(ref.watch(dioProvider));
  return PayrollRepository(source);
});

// Employees
final employeesProvider = FutureProvider<List<PayrollEmployee>>(...)
final employeeDetailProvider = FutureProvider.family<PayrollEmployee?, String>(...)
final addEmployeeProvider — AsyncNotifierProvider
final updateEmployeeProvider — AsyncNotifierProvider

// Contracts
final contractsProvider = FutureProvider.family<List<EmploymentContract>, String?>(...)

// Pay Groups & Structures
final payGroupsProvider = FutureProvider<List<PayGroup>>(...)
final payStructuresProvider = FutureProvider<List<PayStructure>>(...)

// Roster
final rosterProvider = FutureProvider.family<List<Shift>, DateTime?>(...)

// Attendance
final attendanceProvider = FutureProvider.family(...)
final attendanceSummaryProvider — derived: % present / absent / late for date range

// Pay Runs
final payRunsProvider = FutureProvider<List<PayRun>>(...)
final payRunDetailProvider = FutureProvider.family<PayRun?, String>(...)
final activePayRunProvider — derived: most recent non-disbursed run
final payRunComplianceProvider — derived: List<ComplianceAlert> for a run

// Payslips
final payslipsProvider = FutureProvider.family(...)
final payslipDetailProvider = FutureProvider.family<Payslip?, String>(...)

// Leave
final leaveTypesProvider = FutureProvider<List<LeaveType>>(...)
final leaveBalancesProvider = FutureProvider.family(...)
final pendingLeaveRequestsProvider — derived: requests with status=pending
final myLeaveProvider = FutureProvider.family(...)

// Deductions
final deductionRulesProvider = FutureProvider<List<DeductionRule>>(...)
final statutoryDeductionsProvider — derived: filter type=statutory

// Compliance
final complianceAlertsProvider = FutureProvider<List<ComplianceAlert>>(...)
final criticalAlertsProvider — derived: filter severity=critical
final complianceBadgeCountProvider — derived: int count for nav badge

// Disbursements
final disbursementsProvider = FutureProvider.family(...)

// Audit
final auditLogProvider = FutureProvider.family(...)

// Incidents
final incidentsProvider = FutureProvider<List<IncidentRecord>>(...)
final openIncidentsProvider — derived: filter status=open

// Communications
final communicationLogsProvider = FutureProvider<List<CommunicationLog>>(...)
```

Estimated providers: ~40 providers

---

## Screen Inventory (38 screens)

| Screen file | Section | Phase |
|---|---|---|
| `payroll_hub_screen.dart` | Dashboard: KPIs, pending actions, compliance badge | 1 |
| `employees/employee_list_screen.dart` | All workers, filter by status/type | 1 |
| `employees/employee_detail_screen.dart` | Full profile, contract, attendance, leave tabs | 1 |
| `employees/add_edit_employee_screen.dart` | Multi-step form: personal → employment → payment | 1 |
| `employees/employee_import_screen.dart` | CSV/Excel bulk import UI | 3 |
| `contracts/contract_list_screen.dart` | All contracts with status | 1 |
| `contracts/contract_detail_screen.dart` | View contract, amendment history | 1 |
| `contracts/generate_contract_screen.dart` | Template fill-in form (auto-populates from employee) | 3 |
| `contracts/contract_sign_screen.dart` | Digital signature pad + confirmation | 3 |
| `roster/roster_screen.dart` | Weekly calendar view — drag/drop shift planning | 2 |
| `roster/add_shift_screen.dart` | Create shift, assign employee or team, link task code | 2 |
| `roster/task_sheet_screen.dart` | List task assignments with payroll codes | 2 |
| `attendance/attendance_log_screen.dart` | Daily/weekly view; exceptions flagged red | 1 |
| `attendance/clock_in_screen.dart` | Supervisor quick clock-in for a worker | 1 |
| `attendance/attendance_exceptions_screen.dart` | Missed punches, late, AWOL — approval/correction | 2 |
| `pay_structures/pay_structures_screen.dart` | List pay structures (hourly, piecework, etc.) | 1 |
| `pay_structures/add_edit_pay_structure_screen.dart` | Configure rate type, NMWA check, overtime rules | 1 |
| `pay_runs/pay_run_list_screen.dart` | History of all pay runs with status | 1 |
| `pay_runs/run_payroll_screen.dart` | Select pay group + period → trigger calculation | 1 |
| `pay_runs/pay_run_detail_screen.dart` | Pre-payroll report: per-employee breakdown, warnings | 1 |
| `pay_runs/payroll_approval_screen.dart` | Multi-signatory approval before disburse | 2 |
| `payslips/payslip_list_screen.dart` | Per-employee payslip history | 1 |
| `payslips/payslip_detail_screen.dart` | Full payslip view with all line items; export PDF | 1 |
| `leave/leave_dashboard_screen.dart` | Team leave calendar + balance overview | 1 |
| `leave/leave_request_screen.dart` | Employee submits leave request | 1 |
| `leave/leave_approval_screen.dart` | Supervisor approves/rejects pending requests | 1 |
| `leave/leave_balance_screen.dart` | Per-employee leave balance breakdown by type | 1 |
| `deductions/deductions_screen.dart` | All configured deduction rules | 1 |
| `deductions/add_edit_deduction_screen.dart` | Configure deduction: type, basis, cap, employee scope | 1 |
| `pay_groups/pay_groups_screen.dart` | List pay groups + frequency | 1 |
| `pay_groups/add_edit_pay_group_screen.dart` | Create/edit pay group | 1 |
| `compliance/compliance_dashboard_screen.dart` | Compliance health: critical/warning/info alerts | 2 |
| `compliance/uif_returns_screen.dart` | UIF calculation, UI-19 export | 2 |
| `compliance/paye_screen.dart` | PAYE brackets, EMP201, IRP5 generation | 2 |
| `compliance/coida_screen.dart` | COIDA contribution tracking | 2 |
| `disbursements/disbursement_screen.dart` | Initiate bank batch / cash / mobile money | 2 |
| `disbursements/payment_history_screen.dart` | All transactions with status | 2 |
| `communications/communications_screen.dart` | Log of sent messages (SMS/WhatsApp) | 3 |
| `communications/compose_message_screen.dart` | Select template, recipients, channel | 3 |
| `reports/payroll_reports_screen.dart` | Cost by team/crop/period, absenteeism, export | 2 |
| `audit/audit_log_screen.dart` | Full audit trail with filters | 3 |
| `incidents/incident_list_screen.dart` | All incidents with status | 2 |
| `incidents/incident_detail_screen.dart` | Full incident record + documents | 2 |
| `incidents/add_incident_screen.dart` | Log new incident | 2 |

**Total: 44 screens** (includes a few more sub-screens than initial estimate)

---

## Mock Data Specification (SA Context)

All mock data mirrors real SA farm payroll. Currency: ZAR. Date context: 2026.

### Employees (8 records)
| Name | Type | Role | Wage basis | Pay group |
|---|---|---|---|---|
| Sipho Dlamini | Permanent | Cattle Manager | R18,000/month | Monthly Staff |
| Maria van Wyk | Permanent | General Worker | R5,200/month | Monthly Staff |
| Thabo Nkosi | Seasonal | Crop Picker | R25.42/hr (NMWA) | Weekly Casual |
| Nomsa Zulu | Seasonal | Crop Picker | R25.42/hr (NMWA) | Weekly Casual |
| Bongani Khumalo | Seasonal | Crop Picker | R25.42/hr (NMWA) | Weekly Casual |
| Pieter Botha | Permanent | Supervisor | R9,500/month | Monthly Staff |
| Ayanda Cele | Casual | Day Worker | R220/day | Weekly Casual |
| Lindiwe Mokoena | Casual | Day Worker | R220/day | Weekly Casual |

### Pay Groups (3)
- **Monthly Staff**: 1st of month, 8 employees (permanent)
- **Weekly Casual**: Friday, seasonal + casual workers
- **Bi-weekly Seasonal**: Bi-weekly Friday (inactive — for reference)

### Pay Structures (4)
- **Monthly Salaried**: fixed monthly amount
- **Hourly NMWA**: R25.42/hr, overtime 1.5×, Sunday 2.0×
- **Daily Rate**: R220/day, no overtime, cash disbursement
- **Piecework Grape**: R2.80/kg, 50kg guaranteed minimum per day

### Seeded Leave Balances (per active employee)
- Annual leave: ~8–15 days remaining (based on service length)
- Sick leave: 28–30 days (36-month cycle)
- Family responsibility: 3 days (full)

### Leave Requests (5 records)
| Employee | Type | Status | Duration |
|---|---|---|---|
| Sipho Dlamini | Annual | Approved | 5 days |
| Maria van Wyk | Sick | Approved | 2 days |
| Thabo Nkosi | Annual | Pending | 3 days |
| Pieter Botha | Annual | Rejected | 10 days (rejected: peak season) |
| Nomsa Zulu | Family | Approved | 1 day |

### Completed Pay Runs (3)
- **March 2026** — Monthly Staff + Weekly Casual — status: disbursed
- **April 2026** — Monthly Staff + Weekly Casual — status: disbursed
- **May 2026 (current)** — Monthly Staff — status: calculated / pending approval

### Payslips
- 8 payslips for March 2026 + 8 for April 2026 = 16 seeded payslips
- Each includes: basic wage, UIF (1%), PAYE where applicable, housing deduction (Sipho), net pay

### Deduction Rules (5)
| Code | Label | Type | Basis | Value |
|---|---|---|---|---|
| UIF_EE | UIF Employee | Statutory | % | 1.0% |
| UIF_ER | UIF Employer | Statutory | % | 1.0% |
| PAYE | Income Tax PAYE | Statutory | % | Bracket-based |
| HOUSING | Housing Deduction | Benefit | ZAR | R800/month (Sipho) |
| LOAN_01 | Staff Loan | Voluntary | ZAR | R500/month (Pieter) |

### Compliance Alerts (3)
- `NMWA_BREACH` — critical: Ayanda Cele daily rate R220 = R27.50/hr (>8hr day → review)
- `CONTRACT_EXPIRED` — warning: Bongani Khumalo seasonal contract expired
- `UIF_MISSING_BANK` — info: Lindiwe Mokoena missing bank details

### Incidents (2)
- Pieter Botha — disciplinary — resolved (verbal warning issued)
- Bongani Khumalo — grievance — open

---

## Routes

Add to `app_routes.dart`:
```dart
static const String payrollHub = '/payroll';
static const String payrollEmployees = '/payroll/employees';
static const String payrollEmployeeDetail = '/payroll/employees/:id';
static const String payrollAddEmployee = '/payroll/employees/add';
static const String payrollContracts = '/payroll/contracts';
static const String payrollRoster = '/payroll/roster';
static const String payrollAttendance = '/payroll/attendance';
static const String payrollPayStructures = '/payroll/pay-structures';
static const String payrollPayRuns = '/payroll/pay-runs';
static const String payrollPayslips = '/payroll/payslips';
static const String payrollLeave = '/payroll/leave';
static const String payrollDeductions = '/payroll/deductions';
static const String payrollPayGroups = '/payroll/pay-groups';
static const String payrollCompliance = '/payroll/compliance';
static const String payrollDisbursements = '/payroll/disbursements';
static const String payrollCommunications = '/payroll/communications';
static const String payrollReports = '/payroll/reports';
static const String payrollAuditLog = '/payroll/audit';
static const String payrollIncidents = '/payroll/incidents';
```

The payroll hub route must be guarded (authenticated users only — already covered by app_router.dart redirect logic). Payroll Manager role required for pay runs, approvals, deduction management. Read-only access for Auditor role.

---

## Development Phases

### Phase 1 — Foundation (MVP) · ~4 weeks

**Goal:** Working end-to-end payroll cycle with mock data — hire worker, log attendance, run payroll, view payslip.

**Deliverables:**
- [ ] All 19 data models
- [ ] `PayrollDataSource` abstract interface (42 methods)
- [ ] `PayrollMockDataSource` — all 8 employees + 3 pay runs + 16 payslips seeded
- [ ] `PayrollRemoteDataSource` stub
- [ ] `PayrollRepository` wired to interface
- [ ] `payroll_providers.dart` — ~40 providers
- [ ] Add `payroll` to Feature Migration Status table in architecture.md
- [ ] **Screens (Phase 1 — 22 screens):**
  - `payroll_hub_screen.dart`
  - `employees/employee_list_screen.dart`
  - `employees/employee_detail_screen.dart`
  - `employees/add_edit_employee_screen.dart`
  - `contracts/contract_list_screen.dart`
  - `contracts/contract_detail_screen.dart`
  - `pay_structures/pay_structures_screen.dart`
  - `pay_structures/add_edit_pay_structure_screen.dart`
  - `pay_groups/pay_groups_screen.dart`
  - `pay_groups/add_edit_pay_group_screen.dart`
  - `attendance/attendance_log_screen.dart`
  - `attendance/clock_in_screen.dart`
  - `pay_runs/pay_run_list_screen.dart`
  - `pay_runs/run_payroll_screen.dart`
  - `pay_runs/pay_run_detail_screen.dart`
  - `payslips/payslip_list_screen.dart`
  - `payslips/payslip_detail_screen.dart`
  - `leave/leave_dashboard_screen.dart`
  - `leave/leave_request_screen.dart`
  - `leave/leave_approval_screen.dart`
  - `leave/leave_balance_screen.dart`
  - `deductions/deductions_screen.dart`
  - `deductions/add_edit_deduction_screen.dart`

### Phase 2 — Compliance, Approvals & Disbursements · ~3 weeks

**Goal:** Full SA compliance engine, multi-step approvals, disbursement tracking, reports.

**Deliverables:**
- [ ] NMWA enforcement in `calculatePayRun()` — prevent net < minimum
- [ ] UIF auto-calculation (1% EE + 1% ER, capped at UIF threshold)
- [ ] PAYE bracket engine (2026/27 SARS tables built into mock)
- [ ] COIDA contribution tracking
- [ ] Multi-signatory payroll approval flow
- [ ] Compliance alerts auto-generated on pay run calculation
- [ ] **Screens (Phase 2 — 12 screens):**
  - `roster/roster_screen.dart`
  - `roster/add_shift_screen.dart`
  - `roster/task_sheet_screen.dart`
  - `attendance/attendance_exceptions_screen.dart`
  - `pay_runs/payroll_approval_screen.dart`
  - `compliance/compliance_dashboard_screen.dart`
  - `compliance/uif_returns_screen.dart`
  - `compliance/paye_screen.dart`
  - `compliance/coida_screen.dart`
  - `disbursements/disbursement_screen.dart`
  - `disbursements/payment_history_screen.dart`
  - `reports/payroll_reports_screen.dart`
  - `incidents/incident_list_screen.dart`
  - `incidents/incident_detail_screen.dart`
  - `incidents/add_incident_screen.dart`

### Phase 3 — Advanced Features · ~4 weeks

**Goal:** Piecework tracking, contract e-signing, communication system, self-service, audit trail, multi-language, offline sync.

**Deliverables:**
- [ ] Piecework / yield-based pay calculation in pay run engine
- [ ] Contract template engine + digital signature pad (`flutter_signature_pad`)
- [ ] Bulk CSV/Excel employee import
- [ ] SMS/WhatsApp message delivery simulation (mock → real via API)
- [ ] Multi-language payslip labels (Zulu, Xhosa, Afrikaans, Sesotho)
- [ ] Statutory report exports: UI-19 (UIF), EMP201 (SARS PAYE), IRP5 PDF
- [ ] Audit log full UI
- [ ] **Screens (Phase 3 — 10 screens):**
  - `employees/employee_import_screen.dart`
  - `contracts/generate_contract_screen.dart`
  - `contracts/contract_sign_screen.dart`
  - `communications/communications_screen.dart`
  - `communications/compose_message_screen.dart`
  - `audit/audit_log_screen.dart`

---

## SA Statutory Rates (2026 — embedded in mock data source)

| Item | Rate | Notes |
|---|---|---|
| NMWA farm workers | R25.42/hr | Effective Mar 2025; update engine auto-checks |
| UIF contribution | 1% EE + 1% ER | Capped at monthly remuneration R17,747.46 |
| PAYE threshold | R95,750/year | Below = no PAYE for 2025/26 |
| PAYE 18% bracket | Up to R237,100 | After rebate (R17,235 primary) |
| COIDA rate | ~0.8–1.2% | Industry class dependent |
| Annual leave entitlement | 15 days/year (21 days cycle) | BCEA s.20 |
| Sick leave | 30 days per 36-month cycle | BCEA s.22 |
| Maternity leave | 4 consecutive months | BCEA s.25 — unpaid; UIF maternity benefits |
| Family responsibility | 3 days/year | BCEA s.27 |
| Overtime rate | 1.5× normal | BCEA s.10; > 45 hrs/week |
| Sunday rate | 2.0× normal | BCEA s.16 |
| Public holiday rate | 2.0× normal | If worked; BCEA s.18 |

---

## Key Computation Rules (Payroll Engine)

1. **NMWA check**: `netEarnings / hoursWorked >= nmwaHourlyRate` — if breached, fire `NMWA_BREACH` alert; block approval
2. **UIF cap**: `uifContribution = min(grossPay, 17747.46) * 0.01` — employer matches
3. **PAYE**: only for employees earning above annual threshold; use SARS brackets + rebates
4. **In-kind benefits**: housing + food values added to gross for NMWA check, then deducted back as named lines; shown explicitly on payslip
5. **Overtime auto-flag**: if `hoursWorked > 9` in a day or `> 45` in a week; apply 1.5× for excess
6. **Max deduction cap**: total deductions must not reduce net below 25% of gross (BCEA protection)
7. **Leave accrual**: `accrualDaysPerYear / 12` per completed month; posted monthly
8. **Retroactive rate change**: if NMWA rate increases mid-period, engine re-runs backpay calculation and raises `BACKPAY_REQUIRED` alert

---

## Architecture.md Update Required

Add `payroll` row to Feature Migration Status table when Phase 1 data layer is complete:

| Feature | Interface | Mock source | Remote stub | pubspec cleaned |
|---|---|---|---|---|
| payroll | ❌ | ❌ | ❌ | ✅ (no assets needed) |

Update to ✅ per item as each is implemented.

---

## Testing Plan

| Test file | What it covers |
|---|---|
| `test/payroll/models/payroll_employee_test.dart` | Model construction, computed fields |
| `test/payroll/models/payslip_test.dart` | Deduction line totals, net pay math |
| `test/payroll/data/payroll_repository_test.dart` | Interface compliance, mock data integrity |
| `test/payroll/providers/pay_run_providers_test.dart` | NMWA breach detection, UIF calc, PAYE bracket |
| `test/payroll/providers/leave_providers_test.dart` | Accrual calculation, balance deduction |
| `test/payroll/compliance_engine_test.dart` | All 8 compliance rules — edge cases |

---

## Integration Points (Backend — when `useMockData = false`)

| Endpoint group | Method | Path example |
|---|---|---|
| Employees | GET/POST/PUT | `/api/payroll/employees` |
| Contracts | GET/POST | `/api/payroll/contracts` |
| Pay runs | GET/POST | `/api/payroll/pay-runs` |
| Payslips | GET | `/api/payroll/payslips` |
| Leave | GET/POST/PUT | `/api/payroll/leave` |
| Attendance | GET/POST | `/api/payroll/attendance` |
| Deductions | GET/POST/PUT | `/api/payroll/deductions` |
| Compliance | GET | `/api/payroll/compliance/alerts` |
| Disbursements | GET/POST | `/api/payroll/disbursements` |
| Audit | GET | `/api/payroll/audit-log` |
| UIF export | GET | `/api/payroll/exports/uif-ui19` |
| PAYE export | GET | `/api/payroll/exports/emp201` |
| IRP5 | GET | `/api/payroll/exports/irp5/:employeeId` |

All endpoints consume/return the same typed model shapes used in Flutter — no DTO mapping needed.

---

# PART 3 — Post-Audit Execution Roadmap

> **Audit date:** 21 May 2026
> **Current state:** Phase 1 + 2 screens built. Data layer has critical structural gaps.
> **Rule:** Each sprint must pass its checklist completely before the next sprint begins.
> **No design changes. No new screens beyond the 44 in the screen inventory.**

---

## Sprint 0 — Baseline Fix (Data Layer Foundation)
**Goal:** Every existing screen has a correct, non-crashing data contract.
**Unblocks:** All sprints below.

### 0-A · Update NMWA rate constant
- [ ] `lib/features/payroll/services/payroll_engine.dart` — change `nmwaHourly` from `25.42` to the gazetted 2026 rate
- [ ] `lib/features/payroll/data/payroll_mock_data_source.dart` — update `_nmwaHourly` field to match
- [ ] Update `SaStatutory` rate table comment to cite the correct Gazette reference

### 0-B · Add DELETE / TERMINATE / DEACTIVATE to the abstract interface
Add the following method signatures to `PayrollDataSource`:

| Method | Type | SA retention rule |
|---|---|---|
| `terminateEmployee(String id, DateTime termDate, String reason)` | Soft-delete | 3-year BCEA s31 retention |
| `voidContract(String id, String reason)` | Soft-delete → `terminated` | Retain all versions |
| `deleteShift(String id)` | Hard-delete | Roster planning record only |
| `deleteTaskAssignment(String id)` | Hard-delete | Roster planning record only |
| `deactivateDeductionRule(String id)` | Soft-delete → `isActive=false` | Retain for audit |
| `deletePieceworkLog(String id, String correctionReason)` | Hard-delete + audit entry | Log correction |
| `deleteLeaveRequest(String id)` | Hard-delete (admin only) | Audit-logged |
| `deleteIncident(String id)` | Soft-delete | COIDA defense record |
| `deactivatePayGroup(String id)` | Soft-delete → `isActive=false` | Retain pay run history |
| `getEmployerConfig()` | Read | New |
| `updateEmployerConfig(EmployerConfig config)` | Write | New |

- [ ] Add all 11 method signatures to `payroll_data_source.dart`
- [ ] Implement all 11 in `payroll_mock_data_source.dart` (in-memory list manipulation)
- [ ] Add all 11 stubs (`_ni()`) to `payroll_remote_data_source.dart`
- [ ] Add all 11 proxy methods to `payroll_repository.dart`

### 0-C · Wire delete actions to Riverpod notifiers
- [ ] `payroll_action_providers.dart` — add `terminate()` to `EmployeeNotifier`
- [ ] `payroll_action_providers.dart` — add `void()` to `ContractNotifier`
- [ ] `payroll_action_providers.dart` — add `delete()` to `ShiftNotifier`
- [ ] `payroll_action_providers.dart` — add `delete()` to a new `TaskAssignmentNotifier`
- [ ] `payroll_action_providers.dart` — add `deactivate()` to `DeductionNotifier`
- [ ] `payroll_action_providers.dart` — add `deleteLog()` to a new `PieceworkNotifier`
- [ ] `payroll_action_providers.dart` — add `delete()` to `LeaveNotifier`
- [ ] `payroll_action_providers.dart` — add `deactivate()` to `PayGroupNotifier`
- [ ] Add `EmployerConfigNotifier` with `update()` method
- [ ] All notifiers must call `ref.invalidate` on the affected provider after mutation

### 0-D · Seed missing runtime data
- [ ] `payroll_mock_data_source.dart` — implement `_seedShifts()` (min 14 records — 2 weeks, 8 employees)
- [ ] `payroll_mock_data_source.dart` — implement `_seedTaskAssignments()` (min 10 records across 3 crop activities)
- [ ] `payroll_mock_data_source.dart` — implement `_seedAttendanceRecords()` (4 weeks × 5 days × 8 employees = 160 records; include 5 absences, 3 late)
- [ ] `payroll_mock_data_source.dart` — implement `_seedPieceworkLogs()` (min 20 records for Thabo, Nomsa, Bongani — grape picking, apple picking)
- [ ] `payroll_mock_data_source.dart` — implement `_seedPayslips()` separately from pay run calculation (16 records: March + April 2026, all 8 employees)
- [ ] `payroll_mock_data_source.dart` — implement `_seedEmployerConfig()` returning a hardcoded `EmployerConfig` with farm name, PAYE ref, UIF ref
- [ ] Add all 6 seed calls to `_seed()` method body

### 0-E · Verify Sprint 0 — smoke test
- [ ] Run `flutter analyze` — zero errors
- [ ] Launch app in mock mode — roster board shows shifts, attendance log shows records, payslip detail opens for seeded payslips
- [ ] Run `flutter test test/payroll/` — all pass

---

## Sprint 1 — Engine Completeness (SA Statutory)
**Goal:** The payroll engine produces legally correct figures for all wage types.
**Unblocks:** Sprint 2 (compliance screens), Sprint 4 (pay run approval).
**Depends on:** Sprint 0 complete.

### 1-A · BCEA Section 34 — net pay floor enforcement
- [ ] `payroll_engine.dart` — after applying all deductions, check: `netPay >= SaStatutory.nmwaMonthly` (or `nmwaHourly × hoursWorked` for hourly/daily)
- [ ] If breached: fire `ComplianceAlert` with code `DEDUCTION_FLOOR_BREACH`, severity `critical`
- [ ] Block `approvePayRun` until all `DEDUCTION_FLOOR_BREACH` alerts on that run are resolved

### 1-B · SDL (Skills Development Levy)
- [ ] `payroll_engine.dart` — add `SaStatutory.sdlRate = 0.01` constant
- [ ] `payroll_engine.dart` — add `SaStatutory.sdlAnnualThreshold = 500000.0` constant
- [ ] `calculatePayRun()` — compute `sdlContribution = totalGrossPayroll × 0.01` when annual payroll > threshold; attach as employer line on pay run summary (not on individual payslip)
- [ ] `payroll_mock_data_source.dart` — add `dr_sdl` deduction rule (employer, statutory, 1%)

### 1-C · ETI (Employment Tax Incentive)
- [ ] `payroll_engine.dart` — add `computeEti(PayrollEmployee emp, double monthlySalary, int monthOfEmployment)` method
- [ ] Rules: employee age 18–29, `monthlySalary` between `R2,000` and `R6,500`, employer not in debt with SARS
- [ ] ETI = `R1,500/month` in months 1–12; `R750/month` in months 13–24; `R0` after
- [ ] Reduce employer PAYE liability in pay run summary by total ETI across qualifying employees
- [ ] Fire `ETI_QUALIFYING_EMPLOYEE` info alert for each qualifying employee on first calculation

### 1-D · COIDA contribution calculation
- [ ] `payroll_engine.dart` — add `computeCoida(double annualEarnings, double riskRate)` method
- [ ] `SaStatutory` — add `coidaDefaultRate = 0.0125` (farming default 1.25%)
- [ ] `calculatePayRun()` — compute each employee's annualised COIDA contribution; attach to pay run summary
- [ ] `coida_screen.dart` — remove hardcoded display; bind to engine output via provider

### 1-E · Verify Sprint 1 — engine unit tests
- [ ] `test/payroll/compliance_engine_test.dart` — add test: deduction floor breach fires correct alert
- [ ] `test/payroll/compliance_engine_test.dart` — add test: SDL computed only when payroll > threshold
- [ ] `test/payroll/compliance_engine_test.dart` — add test: ETI reduces PAYE by correct amount in month 6 vs month 14
- [ ] `test/payroll/compliance_engine_test.dart` — add test: COIDA computed at 1.25% of annual earnings
- [ ] Run `flutter test test/payroll/` — all pass

---

## Sprint 2 — Screen-Level Bug Fixes
**Goal:** Every existing screen shows correct, consistent data. Zero duplicate logic.
**Depends on:** Sprint 0 complete.

### 2-A · Fix PAYE compliance screen bracket bug
- [ ] `lib/features/payroll/screens/compliance/paye_screen.dart` — **delete** the local `_calcPaye()` function and local `_brackets` list entirely
- [ ] Replace with a call to `SaStatutory.computeMonthlyPaye(annualTaxableIncome)` from `payroll_engine.dart`
- [ ] The screen's displayed PAYE figures must now match payslip figures exactly

### 2-B · Fix employee import screen (functional stub)
- [ ] Add `file_picker: ^6.0.0` to `pubspec.yaml` if not already present
- [ ] `employee_import_screen.dart` — replace hardcoded preview rows with:
  - `FilePicker.platform.pickFiles(allowedExtensions: ['csv'])` call on button press
  - CSV parse using `dart:convert` line-split + comma-split (no external CSV package needed for MVP)
  - Validate each row: required fields (name, ID number, engagement type, pay group)
  - Show parsed preview table with error rows highlighted red
  - "Confirm Import" button calls `ref.read(employeeNotifierProvider.notifier).addEmployee()` for each valid row
  - Show success/failure summary toast after import

### 2-C · Employer config CRUD wired to screen
- [ ] Add `EmployerConfigScreen` route if it doesn't exist, or locate where employer config is currently displayed
- [ ] Bind all employer config fields to `employerConfigProvider` (reads from seeded data)
- [ ] "Save" action calls `EmployerConfigNotifier.update()` (wired in Sprint 0-C)

### 2-D · UIF returns screen — add "mark as filed" action
- [ ] `uif_returns_screen.dart` — add a `FiledStatus` enum: `notFiled | filed | exported`
- [ ] Add "Export UI-19" button that generates a CSV in the correct UI-19 column format
- [ ] Add "Mark as Filed" button that logs an audit entry: `action=export, entityType=uif_return`

### 2-E · Attendance exceptions — add "resolve" action
- [ ] `attendance_exceptions_screen.dart` — each exception row needs a "Resolve" button
- [ ] Tapping opens a bottom sheet: choose `absent_approved | late_excused | override_hours`
- [ ] Calls `AttendanceNotifier.updateAttendanceRecord()` with corrected status and `supervisorOverride=true`

### 2-F · Verify Sprint 2
- [ ] PAYE screen shows same figure as payslip for same employee/period
- [ ] Import screen accepts a test CSV file and adds employee to list
- [ ] `flutter analyze` — zero errors

---

## Sprint 3 — Roster & Attendance Full Flow
**Goal:** Roster → attendance → piecework → pay run produces non-zero payslips for all wage types.
**Depends on:** Sprint 0-D (seeded data), Sprint 1 (engine complete).

### 3-A · Roster board interactions
- [ ] `roster_screen.dart` — each shift card must have: "Edit" (calls `ShiftNotifier.update()`), "Delete" (calls `ShiftNotifier.delete()` added in Sprint 0-C), "Assign Employee" dropdown
- [ ] `add_shift_screen.dart` — on save, calls `ShiftNotifier.add()` and immediately invalidates `shiftsProvider`

### 3-B · Clock-in / clock-out full cycle
- [ ] `clock_in_screen.dart` — confirm clock-out path: if employee already has an open `AttendanceRecord` (no `clockOut`), show "Clock Out" button instead of "Clock In"
- [ ] `AttendanceNotifier.clockOut()` — sets `clockOut` timestamp, computes `hoursWorked = clockOut - clockIn` in hours (decimal), updates record

### 3-C · Piecework log entry screen
- [ ] Verify `add_piecework_log` screen exists; if it's a stub, wire it:
  - Fields: employee picker, shift picker, activity code, units (numeric), auto-show rate and computed gross
  - On save: calls `PieceworkNotifier.addLog()` (new notifier from Sprint 0-C)
  - Adds audit log entry after save

### 3-D · Pay run calculation uses seeded attendance + piecework
- [ ] `calculatePayRun()` in mock — for each employee in pay group:
  - If `wageType == hourly`: sum `hoursWorked` from `AttendanceRecord` in period; apply overtime rules
  - If `wageType == daily`: count `present` days in period × `baseRate`
  - If `wageType == piecework`: sum `grossEarning` from `PieceworkLog` in period; apply NMWA floor top-up
  - If `wageType == monthly`: use `grossMonthlySalary` directly
- [ ] Resulting payslip `basicWage` must be > 0 for hourly/daily/piecework employees when seeded data covers the period

### 3-E · Verify Sprint 3 — end-to-end flow
- [ ] Manually trace: create shift → clock in employee → add piecework log → run payroll → verify payslip shows correct gross
- [ ] `test/payroll/providers/pay_run_providers_test.dart` — add test: piecework employee earns correct gross from seeded logs

---

## Sprint 4 — Compliance Exports & Filing
**Goal:** SARS/UIF/COIDA outputs are exportable in the correct formats.
**Depends on:** Sprint 1 complete, Sprint 3 complete.

### 4-A · UIF UI-19 export format
- [ ] Create `lib/features/payroll/services/uif_export_service.dart`
- [ ] Method: `generateUi19Csv(List<Payslip> payslips, EmployerConfig config) → String`
- [ ] Column order per UIF e-Filing spec: employer ref, employee ID, name, period, gross, UIF deducted, employer UIF
- [ ] Wire to "Export UI-19" button added in Sprint 2-D
- [ ] Use `path_provider` + `dart:io` to save CSV to app documents directory; show share dialog

### 4-B · EMP201 summary export
- [ ] Create `lib/features/payroll/services/emp201_export_service.dart`
- [ ] Method: `generateEmp201(PayRun payRun, EmployerConfig config) → Map<String, dynamic>`
- [ ] Fields: period, total PAYE, total UIF (EE+ER), total SDL; formatted for EMP201 submission
- [ ] Wire to a "Download EMP201" button on `paye_screen.dart`

### 4-C · IRP5 PDF completeness audit
- [ ] Read `irp5_generator.dart` fully; verify all required SARS IRP5 codes are populated:
  - 3601 (salary), 3605 (annual payment), 3713 (use of motor vehicle), 3810 (housing), 4001 (PAYE), 4141 (UIF EE)
- [ ] Add any missing codes; for codes not applicable to this module, add `0.00` placeholder
- [ ] Test IRP5 PDF generation for Sipho Dlamini (has housing benefit) — verify correct codes appear

### 4-D · Verify Sprint 4
- [ ] Export a UIF UI-19 CSV — open in Excel; verify correct column format
- [ ] Generate IRP5 PDF for one employee — verify no missing fields

---

## Sprint 5 — Leave Accrual Engine
**Goal:** Leave balances auto-accrue and payslip leave snapshots are accurate.
**Depends on:** Sprint 0 complete.

### 5-A · Monthly accrual calculation
- [ ] `payroll_engine.dart` — add `accrueLeave(PayrollEmployee emp, LeaveType type, int completedMonths) → double`
- [ ] Formula: `type.accrualDaysPerYear / 12 × completedMonths` capped at `type.maxCarryOver`
- [ ] BCEA s20: 1 day per 17 days worked (hourly/casual workers) — add alternate formula for non-monthly employees

### 5-B · Run accrual on pay run close
- [ ] `approvePayRun()` in mock — for each employee in run, call `accrueLeave()` and `updateLeaveBalance()`
- [ ] Trigger `ref.invalidate(leaveBalancesProvider(employeeId))` for each affected employee

### 5-C · Payslip leave balance snapshot
- [ ] `calculatePayRun()` — when building `Payslip`, populate `annualLeaveBalance` and `sickLeaveBalance` from current `LeaveBalance` records
- [ ] These values must appear on the payslip PDF

### 5-D · Verify Sprint 5
- [ ] Run payroll for Monthly Staff — after approval, check Sipho Dlamini's annual leave balance incremented by `15/12 = 1.25 days`
- [ ] Open payslip PDF — verify leave balances section is populated

---

## Sprint 6 — Garnishee Orders & Advanced Deductions
**Goal:** EAO/garnishee orders modeled; deduction cap enforced correctly.
**Depends on:** Sprint 1 complete.

### 6-A · Emolument Attachment Order model
- [ ] Add `GarnisheeOrder` model: `id`, `employeeId`, `courtOrderRef`, `creditorName`, `monthlyDeductionAmount`, `totalOwed`, `amountDeducted`, `status` (`active | satisfied | suspended`)
- [ ] Add `getGarnisheeOrders(String employeeId)` and `addGarnisheeOrder()` to `PayrollDataSource`
- [ ] Add `DeductionType.garnishee` to the `DeductionType` enum
- [ ] Engine: garnishee deductions applied after statutory (UIF, PAYE); total garnishee capped at 25% of net post-statutory

### 6-B · Deduction cap validation hardening
- [ ] `payroll_engine.dart` — after applying all voluntary deductions, assert: `voluntaryDeductions <= grossPay * 0.25`
- [ ] If cap exceeded: reduce the last-applied voluntary deduction to bring net to the floor; fire `DEDUCTION_CAP_EXCEEDED` warning alert
- [ ] This rule must also run for garnishee orders

---

## Sprint 7 — Phase 3 Features (Communications & Audit)
**Goal:** Communications system functional, audit log searchable.
**Depends on:** Sprint 0 complete.

### 7-A · Communications compose screen
- [ ] `compose_message_screen.dart` — recipient picker (all employees, by pay group, by name)
- [ ] Template picker: `PAYSLIP_READY`, `LEAVE_APPROVED`, `WAGE_INCREASE_NOTICE`, `CONTRACT_RENEWAL`, `CUSTOM`
- [ ] On send: calls `sendCommunication()` on data source; adds entry to `_communications` list; fires `ref.invalidate(communicationLogsProvider)`

### 7-B · Audit log filters
- [ ] `audit_log_screen.dart` — add filter bar: by entity type, by actor, by date range
- [ ] Wire to `auditLogProvider(AuditFilter filter)` — add filter model if not present
- [ ] Each row shows: timestamp, actor name, entity type, action, before/after summary (collapsed by default)

### 7-C · Contract e-sign screen
- [ ] `contract_sign_screen.dart` — verify `flutter_signature_pad` or equivalent is in `pubspec.yaml`
- [ ] On sign: capture signature as PNG bytes; embed in contract PDF via `payslip_pdf_generator` pattern; update contract `status → signed`, set `signedAt = DateTime.now()`

---

## Sprint 8 — Backend Wiring (Remote Data Source)
**Goal:** Flip `useMockData = false`; all screens work against the real API.
**Depends on:** Sprints 0–7 complete. Backend API deployed.

### 8-A · Implement `PayrollRemoteDataSource`
- [ ] Replace every `_ni()` with a `Dio` call to the correct endpoint from the Integration Points table
- [ ] All delete/terminate methods from Sprint 0 must have corresponding `DELETE /api/payroll/...` calls
- [ ] Request/response use the same typed Dart models — no separate DTO layer

### 8-B · Error handling boundary
- [ ] Wrap every `Dio` call in `try/catch`; map `DioException.type` to a `PayrollError` sealed class: `network | notFound | serverError | unauthorized`
- [ ] Providers surface `PayrollError` via `AsyncError` state — screens already handle `AsyncError` if written to the riverpod pattern

### 8-C · Offline sync stub
- [ ] Add `OfflineSyncService` with `queueMutation(PayrollMutation m)` and `flushQueue()` methods
- [ ] `PayrollRemoteDataSource` on `DioException.connectionTimeout` → calls `OfflineSyncService.queueMutation()`
- [ ] `flushQueue()` called on `AppLifecycleState.resumed` when connectivity restored

---

## Full Task Dependency Graph

```
Sprint 0  ──────────────────────────────────────────────────────────►
           └── Sprint 1 (engine)  ──────────────────────────────────►
                └── Sprint 4 (exports)
           └── Sprint 2 (screen fixes) ─────────────────────────────►
           └── Sprint 3 (roster flow)  ──────────────────────────────►
                └── Sprint 4 (exports)
           └── Sprint 5 (leave accrual)
           └── Sprint 6 (garnishee)  ──── Sprint 1 required ────────►
           └── Sprint 7 (comms/audit)
Sprint 7 + Sprint 5 + Sprint 4 ──────────────────────────────────────►
Sprint 8 (backend wiring)  ◄── ALL sprints 0-7 complete
```

---

## Completion Checklist (Ship Criteria)

Before switching from mock to remote data source, every item below must be ticked:

| # | Item | Sprint |
|---|---|---|
| 1 | NMWA rate is current gazette value | 0-A |
| 2 | `terminateEmployee` exists on all data layers | 0-B |
| 3 | All 4 missing seed categories populated | 0-D |
| 4 | Historical payslips seeded (not compute-dependent) | 0-D |
| 5 | BCEA s34 deduction floor enforced in engine | 1-A |
| 6 | SDL computed on pay run summary | 1-B |
| 7 | ETI reduces employer PAYE for qualifying farm workers | 1-C |
| 8 | COIDA calculation in engine, not just a UI screen | 1-D |
| 9 | PAYE compliance screen uses engine method (no duplicate logic) | 2-A |
| 10 | Employee import screen actually parses and saves CSV | 2-B |
| 11 | Roster → attendance → pay run → payslip produces correct gross for all wage types | 3-D |
| 12 | UI-19 CSV exportable in correct column format | 4-A |
| 13 | IRP5 PDF has all required SARS codes | 4-C |
| 14 | Leave balances accrue on pay run close | 5-B |
| 15 | Payslip PDF shows leave balance snapshot | 5-C |
| 16 | Garnishee order model and 25% cap enforced | 6-A |
| 17 | `flutter analyze` zero warnings | all |
| 18 | `flutter test test/payroll/` 100% pass | all |