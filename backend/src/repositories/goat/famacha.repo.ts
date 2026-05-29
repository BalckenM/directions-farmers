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

export const goatFamachaRepo = {
  listFamachaRecords: (farmOwnerId: string) =>
    db
      .select(famachaSelect)
      .from(goatFamachaRecords)
      .where(eq(goatFamachaRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatFamachaRecords.date)),

  findFamachaRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(famachaSelect)
      .from(goatFamachaRecords)
      .where(and(eq(goatFamachaRecords.farmOwnerId, farmOwnerId), eq(goatFamachaRecords.id, id)))
      .then((r) => r[0] ?? null),

  createFamachaRecord: (data: any) => db.insert(goatFamachaRecords).values(data),
};

