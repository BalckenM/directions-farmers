import { sql } from "drizzle-orm";
import { db } from "../../config/database";

/**
 * Seed: crop_categories
 *
 * Inserts standard South African agricultural crop categories.
 * crop_categories is global reference data (no farm_owner_id) so it can
 * be pre-seeded for every installation.
 *
 * Idempotent: ON DUPLICATE KEY UPDATE fires on the primary-key id,
 * so re-running just refreshes the name in case it was ever edited.
 */

const now = new Date().toISOString().slice(0, 19).replace("T", " ");

const categories: Array<{ id: string; name: string }> = [
  { id: "cat_vegetables", name: "Vegetables" },
  { id: "cat_grains", name: "Grains & Cereals" },
  { id: "cat_legumes", name: "Legumes & Pulses" },
  { id: "cat_fruits", name: "Fruits & Orchards" },
  { id: "cat_pasture", name: "Pasture & Fodder" },
  { id: "cat_oilseeds", name: "Oil Seeds" },
  { id: "cat_sugarcane", name: "Sugar Cane" },
  { id: "cat_nuts", name: "Nuts & Seeds" },
  { id: "cat_herbs", name: "Herbs & Spices" },
  { id: "cat_rootcrops", name: "Root Crops & Tubers" },
];

export async function runCropCategoriesSeed(): Promise<void> {
  for (const cat of categories) {
    await db.execute(sql`
      INSERT INTO crop_categories (id, name, created_at)
      VALUES (${cat.id}, ${cat.name}, ${now})
      ON DUPLICATE KEY UPDATE name = VALUES(name)
    `);
  }
  console.log(`crop_categories seeded (${categories.length} categories)`);
}
