import type { Connection } from "mysql2/promise";

/**
 * Migration 0018: Create payroll operations tables.
 *
 * Adds four new tables for workforce management:
 *   - payroll_shifts            — scheduled work shifts
 *   - payroll_task_assignments  — tasks assigned to employees
 *   - payroll_attendance_records — daily clock-in/out tracking
 *   - payroll_employer_config   — farm-level payroll settings
 *
 * Idempotency: all statements use CREATE TABLE IF NOT EXISTS.
 */
export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // payroll_shifts — scheduled work shifts per employee
    `CREATE TABLE IF NOT EXISTS \`payroll_shifts\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36) NOT NULL,
      \`shift_date\` date NOT NULL,
      \`start_time\` varchar(10) NOT NULL,
      \`end_time\` varchar(10) NOT NULL,
      \`break_minutes\` int NOT NULL DEFAULT 0,
      \`shift_type\` varchar(50),
      \`status\` varchar(20) NOT NULL DEFAULT 'scheduled',
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_shifts_id\` PRIMARY KEY (\`id\`),
      INDEX \`payroll_shifts_farm_owner_idx\` (\`farm_owner_id\`),
      INDEX \`payroll_shifts_employee_idx\` (\`employee_id\`)
    )`,

    // payroll_task_assignments — tasks assigned to employees with priority & status
    `CREATE TABLE IF NOT EXISTS \`payroll_task_assignments\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36) NOT NULL,
      \`task_name\` varchar(255) NOT NULL,
      \`assigned_date\` date NOT NULL,
      \`due_date\` date,
      \`completed_at\` datetime,
      \`status\` varchar(20) NOT NULL DEFAULT 'assigned',
      \`priority\` varchar(20) DEFAULT 'normal',
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_task_assignments_id\` PRIMARY KEY (\`id\`),
      INDEX \`payroll_task_assignments_farm_owner_idx\` (\`farm_owner_id\`),
      INDEX \`payroll_task_assignments_employee_idx\` (\`employee_id\`)
    )`,

    // payroll_attendance_records — daily attendance with clock in/out
    `CREATE TABLE IF NOT EXISTS \`payroll_attendance_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`employee_id\` varchar(36) NOT NULL,
      \`attendance_date\` date NOT NULL,
      \`clock_in\` varchar(10),
      \`clock_out\` varchar(10),
      \`hours_worked\` decimal(5,2),
      \`status\` varchar(20) NOT NULL DEFAULT 'present',
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_attendance_records_id\` PRIMARY KEY (\`id\`),
      INDEX \`payroll_attendance_records_farm_owner_idx\` (\`farm_owner_id\`),
      INDEX \`payroll_attendance_records_employee_idx\` (\`employee_id\`)
    )`,

    // payroll_employer_config — one-per-farm configuration (tax refs, pay day, etc.)
    `CREATE TABLE IF NOT EXISTS \`payroll_employer_config\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`company_name\` varchar(255),
      \`tax_number\` varchar(50),
      \`uif_number\` varchar(50),
      \`sdl_number\` varchar(50),
      \`pay_day\` int DEFAULT 25,
      \`overtime_multiplier\` decimal(3,2) DEFAULT 1.50,
      \`currency\` varchar(3) DEFAULT 'ZAR',
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`payroll_employer_config_id\` PRIMARY KEY (\`id\`),
      UNIQUE KEY \`payroll_employer_config_farm_owner_unique\` (\`farm_owner_id\`),
      INDEX \`payroll_employer_config_farm_owner_idx\` (\`farm_owner_id\`)
    )`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
