import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropPlantingPlans } from "../../db/schema";

export const cropPlantingPlansRepo = {
  listPlantingPlans: async (farmOwnerId: string, offset: number, limit: number) => {
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

  updatePlantingPlan: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cropPlantingPlans)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(cropPlantingPlans.farmOwnerId, farmOwnerId),
          eq(cropPlantingPlans.id, id),
        ),
      ),

  deletePlantingPlan: (farmOwnerId: string, id: string) =>
    db
      .delete(cropPlantingPlans)
      .where(
        and(
          eq(cropPlantingPlans.farmOwnerId, farmOwnerId),
          eq(cropPlantingPlans.id, id),
        ),
      ),
};
