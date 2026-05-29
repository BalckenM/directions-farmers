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

export const goatHealthRepo = {
  listHealthEvents: (farmOwnerId: string) =>
    db
      .select(healthSelect)
      .from(goatHealthEvents)
      .where(eq(goatHealthEvents.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatHealthEvents.date)),

  findHealthEventById: (farmOwnerId: string, id: string) =>
    db
      .select(healthSelect)
      .from(goatHealthEvents)
      .where(and(eq(goatHealthEvents.farmOwnerId, farmOwnerId), eq(goatHealthEvents.id, id)))
      .then((r) => r[0] ?? null),

  createHealthEvent: (data: any) => db.insert(goatHealthEvents).values(data),

  updateHealthEvent: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(goatHealthEvents)
      .set(data)
      .where(and(eq(goatHealthEvents.farmOwnerId, farmOwnerId), eq(goatHealthEvents.id, id))),
};

