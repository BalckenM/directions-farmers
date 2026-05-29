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

export const cattleBreedingRepo = {

  listBreedingRecords: (farmOwnerId: string) =>
    db
      .select(breedingSelect)
      .from(cattleBreedingRecords)
      .where(eq(cattleBreedingRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleBreedingRecords.serviceDate)),

  findBreedingRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(breedingSelect)
      .from(cattleBreedingRecords)
      .where(and(eq(cattleBreedingRecords.farmOwnerId, farmOwnerId), eq(cattleBreedingRecords.id, id)))
      .then((r) => r[0] ?? null),

  createBreedingRecord: (data: any) => db.insert(cattleBreedingRecords).values(data),

  updateBreedingRecord: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cattleBreedingRecords)
      .set(data)
      .where(and(eq(cattleBreedingRecords.farmOwnerId, farmOwnerId), eq(cattleBreedingRecords.id, id))),
};

