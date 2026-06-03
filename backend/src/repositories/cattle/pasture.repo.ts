import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cattlePastureRecords } from "../../db/schema";

import { pastureSelect } from "./_projections";

// ─────────────────────────────────────────────────────────────────────────────

export const cattlePastureRepo = {
  listPastureRecords: (farmOwnerId: string) =>
    db
      .select(pastureSelect)
      .from(cattlePastureRecords)
      .where(eq(cattlePastureRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattlePastureRecords.entryDate)),

  findPastureRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(pastureSelect)
      .from(cattlePastureRecords)
      .where(
        and(
          eq(cattlePastureRecords.farmOwnerId, farmOwnerId),
          eq(cattlePastureRecords.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  createPastureRecord: (data: any) =>
    db.insert(cattlePastureRecords).values(data),

  updatePastureRecord: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cattlePastureRecords)
      .set(data)
      .where(
        and(
          eq(cattlePastureRecords.farmOwnerId, farmOwnerId),
          eq(cattlePastureRecords.id, id),
        ),
      ),
};
