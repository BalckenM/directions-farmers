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

export const goatPregnancyRepo = {
  listPregnancyChecks: (farmOwnerId: string) =>
    db
      .select(pregnancyCheckSelect)
      .from(goatPregnancyChecks)
      .where(eq(goatPregnancyChecks.farmOwnerId, farmOwnerId))
      .orderBy(desc(goatPregnancyChecks.date)),

  findPregnancyCheckById: (farmOwnerId: string, id: string) =>
    db
      .select(pregnancyCheckSelect)
      .from(goatPregnancyChecks)
      .where(and(eq(goatPregnancyChecks.farmOwnerId, farmOwnerId), eq(goatPregnancyChecks.id, id)))
      .then((r) => r[0] ?? null),

  createPregnancyCheck: (data: any) => db.insert(goatPregnancyChecks).values(data),
};

