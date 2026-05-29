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

export const goatSalesRepo = {
  listSaleRecords: (farmOwnerId: string) =>
    db
      .select(saleSelect)
      .from(goatSaleRecords)
      .where(eq(goatSaleRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatSaleRecords.saleDate)),

  findSaleRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(saleSelect)
      .from(goatSaleRecords)
      .where(and(eq(goatSaleRecords.farmOwnerId, farmOwnerId), eq(goatSaleRecords.id, id)))
      .then((r) => r[0] ?? null),

  createSaleRecord: (data: any) => db.insert(goatSaleRecords).values(data),

  updateSaleRecord: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(goatSaleRecords)
      .set(data)
      .where(and(eq(goatSaleRecords.farmOwnerId, farmOwnerId), eq(goatSaleRecords.id, id))),

  deleteSaleRecord: (farmOwnerId: string, id: string) =>
    db
      .delete(goatSaleRecords)
      .where(and(eq(goatSaleRecords.farmOwnerId, farmOwnerId), eq(goatSaleRecords.id, id))),
};

