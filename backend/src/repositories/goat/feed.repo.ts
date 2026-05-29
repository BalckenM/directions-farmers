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

export const goatFeedRepo = {
  listFeedRecords: (farmOwnerId: string) =>
    db
      .select(feedSelect)
      .from(goatFeedRecords)
      .where(eq(goatFeedRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatFeedRecords.date)),

  findFeedRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(feedSelect)
      .from(goatFeedRecords)
      .where(and(eq(goatFeedRecords.farmOwnerId, farmOwnerId), eq(goatFeedRecords.id, id)))
      .then((r) => r[0] ?? null),

  createFeedRecord: (data: any) => db.insert(goatFeedRecords).values(data),

  deleteFeedRecord: (farmOwnerId: string, id: string) =>
    db
      .delete(goatFeedRecords)
      .where(and(eq(goatFeedRecords.farmOwnerId, farmOwnerId), eq(goatFeedRecords.id, id))),
};

