import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
  cattleAnimals,
  cattleBcsRecords,
  cattleBreedingRecords,
  cattleCalvingEvents,
  cattleDailyMilk,
  cattleDippingRecords,
  cattleFeedRecords,
  cattleHealthEvents,
  cattleMedicationLogs,
  cattlePastureRecords,
  cattlePregnancyChecks,
  cattleSaleRecords,
  cattleVaccinations,
  cattleWeightRecords,
} from "../../db/schema";

import { animalSelect, weightSelect, breedingSelect, pregnancyCheckSelect, calvingSelect, milkSelect, healthSelect, medicationSelect, vaccinationSelect, saleSelect, feedSelect, pastureSelect, bcsSelect, dippingSelect } from "./_projections";

// ─────────────────────────────────────────────────────────────────────────────

export const cattleSalesRepo = {

  listSaleRecords: (farmOwnerId: string) =>
    db
      .select(saleSelect)
      .from(cattleSaleRecords)
      .where(eq(cattleSaleRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleSaleRecords.saleDate)),

  findSaleRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(saleSelect)
      .from(cattleSaleRecords)
      .where(and(eq(cattleSaleRecords.farmOwnerId, farmOwnerId), eq(cattleSaleRecords.id, id)))
      .then((r) => r[0] ?? null),

  createSaleRecord: (data: any) => db.insert(cattleSaleRecords).values(data),

  updateSaleRecord: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cattleSaleRecords)
      .set(data)
      .where(and(eq(cattleSaleRecords.farmOwnerId, farmOwnerId), eq(cattleSaleRecords.id, id))),

  deleteSaleRecord: (farmOwnerId: string, id: string) =>
    db
      .delete(cattleSaleRecords)
      .where(and(eq(cattleSaleRecords.farmOwnerId, farmOwnerId), eq(cattleSaleRecords.id, id))),
};

