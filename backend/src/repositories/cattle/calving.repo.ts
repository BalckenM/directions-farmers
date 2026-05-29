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

export const cattleCalvingRepo = {

  listCalvingEvents: (farmOwnerId: string) =>
    db
      .select(calvingSelect)
      .from(cattleCalvingEvents)
      .where(eq(cattleCalvingEvents.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleCalvingEvents.calvingDate)),

  findCalvingEventById: (farmOwnerId: string, id: string) =>
    db
      .select(calvingSelect)
      .from(cattleCalvingEvents)
      .where(and(eq(cattleCalvingEvents.farmOwnerId, farmOwnerId), eq(cattleCalvingEvents.id, id)))
      .then((r) => r[0] ?? null),

  createCalvingEvent: (data: any) => db.insert(cattleCalvingEvents).values(data),
};

