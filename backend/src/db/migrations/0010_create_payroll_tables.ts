import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // payroll_employees — worker profile with banking and personal details
    `CREATE TABLE IF NOT EXISTS \`payroll_employees\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_number\` varchar(50) NOT NULL,
      \`first_name\` varchar(100) NOT NULL,
      \`last_name\` varchar(100) NOT NULL,
      \`id_number\` varchar(50),
      \`tax_number\` varchar(50),
      \`email\` varchar(255),
      \`phone\` varchar(20),
      \`date_of_birth\` date,
      \`sex\` varchar(10),
      \`nationality\` varchar(50),
      \`bank_name\` varchar(100),
      \`bank_account_number\` varchar(50),
      \`bank_branch_code\` varchar(20),
      \`start_date\` date NOT NULL,
      \`end_date\` date,
      \`is_active\` boolean NOT NULL DEFAULT true,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_employees_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_contracts — employment contract terms (type, frequency, salary)
    `CREATE TABLE IF NOT EXISTS \`payroll_contracts\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36) NOT NULL,
      \`contract_type\` varchar(50) NOT NULL,
      \`pay_frequency\` varchar(20) NOT NULL,
      \`base_salary\` decimal(10,2) NOT NULL,
      \`currency\` varchar(3) NOT NULL DEFAULT 'ZAR',
      \`start_date\` date NOT NULL,
      \`end_date\` date,
      \`is_active\` boolean NOT NULL DEFAULT true,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_contracts_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_pay_groups — groups employees by pay frequency / schedule
    `CREATE TABLE IF NOT EXISTS \`payroll_pay_groups\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`pay_frequency\` varchar(20) NOT NULL,
      \`pay_day\` int,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_pay_groups_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_pay_structures — reusable earnings component templates
    `CREATE TABLE IF NOT EXISTS \`payroll_pay_structures\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`components\` text NOT NULL,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_pay_structures_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_deduction_rules — reusable deduction definitions (UIF, tax, etc.)
    `CREATE TABLE IF NOT EXISTS \`payroll_deduction_rules\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`type\` varchar(50) NOT NULL,
      \`calculation_method\` varchar(20) NOT NULL,
      \`value\` decimal(10,4) NOT NULL,
      \`is_active\` boolean NOT NULL DEFAULT true,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_deduction_rules_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_leave_types — farm-specific leave categories with accrual rules
    `CREATE TABLE IF NOT EXISTS \`payroll_leave_types\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`accrual_days_per_year\` decimal(5,2) NOT NULL,
      \`is_paid\` boolean NOT NULL DEFAULT true,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_leave_types_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_pay_runs — a single payroll processing cycle
    `CREATE TABLE IF NOT EXISTS \`payroll_pay_runs\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`pay_group_id\` varchar(36),
      \`period_start\` date NOT NULL,
      \`period_end\` date NOT NULL,
      \`pay_date\` date NOT NULL,
      \`status\` varchar(20) NOT NULL DEFAULT 'draft',
      \`total_gross\` decimal(12,2) NOT NULL DEFAULT '0',
      \`total_deductions\` decimal(12,2) NOT NULL DEFAULT '0',
      \`total_net\` decimal(12,2) NOT NULL DEFAULT '0',
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_pay_runs_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_payslips — individual pay slip generated per employee per pay run
    `CREATE TABLE IF NOT EXISTS \`payroll_payslips\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`pay_run_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36) NOT NULL,
      \`gross_pay\` decimal(10,2) NOT NULL,
      \`total_deductions\` decimal(10,2) NOT NULL,
      \`net_pay\` decimal(10,2) NOT NULL,
      \`pdf_data\` text,
      \`line_items\` text NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_payslips_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_transactions — individual payment entries (advances, deductions, etc.)
    `CREATE TABLE IF NOT EXISTS \`payroll_transactions\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36) NOT NULL,
      \`pay_run_id\` varchar(36),
      \`type\` varchar(50) NOT NULL,
      \`description\` varchar(255),
      \`amount\` decimal(10,2) NOT NULL,
      \`transaction_date\` date NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_transactions_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_leave_requests — employee leave applications with approval workflow
    `CREATE TABLE IF NOT EXISTS \`payroll_leave_requests\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36) NOT NULL,
      \`leave_type_id\` varchar(36) NOT NULL,
      \`start_date\` date NOT NULL,
      \`end_date\` date NOT NULL,
      \`days_requested\` decimal(5,2) NOT NULL,
      \`status\` varchar(20) NOT NULL DEFAULT 'pending',
      \`reason\` text,
      \`approved_by\` varchar(36),
      \`approved_at\` datetime,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_leave_requests_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_leave_balances — current leave balance per employee per leave type
    `CREATE TABLE IF NOT EXISTS \`payroll_leave_balances\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36) NOT NULL,
      \`leave_type_id\` varchar(36) NOT NULL,
      \`balance\` decimal(7,2) NOT NULL DEFAULT '0',
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_leave_balances_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_piecework_logs — task-based piece-rate earnings
    `CREATE TABLE IF NOT EXISTS \`payroll_piecework_logs\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36) NOT NULL,
      \`task_name\` varchar(255) NOT NULL,
      \`quantity\` decimal(10,2) NOT NULL,
      \`rate_per_unit\` decimal(8,4) NOT NULL,
      \`total_amount\` decimal(10,2) NOT NULL,
      \`work_date\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_piecework_logs_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_garnishee_orders — court-ordered wage deductions
    `CREATE TABLE IF NOT EXISTS \`payroll_garnishee_orders\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36) NOT NULL,
      \`case_number\` varchar(100),
      \`amount\` decimal(10,2) NOT NULL,
      \`creditor_name\` varchar(255),
      \`start_date\` date NOT NULL,
      \`end_date\` date,
      \`is_active\` boolean NOT NULL DEFAULT true,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_garnishee_orders_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_communications — payroll-related messages to employees
    `CREATE TABLE IF NOT EXISTS \`payroll_communications\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36),
      \`subject\` varchar(255) NOT NULL,
      \`message\` text NOT NULL,
      \`sent_at\` datetime,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_communications_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_incidents — disciplinary incidents and workplace events
    `CREATE TABLE IF NOT EXISTS \`payroll_incidents\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36),
      \`incident_date\` date NOT NULL,
      \`type\` varchar(50) NOT NULL,
      \`description\` text NOT NULL,
      \`status\` varchar(20) NOT NULL DEFAULT 'open',
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_incidents_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_compliance_alerts — automated regulatory compliance warnings
    `CREATE TABLE IF NOT EXISTS \`payroll_compliance_alerts\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`alert_type\` varchar(50) NOT NULL,
      \`severity\` varchar(20) NOT NULL,
      \`message\` text NOT NULL,
      \`is_resolved\` boolean NOT NULL DEFAULT false,
      \`resolved_at\` datetime,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_compliance_alerts_id\` PRIMARY KEY (\`id\`)
    )`,

    // payroll_audit_log — immutable record of all payroll changes
    `CREATE TABLE IF NOT EXISTS \`payroll_audit_log\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`actor_id\` varchar(36) NOT NULL,
      \`action\` varchar(100) NOT NULL,
      \`resource_type\` varchar(50) NOT NULL,
      \`resource_id\` varchar(36),
      \`old_values\` text,
      \`new_values\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_audit_log_id\` PRIMARY KEY (\`id\`)
    )`,

    // Indexes
    `CREATE INDEX IF NOT EXISTS \`payroll_employees_farm_owner_idx\` ON \`payroll_employees\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_contracts_farm_owner_idx\` ON \`payroll_contracts\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_contracts_employee_idx\` ON \`payroll_contracts\` (\`employee_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_pay_groups_farm_owner_idx\` ON \`payroll_pay_groups\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_pay_structures_farm_owner_idx\` ON \`payroll_pay_structures\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_deduction_rules_farm_owner_idx\` ON \`payroll_deduction_rules\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_leave_types_farm_owner_idx\` ON \`payroll_leave_types\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_pay_runs_farm_owner_idx\` ON \`payroll_pay_runs\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_payslips_farm_owner_idx\` ON \`payroll_payslips\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_payslips_pay_run_idx\` ON \`payroll_payslips\` (\`pay_run_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_payslips_employee_idx\` ON \`payroll_payslips\` (\`employee_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_transactions_farm_owner_idx\` ON \`payroll_transactions\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_leave_requests_farm_owner_idx\` ON \`payroll_leave_requests\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_leave_balances_farm_owner_idx\` ON \`payroll_leave_balances\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_piecework_logs_farm_owner_idx\` ON \`payroll_piecework_logs\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_garnishee_orders_farm_owner_idx\` ON \`payroll_garnishee_orders\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_communications_farm_owner_idx\` ON \`payroll_communications\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_incidents_farm_owner_idx\` ON \`payroll_incidents\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_compliance_alerts_farm_owner_idx\` ON \`payroll_compliance_alerts\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`payroll_audit_log_farm_owner_idx\` ON \`payroll_audit_log\` (\`farm_owner_id\`)`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
