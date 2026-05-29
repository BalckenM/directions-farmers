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

export const goatMilkRepo = {
  listDailyMilk: (farmOwnerId: string) =>
    db
      .select(milkSelect)
      .from(goatDailyMilk)
      .where(eq(goatDailyMilk.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatDailyMilk.date)),

  findDailyMilkById: (farmOwnerId: string, id: string) =>
    db
      .select(milkSelect)
      .from(goatDailyMilk)
      .where(and(eq(goatDailyMilk.farmOwnerId, farmOwnerId), eq(goatDailyMilk.id, id)))
      .then((r) => r[0] ?? null),

  createDailyMilk: (data: any) => db.insert(goatDailyMilk).values(data),

  deleteDailyMilk: (farmOwnerId: string, id: string) =>
    db
      .delete(goatDailyMilk)
      .where(and(eq(goatDailyMilk.farmOwnerId, farmOwnerId), eq(goatDailyMilk.id, id))),
};

