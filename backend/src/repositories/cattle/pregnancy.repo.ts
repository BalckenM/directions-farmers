import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cattlePregnancyChecks } from "../../db/schema";

import { pregnancyCheckSelect } from "./_projections";

// ─────────────────────────────────────────────────────────────────────────────

export const cattlePregnancyRepo = {
  listPregnancyChecks: (farmOwnerId: string) =>
    db
      .select(pregnancyCheckSelect)
      .from(cattlePregnancyChecks)
      .where(eq(cattlePregnancyChecks.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattlePregnancyChecks.date)),

  findPregnancyCheckById: (farmOwnerId: string, id: string) =>
    db
      .select(pregnancyCheckSelect)
      .from(cattlePregnancyChecks)
      .where(
        and(
          eq(cattlePregnancyChecks.farmOwnerId, farmOwnerId),
          eq(cattlePregnancyChecks.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  createPregnancyCheck: (data: any) =>
    db.insert(cattlePregnancyChecks).values(data),
};
