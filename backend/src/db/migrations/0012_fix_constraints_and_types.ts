import type { Connection } from "mysql2/promise";

import {
    addUniqueKeyIfNotExists,
    dropIndexIfExists,
    modifyColumnIfExists,
} from "./_helpers";

/**
 * Migration 0012: Fix data-type and constraint bugs introduced in earlier migrations.
 *
 * Problems fixed:
 * 1. farm_weight_records.weight_kg was varchar(20) — should be decimal(7,2)
 *    so SQL arithmetic and ordering work correctly on weight values.
 *
 * 2. plan_module_access had a plain (non-unique) index on (plan_id, module_id).
 *    Without a UNIQUE constraint, ON DUPLICATE KEY UPDATE in the seed file
 *    never fires (the PK is always a new UUID) and every seed run inserts
 *    duplicate rows. Upgrading to a UNIQUE constraint makes the seed
 *    fully idempotent.
 *
 * Safety: Before adding the unique constraint the migration deletes any
 * duplicate (plan_id, module_id) rows that may have accumulated from
 * previous seed runs, keeping the earliest inserted row.
 *
 * Idempotency: All DDL operations are guarded by helpers from _helpers.ts
 * so this migration is safe to replay against an already-patched database.
 */
export async function up(connection: Connection): Promise<void> {
  // ── 1. Fix farm_weight_records.weight_kg column type ──────────────────────
  await modifyColumnIfExists(
    connection,
    "farm_weight_records",
    "weight_kg",
    "decimal(7,2) NOT NULL",
  );

  // ── 2. Deduplicate plan_module_access before adding UNIQUE constraint ──────
  // Keep only the first-inserted row per (plan_id, module_id) pair.
  // MySQL does not allow DELETE … WHERE id NOT IN (SELECT … FROM same table)
  // directly, so we bounce through a temporary table.
  // DROP IF EXISTS first so re-running the migration is safe.
  await connection.execute(`DROP TEMPORARY TABLE IF EXISTS \`_pma_keep\``);

  await connection.execute(`
    CREATE TEMPORARY TABLE \`_pma_keep\`
      SELECT MIN(\`id\`) AS \`id\`
      FROM \`plan_module_access\`
      GROUP BY \`plan_id\`, \`module_id\`
  `);

  await connection.execute(`
    DELETE FROM \`plan_module_access\`
    WHERE \`id\` NOT IN (SELECT \`id\` FROM \`_pma_keep\`)
  `);

  await connection.execute(`DROP TEMPORARY TABLE IF EXISTS \`_pma_keep\``);

  // ── 3. Upgrade the index on plan_module_access to UNIQUE ──────────────────
  await dropIndexIfExists(
    connection,
    "plan_module_access",
    "plan_module_access_plan_module_idx",
  );

  await addUniqueKeyIfNotExists(
    connection,
    "plan_module_access",
    "plan_module_access_plan_module_idx",
    "`plan_id`, `module_id`",
  );
}
