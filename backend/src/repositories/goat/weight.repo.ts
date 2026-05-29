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

export const goatWeightRepo = {
  listWeightRecords: (farmOwnerId: string) =>
    db
      .select(weightSelect)
      .from(goatWeightRecords)
      .where(eq(goatWeightRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatWeightRecords.date)),

  findWeightRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(weightSelect)
      .from(goatWeightRecords)
      .where(and(eq(goatWeightRecords.farmOwnerId, farmOwnerId), eq(goatWeightRecords.id, id)))
      .then((r) => r[0] ?? null),

  createWeightRecord: (data: any) => db.insert(goatWeightRecords).values(data),

  deleteWeightRecord: (farmOwnerId: string, id: string) =>
    db
      .delete(goatWeightRecords)
      .where(and(eq(goatWeightRecords.farmOwnerId, farmOwnerId), eq(goatWeightRecords.id, id))),
};

