import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
  cattleBreedingRecords
} from "../../db/schema";

import { breedingSelect } from "./_projections";

// ─────────────────────────────────────────────────────────────────────────────

export const cattleBreedingRepo = {

  listBreedingRecords: (farmOwnerId: string) =>
    db
      .select(breedingSelect)
      .from(cattleBreedingRecords)
      .where(eq(cattleBreedingRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cattleBreedingRecords.breedingDate)),

  findBreedingRecordById: (farmOwnerId: string, id: string) =>
    db
      .select(breedingSelect)
      .from(cattleBreedingRecords)
      .where(and(eq(cattleBreedingRecords.farmOwnerId, farmOwnerId), eq(cattleBreedingRecords.id, id)))
      .then((r) => r[0] ?? null),

  createBreedingRecord: (data: any) => db.insert(cattleBreedingRecords).values(data),

  updateBreedingRecord: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cattleBreedingRecords)
      .set(data)
      .where(and(eq(cattleBreedingRecords.farmOwnerId, farmOwnerId), eq(cattleBreedingRecords.id, id))),
};

