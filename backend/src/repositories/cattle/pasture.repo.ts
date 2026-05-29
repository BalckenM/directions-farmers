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

export const cattlePastureRepo = {

  listPastureRecords: (farmOwnerId: string) =>
    db
      .select(pastureSelect)
      .from(cattlePastureRecords)
      .where(eq(cattlePastureRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattlePastureRecords.entryDate)),

  findPastureRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(pastureSelect)
      .from(cattlePastureRecords)
      .where(and(eq(cattlePastureRecords.farmOwnerId, farmOwnerId), eq(cattlePastureRecords.id, id)))
      .then((r) => r[0] ?? null),

  createPastureRecord: (data: any) => db.insert(cattlePastureRecords).values(data),

  updatePastureRecord: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cattlePastureRecords)
      .set(data)
      .where(and(eq(cattlePastureRecords.farmOwnerId, farmOwnerId), eq(cattlePastureRecords.id, id))),
};

