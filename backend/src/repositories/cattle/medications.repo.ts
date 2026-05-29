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

export const cattleMedicationsRepo = {

  listMedicationLogs: (farmOwnerId: string) =>
    db
      .select(medicationSelect)
      .from(cattleMedicationLogs)
      .where(eq(cattleMedicationLogs.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleMedicationLogs.date)),

  findMedicationLogById: (farmOwnerId: string, id: string) =>
    db
      .select(medicationSelect)
      .from(cattleMedicationLogs)
      .where(and(eq(cattleMedicationLogs.farmOwnerId, farmOwnerId), eq(cattleMedicationLogs.id, id)))
      .then((r) => r[0] ?? null),

  createMedicationLog: (data: any) => db.insert(cattleMedicationLogs).values(data),
};

