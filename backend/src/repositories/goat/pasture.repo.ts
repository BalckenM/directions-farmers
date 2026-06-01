import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    goatPastureRecords
} from "../../db/schema";

import { pastureSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatPastureRepo = {
  listPastureRecords: (farmOwnerId: string) =>
    db
      .select(pastureSelect)
      .from(goatPastureRecords)
      .where(eq(goatPastureRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatPastureRecords.moveDate)),

  findPastureRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(pastureSelect)
      .from(goatPastureRecords)
      .where(and(eq(goatPastureRecords.farmOwnerId, farmOwnerId), eq(goatPastureRecords.id, id)))
      .then((r) => r[0] ?? null),

  createPastureRecord: (data: any) => db.insert(goatPastureRecords).values(data),

  updatePastureRecord: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(goatPastureRecords)
      .set(data)
      .where(and(eq(goatPastureRecords.farmOwnerId, farmOwnerId), eq(goatPastureRecords.id, id))),
};

