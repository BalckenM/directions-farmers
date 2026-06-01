import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    goatPregnancyChecks
} from "../../db/schema";

import { pregnancyCheckSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatPregnancyRepo = {
  listPregnancyChecks: (farmOwnerId: string) =>
    db
      .select(pregnancyCheckSelect)
      .from(goatPregnancyChecks)
      .where(eq(goatPregnancyChecks.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatPregnancyChecks.checkDate)),

  findPregnancyCheckById: (farmOwnerId: string, id: string) =>
    db
      .select(pregnancyCheckSelect)
      .from(goatPregnancyChecks)
      .where(and(eq(goatPregnancyChecks.farmOwnerId, farmOwnerId), eq(goatPregnancyChecks.id, id)))
      .then((r) => r[0] ?? null),

  createPregnancyCheck: (data: any) => db.insert(goatPregnancyChecks).values(data),
};

