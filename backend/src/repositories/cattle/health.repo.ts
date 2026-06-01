import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    cattleHealthEvents
} from "../../db/schema";

import { healthSelect } from "./_projections";

// ─────────────────────────────────────────────────────────────────────────────

export const cattleHealthRepo = {

  listHealthEvents: (farmOwnerId: string) =>
    db
      .select(healthSelect)
      .from(cattleHealthEvents)
      .where(eq(cattleHealthEvents.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleHealthEvents.eventDate)),

  findHealthEventById: (farmOwnerId: string, id: string) =>
    db
      .select(healthSelect)
      .from(cattleHealthEvents)
      .where(and(eq(cattleHealthEvents.farmOwnerId, farmOwnerId), eq(cattleHealthEvents.id, id)))
      .then((r) => r[0] ?? null),

  createHealthEvent: (data: any) => db.insert(cattleHealthEvents).values(data),

  updateHealthEvent: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cattleHealthEvents)
      .set(data)
      .where(and(eq(cattleHealthEvents.farmOwnerId, farmOwnerId), eq(cattleHealthEvents.id, id))),
};

