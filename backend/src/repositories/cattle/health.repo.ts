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

export const cattleHealthRepo = {

  listHealthEvents: (farmOwnerId: string) =>
    db
      .select(healthSelect)
      .from(cattleHealthEvents)
      .where(eq(cattleHealthEvents.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleHealthEvents.date)),

  findHealthEventById: (farmOwnerId: string, id: string) =>
    db
      .select(healthSelect)
      .from(cattleHealthEvents)
      .where(and(eq(cattleHealthEvents.farmOwnerId, farmOwnerId), eq(cattleHealthEvents.id, id)))
      .then((r) => r[0] ?? null),

  createHealthEvent: (data: any) => db.insert(cattleHealthEvents).values(data),

  updateHealthEvent: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cattleHealthEvents)
      .set(data)
      .where(and(eq(cattleHealthEvents.farmOwnerId, farmOwnerId), eq(cattleHealthEvents.id, id))),
};

