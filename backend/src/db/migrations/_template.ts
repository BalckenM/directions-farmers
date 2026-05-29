/**
 * ╔════════════════════════════════════════════════════════════════════════╗
 * ║  MIGRATION TEMPLATE — copy this file, do NOT run it directly          ║
 * ║                                                                         ║
 * ║  Steps to create a new migration                                        ║
 * ║  ──────────────────────────────                                         ║
 * ║  1. Copy this file to a new name following the convention below.       ║
 * ║  2. Delete the example code inside up() and write your own.            ║
 * ║  3. Remove unused helper imports.                                       ║
 * ║  4. Run  npm run db:migrate  to apply.                                  ║
 * ║                                                                         ║
 * ║  File naming convention:  NNNN_<verb>_<description>.ts                 ║
 * ║  Where NNNN is the next available 4-digit sequence number.             ║
 * ║                                                                         ║
 * ║  Examples                                                               ║
 * ║    0018_add_crop_season_columns.ts                                      ║
 * ║    0019_create_notifications_table.ts                                   ║
 * ║    0020_alter_staff_add_role_column.ts                                  ║
 * ╚════════════════════════════════════════════════════════════════════════╝
 *
 * ── Idempotency rules (REQUIRED — enforced by code review) ───────────────────
 *
 *  1. CREATE TABLE
 *       Always  CREATE TABLE IF NOT EXISTS — never plain CREATE TABLE.
 *
 *  2. ADD COLUMN
 *       Always  addColumnIfNotExists(connection, table, column, definition)
 *       Never a bare  ALTER TABLE … ADD COLUMN … statement.
 *
 *  3. MODIFY / CHANGE COLUMN
 *       Always  modifyColumnIfExists(connection, table, column, definition)
 *
 *  4. DROP INDEX / ADD UNIQUE KEY
 *       Always  dropIndexIfExists() before removing an index.
 *       Always  addUniqueKeyIfNotExists() / addIndexIfNotExists() when adding.
 *
 *  5. DROP TABLE / DROP COLUMN
 *       ✗  FORBIDDEN — migrations must never destroy data.
 *       Retire a column by making it nullable and stopping writes to it.
 *
 *  6. Seed data
 *       Migrations must only change schema — all reference / demo data
 *       belongs in seed files under src/db/seeds/.
 *
 * These rules guarantee the runner is safe to replay against a database that
 * already has some (or all) of the changes applied.
 */
import type { Connection } from "mysql2/promise";

import {
    addColumnIfNotExists,
} from "./_helpers";

// ── The only required export ──────────────────────────────────────────────────
export async function up(connection: Connection): Promise<void> {
  // ── Example: create a new table ────────────────────────────────────────────
  await connection.execute(`
    CREATE TABLE IF NOT EXISTS \`example_table\` (
      \`id\`         varchar(36)  NOT NULL,
      \`name\`       varchar(100) NOT NULL,
      \`created_at\` datetime     NOT NULL,
      CONSTRAINT \`example_table_pk\` PRIMARY KEY (\`id\`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);

  // ── Example: add a column to an existing table ─────────────────────────────
  await addColumnIfNotExists(
    connection,
    "example_table", // table name
    "description", // column name
    "text NULL AFTER `name`", // full definition fragment
  );
}
