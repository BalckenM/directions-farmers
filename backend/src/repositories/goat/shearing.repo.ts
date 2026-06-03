import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { goatShearingRecords } from "../../db/schema";

import { shearingSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatShearingRepo = {
  listShearingRecords: (farmOwnerId: string) =>
    db
      .select(shearingSelect)
      .from(goatShearingRecords)
      .where(eq(goatShearingRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatShearingRecords.shearingDate)),

  findShearingRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(shearingSelect)
      .from(goatShearingRecords)
      .where(and(eq(goatShearingRecords.farmOwnerId, farmOwnerId), eq(goatShearingRecords.id, id)))
      .then((r) => r[0] ?? null),

  createShearingRecord: (data: any) => db.insert(goatShearingRecords).values(data),
};

