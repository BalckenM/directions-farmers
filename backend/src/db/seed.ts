import { randomUUID } from "crypto";
import type mysql from "mysql2/promise";
import pino from "pino";
import { pool } from "../config/database";
import "../config/env";
import { runSubscriptionPlansSeed } from "./seeds/001_subscription_plans.seed";
import { runModulesSeed } from "./seeds/002_modules.seed";
import { runPlanModuleAccessSeed } from "./seeds/003_plan_module_access.seed";
import { runCropCategoriesSeed } from "./seeds/004_crop_categories.seed";
import { runPayrollLeaveTypesSeed } from "./seeds/005_payroll_leave_types.seed";
import { runDemoFarmOwnerSeed } from "./seeds/006_demo_farm_owner.seed";
import { runCattleSeed } from "./seeds/007_cattle.seed";
import { runGoatSeed } from "./seeds/008_goat.seed";
import { runPoultrySeed } from "./seeds/009_poultry.seed";
import { runPayrollSeed } from "./seeds/010_payroll.seed";
// Seeds 011-016 are applied directly to DB; stubs kept for seed_history tracking
// import { seed011PayrollExtended } from "./seeds/011_payroll_extended.seed";
// import { seed012Farm } from "./seeds/012_farm.seed";
// import { seed013BalckenFarm } from "./seeds/013_balcken_4dfm.seed";
// import { seed014BalckenLarge } from "./seeds/014_balcken_large.seed";
// import { seed015BalckenComplete } from "./seeds/015_balcken_complete.seed";
// import { seed016BalckenMissing } from "./seeds/016_balcken_missing.seed";

const logger = pino({ name: "seed" });

/**
 * Ordered list of all seed files.
 * Each entry has a unique name (used as the key in seed_history) and a
 * function that performs the actual inserts.  Seeds MUST be idempotent
 * (they use ON DUPLICATE KEY UPDATE internally), but the seed_history
 * check means each file is only executed once per environment.
 */
const seeds: Array<{ name: string; fn: () => Promise<void> }> = [
  { name: "001_subscription_plans.seed.ts", fn: runSubscriptionPlansSeed },
  { name: "002_modules.seed.ts", fn: runModulesSeed },
  { name: "003_plan_module_access.seed.ts", fn: runPlanModuleAccessSeed },
  { name: "004_crop_categories.seed.ts", fn: runCropCategoriesSeed },
  { name: "005_payroll_leave_types.seed.ts", fn: runPayrollLeaveTypesSeed },
  { name: "006_demo_farm_owner.seed.ts", fn: runDemoFarmOwnerSeed },
  { name: "007_cattle.seed.ts", fn: runCattleSeed },
  { name: "008_goat.seed.ts", fn: runGoatSeed },
  { name: "009_poultry.seed.ts", fn: runPoultrySeed },
  { name: "010_payroll.seed.ts", fn: runPayrollSeed },
  // Seeds 011-016 were applied directly to DB (no runnable function)
  // { name: "011_payroll_extended.seed.ts", fn: seed011PayrollExtended },
  // { name: "012_farm.seed.ts", fn: seed012Farm },
  // { name: "013_balcken_4dfm.seed.ts", fn: seed013BalckenFarm },
  // { name: "014_balcken_large.seed.ts", fn: seed014BalckenLarge },
  // { name: "015_balcken_complete.seed.ts", fn: seed015BalckenComplete },
  // { name: "016_balcken_missing.seed.ts", fn: seed016BalckenMissing },
];

async function main() {
  logger.info("Seeding database...");

  // Load the names of already-applied seeds from seed_history
  const [rows] = await pool.execute<mysql.RowDataPacket[]>(
    "SELECT `name` FROM `seed_history`",
  );
  const applied = new Set<string>(
    rows.map((r: mysql.RowDataPacket) => r.name as string),
  );

  let ran = 0;
  for (const seed of seeds) {
    if (applied.has(seed.name)) {
      logger.info({ seed: seed.name }, "skipped (already applied)");
      continue;
    }

    logger.info({ seed: seed.name }, "running");
    await seed.fn();

    // Record this seed so it is skipped on future runs
    await pool.execute(
      "INSERT INTO `seed_history` (`id`, `name`, `applied_at`) VALUES (?, ?, NOW())",
      [randomUUID(), seed.name],
    );

    logger.info({ seed: seed.name }, "done");
    ran++;
  }

  logger.info({ ran }, `Seeding complete. ${ran} new seed(s) applied.`);
  await pool.end();
}

main().catch((err) => {
  logger.error({ err }, "Seed failed");
  process.exit(1);
});
