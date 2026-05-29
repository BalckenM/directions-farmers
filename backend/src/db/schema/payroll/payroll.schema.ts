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
    payFrequency: varchar("pay_frequency", { length: 20 }).notNull(),
    baseSalary: decimal("base_salary", { precision: 10, scale: 2 }).notNull(),
    currency: varchar("currency", { length: 3 }).notNull().default("ZAR"),
    startDate: date("start_date").notNull(),
    endDate: date("end_date"),
    isActive: boolean("is_active").notNull().default(true),
    status: varchar("status", { length: 50 }),
    jobDescription: text("job_description"),
    signedAt: datetime("signed_at"),
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
    grossPay: decimal("gross_pay", { precision: 10, scale: 2 }).notNull(),
    totalDeductions: decimal("total_deductions", {
      precision: 10,
      scale: 2,
    }).notNull(),
    netPay: decimal("net_pay", { precision: 10, scale: 2 }).notNull(),
    pdfData: text("pdf_data"),
    lineItems: text("line_items").notNull(),
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
    caseNumber: varchar("case_number", { length: 100 }),
    amount: decimal("amount", { precision: 10, scale: 2 }).notNull(),
    creditorName: varchar("creditor_name", { length: 255 }),
    startDate: date("start_date").notNull(),
    endDate: date("end_date"),
    isActive: boolean("is_active").notNull().default(true),
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
    accrualDaysPerYear: decimal("accrual_days_per_year", {
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
    balance: decimal("balance", { precision: 7, scale: 2 })
      .notNull()
      .default("0"),
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
    approvedBy: varchar("approved_by", { length: 36 }),
    approvedAt: datetime("approved_at"),
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
    alertType: varchar("alert_type", { length: 50 }).notNull(),
    severity: varchar("severity", { length: 20 }).notNull(),
    message: text("message").notNull(),
    isResolved: boolean("is_resolved").notNull().default(false),
    resolvedAt: datetime("resolved_at"),
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
    description: text("description").notNull(),
    status: varchar("status", { length: 20 }).notNull().default("open"),
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
    employeeId: varchar("employee_id", { length: 36 }),
    subject: varchar("subject", { length: 255 }).notNull(),
    message: text("message").notNull(),
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
