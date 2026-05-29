import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../config/database";
import {
    poultryDailyRecords,
    poultryFlocks,
    poultryHarvestRecords,
    poultryVaccinationSchedules,
} from "../db/schema";

export const poultryRepo = {
  listFlocks: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(poultryFlocks)
        .where(eq(poultryFlocks.farmOwnerId, farmOwnerId))
        .orderBy(desc(poultryFlocks.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(poultryFlocks)
        .where(eq(poultryFlocks.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findFlockById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(poultryFlocks)
      .where(
        and(
          eq(poultryFlocks.farmOwnerId, farmOwnerId),
          eq(poultryFlocks.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  createFlock: (data: any) =>
    db.insert(poultryFlocks).values(data),

  updateFlock: (
    farmOwnerId: string,
    id: string,
    data: any,
  ) =>
    db
      .update(poultryFlocks)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(poultryFlocks.farmOwnerId, farmOwnerId),
          eq(poultryFlocks.id, id),
        ),
      ),

  deleteFlock: (farmOwnerId: string, id: string) =>
    db
      .delete(poultryFlocks)
      .where(
        and(
          eq(poultryFlocks.farmOwnerId, farmOwnerId),
          eq(poultryFlocks.id, id),
        ),
      ),

  listDailyRecords: (farmOwnerId: string, flockId: string) =>
    db
      .select()
      .from(poultryDailyRecords)
      .where(
        and(
          eq(poultryDailyRecords.farmOwnerId, farmOwnerId),
          eq(poultryDailyRecords.flockId, flockId),
        ),
      )
      .orderBy(desc(poultryDailyRecords.recordDate)),

  createDailyRecord: (data: any) =>
    db.insert(poultryDailyRecords).values(data),

  listVaccinationSchedules: (farmOwnerId: string, flockId: string) =>
    db
      .select()
      .from(poultryVaccinationSchedules)
      .where(
        and(
          eq(poultryVaccinationSchedules.farmOwnerId, farmOwnerId),
          eq(poultryVaccinationSchedules.flockId, flockId),
        ),
      )
      .orderBy(desc(poultryVaccinationSchedules.scheduledDate)),

  createVaccinationSchedule: (
    data: any,
  ) => db.insert(poultryVaccinationSchedules).values(data),

  listHarvestRecords: (farmOwnerId: string, flockId: string) =>
    db
      .select()
      .from(poultryHarvestRecords)
      .where(
        and(
          eq(poultryHarvestRecords.farmOwnerId, farmOwnerId),
          eq(poultryHarvestRecords.flockId, flockId),
        ),
      )
      .orderBy(desc(poultryHarvestRecords.harvestDate)),

  createHarvestRecord: (data: any) =>
    db.insert(poultryHarvestRecords).values(data),
};
