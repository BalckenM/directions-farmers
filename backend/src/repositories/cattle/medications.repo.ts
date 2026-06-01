import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    cattleMedicationLogs
} from "../../db/schema";

import { medicationSelect } from "./_projections";

// ─────────────────────────────────────────────────────────────────────────────

export const cattleMedicationsRepo = {

  listMedicationLogs: (farmOwnerId: string) =>
    db
      .select(medicationSelect)
      .from(cattleMedicationLogs)
      .where(eq(cattleMedicationLogs.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleMedicationLogs.administeredAt)),

  findMedicationLogById: (farmOwnerId: string, id: string) =>
    db
      .select(medicationSelect)
      .from(cattleMedicationLogs)
      .where(and(eq(cattleMedicationLogs.farmOwnerId, farmOwnerId), eq(cattleMedicationLogs.id, id)))
      .then((r) => r[0] ?? null),

  createMedicationLog: (data: any) => db.insert(cattleMedicationLogs).values(data),
};

