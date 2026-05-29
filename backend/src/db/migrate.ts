/**
 * ┌─────────────────────────────────────────────────────────────────────────┐
 * │  Database Migration Runner — 4DFarmer API                               │
 * │                                                                          │
 * │  Design principles                                                       │
 * │  ─────────────────                                                       │
 * │  • Every migration is executed EXACTLY ONCE per environment.            │
 * │    Applied migrations are tracked in the `schema_migrations` table.     │
 * │  • Migration files are auto-discovered and sorted by their 4-digit      │
 * │    numeric prefix — order is deterministic and human-readable.          │
 * │  • Migrations are idempotent by design (see rules below).               │
 * │  • A single DB connection is held for the entire run so that            │
 * │    session-scoped objects (e.g. TEMPORARY TABLEs) behave correctly.     │
 * │  • On error the runner exits with code 1.  Already-applied migrations   │
 * │    are never re-run.                                                     │
 * │                                                                          │
 * │  Idempotency rules (enforced in every migration file)                   │
 * │  ────────────────────────────────────────────────────                   │
 * │   CREATE TABLE  →  always use  CREATE TABLE IF NOT EXISTS               │
 * │   ADD COLUMN    →  always use  addColumnIfNotExists()  from _helpers    │
 * │   MODIFY COLUMN →  always use  modifyColumnIfExists()  from _helpers    │
 * │   DROP INDEX    →  always use  dropIndexIfExists()     from _helpers    │
 * │   ADD INDEX     →  always use  addUniqueKeyIfNotExists / addIndexIfNotExists │
 * │   DROP TABLE    →  FORBIDDEN — migrations must never delete tables      │
 * │   DROP COLUMN   →  FORBIDDEN — retire columns by making them nullable   │
 * │                                                                          │
 * │  File naming convention                                                  │
 * │  ──────────────────────                                                  │
 * │    NNNN_<verb>_<description>.ts                                          │
 * │    e.g.  0018_add_crop_season_columns.ts                                 │
 * │    Files whose names start with  _  are excluded (helpers / templates). │
 * │                                                                          │
 * │  Run:  npm run db:migrate                                                │
 * └─────────────────────────────────────────────────────────────────────────┘
 */
import fs from "fs";
import type { Connection, RowDataPacket } from "mysql2/promise";
import path from "path";
import pino from "pino";

// Load and validate env before anything else
import { pool } from "../config/database";
import "../config/env";

const logger = pino({ name: "migrate", transport: { target: "pino-pretty" } });

const MIGRATIONS_DIR = path.join(__dirname, "migrations");

// ── Tracking table ────────────────────────────────────────────────────────────

/**
 * Creates `schema_migrations` if it does not yet exist.
 * This table is the single source of truth for which migrations have run.
 */
async function ensureTrackingTable(connection: Connection): Promise<void> {
  // Create table if it does not exist (full schema)
  await connection.execute(`
    CREATE TABLE IF NOT EXISTS \`schema_migrations\` (
      \`name\`              varchar(255) NOT NULL COMMENT 'Migration filename, e.g. 0001_create_auth_tables.ts',
      \`applied_at\`        datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'UTC timestamp when migration was applied',
      \`execution_time_ms\` int          NOT NULL DEFAULT 0 COMMENT 'Wall-clock duration in milliseconds',
      CONSTRAINT \`schema_migrations_pk\` PRIMARY KEY (\`name\`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
      COMMENT='Tracks applied database migrations — managed by the migration runner'
  `);

  // Upgrade pre-existing tables that are missing the execution_time_ms column
  await connection.execute(`
    ALTER TABLE \`schema_migrations\`
      ADD COLUMN IF NOT EXISTS \`execution_time_ms\` int NOT NULL DEFAULT 0
        COMMENT 'Wall-clock duration in milliseconds'
  `);
}

/** Returns the set of migration filenames that have already been applied. */
async function getApplied(connection: Connection): Promise<Set<string>> {
  const [rows] = await connection.execute<RowDataPacket[]>(
    "SELECT `name` FROM `schema_migrations` ORDER BY `name`",
  );
  return new Set(rows.map((r) => r.name as string));
}

// ── File discovery ────────────────────────────────────────────────────────────

/**
 * Returns all runnable migration filenames in ascending numeric order.
 * Files whose names start with `_` are excluded (they are helpers or templates).
 */
function discoverMigrations(): string[] {
  return fs
    .readdirSync(MIGRATIONS_DIR)
    .filter((f) => /^\d{4}_.*\.ts$/.test(f)) // 4-digit prefix, no leading underscore
    .sort(); // lexicographic order == numeric order for zero-padded filenames
}

// ── Runner ────────────────────────────────────────────────────────────────────

async function main(): Promise<void> {
  logger.info("Migration runner starting…");

  const connection = await pool.getConnection();

  try {
    await ensureTrackingTable(connection);

    const applied = await getApplied(connection);
    const all = discoverMigrations();
    const pending = all.filter((f) => !applied.has(f));

    logger.info(
      `Migrations — total: ${all.length}  applied: ${applied.size}  pending: ${pending.length}`,
    );

    if (pending.length === 0) {
      logger.info("✓ Database is up to date — nothing to do.");
      return;
    }

    for (const file of pending) {
      const fullPath = path.join(MIGRATIONS_DIR, file);
      logger.info(`→ Applying ${file} …`);

      const start = Date.now();

      // CommonJS require() works reliably with tsx for TypeScript source files.
      // Migration files must export:  async function up(connection): Promise<void>
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      const mod = require(fullPath) as Record<string, unknown>;

      if (typeof mod.up !== "function") {
        throw new Error(
          `Migration "${file}" must export:\n` +
            `  export async function up(connection: Connection): Promise<void>`,
        );
      }

      await (mod.up as (c: Connection) => Promise<void>)(connection);

      const ms = Date.now() - start;

      await connection.execute(
        "INSERT INTO `schema_migrations` (`name`, `applied_at`, `execution_time_ms`) VALUES (?, NOW(), ?)",
        [file, ms],
      );

      logger.info(`✓ ${file}  (${ms} ms)`);
    }

    logger.info(
      `All ${pending.length} pending migration(s) applied successfully.`,
    );
  } catch (err) {
    logger.error({ err }, "Migration failed — runner aborted");
    throw err;
  } finally {
    connection.release();
    await pool.end();
  }
}

main().catch((err: unknown) => {
  logger.error({ err }, "Unhandled error in migration runner");
  process.exit(1);
});
