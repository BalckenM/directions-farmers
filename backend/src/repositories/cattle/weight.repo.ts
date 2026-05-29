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

export const cattleWeightRepo = {

  listWeightRecords: (farmOwnerId: string) =>
    db
      .select(weightSelect)
      .from(cattleWeightRecords)
      .where(eq(cattleWeightRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleWeightRecords.date)),

  findWeightRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(weightSelect)
      .from(cattleWeightRecords)
      .where(and(eq(cattleWeightRecords.farmOwnerId, farmOwnerId), eq(cattleWeightRecords.id, id)))
      .then((r) => r[0] ?? null),

  createWeightRecord: (data: any) => db.insert(cattleWeightRecords).values(data),

  deleteWeightRecord: (farmOwnerId: string, id: string) =>
    db
      .delete(cattleWeightRecords)
      .where(and(eq(cattleWeightRecords.farmOwnerId, farmOwnerId), eq(cattleWeightRecords.id, id))),
};

