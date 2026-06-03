import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { goatKiddingEvents } from "../../db/schema";

import { kiddingSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatKiddingRepo = {
  listKiddingEvents: (farmOwnerId: string) =>
    db
      .select(kiddingSelect)
      .from(goatKiddingEvents)
      .where(eq(goatKiddingEvents.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatKiddingEvents.kiddingDate)),

  findKiddingEventById: (farmOwnerId: string, id: string) =>
    db
      .select(kiddingSelect)
      .from(goatKiddingEvents)
      .where(and(eq(goatKiddingEvents.farmOwnerId, farmOwnerId), eq(goatKiddingEvents.id, id)))
      .then((r) => r[0] ?? null),

  createKiddingEvent: (data: any) => db.insert(goatKiddingEvents).values(data),
};

