import { desc, eq } from "drizzle-orm";
import { db } from "../config/database";
import {
  cattleAnimals,
  farmHealthEvents,
  feedLogs,
  goatAnimals,
} from "../db/schema";

// ── Data-driven advice engine (no external LLM) ────────────────────────────

function generateAdvice(
  topic: string,
  ctx: { goatCount: number; cattleCount: number; healthEvents: unknown[] },
): string[] {
  const { goatCount, cattleCount, healthEvents } = ctx;
  const tips: string[] = [];

  switch (topic.toLowerCase()) {
    case "health":
      if (healthEvents.length > 0)
        tips.push(
          "Recent health events on record — isolate affected animals and consult a vet if symptoms persist.",
        );
      tips.push(
        "Maintain vaccination schedules and deworm regularly based on FAMACHA scores.",
      );
      tips.push(
        "Monitor body condition scores monthly to detect nutritional issues early.",
      );
      break;
    case "feeding":
      if (goatCount > 0)
        tips.push(
          "Goats require roughage as 60–70% of their diet. Supplement with quality hay during dry seasons.",
        );
      if (cattleCount > 0)
        tips.push(
          "Cattle should have access to lick blocks and clean water at all times.",
        );
      tips.push("Log feed consumption daily to identify under- or over-feeding trends.");
      break;
    case "breeding":
      tips.push(
        "Plan mating to avoid kidding/calving during extreme weather.",
      );
      tips.push(
        "Keep breeding records up to date to track conception rates and top-performing sires.",
      );
      break;
    case "pasture":
      tips.push("Rotate paddocks every 3–4 weeks to prevent overgrazing and allow recovery.");
      tips.push("Test soil annually and apply lime or fertiliser based on results.");
      break;
    default:
      tips.push("Log daily farm activities to build a data history for better recommendations.");
      tips.push(
        "Regular record-keeping improves decision-making and traceability compliance.",
      );
  }

  return tips;
}

export const advisorService = {
  getAdvice: async (farmOwnerId: string, topic: string) => {
    const [goatCount, cattleCount, healthEvents] = await Promise.all([
      db
        .select()
        .from(goatAnimals)
        .where(eq(goatAnimals.farmOwnerId, farmOwnerId))
        .then((r) => r.length),
      db
        .select()
        .from(cattleAnimals)
        .where(eq(cattleAnimals.farmOwnerId, farmOwnerId))
        .then((r) => r.length),
      db
        .select()
        .from(farmHealthEvents)
        .where(eq(farmHealthEvents.farmOwnerId, farmOwnerId))
        .orderBy(desc(farmHealthEvents.createdAt))
        .limit(5),
    ]);

    return {
      topic,
      advice: generateAdvice(topic, { goatCount, cattleCount, healthEvents }),
      generatedAt: new Date().toISOString(),
    };
  },

  getDailyBriefing: async (farmOwnerId: string) => {
    const [goatCount, cattleCount, healthEvents, recentFeed] = await Promise.all([
      db
        .select()
        .from(goatAnimals)
        .where(eq(goatAnimals.farmOwnerId, farmOwnerId))
        .then((r) => r.length),
      db
        .select()
        .from(cattleAnimals)
        .where(eq(cattleAnimals.farmOwnerId, farmOwnerId))
        .then((r) => r.length),
      db
        .select()
        .from(farmHealthEvents)
        .where(eq(farmHealthEvents.farmOwnerId, farmOwnerId))
        .orderBy(desc(farmHealthEvents.createdAt))
        .limit(3),
      db
        .select()
        .from(feedLogs)
        .where(eq(feedLogs.farmOwnerId, farmOwnerId))
        .orderBy(desc(feedLogs.createdAt))
        .limit(3),
    ]);

    const briefings: string[] = [];
    if (goatCount > 0)
      briefings.push(`${goatCount} goat(s) on record — check water and feed daily.`);
    if (cattleCount > 0)
      briefings.push(`${cattleCount} cattle on record — inspect pastures and water troughs.`);
    if (healthEvents.length > 0)
      briefings.push(
        `${healthEvents.length} recent health event(s) — follow up on any open treatments.`,
      );
    if (recentFeed.length === 0)
      briefings.push("No recent feed logs. Consider logging today's feeding to track consumption.");

    return {
      date: new Date().toISOString().split("T")[0],
      briefings,
      generatedAt: new Date().toISOString(),
    };
  },
};
