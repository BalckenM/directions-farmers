import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    cattleBcsRecords
} from "../../db/schema";

import { bcsSelect } from "./_projections";

// ─────────────────────────────────────────────────────────────────────────────

export const cattleBcsRepo = {

  listBcsRecords: (farmOwnerId: string) =>
    db
      .select(bcsSelect)
      .from(cattleBcsRecords)
      .where(eq(cattleBcsRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleBcsRecords.recordDate)),

  findBcsRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(bcsSelect)
      .from(cattleBcsRecords)
      .where(and(eq(cattleBcsRecords.farmOwnerId, farmOwnerId), eq(cattleBcsRecords.id, id)))
      .then((r) => r[0] ?? null),

  createBcsRecord: (data: any) => db.insert(cattleBcsRecords).values(data),
};

