import type { Connection } from "mysql2/promise";

import { addColumnIfNotExists } from "./_helpers";

/**
 * Migration 0013: Add missing columns to payroll_leave_types.
 *
 * The Dart LeaveType model (leave_type.dart) defines the following fields
 * that were absent from the original migration:
 *   - code             VARCHAR(50) — machine code e.g. 'ANNUAL', 'SICK'
 *   - requires_approval BOOLEAN   — whether manager approval is required
 *   - color_hex        VARCHAR(7)  — UI display colour e.g. '#2E7D32'
 *   - description      TEXT        — optional BCEA reference note
 *
 * Adding them here keeps the DB schema in sync with the mobile app model
 * so the remote data source can read/write every field the app expects.
 *
 * Idempotency: each column is added only if it does not yet exist.
 */
export async function up(connection: Connection): Promise<void> {
  await addColumnIfNotExists(
    connection,
    "payroll_leave_types",
    "code",
    "varchar(50) NOT NULL DEFAULT '' AFTER `farm_owner_id`",
  );

  await addColumnIfNotExists(
    connection,
    "payroll_leave_types",
    "requires_approval",
    "boolean NOT NULL DEFAULT true AFTER `is_paid`",
  );

  await addColumnIfNotExists(
    connection,
    "payroll_leave_types",
    "color_hex",
    "varchar(7) NULL AFTER `requires_approval`",
  );

  await addColumnIfNotExists(
    connection,
    "payroll_leave_types",
    "description",
    "text NULL AFTER `color_hex`",
  );
}
