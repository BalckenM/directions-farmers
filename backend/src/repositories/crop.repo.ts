import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../config/database";
import {
    cropFields,
    cropHarvestRecords,
    cropPlantingPlans,
    cropSprayRecords,
    cropTasks,
} from "../db/schema";

export const cropRepo = {
  listFields: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(cropFields)
        .where(eq(cropFields.farmOwnerId, farmOwnerId))
        .orderBy(desc(cropFields.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(cropFields)
        .where(eq(cropFields.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findFieldById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(cropFields)
      .where(
        and(eq(cropFields.farmOwnerId, farmOwnerId), eq(cropFields.id, id)),
      )
      .then((r) => r[0] ?? null),

  createField: (data: any) =>
    db.insert(cropFields).values(data),

  updateField: (
    farmOwnerId: string,
    id: string,
    data: any,
  ) =>
    db
      .update(cropFields)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(eq(cropFields.farmOwnerId, farmOwnerId), eq(cropFields.id, id)),
      ),

  deleteField: (farmOwnerId: string, id: string) =>
    db
      .delete(cropFields)
      .where(
        and(eq(cropFields.farmOwnerId, farmOwnerId), eq(cropFields.id, id)),
      ),

  listPlantingPlans: async (
    farmOwnerId: string,
    offset: number,
    limit: number,
  ) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(cropPlantingPlans)
        .where(eq(cropPlantingPlans.farmOwnerId, farmOwnerId))
        .orderBy(desc(cropPlantingPlans.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(cropPlantingPlans)
        .where(eq(cropPlantingPlans.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findPlantingPlanById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(cropPlantingPlans)
      .where(
        and(
          eq(cropPlantingPlans.farmOwnerId, farmOwnerId),
          eq(cropPlantingPlans.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  createPlantingPlan: (data: any) =>
    db.insert(cropPlantingPlans).values(data),

  updatePlantingPlan: (
    farmOwnerId: string,
    id: string,
    data: any,
  ) =>
    db
      .update(cropPlantingPlans)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(cropPlantingPlans.farmOwnerId, farmOwnerId),
          eq(cropPlantingPlans.id, id),
        ),
      ),

  listHarvestRecords: (farmOwnerId: string, planId: string) =>
    db
      .select()
      .from(cropHarvestRecords)
      .where(
        and(
          eq(cropHarvestRecords.farmOwnerId, farmOwnerId),
          eq(cropHarvestRecords.plantingPlanId, planId),
        ),
      )
      .orderBy(desc(cropHarvestRecords.harvestDate)),

  createHarvestRecord: (data: any) =>
    db.insert(cropHarvestRecords).values(data),

  listTasks: (farmOwnerId: string, offset: number, limit: number) =>
    db
      .select()
      .from(cropTasks)
      .where(eq(cropTasks.farmOwnerId, farmOwnerId))
      .orderBy(desc(cropTasks.createdAt))
      .limit(limit)
      .offset(offset),

  createTask: (data: any) =>
    db.insert(cropTasks).values(data),

  updateTask: (
    farmOwnerId: string,
    id: string,
    data: any,
  ) =>
    db
      .update(cropTasks)
      .set({ ...data, updatedAt: new Date() })
      .where(and(eq(cropTasks.farmOwnerId, farmOwnerId), eq(cropTasks.id, id))),

  listSprayRecords: (farmOwnerId: string, offset: number, limit: number) =>
    db
      .select()
      .from(cropSprayRecords)
      .where(eq(cropSprayRecords.farmOwnerId, farmOwnerId))
      .orderBy(desc(cropSprayRecords.sprayDate))
      .limit(limit)
      .offset(offset),

  createSprayRecord: (data: any) =>
    db.insert(cropSprayRecords).values(data),
};
