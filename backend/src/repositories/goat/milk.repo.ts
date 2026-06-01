import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    goatDailyMilk
} from "../../db/schema";

import { milkSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatMilkRepo = {
  listDailyMilk: (farmOwnerId: string) =>
    db
      .select(milkSelect)
      .from(goatDailyMilk)
      .where(eq(goatDailyMilk.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatDailyMilk.recordDate)),

  findDailyMilkById: (farmOwnerId: string, id: string) =>
    db
      .select(milkSelect)
      .from(goatDailyMilk)
      .where(and(eq(goatDailyMilk.farmOwnerId, farmOwnerId), eq(goatDailyMilk.id, id)))
      .then((r) => r[0] ?? null),

  createDailyMilk: (data: any) => db.insert(goatDailyMilk).values(data),

  deleteDailyMilk: (farmOwnerId: string, id: string) =>
    db
      .delete(goatDailyMilk)
      .where(and(eq(goatDailyMilk.farmOwnerId, farmOwnerId), eq(goatDailyMilk.id, id))),
};

