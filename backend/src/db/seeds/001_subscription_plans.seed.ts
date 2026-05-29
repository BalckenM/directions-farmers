import { sql } from "drizzle-orm";
import { db } from "../../config/database";

const now = new Date().toISOString().slice(0, 19).replace("T", " ");

const plans = [
  {
    id: "plan_free",
    name: "Free",
    description: "Get started with basic farm management",
    priceMonthly: 0,
    priceAnnual: 0,
    isActive: 1,
  },
  {
    id: "plan_basic",
    name: "Basic",
    description: "Essential tools for small farms",
    priceMonthly: 9900,
    priceAnnual: 99000,
    isActive: 1,
  },
  {
    id: "plan_pro",
    name: "Pro",
    description: "Advanced features for growing operations",
    priceMonthly: 29900,
    priceAnnual: 299000,
    isActive: 1,
  },
  {
    id: "plan_enterprise",
    name: "Enterprise",
    description: "Full suite for large agricultural businesses",
    priceMonthly: 99900,
    priceAnnual: 999000,
    isActive: 1,
  },
];

export async function runSubscriptionPlansSeed() {
  for (const plan of plans) {
    await db.execute(sql`
      INSERT INTO subscription_plans (id, name, description, price_monthly, price_annual, is_active, created_at, updated_at)
      VALUES (${plan.id}, ${plan.name}, ${plan.description}, ${plan.priceMonthly}, ${plan.priceAnnual}, ${plan.isActive}, ${now}, ${now})
      ON DUPLICATE KEY UPDATE name = VALUES(name), price_monthly = VALUES(price_monthly), price_annual = VALUES(price_annual)
    `);
  }
  console.log("subscription_plans seeded");
}
