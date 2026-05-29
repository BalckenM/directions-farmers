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

export const cattleFeedRepo = {

  listFeedRecords: (farmOwnerId: string) =>
    db
      .select(feedSelect)
      .from(cattleFeedRecords)
      .where(eq(cattleFeedRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleFeedRecords.date)),

  findFeedRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(feedSelect)
      .from(cattleFeedRecords)
      .where(and(eq(cattleFeedRecords.farmOwnerId, farmOwnerId), eq(cattleFeedRecords.id, id)))
      .then((r) => r[0] ?? null),

  createFeedRecord: (data: any) => db.insert(cattleFeedRecords).values(data),

  deleteFeedRecord: (farmOwnerId: string, id: string) =>
    db
      .delete(cattleFeedRecords)
      .where(and(eq(cattleFeedRecords.farmOwnerId, farmOwnerId), eq(cattleFeedRecords.id, id))),
};

