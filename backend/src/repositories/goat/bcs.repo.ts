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

export const goatBcsRepo = {
  listBcsRecords: (farmOwnerId: string) =>
    db
      .select(bcsSelect)
      .from(goatBcsRecords)
      .where(eq(goatBcsRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatBcsRecords.date)),

  findBcsRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(bcsSelect)
      .from(goatBcsRecords)
      .where(and(eq(goatBcsRecords.farmOwnerId, farmOwnerId), eq(goatBcsRecords.id, id)))
      .then((r) => r[0] ?? null),

  createBcsRecord: (data: any) => db.insert(goatBcsRecords).values(data),
};

