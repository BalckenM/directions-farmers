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

export const cattleAnimalsRepo = {

  listAnimals: (farmOwnerId: string) =>
    db
      .select(animalSelect)
      .from(cattleAnimals)
      .where(eq(cattleAnimals.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleAnimals.createdAt)),

  findAnimalById: (farmOwnerId: string, id: string) =>
    db
      .select(animalSelect)
      .from(cattleAnimals)
      .where(and(eq(cattleAnimals.farmOwnerId, farmOwnerId), eq(cattleAnimals.id, id)))
      .then((r) => r[0] ?? null),

  createAnimal: (data: any) => db.insert(cattleAnimals).values(data),

  updateAnimal: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cattleAnimals)
      .set({ ...data, updatedAt: new Date() })
      .where(and(eq(cattleAnimals.farmOwnerId, farmOwnerId), eq(cattleAnimals.id, id))),

  deleteAnimal: (farmOwnerId: string, id: string) =>
    db
      .delete(cattleAnimals)
      .where(and(eq(cattleAnimals.farmOwnerId, farmOwnerId), eq(cattleAnimals.id, id))),
};

