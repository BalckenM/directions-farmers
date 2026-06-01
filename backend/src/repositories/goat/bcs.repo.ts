import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    goatBcsRecords
} from "../../db/schema";

import { bcsSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatBcsRepo = {
  listBcsRecords: (farmOwnerId: string) =>
    db
      .select(bcsSelect)
      .from(goatBcsRecords)
      .where(eq(goatBcsRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatBcsRecords.recordDate)),

  findBcsRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(bcsSelect)
      .from(goatBcsRecords)
      .where(and(eq(goatBcsRecords.farmOwnerId, farmOwnerId), eq(goatBcsRecords.id, id)))
      .then((r) => r[0] ?? null),

  createBcsRecord: (data: any) => db.insert(goatBcsRecords).values(data),
};

