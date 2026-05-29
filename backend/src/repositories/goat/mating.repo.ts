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

export const goatMatingRepo = {
  listMatings: (farmOwnerId: string) =>
    db
      .select(matingSelect)
      .from(goatMatingRecords)
      .where(eq(goatMatingRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatMatingRecords.serviceDate)),

  findMatingById: (farmOwnerId: string, id: string) =>
    db
      .select(matingSelect)
      .from(goatMatingRecords)
      .where(and(eq(goatMatingRecords.farmOwnerId, farmOwnerId), eq(goatMatingRecords.id, id)))
      .then((r) => r[0] ?? null),

  createMating: (data: any) => db.insert(goatMatingRecords).values(data),

  updateMating: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(goatMatingRecords)
      .set(data)
      .where(and(eq(goatMatingRecords.farmOwnerId, farmOwnerId), eq(goatMatingRecords.id, id))),
};

