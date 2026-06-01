import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    goatMatingRecords
} from "../../db/schema";

import { matingSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatMatingRepo = {
  listMatings: (farmOwnerId: string) =>
    db
      .select(matingSelect)
      .from(goatMatingRecords)
      .where(eq(goatMatingRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatMatingRecords.matingDate)),

  findMatingById: (farmOwnerId: string, id: string) =>
    db
      .select(matingSelect)
      .from(goatMatingRecords)
      .where(and(eq(goatMatingRecords.farmOwnerId, farmOwnerId), eq(goatMatingRecords.id, id)))
      .then((r) => r[0] ?? null),

  createMating: (data: any) => db.insert(goatMatingRecords).values(data),

  updateMating: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(goatMatingRecords)
      .set(data)
      .where(and(eq(goatMatingRecords.farmOwnerId, farmOwnerId), eq(goatMatingRecords.id, id))),
};

