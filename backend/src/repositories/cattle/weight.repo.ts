import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    cattleWeightRecords
} from "../../db/schema";

import { weightSelect } from "./_projections";

// ─────────────────────────────────────────────────────────────────────────────

export const cattleWeightRepo = {

  listWeightRecords: (farmOwnerId: string) =>
    db
      .select(weightSelect)
      .from(cattleWeightRecords)
      .where(eq(cattleWeightRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleWeightRecords.recordedAt)),

  findWeightRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(weightSelect)
      .from(cattleWeightRecords)
      .where(and(eq(cattleWeightRecords.farmOwnerId, farmOwnerId), eq(cattleWeightRecords.id, id)))
      .then((r) => r[0] ?? null),

  createWeightRecord: (data: any) => db.insert(cattleWeightRecords).values(data),

  deleteWeightRecord: (farmOwnerId: string, id: string) =>
    db
      .delete(cattleWeightRecords)
      .where(and(eq(cattleWeightRecords.farmOwnerId, farmOwnerId), eq(cattleWeightRecords.id, id))),
};

