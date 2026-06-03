import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cattleDailyMilk } from "../../db/schema";

import { milkSelect } from "./_projections";

// ─────────────────────────────────────────────────────────────────────────────

export const cattleMilkRepo = {
  listDailyMilk: (farmOwnerId: string) =>
    db
      .select(milkSelect)
      .from(cattleDailyMilk)
      .where(eq(cattleDailyMilk.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleDailyMilk.date)),

  findDailyMilkById: (farmOwnerId: string, id: string) =>
    db
      .select(milkSelect)
      .from(cattleDailyMilk)
      .where(
        and(
          eq(cattleDailyMilk.farmOwnerId, farmOwnerId),
          eq(cattleDailyMilk.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  createDailyMilk: (data: any) => db.insert(cattleDailyMilk).values(data),

  deleteDailyMilk: (farmOwnerId: string, id: string) =>
    db
      .delete(cattleDailyMilk)
      .where(
        and(
          eq(cattleDailyMilk.farmOwnerId, farmOwnerId),
          eq(cattleDailyMilk.id, id),
        ),
      ),
};
