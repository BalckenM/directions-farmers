import 'dart:math';

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
import '../services/payroll_engine.dart';

// ─── SA Statutory constants (2025/2026) — kept for seed helper methods ────────
const double _nmwaHourly = 25.42;
const double _uifRate = 0.01;
const double _uifMonthlyCap = 17747.46;
const double _payeThresholdAnnual = 95750.0;
const double _payePrimaryRebate = 17235.0;
const double _payeRate1 = 0.18; // used only in seed _computeDeductions

String _uid() => DateTime.now().microsecondsSinceEpoch.toString() +
    Random().nextInt(99999).toString();

class PayrollMockDataSource implements PayrollDataSource {
  PayrollMockDataSource() {
    _seed();
  }

  // ─── In-memory stores ──────────────────────────────────────────────────────
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
  final List<DeductionRule> _deductionRules = [];
  final List<GarnisheeOrder> _garnisheeOrders = [];
  final List<LeaveType> _leaveTypes = [];
  final List<LeaveBalance> _leaveBalances = [];
  final List<LeaveRequest> _leaveRequests = [];
  final List<PaymentTransaction> _transactions = [];
  final List<ComplianceAlert> _alerts = [];
  final List<AuditLogEntry> _auditLog = [];
  final List<IncidentRecord> _incidents = [];
  final List<CommunicationLog> _communications = [];
  EmployerConfig _employerConfig = EmployerConfig.defaultConfig;

  // ─── Seed ──────────────────────────────────────────────────────────────────
  void _seed() {
    _seedLeaveTypes();
    _seedPayGroups();
    _seedPayStructures();
    _seedDeductionRules();
    _seedEmployees();
    _seedContracts();
    _seedLeaveBalances();
    _seedLeaveRequests();
    _seedShifts();
    _seedTaskAssignments();
    _seedAttendanceRecords();
    _seedPieceworkLogs();
    _seedPayRuns();
    _seedAlerts();
    _seedIncidents();
    _seedTransactions();
    _seedCommunications();
    _seedHistoricalAuditLog();
  }

  void _seedLeaveTypes() {
    _leaveTypes.addAll([
      const LeaveType(
        id: 'lt_annual',
        code: 'ANNUAL',
        name: 'Annual Leave',
        annualEntitlementDays: 15,
        isPaid: true,
        requiresApproval: true,
        colorHex: '#2E7D32',
      ),
      const LeaveType(
        id: 'lt_sick',
        code: 'SICK',
        name: 'Sick Leave',
        annualEntitlementDays: 30,
        isPaid: true,
        requiresApproval: false,
        colorHex: '#F57F17',
        description: '30 days in a 36-month cycle (BCEA)',
      ),
      const LeaveType(
        id: 'lt_maternity',
        code: 'MATERNITY',
        name: 'Maternity Leave',
        annualEntitlementDays: 120,
        isPaid: false,
        requiresApproval: true,
        colorHex: '#9C27B0',
        description: '4 consecutive months — unpaid (BCEA s25)',
      ),
      const LeaveType(
        id: 'lt_family',
        code: 'FAMILY',
        name: 'Family Responsibility',
        annualEntitlementDays: 3,
        isPaid: true,
        requiresApproval: true,
        colorHex: '#1565C0',
        description: '3 days per year (BCEA s27)',
      ),
    ]);
  }

  void _seedPayGroups() {
    _payGroups.addAll([
      PayGroup(
        id: 'pg_monthly',
        name: 'Monthly Staff',
        frequency: PayFrequency.monthly,
        payDayOffset: 25,
        description: 'Permanent salaried employees — paid on 25th',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
      ),
      PayGroup(
        id: 'pg_weekly',
        name: 'Weekly Casual',
        frequency: PayFrequency.weekly,
        payDayOffset: 5, // Friday
        description: 'Casual & seasonal workers — paid weekly on Friday',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
      ),
      PayGroup(
        id: 'pg_biweekly',
        name: 'Bi-weekly Seasonal',
        frequency: PayFrequency.biweekly,
        payDayOffset: 5,
        description: 'Seasonal contract workers — paid every 2nd Friday',
        isActive: false,
        createdAt: DateTime(2024, 1, 1),
      ),
    ]);
  }

  void _seedPayStructures() {
    _payStructures.addAll([
      PayStructure(
        id: 'ps_monthly_salary',
        name: 'Monthly Salaried',
        wageType: WageType.monthlySalary,
        baseRate: 18000,
        nmwaEnforced: true,
        createdAt: DateTime(2024, 1, 1),
      ),
      PayStructure(
        id: 'ps_nmwa_hourly',
        name: 'NMWA Hourly (Farm)',
        wageType: WageType.hourlyRate,
        baseRate: _nmwaHourly,
        nmwaEnforced: true,
        createdAt: DateTime(2024, 1, 1),
      ),
      PayStructure(
        id: 'ps_daily_220',
        name: 'Daily Rate R220',
        wageType: WageType.dailyRate,
        baseRate: 220.0,
        nmwaEnforced: true,
        createdAt: DateTime(2024, 1, 1),
      ),
      PayStructure(
        id: 'ps_piecework_grape',
        name: 'Piecework — Grape Picking',
        wageType: WageType.piecework,
        baseRate: 2.80,
        pieceworkUnit: 'kg',
        pieceworkMinUnitsPerDay: 30,
        nmwaEnforced: true,
        createdAt: DateTime(2024, 1, 1),
      ),
    ]);
  }

  void _seedDeductionRules() {
    _deductionRules.addAll([
      DeductionRule(
        id: 'dr_uif_ee',
        code: 'UIF_EE',
        label: 'UIF (Employee)',
        type: DeductionType.statutory,
        basis: DeductionBasis.percentage,
        value: 1.0,
        cappedAt: _uifMonthlyCap * _uifRate,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
      ),
      DeductionRule(
        id: 'dr_uif_er',
        code: 'UIF_ER',
        label: 'UIF (Employer)',
        type: DeductionType.statutory,
        basis: DeductionBasis.percentage,
        value: 1.0,
        cappedAt: _uifMonthlyCap * _uifRate,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
      ),
      DeductionRule(
        id: 'dr_paye',
        code: 'PAYE',
        label: 'PAYE Income Tax',
        type: DeductionType.statutory,
        basis: DeductionBasis.percentage,
        value: 18.0,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
      ),
      DeductionRule(
        id: 'dr_housing',
        code: 'HOUSING',
        label: 'Housing Benefit Deduction',
        type: DeductionType.benefit,
        basis: DeductionBasis.fixedAmount,
        value: 800.0,
        employeeIds: ['emp_sipho'],
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
      ),
      DeductionRule(
        id: 'dr_loan_pieter',
        code: 'LOAN_01',
        label: 'Personal Loan Repayment',
        type: DeductionType.voluntary,
        basis: DeductionBasis.fixedAmount,
        value: 500.0,
        employeeIds: ['emp_pieter'],
        isActive: true,
        createdAt: DateTime(2024, 3, 1),
      ),
      // SDL — employer-only statutory levy (1% of leviable payroll, if annual payroll > R500k)
      DeductionRule(
        id: 'dr_sdl',
        code: 'SDL_ER',
        label: 'Skills Development Levy (Employer)',
        type: DeductionType.statutory,
        basis: DeductionBasis.percentage,
        value: 1.0, // 1% of gross
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
      ),
    ]);
  }

  void _seedEmployees() {
    final now = DateTime.now();
    _employees.addAll([
      PayrollEmployee(
        id: 'emp_sipho',
        firstName: 'Sipho',
        lastName: 'Dlamini',
        idOrPassportNumber: '9001015001087',
        phone: '+27821234567',
        email: 'sipho.dlamini@farm.co.za',
        address: '12 Farm Cottage, Stellenbosch, 7600',
        nextOfKinName: 'Nomvula Dlamini',
        nextOfKinPhone: '+27829876543',
        status: EmploymentStatus.active,
        engagementType: EngagementType.permanent,
        occupationTitle: 'Farm Foreman',
        payGroupId: 'pg_monthly',
        payStructureId: 'ps_monthly_salary',
        startDate: DateTime(2020, 3, 1),
        bankName: 'Standard Bank',
        bankAccountNumber: '012345678',
        bankBranchCode: '051001',
        disbursementMethod: DisbursementMethod.bank,
        hasHousingBenefit: true,
        housingValuePerMonth: 800.0,
        hasFoodBenefit: false,
        preferredLanguage: 'zu',
        createdAt: DateTime(2020, 3, 1),
        updatedAt: now,
      ),
      PayrollEmployee(
        id: 'emp_maria',
        firstName: 'Maria',
        lastName: 'van Wyk',
        idOrPassportNumber: '8506125002086',
        phone: '+27833456789',
        email: 'maria.vanwyk@farm.co.za',
        address: '5 Vineyard Rd, Paarl, 7646',
        nextOfKinName: 'Johann van Wyk',
        nextOfKinPhone: '+27834567890',
        status: EmploymentStatus.active,
        engagementType: EngagementType.permanent,
        occupationTitle: 'Office Administrator',
        payGroupId: 'pg_monthly',
        payStructureId: 'ps_monthly_salary',
        startDate: DateTime(2019, 7, 15),
        bankName: 'Absa',
        bankAccountNumber: '9876543210',
        bankBranchCode: '632005',
        disbursementMethod: DisbursementMethod.bank,
        hasHousingBenefit: false,
        hasFoodBenefit: false,
        preferredLanguage: 'af',
        createdAt: DateTime(2019, 7, 15),
        updatedAt: now,
      ),
      PayrollEmployee(
        id: 'emp_thabo',
        firstName: 'Thabo',
        lastName: 'Nkosi',
        idOrPassportNumber: '9503075003081',
        phone: '+27844567890',
        address: 'Plot 4, Hex River Valley, 6855',
        nextOfKinName: 'Grace Nkosi',
        nextOfKinPhone: '+27845678901',
        status: EmploymentStatus.active,
        engagementType: EngagementType.seasonal,
        occupationTitle: 'Seasonal Farm Worker',
        payGroupId: 'pg_weekly',
        payStructureId: 'ps_nmwa_hourly',
        startDate: DateTime(2025, 1, 15),
        endDate: DateTime(2025, 6, 30),
        bankName: 'Capitec',
        bankAccountNumber: '1122334455',
        bankBranchCode: '470010',
        disbursementMethod: DisbursementMethod.bank,
        hasHousingBenefit: false,
        hasFoodBenefit: false,
        preferredLanguage: 'xh',
        createdAt: DateTime(2025, 1, 15),
        updatedAt: now,
      ),
      PayrollEmployee(
        id: 'emp_nomsa',
        firstName: 'Nomsa',
        lastName: 'Zulu',
        idOrPassportNumber: '9712250004080',
        phone: '+27856789012',
        address: 'Block C, Farm Labour Housing, Hex River',
        nextOfKinName: 'Baba Zulu',
        nextOfKinPhone: '+27857890123',
        status: EmploymentStatus.active,
        engagementType: EngagementType.seasonal,
        occupationTitle: 'Seasonal Farm Worker',
        payGroupId: 'pg_weekly',
        payStructureId: 'ps_nmwa_hourly',
        startDate: DateTime(2025, 1, 15),
        endDate: DateTime(2025, 6, 30),
        bankName: 'Capitec',
        bankAccountNumber: '2233445566',
        bankBranchCode: '470010',
        disbursementMethod: DisbursementMethod.bank,
        hasHousingBenefit: false,
        hasFoodBenefit: false,
        preferredLanguage: 'zu',
        createdAt: DateTime(2025, 1, 15),
        updatedAt: now,
      ),
      PayrollEmployee(
        id: 'emp_bongani',
        firstName: 'Bongani',
        lastName: 'Khumalo',
        idOrPassportNumber: '9408205005089',
        phone: '+27867890123',
        address: 'Plot 7, Villiersdorp, 7170',
        nextOfKinName: 'Zanele Khumalo',
        nextOfKinPhone: '+27868901234',
        status: EmploymentStatus.active,
        engagementType: EngagementType.seasonal,
        occupationTitle: 'Seasonal Farm Worker',
        payGroupId: 'pg_weekly',
        payStructureId: 'ps_nmwa_hourly',
        startDate: DateTime(2025, 2, 1),
        endDate: DateTime(2025, 7, 31),
        bankName: 'FNB',
        bankAccountNumber: '3344556677',
        bankBranchCode: '250655',
        disbursementMethod: DisbursementMethod.bank,
        hasHousingBenefit: false,
        hasFoodBenefit: false,
        preferredLanguage: 'zu',
        createdAt: DateTime(2025, 2, 1),
        updatedAt: now,
      ),
      PayrollEmployee(
        id: 'emp_pieter',
        firstName: 'Pieter',
        lastName: 'Botha',
        idOrPassportNumber: '7801065006085',
        phone: '+27878901234',
        email: 'pbotha@farm.co.za',
        address: '3 Orchard Lane, Elgin, 7180',
        nextOfKinName: 'Annet Botha',
        nextOfKinPhone: '+27879012345',
        status: EmploymentStatus.active,
        engagementType: EngagementType.permanent,
        occupationTitle: 'Orchard Supervisor',
        payGroupId: 'pg_monthly',
        payStructureId: 'ps_monthly_salary',
        startDate: DateTime(2018, 5, 1),
        bankName: 'Nedbank',
        bankAccountNumber: '4455667788',
        bankBranchCode: '198765',
        disbursementMethod: DisbursementMethod.bank,
        hasHousingBenefit: false,
        hasFoodBenefit: false,
        preferredLanguage: 'af',
        createdAt: DateTime(2018, 5, 1),
        updatedAt: now,
      ),
      PayrollEmployee(
        id: 'emp_ayanda',
        firstName: 'Ayanda',
        lastName: 'Cele',
        idOrPassportNumber: '0001015007081',
        phone: '+27889012345',
        address: 'Lot 9, Grabouw, 7160',
        nextOfKinName: 'Sipho Cele',
        nextOfKinPhone: '+27890123456',
        status: EmploymentStatus.active,
        engagementType: EngagementType.casual,
        occupationTitle: 'Casual Farm Worker',
        payGroupId: 'pg_weekly',
        payStructureId: 'ps_daily_220',
        startDate: DateTime(2025, 3, 1),
        disbursementMethod: DisbursementMethod.cash,
        hasHousingBenefit: false,
        hasFoodBenefit: false,
        preferredLanguage: 'zu',
        createdAt: DateTime(2025, 3, 1),
        updatedAt: now,
      ),
      PayrollEmployee(
        id: 'emp_lindiwe',
        firstName: 'Lindiwe',
        lastName: 'Mokoena',
        idOrPassportNumber: '0205235008084',
        phone: '+27901234567',
        address: 'Block A, Farm Hostel, Ceres, 6835',
        nextOfKinName: 'Thembi Mokoena',
        nextOfKinPhone: '+27902345678',
        status: EmploymentStatus.active,
        engagementType: EngagementType.casual,
        occupationTitle: 'Casual Farm Worker',
        payGroupId: 'pg_weekly',
        payStructureId: 'ps_daily_220',
        startDate: DateTime(2025, 3, 10),
        // ⚠ No bank details — triggers UIF_MISSING_BANK compliance alert
        disbursementMethod: DisbursementMethod.cash,
        hasHousingBenefit: false,
        hasFoodBenefit: false,
        preferredLanguage: 'st',
        createdAt: DateTime(2025, 3, 10),
        updatedAt: now,
      ),
    ]);

    // Override base rate for Sipho and Pieter (different monthly amounts)
    // Their payStructureId both point to ps_monthly_salary (18k) but Pieter
    // is on 9.5k and Maria is on 5.2k — we use a per-employee override
    // stored on the employee (no field yet; handled in calculatePayRun via a
    // lookup map).
  }

  void _seedContracts() {
    _contracts.addAll([
      EmploymentContract(
        id: 'ct_sipho',
        employeeId: 'emp_sipho',
        type: ContractType.permanent,
        status: ContractStatus.signed,
        jobDescription: 'Farm Foreman',
        startDate: DateTime(2020, 3, 1),
        grossMonthlySalary: 18000,
        signedAt: DateTime(2020, 3, 1),
        createdAt: DateTime(2020, 3, 1),
      ),
      EmploymentContract(
        id: 'ct_maria',
        employeeId: 'emp_maria',
        type: ContractType.permanent,
        status: ContractStatus.signed,
        jobDescription: 'Office Administrator',
        startDate: DateTime(2019, 7, 15),
        grossMonthlySalary: 5200,
        signedAt: DateTime(2019, 7, 15),
        createdAt: DateTime(2019, 7, 15),
      ),
      EmploymentContract(
        id: 'ct_thabo',
        employeeId: 'emp_thabo',
        type: ContractType.fixedTerm,
        status: ContractStatus.signed,
        jobDescription: 'Seasonal Farm Worker',
        startDate: DateTime(2025, 1, 15),
        endDate: DateTime(2025, 6, 30),
        grossMonthlySalary: 4415.47, // ~25.42×173.33hrs
        signedAt: DateTime(2025, 1, 15),
        createdAt: DateTime(2025, 1, 15),
      ),
      EmploymentContract(
        id: 'ct_bongani',
        employeeId: 'emp_bongani',
        type: ContractType.fixedTerm,
        status: ContractStatus.expired,
        jobDescription: 'Seasonal Farm Worker',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 7, 31),
        grossMonthlySalary: 4100,
        signedAt: DateTime(2024, 2, 1),
        createdAt: DateTime(2024, 2, 1),
      ),
      EmploymentContract(
        id: 'ct_pieter',
        employeeId: 'emp_pieter',
        type: ContractType.permanent,
        status: ContractStatus.signed,
        jobDescription: 'Orchard Supervisor',
        startDate: DateTime(2018, 5, 1),
        grossMonthlySalary: 9500,
        signedAt: DateTime(2018, 5, 1),
        createdAt: DateTime(2018, 5, 1),
      ),
    ]);
  }

  static const Map<String, double> _empSalaryOverride = {
    'emp_sipho': 18000,
    'emp_maria': 5200,
    'emp_pieter': 9500,
  };

  void _seedLeaveBalances() {
    final now = DateTime(2026, 5, 1);
    for (final emp in _employees.where((e) => e.isActive)) {
      for (final lt in _leaveTypes) {
        double taken = 0;
        double pending = 0;
        if (emp.id == 'emp_sipho' && lt.code == 'ANNUAL') taken = 5;
        if (emp.id == 'emp_maria' && lt.code == 'SICK') taken = 3;
        if (emp.id == 'emp_nomsa' && lt.code == 'ANNUAL') pending = 2;
        _leaveBalances.add(LeaveBalance(
          id: 'lb_${emp.id}_${lt.code}',
          employeeId: emp.id,
          leaveTypeId: lt.id,
          leaveTypeCode: lt.code,
          leaveTypeName: lt.name,
          totalEntitled: lt.annualEntitlementDays,
          taken: taken,
          pending: pending,
          asOfDate: now,
        ));
      }
    }
  }

  void _seedLeaveRequests() {
    _leaveRequests.addAll([
      LeaveRequest(
        id: 'lr_sipho_annual',
        employeeId: 'emp_sipho',
        leaveTypeId: 'lt_annual',
        startDate: DateTime(2026, 4, 7),
        endDate: DateTime(2026, 4, 11),
        daysRequested: 5,
        reason: 'Family holiday',
        status: LeaveStatus.approved,
        reviewedByUserId: 'usr_manager',
        reviewedAt: DateTime(2026, 3, 20),
        submittedAt: DateTime(2026, 3, 18),
      ),
      LeaveRequest(
        id: 'lr_maria_sick',
        employeeId: 'emp_maria',
        leaveTypeId: 'lt_sick',
        startDate: DateTime(2026, 4, 14),
        endDate: DateTime(2026, 4, 16),
        daysRequested: 3,
        reason: 'Flu',
        status: LeaveStatus.approved,
        reviewedByUserId: 'usr_manager',
        reviewedAt: DateTime(2026, 4, 14),
        submittedAt: DateTime(2026, 4, 14),
      ),
      LeaveRequest(
        id: 'lr_thabo_annual',
        employeeId: 'emp_thabo',
        leaveTypeId: 'lt_annual',
        startDate: DateTime(2026, 5, 19),
        endDate: DateTime(2026, 5, 20),
        daysRequested: 2,
        reason: 'Personal',
        status: LeaveStatus.pending,
        submittedAt: DateTime(2026, 5, 2),
      ),
      LeaveRequest(
        id: 'lr_pieter_annual',
        employeeId: 'emp_pieter',
        leaveTypeId: 'lt_annual',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 5),
        daysRequested: 5,
        reason: 'Vacation',
        status: LeaveStatus.rejected,
        reviewedByUserId: 'usr_manager',
        reviewedAt: DateTime(2026, 5, 1),
        rejectionReason: 'Peak harvest period — insufficient cover',
        submittedAt: DateTime(2026, 4, 28),
      ),
      LeaveRequest(
        id: 'lr_nomsa_family',
        employeeId: 'emp_nomsa',
        leaveTypeId: 'lt_family',
        startDate: DateTime(2026, 5, 5),
        endDate: DateTime(2026, 5, 5),
        daysRequested: 1,
        reason: 'Child hospital appointment',
        status: LeaveStatus.approved,
        reviewedByUserId: 'usr_manager',
        reviewedAt: DateTime(2026, 5, 3),
        submittedAt: DateTime(2026, 5, 2),
      ),
    ]);
  }

  void _seedPayRuns() {
    final march = PayRun(
      id: 'pr_mar_2026_monthly',
      payGroupId: 'pg_monthly',
      periodStart: DateTime(2026, 3, 1),
      periodEnd: DateTime(2026, 3, 31),
      payDate: DateTime(2026, 3, 25),
      status: PayRunStatus.disbursed,
      totalGross: 32700,
      totalDeductions: 3480,
      totalNet: 29220,
      employeeCount: 3,
      approvedByUserId: 'usr_manager',
      approvedAt: DateTime(2026, 3, 24),
      disbursedAt: DateTime(2026, 3, 25),
      complianceAlertIds: [],
      lineItems: [],
      createdAt: DateTime(2026, 3, 20),
      updatedAt: DateTime(2026, 3, 25),
    );

    final april = PayRun(
      id: 'pr_apr_2026_monthly',
      payGroupId: 'pg_monthly',
      periodStart: DateTime(2026, 4, 1),
      periodEnd: DateTime(2026, 4, 30),
      payDate: DateTime(2026, 4, 25),
      status: PayRunStatus.disbursed,
      totalGross: 32700,
      totalDeductions: 3480,
      totalNet: 29220,
      employeeCount: 3,
      approvedByUserId: 'usr_manager',
      approvedAt: DateTime(2026, 4, 24),
      disbursedAt: DateTime(2026, 4, 25),
      complianceAlertIds: [],
      lineItems: [],
      createdAt: DateTime(2026, 4, 20),
      updatedAt: DateTime(2026, 4, 25),
    );

    final may = PayRun(
      id: 'pr_may_2026_monthly',
      payGroupId: 'pg_monthly',
      periodStart: DateTime(2026, 5, 1),
      periodEnd: DateTime(2026, 5, 31),
      payDate: DateTime(2026, 5, 25),
      status: PayRunStatus.pendingApproval,
      totalGross: 32700,
      totalDeductions: 3480,
      totalNet: 29220,
      employeeCount: 3,
      complianceAlertIds: ['ca_nmwa_ayanda'],
      lineItems: [],
      createdAt: DateTime(2026, 5, 20),
      updatedAt: DateTime(2026, 5, 20),
    );

    _payRuns.addAll([march, april, may]);

    // Generate payslips for March and April monthly runs
    for (final run in [march, april]) {
      _payslips.addAll(_generatePayslipsForRun(run));
    }
  }

  List<Payslip> _generatePayslipsForRun(PayRun run) {
    final payslips = <Payslip>[];
    final monthlyEmployees = _employees
        .where((e) => e.payGroupId == 'pg_monthly' && e.isActive)
        .toList();

    for (final emp in monthlyEmployees) {
      final gross = _empSalaryOverride[emp.id] ?? 18000.0;
      final deductions = _computeDeductions(emp.id, gross);
      final totalDed = deductions.fold(0.0, (s, d) => s + d.amount);

      payslips.add(Payslip(
        id: 'ps_${run.id}_${emp.id}',
        payRunId: run.id,
        employeeId: emp.id,
        periodStart: run.periodStart,
        periodEnd: run.periodEnd,
        payDate: run.payDate,
        basicWage: gross,
        overtimePay: 0,
        holidayPay: 0,
        inKindHousing: emp.hasHousingBenefit ? (emp.housingValuePerMonth ?? 0) : 0,
        inKindFood: emp.hasFoodBenefit ? (emp.foodValuePerMonth ?? 0) : 0,
        otherEarnings: 0,
        grossPay: gross +
            (emp.hasHousingBenefit ? (emp.housingValuePerMonth ?? 0) : 0) +
            (emp.hasFoodBenefit ? (emp.foodValuePerMonth ?? 0) : 0),
        deductions: deductions,
        totalDeductions: totalDed,
        netPay: gross - totalDed,
        leaveBalanceSnapshot: {},
        payslipNumber:
            '${run.periodStart.year}${run.periodStart.month.toString().padLeft(2, '0')}-${emp.id}',
        createdAt: run.createdAt,
      ));
    }
    return payslips;
  }

  List<PayslipDeductionLine> _computeDeductions(String employeeId, double gross) {
    final lines = <PayslipDeductionLine>[];

    // UIF_EE: 1% capped
    final uifBase = min(gross, _uifMonthlyCap);
    lines.add(PayslipDeductionLine(
      code: 'UIF_EE',
      description: 'UIF (Employee 1%)',
      amount: double.parse((uifBase * _uifRate).toStringAsFixed(2)),
      isStatutory: true,
    ));

    // PAYE: only for those earning above threshold
    final annualGross = gross * 12;
    if (annualGross > _payeThresholdAnnual) {
      final taxableAnnual = annualGross - _payeThresholdAnnual;
      final annualTax = max(0.0, taxableAnnual * _payeRate1 - _payePrimaryRebate);
      final monthlyTax = annualTax / 12;
      if (monthlyTax > 0) {
        lines.add(PayslipDeductionLine(
          code: 'PAYE',
          description: 'PAYE Income Tax',
          amount: double.parse(monthlyTax.toStringAsFixed(2)),
          isStatutory: true,
        ));
      }
    }

    // Voluntary / benefit rules
    for (final rule in _deductionRules.where((r) => r.isActive && !r.isStatutoryGlobal)) {
      if (rule.employeeIds == null || rule.employeeIds!.contains(employeeId)) {
        if (rule.basis == DeductionBasis.fixedAmount) {
          lines.add(PayslipDeductionLine(
            code: rule.code,
            description: rule.label,
            amount: rule.value,
            isStatutory: rule.type == DeductionType.statutory,
          ));
        }
      }
    }

    return lines;
  }

  void _seedAlerts() {
    _alerts.addAll([
      ComplianceAlert(
        id: 'ca_nmwa_ayanda',
        code: 'NMWA_BREACH',
        title: 'NMWA Potential Breach — Ayanda Cele',
        description:
            'Daily rate of R220 equates to R27.50/hr (÷8hrs). This is above NMWA (R25.42/hr). Verify actual hours worked — ensure total hours do not inflate effective hourly rate below NMWA.',
        severity: ComplianceSeverity.warning,
        employeeId: 'emp_ayanda',
        isResolved: false,
        raisedAt: DateTime(2026, 5, 20),
      ),
      ComplianceAlert(
        id: 'ca_contract_bongani',
        code: 'CONTRACT_EXPIRED',
        title: 'Expired Contract — Bongani Khumalo',
        description:
            'Contract ct_bongani expired on 31 July 2024. Employee is still active. A new or renewed contract is required.',
        severity: ComplianceSeverity.critical,
        employeeId: 'emp_bongani',
        isResolved: false,
        raisedAt: DateTime(2024, 8, 1),
      ),
      ComplianceAlert(
        id: 'ca_uif_lindiwe',
        code: 'UIF_MISSING_BANK',
        title: 'Missing Bank Details — Lindiwe Mokoena',
        description:
            'UIF registration requires a bank account number. Lindiwe Mokoena has no bank details on file.',
        severity: ComplianceSeverity.warning,
        employeeId: 'emp_lindiwe',
        isResolved: false,
        raisedAt: DateTime(2026, 3, 15),
      ),
    ]);
  }

  void _seedIncidents() {
    _incidents.addAll([
      IncidentRecord(
        id: 'inc_pieter_disc',
        employeeId: 'emp_pieter',
        type: IncidentType.disciplinary,
        title: 'Unauthorised Absence',
        description: 'Employee absent without prior leave approval on 2026-02-14.',
        incidentDate: DateTime(2026, 2, 14),
        status: IncidentStatus.resolved,
        actionTaken: 'Verbal warning issued. Employee acknowledged.',
        resolvedAt: DateTime(2026, 2, 20),
        resolvedByUserId: 'usr_manager',
        reportedByUserId: 'usr_manager',
        createdAt: DateTime(2026, 2, 15),
      ),
      IncidentRecord(
        id: 'inc_bongani_griev',
        employeeId: 'emp_bongani',
        type: IncidentType.grievance,
        title: 'Dispute over overtime payment',
        description:
            'Employee claims 4 hours overtime on 2026-04-18 were not reflected in payslip.',
        incidentDate: DateTime(2026, 4, 18),
        status: IncidentStatus.underInvestigation,
        reportedByUserId: 'emp_bongani',
        createdAt: DateTime(2026, 4, 22),
      ),
    ]);
  }

  void _seedTransactions() {
    // March 2026 disbursements
    _transactions.addAll([
      PaymentTransaction(
        id: 'tx_mar_sipho',
        payRunId: 'pr_mar_2026_monthly',
        employeeId: 'emp_sipho',
        amount: 16318.58,
        currency: 'ZAR',
        method: 'bank',
        status: TransactionStatus.completed,
        bankName: 'FNB',
        accountNumber: '****1234',
        reference: 'AGRI-MAR26-SIPHO',
        initiatedAt: DateTime(2026, 3, 25, 7, 30),
        completedAt: DateTime(2026, 3, 25, 9, 12),
        createdAt: DateTime(2026, 3, 25),
      ),
      PaymentTransaction(
        id: 'tx_mar_maria',
        payRunId: 'pr_mar_2026_monthly',
        employeeId: 'emp_maria',
        amount: 4985.00,
        currency: 'ZAR',
        method: 'bank',
        status: TransactionStatus.completed,
        bankName: 'ABSA',
        accountNumber: '****5678',
        reference: 'AGRI-MAR26-MARIA',
        initiatedAt: DateTime(2026, 3, 25, 7, 30),
        completedAt: DateTime(2026, 3, 25, 9, 15),
        createdAt: DateTime(2026, 3, 25),
      ),
      PaymentTransaction(
        id: 'tx_mar_pieter',
        payRunId: 'pr_mar_2026_monthly',
        employeeId: 'emp_pieter',
        amount: 8950.25,
        currency: 'ZAR',
        method: 'bank',
        status: TransactionStatus.completed,
        bankName: 'Standard Bank',
        accountNumber: '****9012',
        reference: 'AGRI-MAR26-PIETER',
        initiatedAt: DateTime(2026, 3, 25, 7, 30),
        completedAt: DateTime(2026, 3, 25, 9, 18),
        createdAt: DateTime(2026, 3, 25),
      ),
      // April 2026 disbursements
      PaymentTransaction(
        id: 'tx_apr_sipho',
        payRunId: 'pr_apr_2026_monthly',
        employeeId: 'emp_sipho',
        amount: 16318.58,
        currency: 'ZAR',
        method: 'bank',
        status: TransactionStatus.completed,
        bankName: 'FNB',
        accountNumber: '****1234',
        reference: 'AGRI-APR26-SIPHO',
        initiatedAt: DateTime(2026, 4, 25, 7, 30),
        completedAt: DateTime(2026, 4, 25, 9, 10),
        createdAt: DateTime(2026, 4, 25),
      ),
      PaymentTransaction(
        id: 'tx_apr_maria',
        payRunId: 'pr_apr_2026_monthly',
        employeeId: 'emp_maria',
        amount: 4985.00,
        currency: 'ZAR',
        method: 'bank',
        status: TransactionStatus.completed,
        bankName: 'ABSA',
        accountNumber: '****5678',
        reference: 'AGRI-APR26-MARIA',
        initiatedAt: DateTime(2026, 4, 25, 7, 30),
        completedAt: DateTime(2026, 4, 25, 9, 13),
        createdAt: DateTime(2026, 4, 25),
      ),
      PaymentTransaction(
        id: 'tx_apr_pieter',
        payRunId: 'pr_apr_2026_monthly',
        employeeId: 'emp_pieter',
        amount: 8950.25,
        currency: 'ZAR',
        method: 'bank',
        status: TransactionStatus.completed,
        bankName: 'Standard Bank',
        accountNumber: '****9012',
        reference: 'AGRI-APR26-PIETER',
        initiatedAt: DateTime(2026, 4, 25, 7, 30),
        completedAt: DateTime(2026, 4, 25, 9, 16),
        createdAt: DateTime(2026, 4, 25),
      ),
      // Casual / seasonal weekly payments
      PaymentTransaction(
        id: 'tx_wk1_ayanda',
        payRunId: 'pr_mar_2026_monthly',
        employeeId: 'emp_ayanda',
        amount: 1100.00,
        currency: 'ZAR',
        method: 'cash',
        status: TransactionStatus.completed,
        reference: 'CASH-WK12-AYANDA',
        initiatedAt: DateTime(2026, 3, 21, 8, 0),
        completedAt: DateTime(2026, 3, 21, 8, 5),
        createdAt: DateTime(2026, 3, 21),
      ),
      PaymentTransaction(
        id: 'tx_wk1_thabo',
        payRunId: 'pr_mar_2026_monthly',
        employeeId: 'emp_thabo',
        amount: 950.00,
        currency: 'ZAR',
        method: 'cash',
        status: TransactionStatus.completed,
        reference: 'CASH-WK12-THABO',
        initiatedAt: DateTime(2026, 3, 21, 8, 0),
        completedAt: DateTime(2026, 3, 21, 8, 5),
        createdAt: DateTime(2026, 3, 21),
      ),
      // Failed — Lindiwe has no bank details
      PaymentTransaction(
        id: 'tx_apr_lindiwe_fail',
        payRunId: 'pr_apr_2026_monthly',
        employeeId: 'emp_lindiwe',
        amount: 760.00,
        currency: 'ZAR',
        method: 'bank',
        status: TransactionStatus.failed,
        failureReason: 'No bank account on file — disbursement failed. Please update employee bank details.',
        initiatedAt: DateTime(2026, 4, 25, 7, 30),
        createdAt: DateTime(2026, 4, 25),
      ),
      // Processing — May run not yet disbursed
      PaymentTransaction(
        id: 'tx_may_sipho_proc',
        payRunId: 'pr_may_2026_monthly',
        employeeId: 'emp_sipho',
        amount: 16318.58,
        currency: 'ZAR',
        method: 'bank',
        status: TransactionStatus.processing,
        bankName: 'FNB',
        accountNumber: '****1234',
        reference: 'AGRI-MAY26-SIPHO',
        initiatedAt: DateTime(2026, 5, 25, 7, 30),
        createdAt: DateTime(2026, 5, 25),
      ),
    ]);
  }

  void _seedCommunications() {
    _communications.addAll([
      CommunicationLog(
        id: 'comm_mar_payslips',
        templateCode: 'PAYSLIP_READY',
        subject: 'March 2026 Payslip Available',
        body:
            'Dear [Employee], your payslip for the period 1–31 March 2026 is now available. '
            'Please log in to the 4Directions Farmer app to view and download. '
            'Net pay: [NetPay]. Regards, Farm Management.',
        channel: CommunicationChannel.sms,
        recipientEmployeeIds: ['emp_sipho', 'emp_maria', 'emp_pieter'],
        sentByUserId: 'usr_manager',
        deliveredCount: 3,
        failedCount: 0,
        sentAt: DateTime(2026, 3, 25, 10, 0),
      ),
      CommunicationLog(
        id: 'comm_apr_payslips',
        templateCode: 'PAYSLIP_READY',
        subject: 'April 2026 Payslip Available',
        body:
            'Dear [Employee], your payslip for the period 1–30 April 2026 is now available. '
            'Net pay: [NetPay]. Log in to view. Regards, Farm Management.',
        channel: CommunicationChannel.whatsapp,
        recipientEmployeeIds: ['emp_sipho', 'emp_maria', 'emp_pieter'],
        sentByUserId: 'usr_manager',
        deliveredCount: 2,
        failedCount: 1,
        sentAt: DateTime(2026, 4, 25, 10, 30),
      ),
      CommunicationLog(
        id: 'comm_nmwa_notice',
        templateCode: 'COMPLIANCE_NOTICE',
        subject: 'NMWA Compliance Notice',
        body:
            'Please note that the National Minimum Wage Act (2024 amendment) requires '
            'a minimum of R25.42 per hour for farm workers. All casual and daily-rate '
            'employees must be assessed. Please ensure actual hours are captured accurately.',
        channel: CommunicationChannel.inApp,
        recipientEmployeeIds: [
          'emp_sipho',
          'emp_maria',
          'emp_pieter',
          'emp_thabo',
          'emp_nomsa',
          'emp_bongani',
          'emp_ayanda',
          'emp_lindiwe',
        ],
        sentByUserId: 'usr_manager',
        deliveredCount: 7,
        failedCount: 1,
        sentAt: DateTime(2026, 5, 5, 9, 0),
      ),
      CommunicationLog(
        id: 'comm_leave_sipho',
        templateCode: 'LEAVE_APPROVED',
        subject: 'Leave Request Approved',
        body:
            'Dear Sipho, your annual leave request from 12–16 May 2026 has been approved. '
            'Please make arrangements for your duties during this period. Regards.',
        channel: CommunicationChannel.sms,
        recipientEmployeeIds: ['emp_sipho'],
        sentByUserId: 'usr_manager',
        deliveredCount: 1,
        failedCount: 0,
        sentAt: DateTime(2026, 5, 4, 11, 15),
      ),
      CommunicationLog(
        id: 'comm_leave_pieter_rej',
        templateCode: 'LEAVE_REJECTED',
        subject: 'Leave Request Not Approved',
        body:
            'Dear Pieter, regrettably your annual leave request from 15–19 June 2026 '
            'could not be approved at this time due to peak harvest operations. '
            'Please reapply after 30 June 2026. Regards, Farm Management.',
        channel: CommunicationChannel.sms,
        recipientEmployeeIds: ['emp_pieter'],
        sentByUserId: 'usr_manager',
        deliveredCount: 1,
        failedCount: 0,
        sentAt: DateTime(2026, 5, 2, 14, 30),
      ),
      CommunicationLog(
        id: 'comm_contract_exp',
        templateCode: 'CONTRACT_EXPIRY_REMINDER',
        subject: 'Contract Renewal Required — Bongani Khumalo',
        body:
            'This is a reminder that the employment contract for Bongani Khumalo '
            '(emp_bongani) expired on 31 July 2024. Please arrange contract renewal '
            'or update the employee status accordingly to maintain BCEA compliance.',
        channel: CommunicationChannel.inApp,
        recipientEmployeeIds: ['emp_sipho'],
        sentByUserId: 'usr_system',
        deliveredCount: 1,
        failedCount: 0,
        sentAt: DateTime(2026, 4, 1, 8, 0),
      ),
    ]);
  }

  void _seedHistoricalAuditLog() {
    // Pre-seed historical audit log entries (in addition to dynamic ones generated
    // by create/update operations during _seed() calls via _log()).
    _auditLog.addAll([
      AuditLogEntry(
        id: 'aud_pr_mar_create',
        entityType: 'PayRun',
        entityId: 'pr_mar_2026_monthly',
        action: 'CREATE',
        changedByUserId: 'usr_manager',
        changedByName: 'Farm Manager',
        description: 'March 2026 monthly pay run created',
        afterSnapshot: {'id': 'pr_mar_2026_monthly', 'status': 'calculated', 'totalGross': 32700},
        occurredAt: DateTime(2026, 3, 20, 9, 0),
      ),
      AuditLogEntry(
        id: 'aud_pr_mar_approve',
        entityType: 'PayRun',
        entityId: 'pr_mar_2026_monthly',
        action: 'APPROVE',
        changedByUserId: 'usr_manager',
        changedByName: 'Farm Manager',
        description: 'March 2026 pay run approved for disbursement',
        beforeSnapshot: {'status': 'pendingApproval'},
        afterSnapshot: {'status': 'approved', 'approvedByUserId': 'usr_manager'},
        occurredAt: DateTime(2026, 3, 24, 14, 22),
      ),
      AuditLogEntry(
        id: 'aud_pr_mar_disburse',
        entityType: 'PayRun',
        entityId: 'pr_mar_2026_monthly',
        action: 'DISBURSE',
        changedByUserId: 'usr_manager',
        changedByName: 'Farm Manager',
        description: 'March 2026 pay run disbursed — R29,220.00 net paid',
        beforeSnapshot: {'status': 'approved'},
        afterSnapshot: {'status': 'disbursed', 'disbursedAt': '2026-03-25'},
        occurredAt: DateTime(2026, 3, 25, 9, 30),
      ),
      AuditLogEntry(
        id: 'aud_pr_apr_create',
        entityType: 'PayRun',
        entityId: 'pr_apr_2026_monthly',
        action: 'CREATE',
        changedByUserId: 'usr_manager',
        changedByName: 'Farm Manager',
        description: 'April 2026 monthly pay run created',
        afterSnapshot: {'id': 'pr_apr_2026_monthly', 'status': 'calculated', 'totalGross': 32700},
        occurredAt: DateTime(2026, 4, 20, 9, 0),
      ),
      AuditLogEntry(
        id: 'aud_pr_apr_approve',
        entityType: 'PayRun',
        entityId: 'pr_apr_2026_monthly',
        action: 'APPROVE',
        changedByUserId: 'usr_manager',
        changedByName: 'Farm Manager',
        description: 'April 2026 pay run approved for disbursement',
        beforeSnapshot: {'status': 'pendingApproval'},
        afterSnapshot: {'status': 'approved'},
        occurredAt: DateTime(2026, 4, 24, 15, 10),
      ),
      AuditLogEntry(
        id: 'aud_pr_apr_disburse',
        entityType: 'PayRun',
        entityId: 'pr_apr_2026_monthly',
        action: 'DISBURSE',
        changedByUserId: 'usr_manager',
        changedByName: 'Farm Manager',
        description: 'April 2026 pay run disbursed — R29,220.00 net paid',
        beforeSnapshot: {'status': 'approved'},
        afterSnapshot: {'status': 'disbursed', 'disbursedAt': '2026-04-25'},
        occurredAt: DateTime(2026, 4, 25, 9, 20),
      ),
      AuditLogEntry(
        id: 'aud_emp_sipho_add',
        entityType: 'PayrollEmployee',
        entityId: 'emp_sipho',
        action: 'CREATE',
        changedByUserId: 'usr_manager',
        changedByName: 'Farm Manager',
        description: 'Employee Sipho Dlamini added',
        afterSnapshot: {'id': 'emp_sipho', 'name': 'Sipho Dlamini', 'engagementType': 'permanent'},
        occurredAt: DateTime(2024, 1, 15, 10, 0),
      ),
      AuditLogEntry(
        id: 'aud_emp_lindiwe_add',
        entityType: 'PayrollEmployee',
        entityId: 'emp_lindiwe',
        action: 'CREATE',
        changedByUserId: 'usr_manager',
        changedByName: 'Farm Manager',
        description: 'Employee Lindiwe Mokoena added',
        afterSnapshot: {'id': 'emp_lindiwe', 'name': 'Lindiwe Mokoena', 'engagementType': 'casual'},
        occurredAt: DateTime(2025, 8, 3, 9, 30),
      ),
      AuditLogEntry(
        id: 'aud_leave_sipho_app',
        entityType: 'LeaveRequest',
        entityId: 'lr_sipho_annual',
        action: 'APPROVE',
        changedByUserId: 'usr_manager',
        changedByName: 'Farm Manager',
        description: 'Annual leave approved for Sipho Dlamini (5 days)',
        beforeSnapshot: {'status': 'pending'},
        afterSnapshot: {'status': 'approved', 'reviewedByUserId': 'usr_manager'},
        occurredAt: DateTime(2026, 5, 3, 9, 45),
      ),
      AuditLogEntry(
        id: 'aud_leave_pieter_rej',
        entityType: 'LeaveRequest',
        entityId: 'lr_pieter_annual',
        action: 'UPDATE',
        changedByUserId: 'usr_manager',
        changedByName: 'Farm Manager',
        description: 'Annual leave rejected for Pieter van der Berg — peak harvest period',
        beforeSnapshot: {'status': 'pending'},
        afterSnapshot: {'status': 'rejected', 'rejectionReason': 'Peak harvest period'},
        occurredAt: DateTime(2026, 5, 1, 11, 0),
      ),
      AuditLogEntry(
        id: 'aud_alert_nmwa_raised',
        entityType: 'ComplianceAlert',
        entityId: 'ca_nmwa_ayanda',
        action: 'CREATE',
        changedByUserId: 'usr_system',
        changedByName: 'System',
        description: 'NMWA potential breach alert raised for Ayanda Cele',
        afterSnapshot: {'code': 'NMWA_BREACH', 'severity': 'warning', 'employeeId': 'emp_ayanda'},
        occurredAt: DateTime(2026, 5, 20, 8, 0),
      ),
      AuditLogEntry(
        id: 'aud_emp_bongani_update',
        entityType: 'PayrollEmployee',
        entityId: 'emp_bongani',
        action: 'UPDATE',
        changedByUserId: 'usr_manager',
        changedByName: 'Farm Manager',
        description: 'Bongani Khumalo wage rate updated',
        beforeSnapshot: {'baseRate': 4200.0},
        afterSnapshot: {'baseRate': 4500.0},
        occurredAt: DateTime(2025, 11, 1, 10, 30),
      ),
    ]);
  }

  // ─── Interface implementations ────────────────────────────────────────────

  @override
  List<PayrollEmployee> getEmployees() => List.unmodifiable(_employees);

  @override
  PayrollEmployee? getEmployee(String id) =>
      _employees.where((e) => e.id == id).firstOrNull;

  @override
  PayrollEmployee addEmployee(PayrollEmployee employee) {
    _employees.add(employee);
    _log('CREATE', 'PayrollEmployee', employee.id, 'Added ${employee.fullName}', null,
        {'id': employee.id, 'name': employee.fullName});
    return employee;
  }

  @override
  PayrollEmployee updateEmployee(PayrollEmployee employee) {
    final idx = _employees.indexWhere((e) => e.id == employee.id);
    if (idx < 0) throw StateError('Employee ${employee.id} not found');
    _employees[idx] = employee;
    _log('UPDATE', 'PayrollEmployee', employee.id, 'Updated ${employee.fullName}',
        null, {'id': employee.id});
    return employee;
  }

  @override
  List<EmploymentContract> getContracts({String? employeeId}) {
    if (employeeId != null) {
      return _contracts.where((c) => c.employeeId == employeeId).toList();
    }
    return List.unmodifiable(_contracts);
  }

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
    final idx = _contracts.indexWhere((c) => c.id == contract.id);
    if (idx < 0) throw StateError('Contract ${contract.id} not found');
    _contracts[idx] = contract;
    return contract;
  }

  @override
  List<PayGroup> getPayGroups() => List.unmodifiable(_payGroups);

  @override
  PayGroup addPayGroup(PayGroup group) {
    _payGroups.add(group);
    return group;
  }

  @override
  PayGroup updatePayGroup(PayGroup group) {
    final idx = _payGroups.indexWhere((g) => g.id == group.id);
    if (idx < 0) throw StateError('PayGroup ${group.id} not found');
    _payGroups[idx] = group;
    return group;
  }

  @override
  List<PayStructure> getPayStructures() => List.unmodifiable(_payStructures);

  @override
  PayStructure addPayStructure(PayStructure structure) {
    _payStructures.add(structure);
    return structure;
  }

  @override
  PayStructure updatePayStructure(PayStructure structure) {
    final idx = _payStructures.indexWhere((s) => s.id == structure.id);
    if (idx < 0) throw StateError('PayStructure ${structure.id} not found');
    _payStructures[idx] = structure;
    return structure;
  }

  @override
  List<Shift> getShifts({DateTime? weekStart, String? employeeId}) {
    var result = _shifts.toList();
    if (employeeId != null) {
      result = result.where((s) => s.employeeIds.contains(employeeId)).toList();
    }
    if (weekStart != null) {
      final end = weekStart.add(const Duration(days: 7));
      result = result
          .where((s) => !s.date.isBefore(weekStart) && s.date.isBefore(end))
          .toList();
    }
    return result;
  }

  @override
  Shift addShift(Shift shift) {
    _shifts.add(shift);
    return shift;
  }

  @override
  Shift updateShift(Shift shift) {
    final idx = _shifts.indexWhere((s) => s.id == shift.id);
    if (idx < 0) throw StateError('Shift ${shift.id} not found');
    _shifts[idx] = shift;
    return shift;
  }

  @override
  List<TaskAssignment> getTaskAssignments({String? employeeId, DateTime? date}) {
    var result = _tasks.toList();
    if (employeeId != null) {
      result = result.where((t) => t.employeeId == employeeId).toList();
    }
    if (date != null) {
      result = result
          .where((t) =>
              t.date.year == date.year &&
              t.date.month == date.month &&
              t.date.day == date.day)
          .toList();
    }
    return result;
  }

  @override
  TaskAssignment addTaskAssignment(TaskAssignment task) {
    _tasks.add(task);
    return task;
  }

  @override
  TaskAssignment updateTaskAssignment(TaskAssignment task) {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx < 0) throw StateError('Task ${task.id} not found');
    _tasks[idx] = task;
    return task;
  }

  @override
  List<AttendanceRecord> getAttendanceRecords({String? employeeId, DateTime? date, DateTime? fromDate, DateTime? toDate}) {
    var result = _attendance.toList();
    if (employeeId != null) {
      result = result.where((r) => r.employeeId == employeeId).toList();
    }
    if (date != null) {
      result = result
          .where((r) =>
              r.date.year == date.year &&
              r.date.month == date.month &&
              r.date.day == date.day)
          .toList();
    }
    if (fromDate != null) {
      result = result.where((r) => !r.date.isBefore(fromDate)).toList();
    }
    if (toDate != null) {
      result = result.where((r) => !r.date.isAfter(toDate)).toList();
    }
    return result;
  }

  @override
  AttendanceRecord addAttendanceRecord(AttendanceRecord record) {
    _attendance.add(record);
    return record;
  }

  @override
  AttendanceRecord updateAttendanceRecord(AttendanceRecord record) {
    final idx = _attendance.indexWhere((r) => r.id == record.id);
    if (idx < 0) throw StateError('AttendanceRecord ${record.id} not found');
    _attendance[idx] = record;
    return record;
  }

  @override
  List<PieceworkLog> getPieceworkLogs(
      {String? employeeId, DateTime? date, String? shiftId}) {
    var result = _piecework.toList();
    if (employeeId != null) {
      result = result.where((l) => l.employeeId == employeeId).toList();
    }
    if (shiftId != null) {
      result = result.where((l) => l.shiftId == shiftId).toList();
    }
    if (date != null) {
      result = result
          .where((l) =>
              l.date.year == date.year &&
              l.date.month == date.month &&
              l.date.day == date.day)
          .toList();
    }
    return result;
  }

  @override
  PieceworkLog addPieceworkLog(PieceworkLog log) {
    _piecework.add(log);
    return log;
  }

  @override
  List<PayRun> getPayRuns({String? payGroupId}) {
    if (payGroupId != null) {
      return _payRuns.where((r) => r.payGroupId == payGroupId).toList();
    }
    return List.unmodifiable(_payRuns);
  }

  @override
  PayRun? getPayRun(String id) =>
      _payRuns.where((r) => r.id == id).firstOrNull;

  @override
  PayRun calculatePayRun(
      String payGroupId, DateTime periodStart, DateTime periodEnd) {
    final payDate = DateTime(periodEnd.year, periodEnd.month + 1, 1)
        .subtract(const Duration(days: 1));
    final employees =
        _employees.where((e) => e.payGroupId == payGroupId && e.isActive).toList();
    final id = 'pr_${payGroupId}_${periodStart.millisecondsSinceEpoch}';

    // ── Build EmployeePayInput for each employee ──────────────────────────
    final inputs = <EmployeePayInput>[];
    for (final emp in employees) {
      final payStructure =
          _payStructures.where((s) => s.id == emp.payStructureId).firstOrNull;
      if (payStructure == null) continue;

      final attendance = _attendance
          .where((r) =>
              r.employeeId == emp.id &&
              !r.date.isBefore(periodStart) &&
              !r.date.isAfter(periodEnd))
          .toList();

      final piecework = _piecework
          .where((l) =>
              l.employeeId == emp.id &&
              !l.date.isBefore(periodStart) &&
              !l.date.isAfter(periodEnd))
          .toList();

      final rules = _deductionRules
          .where((r) =>
              r.isActive &&
              (r.employeeIds == null || r.employeeIds!.contains(emp.id)))
          .toList();

      // Salary override: active signed contract takes precedence, then override map
      final contractSalary = _contracts
          .where((c) =>
              c.employeeId == emp.id && c.status == ContractStatus.signed)
          .firstOrNull
          ?.grossMonthlySalary;
      final salaryOverride = contractSalary ?? _empSalaryOverride[emp.id];

      inputs.add(EmployeePayInput(
        employee: emp,
        payStructure: payStructure,
        attendanceRecords: attendance,
        pieceworkLogs: piecework,
        deductionRules: rules,
        salaryOverride: salaryOverride,
      ));
    }

    // ── Delegate to PayrollEngine (full SA bracket PAYE + NMWA + overtime) ─
    const engine = PayrollEngine();
    final result = engine.calculatePayRun(
      payRunId: id,
      payGroupId: payGroupId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      payDate: payDate,
      inputs: inputs,
    );

    // ── Enrich payslips with leave balance snapshots ───────────────────────
    final enrichedPayslips = result.payslips.map((ps) {
      final snapshot = <String, double>{};
      for (final bal
          in _leaveBalances.where((b) => b.employeeId == ps.employeeId)) {
        snapshot[bal.leaveTypeCode] = bal.remaining;
      }
      return Payslip(
        id: ps.id,
        payRunId: ps.payRunId,
        employeeId: ps.employeeId,
        periodStart: ps.periodStart,
        periodEnd: ps.periodEnd,
        payDate: ps.payDate,
        basicWage: ps.basicWage,
        overtimePay: ps.overtimePay,
        holidayPay: ps.holidayPay,
        inKindHousing: ps.inKindHousing,
        inKindFood: ps.inKindFood,
        otherEarnings: ps.otherEarnings,
        grossPay: ps.grossPay,
        deductions: ps.deductions,
        totalDeductions: ps.totalDeductions,
        netPay: ps.netPay,
        leaveBalanceSnapshot: snapshot,
        payslipNumber: ps.payslipNumber,
        createdAt: ps.createdAt,
      );
    }).toList();

    _payRuns.add(result.payRun);
    _payslips.addAll(enrichedPayslips);
    _alerts.addAll(result.complianceAlerts);

    _log('CREATE', 'PayRun', id, 'Calculated pay run for $payGroupId via PayrollEngine', null, {
      'payGroupId': payGroupId,
      'totalGross': result.payRun.totalGross,
      'employees': inputs.length,
      'complianceAlerts': result.complianceAlerts.length,
    });
    return result.payRun;
  }

  @override
  PayRun approvePayRun(String id, String approverUserId) {
    final idx = _payRuns.indexWhere((r) => r.id == id);
    if (idx < 0) throw StateError('PayRun $id not found');
    final updated = _payRuns[idx].copyWith(
      status: PayRunStatus.approved,
      approvedByUserId: approverUserId,
      approvedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _payRuns[idx] = updated;
    _log('APPROVE', 'PayRun', id, 'Pay run approved by $approverUserId', null, {'id': id});
    return updated;
  }

  @override
  PayRun disbursePayRun(String id) {
    final idx = _payRuns.indexWhere((r) => r.id == id);
    if (idx < 0) throw StateError('PayRun $id not found');
    final updated = _payRuns[idx].copyWith(
      status: PayRunStatus.disbursed,
      disbursedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _payRuns[idx] = updated;

    // ── BCEA §20 leave accrual on disbursement ──────────────────────────────
    // Annual: 1 day per 17 days worked (15 days/year ÷ 261 working days).
    // Sick:   30 days in 36-month cycle → 0.833 days/month accrual.
    // Only accrue for employees in this pay group.
    _accrueLeaveForPayRun(updated);

    _log('DISBURSE', 'PayRun', id, 'Pay run disbursed', null, {'id': id});
    return updated;
  }

  /// Accrue BCEA leave for all employees in the pay run's pay group.
  void _accrueLeaveForPayRun(PayRun run) {
    final payGroup = _payGroups.where((g) => g.id == run.payGroupId).firstOrNull;
    if (payGroup == null) return;

    // Determine accrual factor based on pay frequency
    // Monthly → 1 month, Weekly → ~0.25 month, BiWeekly → ~0.5 month
    final periodDays =
        run.periodEnd.difference(run.periodStart).inDays + 1;
    final monthFraction = periodDays / 30.44; // avg days/month

    // BCEA accrual rates per month:
    const annualPerMonth = 15.0 / 12.0;   // 1.25 days/month
    const sickPerMonth   = 30.0 / 36.0;   // 0.833 days/month (36-month cycle)

    final employees =
        _employees.where((e) => e.payGroupId == run.payGroupId && e.isActive).toList();

    for (final emp in employees) {
      for (final lt in _leaveTypes) {
        final balIdx = _leaveBalances.indexWhere(
            (b) => b.employeeId == emp.id && b.leaveTypeId == lt.id);
        if (balIdx < 0) continue;

        double accrual = 0.0;
        if (lt.code == 'ANNUAL') {
          accrual = double.parse((annualPerMonth * monthFraction).toStringAsFixed(4));
        } else if (lt.code == 'SICK') {
          accrual = double.parse((sickPerMonth * monthFraction).toStringAsFixed(4));
        }
        if (accrual <= 0) continue;

        final bal = _leaveBalances[balIdx];
        _leaveBalances[balIdx] = bal.copyWith(
          totalEntitled: bal.totalEntitled + accrual,
          asOfDate: run.periodEnd,
        );
        _log('ACCRUE', 'LeaveBalance', bal.id,
            'Accrued ${accrual.toStringAsFixed(4)} ${lt.code} days for ${emp.id}',
            null, {'accrual': accrual, 'newTotal': bal.totalEntitled + accrual});
      }
    }
  }

  @override
  List<Payslip> getPayslips({String? employeeId, String? payRunId}) {
    var result = _payslips.toList();
    if (employeeId != null) {
      result = result.where((p) => p.employeeId == employeeId).toList();
    }
    if (payRunId != null) {
      result = result.where((p) => p.payRunId == payRunId).toList();
    }
    return result;
  }

  @override
  Payslip? getPayslip(String id) =>
      _payslips.where((p) => p.id == id).firstOrNull;

  @override
  List<DeductionRule> getDeductionRules({String? employeeId}) {
    if (employeeId == null) return List.unmodifiable(_deductionRules);
    return _deductionRules
        .where((r) => r.employeeIds == null || r.employeeIds!.contains(employeeId))
        .toList();
  }

  @override
  DeductionRule addDeductionRule(DeductionRule rule) {
    _deductionRules.add(rule);
    return rule;
  }

  @override
  DeductionRule updateDeductionRule(DeductionRule rule) {
    final idx = _deductionRules.indexWhere((r) => r.id == rule.id);
    if (idx < 0) throw StateError('DeductionRule ${rule.id} not found');
    _deductionRules[idx] = rule;
    return rule;
  }

  // ── Garnishee orders ────────────────────────────────────────────────────
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

  @override
  List<LeaveType> getLeaveTypes() => List.unmodifiable(_leaveTypes);

  @override
  List<LeaveBalance> getLeaveBalances({String? employeeId}) {
    if (employeeId != null) {
      return _leaveBalances.where((b) => b.employeeId == employeeId).toList();
    }
    return List.unmodifiable(_leaveBalances);
  }

  @override
  List<LeaveRequest> getLeaveRequests({String? employeeId, LeaveStatus? status}) {
    var result = _leaveRequests.toList();
    if (employeeId != null) {
      result = result.where((r) => r.employeeId == employeeId).toList();
    }
    if (status != null) {
      result = result.where((r) => r.status == status).toList();
    }
    return result;
  }

  @override
  LeaveRequest addLeaveRequest(LeaveRequest request) {
    _leaveRequests.add(request);
    return request;
  }

  @override
  LeaveRequest approveLeaveRequest(String id, String approverId) {
    final idx = _leaveRequests.indexWhere((r) => r.id == id);
    if (idx < 0) throw StateError('LeaveRequest $id not found');
    final updated = _leaveRequests[idx].copyWith(
      status: LeaveStatus.approved,
      reviewedByUserId: approverId,
      reviewedAt: DateTime.now(),
    );
    _leaveRequests[idx] = updated;
    _log('APPROVE', 'LeaveRequest', id, 'Leave request approved', null, {'id': id});
    return updated;
  }

  @override
  LeaveRequest rejectLeaveRequest(String id, String approverId, String reason) {
    final idx = _leaveRequests.indexWhere((r) => r.id == id);
    if (idx < 0) throw StateError('LeaveRequest $id not found');
    final updated = _leaveRequests[idx].copyWith(
      status: LeaveStatus.rejected,
      reviewedByUserId: approverId,
      reviewedAt: DateTime.now(),
      rejectionReason: reason,
    );
    _leaveRequests[idx] = updated;
    return updated;
  }

  @override
  LeaveRequest cancelLeaveRequest(String id) {
    final idx = _leaveRequests.indexWhere((r) => r.id == id);
    if (idx < 0) throw StateError('LeaveRequest $id not found');
    final updated = _leaveRequests[idx].copyWith(status: LeaveStatus.cancelled);
    _leaveRequests[idx] = updated;
    return updated;
  }

  @override
  List<PaymentTransaction> getTransactions({String? payRunId, String? employeeId}) {
    var result = _transactions.toList();
    if (payRunId != null) {
      result = result.where((t) => t.payRunId == payRunId).toList();
    }
    if (employeeId != null) {
      result = result.where((t) => t.employeeId == employeeId).toList();
    }
    return result;
  }

  @override
  List<ComplianceAlert> getComplianceAlerts({bool includeResolved = false}) {
    if (includeResolved) return List.unmodifiable(_alerts);
    return _alerts.where((a) => !a.isResolved).toList();
  }

  @override
  ComplianceAlert resolveAlert(
      String id, String resolvedByUserId, String resolution) {
    final idx = _alerts.indexWhere((a) => a.id == id);
    if (idx < 0) throw StateError('ComplianceAlert $id not found');
    final updated = _alerts[idx].copyWith(
      isResolved: true,
      resolvedByUserId: resolvedByUserId,
      resolvedAt: DateTime.now(),
      resolution: resolution,
    );
    _alerts[idx] = updated;
    _log('RESOLVE', 'ComplianceAlert', id, 'Alert resolved: $resolution', null, {'id': id});
    return updated;
  }

  @override
  List<AuditLogEntry> getAuditLog(
      {String? entityType, String? entityId, int limit = 100}) {
    var result = _auditLog.toList();
    if (entityType != null) {
      result = result.where((e) => e.entityType == entityType).toList();
    }
    if (entityId != null) {
      result = result.where((e) => e.entityId == entityId).toList();
    }
    result.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return result.take(limit).toList();
  }

  @override
  List<IncidentRecord> getIncidents({String? employeeId}) {
    if (employeeId != null) {
      return _incidents.where((i) => i.employeeId == employeeId).toList();
    }
    return List.unmodifiable(_incidents);
  }

  @override
  IncidentRecord addIncident(IncidentRecord incident) {
    _incidents.add(incident);
    return incident;
  }

  @override
  IncidentRecord updateIncident(IncidentRecord incident) {
    final idx = _incidents.indexWhere((i) => i.id == incident.id);
    if (idx < 0) throw StateError('IncidentRecord ${incident.id} not found');
    _incidents[idx] = incident;
    return incident;
  }

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

  // ─── Audit helper ──────────────────────────────────────────────────────────
  void _log(
    String action,
    String entityType,
    String entityId,
    String description,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
  ) {
    _auditLog.add(AuditLogEntry(
      id: _uid(),
      entityType: entityType,
      entityId: entityId,
      action: action,
      changedByUserId: 'usr_system',
      changedByName: 'System',
      beforeSnapshot: before,
      afterSnapshot: after,
      description: description,
      occurredAt: DateTime.now(),
    ));
  }

  // ─── Seed: Shifts ──────────────────────────────────────────────────────────────
  void _seedShifts() {
    // Two weeks of morning-shift rosters for weekly pay-group employees
    // Week A: 2026-05-04 – 2026-05-08
    for (var dayOffset = 0; dayOffset < 5; dayOffset++) {
      final date = DateTime(2026, 5, 4 + dayOffset);
      _shifts.add(Shift(
        id: 'sh_wkA_d${dayOffset + 1}',
        date: date,
        startTime: '07:00',
        endTime: '15:00',
        employeeIds: ['emp_thabo', 'emp_nomsa', 'emp_bongani', 'emp_ayanda', 'emp_lindiwe'],
        taskCode: 'GRAPE_PICK',
        fieldOrArea: 'Block A — Hex River',
        status: ShiftStatus.completed,
        supervisorId: 'emp_sipho',
        createdAt: DateTime(2026, 5, 3),
      ));
    }
    // Week B: 2026-05-11 – 2026-05-15
    for (var dayOffset = 0; dayOffset < 5; dayOffset++) {
      final date = DateTime(2026, 5, 11 + dayOffset);
      _shifts.add(Shift(
        id: 'sh_wkB_d${dayOffset + 1}',
        date: date,
        startTime: '07:00',
        endTime: '15:00',
        employeeIds: ['emp_thabo', 'emp_nomsa', 'emp_bongani', 'emp_ayanda', 'emp_lindiwe'],
        taskCode: 'APPLE_PICK',
        fieldOrArea: 'Block B — Elgin Orchard',
        status: dayOffset < 3 ? ShiftStatus.completed : ShiftStatus.planned,
        supervisorId: 'emp_sipho',
        createdAt: DateTime(2026, 5, 10),
      ));
    }
    // Monthly staff morning supervision shifts
    _shifts.addAll([
      Shift(
        id: 'sh_sipho_sup_mon',
        date: DateTime(2026, 5, 4),
        startTime: '06:30',
        endTime: '16:00',
        employeeIds: ['emp_sipho'],
        taskCode: 'SUPERVISION',
        fieldOrArea: 'Block A',
        status: ShiftStatus.completed,
        supervisorId: 'emp_sipho',
        createdAt: DateTime(2026, 5, 3),
      ),
      Shift(
        id: 'sh_pieter_orch_mon',
        date: DateTime(2026, 5, 4),
        startTime: '07:30',
        endTime: '16:30',
        employeeIds: ['emp_pieter'],
        taskCode: 'ORCHARD_MANAGE',
        fieldOrArea: 'Elgin Orchard',
        status: ShiftStatus.completed,
        supervisorId: 'emp_pieter',
        createdAt: DateTime(2026, 5, 3),
      ),
    ]);
  }

  // ─── Seed: Task Assignments ─────────────────────────────────────────────────────
  void _seedTaskAssignments() {
    const weekAIds = ['emp_thabo', 'emp_nomsa', 'emp_bongani'];
    const weekBIds = ['emp_thabo', 'emp_nomsa', 'emp_bongani', 'emp_ayanda', 'emp_lindiwe'];
    for (var i = 0; i < weekAIds.length; i++) {
      _tasks.add(TaskAssignment(
        id: 'ta_wkA_${weekAIds[i]}',
        employeeId: weekAIds[i],
        date: DateTime(2026, 5, 4),
        shiftId: 'sh_wkA_d1',
        payrollCode: 'GRAPE_PICK',
        description: 'Grape picking — Hex River Block A',
        fieldOrArea: 'Block A',
        status: TaskAssignmentStatus.completed,
        createdAt: DateTime(2026, 5, 3),
      ));
    }
    for (var i = 0; i < weekBIds.length; i++) {
      _tasks.add(TaskAssignment(
        id: 'ta_wkB_${weekBIds[i]}',
        employeeId: weekBIds[i],
        date: DateTime(2026, 5, 11),
        shiftId: 'sh_wkB_d1',
        payrollCode: 'APPLE_PICK',
        description: 'Apple picking — Elgin Block B',
        fieldOrArea: 'Block B',
        status: TaskAssignmentStatus.inProgress,
        createdAt: DateTime(2026, 5, 10),
      ));
    }
    _tasks.add(TaskAssignment(
      id: 'ta_sipho_sup',
      employeeId: 'emp_sipho',
      date: DateTime(2026, 5, 4),
      shiftId: 'sh_sipho_sup_mon',
      payrollCode: 'SUPERVISION',
      description: 'Supervise weekly team — Block A',
      status: TaskAssignmentStatus.completed,
      createdAt: DateTime(2026, 5, 3),
    ));
  }

  // ─── Seed: Attendance Records ─────────────────────────────────────────────────────
  void _seedAttendanceRecords() {
    // 2 weeks × 5 days × 5 weekly employees, plus 3 monthly employees
    // Absences: Thabo absent on 2026-05-06, Lindiwe absent on 2026-05-12
    // Late: Nomsa late on 2026-05-07
    const weeklyEmps = [
      'emp_thabo', 'emp_nomsa', 'emp_bongani', 'emp_ayanda', 'emp_lindiwe'
    ];
    const monthlyEmps = ['emp_sipho', 'emp_maria', 'emp_pieter'];

    // Week A: 2026-05-04 – 2026-05-08
    for (var d = 0; d < 5; d++) {
      final date = DateTime(2026, 5, 4 + d);
      for (final empId in weeklyEmps) {
        final isAbsent = empId == 'emp_thabo' && d == 2; // Wed 06 May
        final isLate   = empId == 'emp_nomsa' && d == 3; // Thu 07 May
        _attendance.add(AttendanceRecord(
          id: 'att_wkA_${empId}_d${d + 1}',
          employeeId: empId,
          date: date,
          status: isAbsent
              ? AttendanceStatus.absent
              : isLate
                  ? AttendanceStatus.late
                  : AttendanceStatus.present,
          clockInTime: isAbsent ? null : (isLate ? '07:42' : '07:01'),
          clockOutTime: isAbsent ? null : '15:05',
          hoursWorked: isAbsent ? null : (isLate ? 7.4 : 8.0),
          shiftId: 'sh_wkA_d${d + 1}',
          recordedByUserId: 'emp_sipho',
          method: AttendanceMethod.qrCode,
          createdAt: date,
        ));
      }
      for (final empId in monthlyEmps) {
        _attendance.add(AttendanceRecord(
          id: 'att_wkA_${empId}_d${d + 1}',
          employeeId: empId,
          date: date,
          status: AttendanceStatus.present,
          clockInTime: '08:00',
          clockOutTime: '17:00',
          hoursWorked: 8.0,
          recordedByUserId: 'emp_sipho',
          method: AttendanceMethod.manual,
          createdAt: date,
        ));
      }
    }

    // Week B: 2026-05-11 – 2026-05-15
    for (var d = 0; d < 5; d++) {
      final date = DateTime(2026, 5, 11 + d);
      for (final empId in weeklyEmps) {
        final isAbsent = empId == 'emp_lindiwe' && d == 1; // Tue 12 May
        _attendance.add(AttendanceRecord(
          id: 'att_wkB_${empId}_d${d + 1}',
          employeeId: empId,
          date: date,
          status: isAbsent ? AttendanceStatus.absent : AttendanceStatus.present,
          clockInTime: isAbsent ? null : '07:00',
          clockOutTime: isAbsent ? null : '15:00',
          hoursWorked: isAbsent ? null : 8.0,
          shiftId: 'sh_wkB_d${d + 1}',
          recordedByUserId: 'emp_sipho',
          method: AttendanceMethod.qrCode,
          createdAt: date,
        ));
      }
      for (final empId in monthlyEmps) {
        _attendance.add(AttendanceRecord(
          id: 'att_wkB_${empId}_d${d + 1}',
          employeeId: empId,
          date: date,
          status: AttendanceStatus.present,
          clockInTime: '08:00',
          clockOutTime: '17:00',
          hoursWorked: 8.0,
          recordedByUserId: 'emp_sipho',
          method: AttendanceMethod.manual,
          createdAt: date,
        ));
      }
    }
  }

  // ─── Seed: Piecework Logs ──────────────────────────────────────────────────────────────
  void _seedPieceworkLogs() {
    // Grape picking: Thabo, Nomsa, Bongani — Week A (5 days)
    const grapeWorkers = ['emp_thabo', 'emp_nomsa', 'emp_bongani'];
    final grapeQty = {'emp_thabo': 42.0, 'emp_nomsa': 38.0, 'emp_bongani': 40.0};
    for (var d = 0; d < 5; d++) {
      if (d == 2) continue; // Thabo absent Wed — skip all grape that day
      final date = DateTime(2026, 5, 4 + d);
      for (final empId in grapeWorkers) {
        _piecework.add(PieceworkLog(
          id: 'pw_grape_${empId}_d${d + 1}',
          employeeId: empId,
          date: date,
          shiftId: 'sh_wkA_d${d + 1}',
          payrollCode: 'GRAPE_PICK',
          unit: 'kg',
          quantity: grapeQty[empId]! * (empId == 'emp_nomsa' && d == 3 ? 0.925 : 1.0), // Late → reduced output
          ratePerUnit: 2.80,
          recordedByUserId: 'emp_sipho',
          createdAt: date,
        ));
      }
    }
    // Apple picking: Thabo, Nomsa, Bongani, Ayanda, Lindiwe — Week B (first 3 days complete)
    const appleWorkers = ['emp_thabo', 'emp_nomsa', 'emp_bongani', 'emp_ayanda', 'emp_lindiwe'];
    final appleQty = {'emp_thabo': 35.0, 'emp_nomsa': 32.0, 'emp_bongani': 34.0, 'emp_ayanda': 28.0, 'emp_lindiwe': 30.0};
    for (var d = 0; d < 3; d++) {
      final date = DateTime(2026, 5, 11 + d);
      for (final empId in appleWorkers) {
        if (empId == 'emp_lindiwe' && d == 1) continue; // Lindiwe absent Tue
        _piecework.add(PieceworkLog(
          id: 'pw_apple_${empId}_d${d + 1}',
          employeeId: empId,
          date: date,
          shiftId: 'sh_wkB_d${d + 1}',
          payrollCode: 'APPLE_PICK',
          unit: 'crates',
          quantity: appleQty[empId]!,
          ratePerUnit: 3.50,
          recordedByUserId: 'emp_sipho',
          createdAt: date,
        ));
      }
    }
  }

  // ─── Soft-delete / Terminate implementations ─────────────────────────────────────────

  @override
  PayrollEmployee terminateEmployee(
      String id, DateTime terminationDate, String reason) {
    final idx = _employees.indexWhere((e) => e.id == id);
    if (idx < 0) throw StateError('Employee $id not found');
    final updated = _employees[idx].copyWith(
      status: EmploymentStatus.terminated,
      endDate: terminationDate,
    );
    _employees[idx] = updated;
    _log('TERMINATE', 'PayrollEmployee', id,
        'Employee ${updated.fullName} terminated: $reason',
        {'status': 'active'}, {'status': 'terminated', 'terminationDate': terminationDate.toIso8601String()});
    return updated;
  }

  @override
  EmploymentContract voidContract(String id, String reason) {
    final idx = _contracts.indexWhere((c) => c.id == id);
    if (idx < 0) throw StateError('Contract $id not found');
    final updated = _contracts[idx].copyWith(status: ContractStatus.terminated);
    _contracts[idx] = updated;
    _log('VOID', 'EmploymentContract', id, 'Contract terminated: $reason',
        {'status': 'active'}, {'status': 'terminated'});
    return updated;
  }

  @override
  bool deleteShift(String id) {
    final idx = _shifts.indexWhere((s) => s.id == id);
    if (idx < 0) return false;
    _shifts.removeAt(idx);
    _log('DELETE', 'Shift', id, 'Shift deleted', null, null);
    return true;
  }

  @override
  bool deleteTaskAssignment(String id) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx < 0) return false;
    _tasks.removeAt(idx);
    _log('DELETE', 'TaskAssignment', id, 'Task assignment deleted', null, null);
    return true;
  }

  @override
  DeductionRule deactivateDeductionRule(String id) {
    final idx = _deductionRules.indexWhere((r) => r.id == id);
    if (idx < 0) throw StateError('DeductionRule $id not found');
    final updated = _deductionRules[idx].copyWith(isActive: false);
    _deductionRules[idx] = updated;
    _log('DEACTIVATE', 'DeductionRule', id, 'Deduction rule deactivated', null, {'isActive': false});
    return updated;
  }

  @override
  bool deletePieceworkLog(String id, String correctionReason) {
    final idx = _piecework.indexWhere((l) => l.id == id);
    if (idx < 0) return false;
    _piecework.removeAt(idx);
    _log('DELETE', 'PieceworkLog', id, 'Piecework log deleted: $correctionReason', null, null);
    return true;
  }

  @override
  bool deleteLeaveRequest(String id) {
    final idx = _leaveRequests.indexWhere((r) => r.id == id);
    if (idx < 0) return false;
    _leaveRequests.removeAt(idx);
    _log('DELETE', 'LeaveRequest', id, 'Leave request deleted', null, null);
    return true;
  }

  @override
  IncidentRecord deactivateIncident(String id) {
    final idx = _incidents.indexWhere((i) => i.id == id);
    if (idx < 0) throw StateError('IncidentRecord $id not found');
    final updated = _incidents[idx].copyWith(status: IncidentStatus.closed);
    _incidents[idx] = updated;
    _log('DEACTIVATE', 'IncidentRecord', id, 'Incident closed/deactivated', null, {'status': 'closed'});
    return updated;
  }

  @override
  PayGroup deactivatePayGroup(String id) {
    final idx = _payGroups.indexWhere((g) => g.id == id);
    if (idx < 0) throw StateError('PayGroup $id not found');
    final updated = _payGroups[idx].copyWith(isActive: false);
    _payGroups[idx] = updated;
    _log('DEACTIVATE', 'PayGroup', id, 'Pay group deactivated', null, {'isActive': false});
    return updated;
  }

  @override
  EmployerConfig getEmployerConfig() => _employerConfig;

  @override
  EmployerConfig updateEmployerConfig(EmployerConfig config) {
    final old = _employerConfig;
    _employerConfig = config;
    _log('UPDATE', 'EmployerConfig', 'employer_config', 'Employer config updated',
        {'name': old.name}, {'name': config.name});
    return _employerConfig;
  }
}

// Helper extension used in _computeDeductions
extension _DeductionRuleX on DeductionRule {
  bool get isStatutoryGlobal =>
      type == DeductionType.statutory && (employeeIds == null || employeeIds!.isEmpty);
}