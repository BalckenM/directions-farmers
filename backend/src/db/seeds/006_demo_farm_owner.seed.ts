import bcrypt from "bcryptjs";
import { sql } from "drizzle-orm";
import { db } from "../../config/database";

/**
 * Seed 006: demo farm_owner
 *
 * Inserts a single demo farm owner account that all other demo seeds
 * (cattle, goat, poultry, payroll) reference via farm_owner_id = 'farm-001'.
 *
 * Credentials (development / demo only — never use in production):
 *   Email    : demo@4dfarm.local
 *   Password : Demo@1234
 *
 * Idempotent: ON DUPLICATE KEY UPDATE refreshes the row if the seed
 * is re-run, without inserting a duplicate.
 */
export async function runDemoFarmOwnerSeed(): Promise<void> {
  const passwordHash = bcrypt.hashSync("Demo@1234", 10);
  const now = new Date().toISOString().slice(0, 19).replace("T", " ");

  await db.execute(sql`
    INSERT INTO farm_owners
      (id, email, password_hash, first_name, last_name, phone,
       email_verified_at, created_at, updated_at)
    VALUES
      ('farm-001', 'demo@4dfarm.local', ${passwordHash}, 'Demo', 'Farmer',
       '+27 60 000 0001', ${now}, '2024-01-01 00:00:00', '2024-01-01 00:00:00')
    ON DUPLICATE KEY UPDATE
      email             = VALUES(email),
      password_hash     = VALUES(password_hash),
      first_name        = VALUES(first_name),
      last_name         = VALUES(last_name),
      phone             = VALUES(phone),
      email_verified_at = VALUES(email_verified_at),
      updated_at        = VALUES(updated_at)
  `);

  console.log("farm_owners seeded (1 demo account: demo@4dfarm.local)");

  // Activate all modules for the demo farm so every API route is accessible
  const moduleIds = [
    "mod_goat",
    "mod_cattle",
    "mod_poultry",
    "mod_crop",
    "mod_payroll",
    "mod_financial",
  ];
  for (const moduleId of moduleIds) {
    const activationId = `act-farm001-${moduleId}`;
    await db.execute(sql`
      INSERT INTO farm_module_activations
        (id, farm_owner_id, module_id, is_active, activated_at, created_at)
      VALUES
        (${activationId}, 'farm-001', ${moduleId}, TRUE, '2024-01-01 00:00:00',
         '2024-01-01 00:00:00')
      ON DUPLICATE KEY UPDATE
        is_active = TRUE
    `);
  }
  console.log("farm_module_activations seeded (6 modules for farm-001)");
}
