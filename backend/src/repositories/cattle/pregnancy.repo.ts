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

export const cattlePregnancyRepo = {

  listPregnancyChecks: (farmOwnerId: string) =>
    db
      .select(pregnancyCheckSelect)
      .from(cattlePregnancyChecks)
      .where(eq(cattlePregnancyChecks.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattlePregnancyChecks.date)),

  findPregnancyCheckById: (farmOwnerId: string, id: string) =>
    db
      .select(pregnancyCheckSelect)
      .from(cattlePregnancyChecks)
      .where(and(eq(cattlePregnancyChecks.farmOwnerId, farmOwnerId), eq(cattlePregnancyChecks.id, id)))
      .then((r) => r[0] ?? null),

  createPregnancyCheck: (data: any) => db.insert(cattlePregnancyChecks).values(data),
};

