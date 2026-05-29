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

export const cattleDippingRepo = {

  listDippingRecords: (farmOwnerId: string) =>
    db
      .select(dippingSelect)
      .from(cattleDippingRecords)
      .where(eq(cattleDippingRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleDippingRecords.dippingDate)),

  findDippingRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(dippingSelect)
      .from(cattleDippingRecords)
      .where(and(eq(cattleDippingRecords.farmOwnerId, farmOwnerId), eq(cattleDippingRecords.id, id)))
      .then((r) => r[0] ?? null),

  createDippingRecord: (data: any) => db.insert(cattleDippingRecords).values(data),
};

