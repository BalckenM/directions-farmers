import { randomUUID } from "crypto";
import { sql } from "drizzle-orm";
import { db } from "../../config/database";

const now = new Date().toISOString().slice(0, 19).replace("T", " ");

// Free plan: financial only. Basic: livestock + financial. Pro+: all modules.
const access: Array<{ planId: string; moduleId: string }> = [
  // Free
  { planId: "plan_free", moduleId: "mod_financial" },
  // Basic
  { planId: "plan_basic", moduleId: "mod_goat" },
  { planId: "plan_basic", moduleId: "mod_cattle" },
  { planId: "plan_basic", moduleId: "mod_poultry" },
  { planId: "plan_basic", moduleId: "mod_financial" },
  // Pro
  { planId: "plan_pro", moduleId: "mod_goat" },
  { planId: "plan_pro", moduleId: "mod_cattle" },
  { planId: "plan_pro", moduleId: "mod_poultry" },
  { planId: "plan_pro", moduleId: "mod_crop" },
  { planId: "plan_pro", moduleId: "mod_payroll" },
  { planId: "plan_pro", moduleId: "mod_financial" },
  // Enterprise
  { planId: "plan_enterprise", moduleId: "mod_goat" },
  { planId: "plan_enterprise", moduleId: "mod_cattle" },
  { planId: "plan_enterprise", moduleId: "mod_poultry" },
  { planId: "plan_enterprise", moduleId: "mod_crop" },
  { planId: "plan_enterprise", moduleId: "mod_payroll" },
  { planId: "plan_enterprise", moduleId: "mod_financial" },
];

export async function runPlanModuleAccessSeed() {
  for (const row of access) {
    const id = randomUUID();
    await db.execute(sql`
      INSERT INTO plan_module_access (id, plan_id, module_id, created_at)
      VALUES (${id}, ${row.planId}, ${row.moduleId}, ${now})
      ON DUPLICATE KEY UPDATE plan_id = VALUES(plan_id)
    `);
  }
  console.log("plan_module_access seeded");
}
