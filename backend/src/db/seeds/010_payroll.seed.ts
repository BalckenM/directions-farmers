import { sql } from "drizzle-orm";
import { db } from "../../config/database";

/**
 * Seed 010: payroll demo data for farm-001.
 *
 * Inserts a realistic set of payroll records so that every payroll API
 * endpoint returns meaningful data out of the box.
 *
 * Tables populated:
 *   payroll_pay_groups        — 2 groups  (weekly, monthly)
 *   payroll_pay_structures    — 2 structures (hourly, monthly salary)
 *   payroll_deduction_rules   — 3 rules  (UIF, PAYE placeholder, funeral)
 *   payroll_employees         — 5 employees (3 permanent, 2 seasonal)
 *   payroll_contracts         — 5 active contracts (one per employee)
 *   payroll_leave_balances    — 20 rows  (5 employees × 4 leave types)
 *
 * All rows are idempotent via ON DUPLICATE KEY UPDATE.
 * farm_owner_id = 'farm-001' (created by seed 006).
 */

const now = "2025-01-15 08:00:00";

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

type PayGroupRow = {
  id: string;
  name: string;
  pay_frequency: string;
  pay_day: number | null;
  is_active: boolean;
  description: string | null;
};

type PayStructureRow = {
  id: string;
  name: string;
  wage_type: string | null;
  base_rate: number | null;
  nmwa_enforced: boolean;
  piecework_unit: string | null;
  piecework_min_units_per_day: number | null;
  components: string;
};

type DeductionRuleRow = {
  id: string;
  code: string | null;
  name: string;
  type: string;
  calculation_method: string;
  value: number;
  capped_at: number | null;
  employee_ids: string | null;
  is_active: boolean;
};

type EmployeeRow = {
  id: string;
  employee_number: string;
  first_name: string;
  last_name: string;
  id_number: string | null;
  phone: string | null;
  sex: string | null;
  nationality: string | null;
  start_date: string;
  engagement_type: string | null;
  occupation_title: string | null;
  pay_group_id: string | null;
  pay_structure_id: string | null;
  disbursement_method: string | null;
  has_housing_benefit: boolean;
  housing_value_per_month: number | null;
  has_food_benefit: boolean;
  preferred_language: string | null;
};

type ContractRow = {
  id: string;
  employee_id: string;
  contract_type: string;
  pay_frequency: string;
  base_salary: number;
  currency: string;
  start_date: string;
  status: string | null;
  job_description: string | null;
};

type LeaveBalanceRow = {
  id: string;
  employee_id: string;
  leave_type_id: string;
  balance: number;
};

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

const payGroups: PayGroupRow[] = [
  {
    id: "pg-001",
    name: "Seasonal / Casual",
    pay_frequency: "weekly",
    pay_day: 5,
    is_active: true,
    description: "Weekly wage for seasonal and casual farm workers",
  },
  {
    id: "pg-002",
    name: "Permanent Staff",
    pay_frequency: "monthly",
    pay_day: 25,
    is_active: true,
    description: "Monthly salary for full-time permanent employees",
  },
];

const payStructures: PayStructureRow[] = [
  {
    id: "ps-001",
    name: "Hourly Wage – NMWA",
    wage_type: "hourly",
    base_rate: 28.79,
    nmwa_enforced: true,
    piecework_unit: null,
    piecework_min_units_per_day: null,
    components: JSON.stringify([
      {
        code: "BASIC",
        name: "Basic Hourly Wage",
        type: "earning",
        method: "rate_x_hours",
      },
      {
        code: "UIF_EE",
        name: "UIF (Employee)",
        type: "deduction",
        method: "percentage",
        rate: 0.01,
      },
    ]),
  },
  {
    id: "ps-002",
    name: "Monthly Salary – Standard",
    wage_type: "monthly",
    base_rate: 12000.0,
    nmwa_enforced: true,
    piecework_unit: null,
    piecework_min_units_per_day: null,
    components: JSON.stringify([
      {
        code: "BASIC",
        name: "Basic Monthly Salary",
        type: "earning",
        method: "fixed",
      },
      {
        code: "UIF_EE",
        name: "UIF (Employee)",
        type: "deduction",
        method: "percentage",
        rate: 0.01,
      },
      {
        code: "PAYE",
        name: "PAYE Income Tax",
        type: "deduction",
        method: "tax_table",
      },
    ]),
  },
];

const deductionRules: DeductionRuleRow[] = [
  {
    id: "dr-001",
    code: "UIF",
    name: "UIF Employee Contribution",
    type: "statutory",
    calculation_method: "percentage",
    value: 0.01,
    capped_at: null,
    employee_ids: null,
    is_active: true,
  },
  {
    id: "dr-002",
    code: "PAYE",
    name: "PAYE Income Tax (placeholder)",
    type: "statutory",
    calculation_method: "percentage",
    value: 0.0,
    capped_at: null,
    employee_ids: null,
    is_active: true,
  },
  {
    id: "dr-003",
    code: "FUNERAL",
    name: "Funeral Benefit Contribution",
    type: "voluntary",
    calculation_method: "flat_amount",
    value: 50.0,
    capped_at: 50.0,
    employee_ids: null,
    is_active: true,
  },
];

const employees: EmployeeRow[] = [
  {
    id: "emp-001",
    employee_number: "EMP-0001",
    first_name: "Sipho",
    last_name: "Dlamini",
    id_number: "8501015800082",
    phone: "0821234567",
    sex: "male",
    nationality: "ZA",
    start_date: "2020-03-01",
    engagement_type: "permanent",
    occupation_title: "Farm Manager",
    pay_group_id: "pg-002",
    pay_structure_id: "ps-002",
    disbursement_method: "bank_transfer",
    has_housing_benefit: true,
    housing_value_per_month: 1500.0,
    has_food_benefit: false,
    preferred_language: "zu",
  },
  {
    id: "emp-002",
    employee_number: "EMP-0002",
    first_name: "Nomsa",
    last_name: "Khumalo",
    id_number: "9203126800087",
    phone: "0839876543",
    sex: "female",
    nationality: "ZA",
    start_date: "2022-01-10",
    engagement_type: "permanent",
    occupation_title: "Dairy Supervisor",
    pay_group_id: "pg-002",
    pay_structure_id: "ps-002",
    disbursement_method: "bank_transfer",
    has_housing_benefit: false,
    housing_value_per_month: null,
    has_food_benefit: true,
    preferred_language: "zu",
  },
  {
    id: "emp-003",
    employee_number: "EMP-0003",
    first_name: "Thabo",
    last_name: "Mokoena",
    id_number: "8807204800083",
    phone: "0765554321",
    sex: "male",
    nationality: "ZA",
    start_date: "2021-07-15",
    engagement_type: "permanent",
    occupation_title: "Livestock Handler",
    pay_group_id: "pg-002",
    pay_structure_id: "ps-002",
    disbursement_method: "cash",
    has_housing_benefit: true,
    housing_value_per_month: 1200.0,
    has_food_benefit: true,
    preferred_language: "st",
  },
  {
    id: "emp-004",
    employee_number: "EMP-0004",
    first_name: "Maria",
    last_name: "van der Berg",
    id_number: null,
    phone: "0710001122",
    sex: "female",
    nationality: "ZW",
    start_date: "2025-01-06",
    engagement_type: "seasonal",
    occupation_title: "Crop Harvester",
    pay_group_id: "pg-001",
    pay_structure_id: "ps-001",
    disbursement_method: "cash",
    has_housing_benefit: false,
    housing_value_per_month: null,
    has_food_benefit: false,
    preferred_language: "en",
  },
  {
    id: "emp-005",
    employee_number: "EMP-0005",
    first_name: "Johannes",
    last_name: "Pietersen",
    id_number: "7712105800086",
    phone: "0832223344",
    sex: "male",
    nationality: "ZA",
    start_date: "2023-04-01",
    engagement_type: "seasonal",
    occupation_title: "General Farm Worker",
    pay_group_id: "pg-001",
    pay_structure_id: "ps-001",
    disbursement_method: "bank_transfer",
    has_housing_benefit: false,
    housing_value_per_month: null,
    has_food_benefit: false,
    preferred_language: "af",
  },
];

const contracts: ContractRow[] = [
  {
    id: "con-001",
    employee_id: "emp-001",
    contract_type: "permanent",
    pay_frequency: "monthly",
    base_salary: 18000.0,
    currency: "ZAR",
    start_date: "2020-03-01",
    status: "active",
    job_description:
      "Overall management of farm operations, staff supervision, and reporting to the owner.",
  },
  {
    id: "con-002",
    employee_id: "emp-002",
    contract_type: "permanent",
    pay_frequency: "monthly",
    base_salary: 13500.0,
    currency: "ZAR",
    start_date: "2022-01-10",
    status: "active",
    job_description:
      "Supervise dairy operations including milking schedules, milk quality, and herd health monitoring.",
  },
  {
    id: "con-003",
    employee_id: "emp-003",
    contract_type: "permanent",
    pay_frequency: "monthly",
    base_salary: 11000.0,
    currency: "ZAR",
    start_date: "2021-07-15",
    status: "active",
    job_description:
      "Day-to-day handling of cattle and goat herds, feeding, and basic health checks.",
  },
  {
    id: "con-004",
    employee_id: "emp-004",
    contract_type: "fixed_term",
    pay_frequency: "weekly",
    base_salary: 28.79,
    currency: "ZAR",
    start_date: "2025-01-06",
    status: "active",
    job_description: "Harvesting and post-harvest handling of seasonal crops.",
  },
  {
    id: "con-005",
    employee_id: "emp-005",
    contract_type: "fixed_term",
    pay_frequency: "weekly",
    base_salary: 28.79,
    currency: "ZAR",
    start_date: "2023-04-01",
    status: "active",
    job_description:
      "General farm maintenance, fencing, irrigation, and animal feeding.",
  },
];

// 4 BCEA leave types (seeded in 005)
const leaveTypeIds = ["lt_annual", "lt_sick", "lt_maternity", "lt_family"];

// Starting balances (days):  annual=15, sick=30, maternity=120, family=3
const startingBalances: Record<string, number> = {
  lt_annual: 15,
  lt_sick: 30,
  lt_maternity: 120,
  lt_family: 3,
};

const leaveBalances: LeaveBalanceRow[] = employees.flatMap((e, ei) =>
  leaveTypeIds.map((ltId, li) => ({
    id: `lb-${String(ei + 1).padStart(3, "0")}-${li + 1}`,
    employee_id: e.id,
    leave_type_id: ltId,
    balance: startingBalances[ltId],
  })),
);

// ─────────────────────────────────────────────────────────────────────────────
// Runner
// ─────────────────────────────────────────────────────────────────────────────

export async function runPayrollSeed(): Promise<void> {
  // ── Pay groups ─────────────────────────────────────────────────────────────
  for (const pg of payGroups) {
    await db.execute(sql`
      INSERT INTO payroll_pay_groups
        (id, farm_owner_id, name, pay_frequency, pay_day, is_active, description, notes, created_at)
      VALUES
        (${pg.id}, 'farm-001', ${pg.name}, ${pg.pay_frequency}, ${pg.pay_day},
         ${pg.is_active}, ${pg.description}, NULL, ${now})
      ON DUPLICATE KEY UPDATE
        name = VALUES(name),
        pay_frequency = VALUES(pay_frequency),
        pay_day = VALUES(pay_day),
        is_active = VALUES(is_active),
        description = VALUES(description)
    `);
  }
  console.log(`payroll_pay_groups seeded (${payGroups.length} rows)`);

  // ── Pay structures ─────────────────────────────────────────────────────────
  for (const ps of payStructures) {
    await db.execute(sql`
      INSERT INTO payroll_pay_structures
        (id, farm_owner_id, name, wage_type, base_rate, nmwa_enforced,
         piecework_unit, piecework_min_units_per_day, components, created_at, updated_at)
      VALUES
        (${ps.id}, 'farm-001', ${ps.name}, ${ps.wage_type}, ${ps.base_rate},
         ${ps.nmwa_enforced}, ${ps.piecework_unit}, ${ps.piecework_min_units_per_day},
         ${ps.components}, ${now}, ${now})
      ON DUPLICATE KEY UPDATE
        name = VALUES(name),
        wage_type = VALUES(wage_type),
        base_rate = VALUES(base_rate),
        nmwa_enforced = VALUES(nmwa_enforced),
        components = VALUES(components),
        updated_at = VALUES(updated_at)
    `);
  }
  console.log(`payroll_pay_structures seeded (${payStructures.length} rows)`);

  // ── Deduction rules ────────────────────────────────────────────────────────
  for (const dr of deductionRules) {
    await db.execute(sql`
      INSERT INTO payroll_deduction_rules
        (id, farm_owner_id, code, name, type, calculation_method, value,
         capped_at, employee_ids, is_active, created_at, updated_at)
      VALUES
        (${dr.id}, 'farm-001', ${dr.code}, ${dr.name}, ${dr.type},
         ${dr.calculation_method}, ${dr.value}, ${dr.capped_at},
         ${dr.employee_ids}, ${dr.is_active}, ${now}, ${now})
      ON DUPLICATE KEY UPDATE
        code = VALUES(code),
        name = VALUES(name),
        type = VALUES(type),
        calculation_method = VALUES(calculation_method),
        value = VALUES(value),
        capped_at = VALUES(capped_at),
        is_active = VALUES(is_active),
        updated_at = VALUES(updated_at)
    `);
  }
  console.log(`payroll_deduction_rules seeded (${deductionRules.length} rows)`);

  // ── Employees ──────────────────────────────────────────────────────────────
  for (const e of employees) {
    await db.execute(sql`
      INSERT INTO payroll_employees
        (id, farm_owner_id, employee_number, first_name, last_name, id_number,
         phone, sex, nationality, start_date, is_active, engagement_type,
         occupation_title, pay_group_id, pay_structure_id, disbursement_method,
         has_housing_benefit, housing_value_per_month, has_food_benefit,
         preferred_language, notes, created_at, updated_at)
      VALUES
        (${e.id}, 'farm-001', ${e.employee_number}, ${e.first_name}, ${e.last_name},
         ${e.id_number}, ${e.phone}, ${e.sex}, ${e.nationality}, ${e.start_date},
         TRUE, ${e.engagement_type}, ${e.occupation_title}, ${e.pay_group_id},
         ${e.pay_structure_id}, ${e.disbursement_method}, ${e.has_housing_benefit},
         ${e.housing_value_per_month}, ${e.has_food_benefit}, ${e.preferred_language},
         NULL, ${now}, ${now})
      ON DUPLICATE KEY UPDATE
        first_name = VALUES(first_name),
        last_name = VALUES(last_name),
        phone = VALUES(phone),
        engagement_type = VALUES(engagement_type),
        occupation_title = VALUES(occupation_title),
        pay_group_id = VALUES(pay_group_id),
        pay_structure_id = VALUES(pay_structure_id),
        disbursement_method = VALUES(disbursement_method),
        has_housing_benefit = VALUES(has_housing_benefit),
        housing_value_per_month = VALUES(housing_value_per_month),
        has_food_benefit = VALUES(has_food_benefit),
        preferred_language = VALUES(preferred_language),
        updated_at = VALUES(updated_at)
    `);
  }
  console.log(`payroll_employees seeded (${employees.length} rows)`);

  // ── Contracts ──────────────────────────────────────────────────────────────
  for (const c of contracts) {
    await db.execute(sql`
      INSERT INTO payroll_contracts
        (id, farm_owner_id, employee_id, contract_type, pay_frequency,
         base_salary, currency, start_date, is_active, status, job_description,
         created_at, updated_at)
      VALUES
        (${c.id}, 'farm-001', ${c.employee_id}, ${c.contract_type},
         ${c.pay_frequency}, ${c.base_salary}, ${c.currency}, ${c.start_date},
         TRUE, ${c.status}, ${c.job_description}, ${now}, ${now})
      ON DUPLICATE KEY UPDATE
        contract_type = VALUES(contract_type),
        pay_frequency = VALUES(pay_frequency),
        base_salary = VALUES(base_salary),
        is_active = VALUES(is_active),
        status = VALUES(status),
        job_description = VALUES(job_description),
        updated_at = VALUES(updated_at)
    `);
  }
  console.log(`payroll_contracts seeded (${contracts.length} rows)`);

  // ── Leave balances ─────────────────────────────────────────────────────────
  for (const lb of leaveBalances) {
    await db.execute(sql`
      INSERT INTO payroll_leave_balances
        (id, farm_owner_id, employee_id, leave_type_id, balance, updated_at)
      VALUES
        (${lb.id}, 'farm-001', ${lb.employee_id}, ${lb.leave_type_id},
         ${lb.balance}, ${now})
      ON DUPLICATE KEY UPDATE
        balance = VALUES(balance),
        updated_at = VALUES(updated_at)
    `);
  }
  console.log(`payroll_leave_balances seeded (${leaveBalances.length} rows)`);
}
