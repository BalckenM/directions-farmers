/**
 * Migration DDL Helpers — idempotent guard functions
 *
 * ────────────────────────────────────────────────────────────────────────────
 * RULE: Every migration that ALTERs an existing table MUST use these helpers
 * instead of raw ALTER TABLE statements.  This ensures every migration is
 * safe to replay on a database where columns or indexes already exist (e.g.
 * after a partial run, a manual hotfix, or a fresh re-run of the full suite).
 *
 * Available helpers
 * ─────────────────
 *   addColumnIfNotExists     — ADD COLUMN guarded by INFORMATION_SCHEMA check
 *   modifyColumnIfExists     — MODIFY COLUMN, silent no-op if column missing
 *   dropColumnIfExists       — DROP COLUMN, silent no-op if column missing
 *   indexExists              — returns boolean
 *   dropIndexIfExists        — DROP INDEX, silent no-op
 *   addUniqueKeyIfNotExists  — ADD UNIQUE KEY, silent no-op if already present
 *
 * Example usage in a migration file
 * ──────────────────────────────────
 *   import { addColumnIfNotExists } from "./_helpers";
 *
 *   await addColumnIfNotExists(
 *     connection, "my_table", "new_col",
 *     "varchar(100) NULL AFTER `existing_col`",
 *   );
 * ────────────────────────────────────────────────────────────────────────────
 */
import type { Connection, RowDataPacket } from "mysql2/promise";

// ── Column helpers ────────────────────────────────────────────────────────────

/** Returns true if the column already exists in the given table. */
export async function columnExists(
  connection: Connection,
  table: string,
  column: string,
): Promise<boolean> {
  const [rows] = await connection.execute<RowDataPacket[]>(
    `SELECT COUNT(*) AS cnt
     FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME   = ?
       AND COLUMN_NAME  = ?`,
    [table, column],
  );
  return (rows[0].cnt as number) > 0;
}

/**
 * Adds a column only if it does not yet exist.
 *
 * @param definition  SQL fragment after the column name, e.g.:
 *                    "varchar(100) NOT NULL DEFAULT '' AFTER `some_col`"
 */
export async function addColumnIfNotExists(
  connection: Connection,
  table: string,
  column: string,
  definition: string,
): Promise<void> {
  if (await columnExists(connection, table, column)) return;
  await connection.execute(
    `ALTER TABLE \`${table}\` ADD COLUMN \`${column}\` ${definition}`,
  );
}

/**
 * Modifies a column definition only if the column already exists.
 * Safe no-op when the column is missing.
 *
 * @param definition  Full column definition, e.g.: "decimal(7,2) NOT NULL"
 */
export async function modifyColumnIfExists(
  connection: Connection,
  table: string,
  column: string,
  definition: string,
): Promise<void> {
  if (!(await columnExists(connection, table, column))) return;
  await connection.execute(
    `ALTER TABLE \`${table}\` MODIFY COLUMN \`${column}\` ${definition}`,
  );
}

/**
 * Drops a column only if it exists.
 * NOTE: Dropping columns is irreversible — use with extreme care.
 */
export async function dropColumnIfExists(
  connection: Connection,
  table: string,
  column: string,
): Promise<void> {
  if (!(await columnExists(connection, table, column))) return;
  await connection.execute(
    `ALTER TABLE \`${table}\` DROP COLUMN \`${column}\``,
  );
}

// ── Index helpers ─────────────────────────────────────────────────────────────

/** Returns true if the named index (or UNIQUE KEY) exists on the table. */
export async function indexExists(
  connection: Connection,
  table: string,
  indexName: string,
): Promise<boolean> {
  const [rows] = await connection.execute<RowDataPacket[]>(
    `SELECT COUNT(*) AS cnt
     FROM INFORMATION_SCHEMA.STATISTICS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME   = ?
       AND INDEX_NAME   = ?`,
    [table, indexName],
  );
  return (rows[0].cnt as number) > 0;
}

/** Drops an index only if it exists on the table. */
export async function dropIndexIfExists(
  connection: Connection,
  table: string,
  indexName: string,
): Promise<void> {
  if (!(await indexExists(connection, table, indexName))) return;
  await connection.execute(
    `ALTER TABLE \`${table}\` DROP INDEX \`${indexName}\``,
  );
}

/**
 * Adds a UNIQUE KEY only if it does not already exist.
 *
 * @param columnList  Comma-separated column names, e.g. "`plan_id`, `module_id`"
 */
export async function addUniqueKeyIfNotExists(
  connection: Connection,
  table: string,
  keyName: string,
  columnList: string,
): Promise<void> {
  if (await indexExists(connection, table, keyName)) return;
  await connection.execute(
    `ALTER TABLE \`${table}\` ADD UNIQUE KEY \`${keyName}\` (${columnList})`,
  );
}

/**
 * Adds a plain (non-unique) INDEX only if it does not already exist.
 *
 * @param columnList  Comma-separated column names
 */
export async function addIndexIfNotExists(
  connection: Connection,
  table: string,
  indexName: string,
  columnList: string,
): Promise<void> {
  if (await indexExists(connection, table, indexName)) return;
  await connection.execute(
    `ALTER TABLE \`${table}\` ADD INDEX \`${indexName}\` (${columnList})`,
  );
}
