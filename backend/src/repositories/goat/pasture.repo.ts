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

export const goatPastureRepo = {
  listPastureRecords: (farmOwnerId: string) =>
    db
      .select(pastureSelect)
      .from(goatPastureRecords)
      .where(eq(goatPastureRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatPastureRecords.entryDate)),

  findPastureRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(pastureSelect)
      .from(goatPastureRecords)
      .where(and(eq(goatPastureRecords.farmOwnerId, farmOwnerId), eq(goatPastureRecords.id, id)))
      .then((r) => r[0] ?? null),

  createPastureRecord: (data: any) => db.insert(goatPastureRecords).values(data),

  updatePastureRecord: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(goatPastureRecords)
      .set(data)
      .where(and(eq(goatPastureRecords.farmOwnerId, farmOwnerId), eq(goatPastureRecords.id, id))),
};

