import { sql } from "drizzle-orm";
import { db } from "../../config/database";

const now = new Date().toISOString().slice(0, 19).replace("T", " ");

const modules = [
  {
    id: "mod_goat",
    name: "Goat Management",
    slug: "goat",
    description: "Track goat herds, health, breeding and production",
    isActive: 1,
  },
  {
    id: "mod_cattle",
    name: "Cattle Management",
    slug: "cattle",
    description: "Track cattle herds, health, breeding and production",
    isActive: 1,
  },
  {
    id: "mod_poultry",
    name: "Poultry Management",
    slug: "poultry",
    description: "Track poultry flocks, health and egg production",
    isActive: 1,
  },
  {
    id: "mod_crop",
    name: "Crop Farming",
    slug: "crop",
    description: "Manage planting plans, field activities and harvests",
    isActive: 1,
  },
  {
    id: "mod_payroll",
    name: "Payroll & HR",
    slug: "payroll",
    description: "Manage employees, pay runs and labour compliance",
    isActive: 1,
  },
  {
    id: "mod_financial",
    name: "Financial Tracking",
    slug: "financial",
    description: "Track farm income, expenses and financial reports",
    isActive: 1,
  },
];

export async function runModulesSeed() {
  for (const mod of modules) {
    await db.execute(sql`
      INSERT INTO modules (id, name, slug, description, is_active, created_at, updated_at)
      VALUES (${mod.id}, ${mod.name}, ${mod.slug}, ${mod.description}, ${mod.isActive}, ${now}, ${now})
      ON DUPLICATE KEY UPDATE name = VALUES(name), slug = VALUES(slug)
    `);
  }
  console.log("modules seeded");
}
