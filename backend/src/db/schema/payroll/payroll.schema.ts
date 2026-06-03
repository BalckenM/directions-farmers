import {
  boolean,
  date,
  datetime,
  decimal,
  index,
  int,
  mysqlTable,
  text,
  varchar,
} from "drizzle-orm/mysql-core";

export const payrollEmployees = mysqlTable(
  "payroll_employees",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    employeeNumber: varchar("employee_number", { length: 50 }).notNull(),
    firstName: varchar("first_name", { length: 100 }).notNull(),
    lastName: varchar("last_name", { length: 100 }).notNull(),
    idNumber: varchar("id_number", { length: 50 }),
    taxNumber: varchar("tax_number", { length: 50 }),
    email: varchar("email", { length: 255 }),
    phone: varchar("phone", { length: 20 }),
    address: text("address"),
    nextOfKinName: varchar("next_of_kin_name", { length: 255 }),
    nextOfKinPhone: varchar("next_of_kin_phone", { length: 20 }),
    dateOfBirth: date("date_of_birth"),
    sex: varchar("sex", { length: 10 }),
    nationality: varchar("nationality", { length: 50 }),
    bankName: varchar("bank_name", { length: 100 }),
    bankAccountNumber: varchar("bank_account_number", { length: 50 }),
    bankBranchCode: varchar("bank_branch_code", { length: 20 }),
    startDate: date("start_date").notNull(),
    endDate: date("end_date"),
    isActive: boolean("is_active").notNull().default(true),
    engagementType: varchar("engagement_type", { length: 50 }),
    occupationTitle: varchar("occupation_title", { length: 100 }),
    payGroupId: varchar("pay_group_id", { length: 36 }),
    payStructureId: varchar("pay_structure_id", { length: 36 }),
    disbursementMethod: varchar("disbursement_method", { length: 50 }),
    hasHousingBenefit: boolean("has_housing_benefit").notNull().default(false),
    housingValuePerMonth: decimal("housing_value_per_month", {
      precision: 8,
      scale: 2,
    }),
    hasFoodBenefit: boolean("has_food_benefit").notNull().default(false),
    preferredLanguage: varchar("preferred_language", { length: 10 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_employees_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const payrollContracts = mysqlTable(
  "payroll_contracts",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    employeeId: varchar("employee_id", { length: 36 }).notNull(),
    contractType: varchar("contract_type", { length: 50 }).notNull(),
    baseSalary: decimal("base_salary", { precision: 10, scale: 2 }).notNull(),
    currency: varchar("currency", { length: 3 }).notNull().default("ZAR"),
    startDate: date("start_date").notNull(),
    endDate: date("end_date"),
    status: varchar("status", { length: 50 }),
    jobDescription: text("job_description"),
    signedAt: datetime("signed_at"),
    signedByName: varchar("signed_by_name", { length: 255 }),
    signatureImageBase64: text("signature_image_base64"),
    pdfPath: varchar("pdf_path", { length: 500 }),
    version: int("version").notNull().default(1),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_contracts_farm_owner_idx").on(t.farmOwnerId),
    employeeIdx: index("payroll_contracts_employee_idx").on(t.employeeId),
  }),
);

export const payrollPayGroups = mysqlTable(
  "payroll_pay_groups",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    name: varchar("name", { length: 100 }).notNull(),
    payFrequency: varchar("pay_frequency", { length: 20 }).notNull(),
    payDay: int("pay_day"),
    isActive: boolean("is_active").notNull().default(true),
    description: text("description"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_pay_groups_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const payrollPayStructures = mysqlTable(
  "payroll_pay_structures",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    name: varchar("name", { length: 100 }).notNull(),
    wageType: varchar("wage_type", { length: 50 }),
    baseRate: decimal("base_rate", { precision: 10, scale: 2 }),
    nmwaEnforced: boolean("nmwa_enforced").notNull().default(true),
    pieceworkUnit: varchar("piecework_unit", { length: 50 }),
    pieceworkMinUnitsPerDay: decimal("piecework_min_units_per_day", {
      precision: 8,
      scale: 2,
    }),
    components: text("components").notNull(),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_pay_structures_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const payrollPayRuns = mysqlTable(
  "payroll_pay_runs",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    payGroupId: varchar("pay_group_id", { length: 36 }),
    periodStart: date("period_start").notNull(),
    periodEnd: date("period_end").notNull(),
    payDate: date("pay_date").notNull(),
    status: varchar("status", { length: 20 }).notNull().default("draft"),
    totalGross: decimal("total_gross", { precision: 12, scale: 2 })
      .notNull()
      .default("0"),
    totalDeductions: decimal("total_deductions", { precision: 12, scale: 2 })
      .notNull()
      .default("0"),
    totalNet: decimal("total_net", { precision: 12, scale: 2 })
      .notNull()
      .default("0"),
    notes: text("notes"),
    employeeCount: int("employee_count").notNull().default(0),
    approvedByUserId: varchar("approved_by_user_id", { length: 36 }),
    approvedAt: datetime("approved_at"),
    disbursedAt: datetime("disbursed_at"),
    complianceAlertIds: text("compliance_alert_ids"),
    lineItems: text("line_items"),
    sdlContribution: decimal("sdl_contribution", { precision: 10, scale: 2 })
      .notNull()
      .default("0"),
    etiCredit: decimal("eti_credit", { precision: 10, scale: 2 })
      .notNull()
      .default("0"),
    totalCoidaContribution: decimal("total_coida_contribution", {
      precision: 10,
      scale: 2,
    })
      .notNull()
      .default("0"),
    approvalChain: text("approval_chain"),
    requiredApprovers: int("required_approvers").notNull().default(1),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_pay_runs_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const payrollPayslips = mysqlTable(
  "payroll_payslips",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    payRunId: varchar("pay_run_id", { length: 36 }).notNull(),
    employeeId: varchar("employee_id", { length: 36 }).notNull(),
    periodStart: date("period_start").notNull(),
    periodEnd: date("period_end").notNull(),
    payDate: date("pay_date").notNull(),
    basicWage: decimal("basic_wage", { precision: 10, scale: 2 })
      .notNull()
      .default("0"),
    overtimePay: decimal("overtime_pay", { precision: 10, scale: 2 })
      .notNull()
      .default("0"),
    holidayPay: decimal("holiday_pay", { precision: 10, scale: 2 })
      .notNull()
      .default("0"),
    inKindHousing: decimal("in_kind_housing", { precision: 10, scale: 2 })
      .notNull()
      .default("0"),
    inKindFood: decimal("in_kind_food", { precision: 10, scale: 2 })
      .notNull()
      .default("0"),
    otherEarnings: decimal("other_earnings", { precision: 10, scale: 2 })
      .notNull()
      .default("0"),
    grossPay: decimal("gross_pay", { precision: 10, scale: 2 }).notNull(),
    deductions: text("deductions"),
    totalDeductions: decimal("total_deductions", {
      precision: 10,
      scale: 2,
    }).notNull(),
    leaveBalanceSnapshot: text("leave_balance_snapshot"),
    netPay: decimal("net_pay", { precision: 10, scale: 2 }).notNull(),
    payslipNumber: varchar("payslip_number", { length: 50 }),
    pdfData: text("pdf_data"),
    lineItems: text("line_items"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_payslips_farm_owner_idx").on(t.farmOwnerId),
    payRunIdx: index("payroll_payslips_pay_run_idx").on(t.payRunId),
    employeeIdx: index("payroll_payslips_employee_idx").on(t.employeeId),
  }),
);

export const payrollDeductionRules = mysqlTable(
  "payroll_deduction_rules",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    code: varchar("code", { length: 50 }),
    name: varchar("name", { length: 100 }).notNull(),
    type: varchar("type", { length: 50 }).notNull(),
    calculationMethod: varchar("calculation_method", { length: 20 }).notNull(),
    value: decimal("value", { precision: 10, scale: 4 }).notNull(),
    cappedAt: decimal("capped_at", { precision: 10, scale: 2 }),
    employeeIds: text("employee_ids"),
    isActive: boolean("is_active").notNull().default(true),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_deduction_rules_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const payrollGarnisheeOrders = mysqlTable(
  "payroll_garnishee_orders",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    employeeId: varchar("employee_id", { length: 36 }).notNull(),
    courtOrderRef: varchar("court_order_ref", { length: 100 }).notNull(),
    creditorName: varchar("creditor_name", { length: 255 }).notNull(),
    status: varchar("status", { length: 20 }).notNull().default("active"),
    monthlyDeductionAmount: decimal("monthly_deduction_amount", {
      precision: 10,
      scale: 2,
    }).notNull(),
    totalOwed: decimal("total_owed", { precision: 10, scale: 2 }).notNull(),
    amountDeducted: decimal("amount_deducted", { precision: 10, scale: 2 })
      .notNull()
      .default("0"),
    satisfiedAt: datetime("satisfied_at"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_garnishee_orders_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const payrollLeaveTypes = mysqlTable(
  "payroll_leave_types",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    code: varchar("code", { length: 50 }).notNull().default(""),
    name: varchar("name", { length: 100 }).notNull(),
    annualEntitlementDays: decimal("annual_entitlement_days", {
      precision: 5,
      scale: 2,
    }).notNull(),
    isPaid: boolean("is_paid").notNull().default(true),
    requiresApproval: boolean("requires_approval").notNull().default(true),
    colorHex: varchar("color_hex", { length: 7 }),
    description: text("description"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_leave_types_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const payrollLeaveBalances = mysqlTable(
  "payroll_leave_balances",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    employeeId: varchar("employee_id", { length: 36 }).notNull(),
    leaveTypeId: varchar("leave_type_id", { length: 36 }).notNull(),
    totalEntitled: decimal("total_entitled", { precision: 7, scale: 2 })
      .notNull()
      .default("0"),
    taken: decimal("taken", { precision: 7, scale: 2 }).notNull().default("0"),
    pending: decimal("pending", { precision: 7, scale: 2 })
      .notNull()
      .default("0"),
    asOfDate: date("as_of_date").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_leave_balances_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const payrollLeaveRequests = mysqlTable(
  "payroll_leave_requests",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    employeeId: varchar("employee_id", { length: 36 }).notNull(),
    leaveTypeId: varchar("leave_type_id", { length: 36 }).notNull(),
    startDate: date("start_date").notNull(),
    endDate: date("end_date").notNull(),
    daysRequested: decimal("days_requested", {
      precision: 5,
      scale: 2,
    }).notNull(),
    status: varchar("status", { length: 20 }).notNull().default("pending"),
    reason: text("reason"),
    reviewedByUserId: varchar("reviewed_by_user_id", { length: 36 }),
    reviewedAt: datetime("reviewed_at"),
    rejectionReason: text("rejection_reason"),
    submittedAt: datetime("submitted_at"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_leave_requests_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const payrollTransactions = mysqlTable(
  "payroll_transactions",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    employeeId: varchar("employee_id", { length: 36 }).notNull(),
    payRunId: varchar("pay_run_id", { length: 36 }),
    type: varchar("type", { length: 50 }).notNull(),
    description: varchar("description", { length: 255 }),
    amount: decimal("amount", { precision: 10, scale: 2 }).notNull(),
    currency: varchar("currency", { length: 3 }).notNull().default("ZAR"),
    method: varchar("method", { length: 50 }),
    status: varchar("status", { length: 20 }).notNull().default("initiated"),
    reference: varchar("reference", { length: 100 }),
    bankName: varchar("bank_name", { length: 100 }),
    accountNumber: varchar("account_number", { length: 50 }),
    initiatedAt: datetime("initiated_at"),
    completedAt: datetime("completed_at"),
    failureReason: text("failure_reason"),
    transactionDate: date("transaction_date").notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_transactions_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const payrollComplianceAlerts = mysqlTable(
  "payroll_compliance_alerts",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    code: varchar("code", { length: 50 }).notNull(),
    title: varchar("title", { length: 255 }).notNull(),
    severity: varchar("severity", { length: 20 }).notNull(),
    description: text("description").notNull(),
    isResolved: boolean("is_resolved").notNull().default(false),
    employeeId: varchar("employee_id", { length: 36 }),
    payRunId: varchar("pay_run_id", { length: 36 }),
    resolvedByUserId: varchar("resolved_by_user_id", { length: 36 }),
    resolution: text("resolution"),
    resolvedAt: datetime("resolved_at"),
    raisedAt: datetime("raised_at").notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_compliance_alerts_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const payrollAuditLog = mysqlTable(
  "payroll_audit_log",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    actorId: varchar("actor_id", { length: 36 }).notNull(),
    action: varchar("action", { length: 100 }).notNull(),
    resourceType: varchar("resource_type", { length: 50 }).notNull(),
    resourceId: varchar("resource_id", { length: 36 }),
    oldValues: text("old_values"),
    newValues: text("new_values"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_audit_log_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const payrollIncidents = mysqlTable(
  "payroll_incidents",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    employeeId: varchar("employee_id", { length: 36 }),
    incidentDate: date("incident_date").notNull(),
    type: varchar("type", { length: 50 }).notNull(),
    title: varchar("title", { length: 255 }).notNull(),
    description: text("description").notNull(),
    status: varchar("status", { length: 20 }).notNull().default("open"),
    actionTaken: text("action_taken"),
    resolvedAt: datetime("resolved_at"),
    resolvedByUserId: varchar("resolved_by_user_id", { length: 36 }),
    documentPaths: text("document_paths"),
    reportedByUserId: varchar("reported_by_user_id", { length: 36 }),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_incidents_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const payrollCommunications = mysqlTable(
  "payroll_communications",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    channel: varchar("channel", { length: 50 }).notNull(),
    templateCode: varchar("template_code", { length: 50 }),
    subject: varchar("subject", { length: 255 }),
    body: text("body").notNull(),
    recipientEmployeeIds: text("recipient_employee_ids"),
    sentByUserId: varchar("sent_by_user_id", { length: 36 }),
    deliveredCount: int("delivered_count").notNull().default(0),
    failedCount: int("failed_count").notNull().default(0),
    sentAt: datetime("sent_at"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_communications_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const payrollPieceworkLogs = mysqlTable(
  "payroll_piecework_logs",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    employeeId: varchar("employee_id", { length: 36 }).notNull(),
    taskName: varchar("task_name", { length: 255 }).notNull(),
    quantity: decimal("quantity", { precision: 10, scale: 2 }).notNull(),
    ratePerUnit: decimal("rate_per_unit", { precision: 8, scale: 4 }).notNull(),
    totalAmount: decimal("total_amount", { precision: 10, scale: 2 }).notNull(),
    workDate: date("work_date").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_piecework_logs_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const payrollShifts = mysqlTable(
  "payroll_shifts",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    employeeId: varchar("employee_id", { length: 36 }).notNull(),
    shiftDate: date("shift_date").notNull(),
    startTime: varchar("start_time", { length: 10 }).notNull(),
    endTime: varchar("end_time", { length: 10 }).notNull(),
    breakMinutes: int("break_minutes").notNull().default(0),
    shiftType: varchar("shift_type", { length: 50 }),
    status: varchar("status", { length: 20 }).notNull().default("scheduled"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_shifts_farm_owner_idx").on(t.farmOwnerId),
    employeeIdx: index("payroll_shifts_employee_idx").on(t.employeeId),
  }),
);

export const payrollTaskAssignments = mysqlTable(
  "payroll_task_assignments",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    employeeId: varchar("employee_id", { length: 36 }).notNull(),
    taskName: varchar("task_name", { length: 255 }).notNull(),
    assignedDate: date("assigned_date").notNull(),
    dueDate: date("due_date"),
    completedAt: datetime("completed_at"),
    status: varchar("status", { length: 20 }).notNull().default("assigned"),
    priority: varchar("priority", { length: 20 }).default("normal"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_task_assignments_farm_owner_idx").on(
      t.farmOwnerId,
    ),
    employeeIdx: index("payroll_task_assignments_employee_idx").on(
      t.employeeId,
    ),
  }),
);

export const payrollAttendanceRecords = mysqlTable(
  "payroll_attendance_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    employeeId: varchar("employee_id", { length: 36 }).notNull(),
    attendanceDate: date("attendance_date").notNull(),
    clockIn: varchar("clock_in", { length: 10 }),
    clockOut: varchar("clock_out", { length: 10 }),
    hoursWorked: decimal("hours_worked", { precision: 5, scale: 2 }),
    status: varchar("status", { length: 20 }).notNull().default("present"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_attendance_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
    employeeIdx: index("payroll_attendance_records_employee_idx").on(
      t.employeeId,
    ),
  }),
);

export const payrollEmployerConfig = mysqlTable(
  "payroll_employer_config",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull().unique(),
    companyName: varchar("company_name", { length: 255 }),
    taxNumber: varchar("tax_number", { length: 50 }),
    uifNumber: varchar("uif_number", { length: 50 }),
    sdlNumber: varchar("sdl_number", { length: 50 }),
    payDay: int("pay_day").default(25),
    overtimeMultiplier: decimal("overtime_multiplier", {
      precision: 3,
      scale: 2,
    }).default("1.50"),
    currency: varchar("currency", { length: 3 }).default("ZAR"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("payroll_employer_config_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);
