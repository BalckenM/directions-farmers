import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    goatFamachaRecords
} from "../../db/schema";

import { famachaSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatFamachaRepo = {
  listFamachaRecords: (farmOwnerId: string) =>
    db
      .select(famachaSelect)
      .from(goatFamachaRecords)
      .where(eq(goatFamachaRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatFamachaRecords.recordDate)),

  findFamachaRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(famachaSelect)
      .from(goatFamachaRecords)
      .where(and(eq(goatFamachaRecords.farmOwnerId, farmOwnerId), eq(goatFamachaRecords.id, id)))
      .then((r) => r[0] ?? null),

  createFamachaRecord: (data: any) => db.insert(goatFamachaRecords).values(data),
};

