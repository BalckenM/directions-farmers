import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
  goatAnimals,
  goatBcsRecords,
  goatDailyMilk,
  goatFamachaRecords,
  goatFeedRecords,
  goatHealthEvents,
  goatKiddingEvents,
  goatMatingRecords,
  goatMedicationLogs,
  goatPastureRecords,
  goatPregnancyChecks,
  goatSaleRecords,
  goatShearingRecords,
  goatVaccinations,
  goatWeightRecords,
} from "../../db/schema";

import { animalSelect, weightSelect, matingSelect, pregnancyCheckSelect, kiddingSelect, milkSelect, shearingSelect, healthSelect, medicationSelect, vaccinationSelect, saleSelect, feedSelect, pastureSelect, famachaSelect, bcsSelect } from "./_projections";

// ── Repository ────────────────────────────────────────────────────────────────

export const goatAnimalsRepo = {
  listAnimals: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select(animalSelect)
        .from(goatAnimals)
        .where(eq(goatAnimals.farmOwnerId, farmOwnerId))
        .orderBy(desc(goatAnimals.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(goatAnimals)
        .where(eq(goatAnimals.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findAnimalById: (farmOwnerId: string, id: string) =>
    db
      .select(animalSelect)
      .from(goatAnimals)
      .where(and(eq(goatAnimals.farmOwnerId, farmOwnerId), eq(goatAnimals.id, id)))
      .then((r) => r[0] ?? null),

  createAnimal: (data: any) => db.insert(goatAnimals).values(data),

  updateAnimal: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(goatAnimals)
      .set({ ...data, updatedAt: new Date() })
      .where(and(eq(goatAnimals.farmOwnerId, farmOwnerId), eq(goatAnimals.id, id))),

  deleteAnimal: (farmOwnerId: string, id: string) =>
    db
      .delete(goatAnimals)
      .where(and(eq(goatAnimals.farmOwnerId, farmOwnerId), eq(goatAnimals.id, id))),
};

