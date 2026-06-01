import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    goatMedicationLogs
} from "../../db/schema";

import { medicationSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatMedicationsRepo = {
  listMedicationLogs: (farmOwnerId: string) =>
    db
      .select(medicationSelect)
      .from(goatMedicationLogs)
      .where(eq(goatMedicationLogs.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatMedicationLogs.administeredAt)),

  findMedicationLogById: (farmOwnerId: string, id: string) =>
    db
      .select(medicationSelect)
      .from(goatMedicationLogs)
      .where(and(eq(goatMedicationLogs.farmOwnerId, farmOwnerId), eq(goatMedicationLogs.id, id)))
      .then((r) => r[0] ?? null),

  createMedicationLog: (data: any) => db.insert(goatMedicationLogs).values(data),
};

