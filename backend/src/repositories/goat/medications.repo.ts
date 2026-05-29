import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
  goatAnimals,
  goatBcsRecords,
  goatDailyMilk,
  goatFamachaRecords,
  goatFeedRecords,
  goatHealthEvents,
  goatKiddingEvents,
  goatMatingRecords,
  goatMedicationLogs,
  goatPastureRecords,
  goatPregnancyChecks,
  goatSaleRecords,
  goatShearingRecords,
  goatVaccinations,
  goatWeightRecords,
} from "../../db/schema";

import { animalSelect, weightSelect, matingSelect, pregnancyCheckSelect, kiddingSelect, milkSelect, shearingSelect, healthSelect, medicationSelect, vaccinationSelect, saleSelect, feedSelect, pastureSelect, famachaSelect, bcsSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatMedicationsRepo = {
  listMedicationLogs: (farmOwnerId: string) =>
    db
      .select(medicationSelect)
      .from(goatMedicationLogs)
      .where(eq(goatMedicationLogs.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatMedicationLogs.date)),

  findMedicationLogById: (farmOwnerId: string, id: string) =>
    db
      .select(medicationSelect)
      .from(goatMedicationLogs)
      .where(and(eq(goatMedicationLogs.farmOwnerId, farmOwnerId), eq(goatMedicationLogs.id, id)))
      .then((r) => r[0] ?? null),

  createMedicationLog: (data: any) => db.insert(goatMedicationLogs).values(data),
};

