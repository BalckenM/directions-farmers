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

export const cattleBcsRepo = {

  listBcsRecords: (farmOwnerId: string) =>
    db
      .select(bcsSelect)
      .from(cattleBcsRecords)
      .where(eq(cattleBcsRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleBcsRecords.date)),

  findBcsRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(bcsSelect)
      .from(cattleBcsRecords)
      .where(and(eq(cattleBcsRecords.farmOwnerId, farmOwnerId), eq(cattleBcsRecords.id, id)))
      .then((r) => r[0] ?? null),

  createBcsRecord: (data: any) => db.insert(cattleBcsRecords).values(data),
};

