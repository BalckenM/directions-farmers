import type { Connection } from "mysql2/promise";

import { addColumnIfNotExists } from "./_helpers";

/**
 * Migration 0017: Add missing columns to payroll tables.
 *
 * Five payroll tables are enhanced to match the Dart model fields that
 * were omitted from the original migration (0010_create_payroll_tables.ts).
 *
 * Tables affected:
 *
 *   payroll_employees
 *     address, next_of_kin_name, next_of_kin_phone, engagement_type,
 *     occupation_title, pay_group_id, pay_structure_id, disbursement_method,
 *     has_housing_benefit, housing_value_per_month, has_food_benefit,
 *     preferred_language
 *
 *   payroll_contracts
 *     status, job_description, signed_at
 *
 *   payroll_pay_groups
 *     is_active, description
 *
 *   payroll_pay_structures
 *     wage_type, base_rate, nmwa_enforced, piecework_unit,
 *     piecework_min_units_per_day
 *
 *   payroll_deduction_rules
 *     code, capped_at, employee_ids
 *
 * Idempotency: each column is added only if it does not yet exist.
 */
export async function up(connection: Connection): Promise<void> {
  // ── payroll_employees ──────────────────────────────────────────────────────
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "address",
    "text NULL AFTER `phone`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "next_of_kin_name",
    "varchar(255) NULL AFTER `address`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "next_of_kin_phone",
    "varchar(20) NULL AFTER `next_of_kin_name`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "engagement_type",
    "varchar(50) NULL AFTER `is_active`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "occupation_title",
    "varchar(100) NULL AFTER `engagement_type`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "pay_group_id",
    "varchar(36) NULL AFTER `occupation_title`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "pay_structure_id",
    "varchar(36) NULL AFTER `pay_group_id`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "disbursement_method",
    "varchar(50) NULL AFTER `pay_structure_id`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "has_housing_benefit",
    "boolean NOT NULL DEFAULT false AFTER `disbursement_method`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "housing_value_per_month",
    "decimal(8,2) NULL AFTER `has_housing_benefit`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "has_food_benefit",
    "boolean NOT NULL DEFAULT false AFTER `housing_value_per_month`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_employees",
    "preferred_language",
    "varchar(10) NULL AFTER `has_food_benefit`",
  );

  // ── payroll_contracts ──────────────────────────────────────────────────────
  await addColumnIfNotExists(
    connection,
    "payroll_contracts",
    "status",
    "varchar(50) NULL AFTER `is_active`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_contracts",
    "job_description",
    "text NULL AFTER `status`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_contracts",
    "signed_at",
    "datetime NULL AFTER `job_description`",
  );

  // ── payroll_pay_groups ─────────────────────────────────────────────────────
  await addColumnIfNotExists(
    connection,
    "payroll_pay_groups",
    "is_active",
    "boolean NOT NULL DEFAULT true AFTER `pay_day`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_pay_groups",
    "description",
    "text NULL AFTER `is_active`",
  );

  // ── payroll_pay_structures ─────────────────────────────────────────────────
  await addColumnIfNotExists(
    connection,
    "payroll_pay_structures",
    "wage_type",
    "varchar(50) NULL AFTER `name`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_pay_structures",
    "base_rate",
    "decimal(10,2) NULL AFTER `wage_type`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_pay_structures",
    "nmwa_enforced",
    "boolean NOT NULL DEFAULT true AFTER `base_rate`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_pay_structures",
    "piecework_unit",
    "varchar(50) NULL AFTER `nmwa_enforced`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_pay_structures",
    "piecework_min_units_per_day",
    "decimal(8,2) NULL AFTER `piecework_unit`",
  );

  // ── payroll_deduction_rules ────────────────────────────────────────────────
  await addColumnIfNotExists(
    connection,
    "payroll_deduction_rules",
    "code",
    "varchar(50) NULL AFTER `farm_owner_id`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_deduction_rules",
    "capped_at",
    "decimal(10,2) NULL AFTER `value`",
  );
  await addColumnIfNotExists(
    connection,
    "payroll_deduction_rules",
    "employee_ids",
    "text NULL AFTER `capped_at`",
  );
}
