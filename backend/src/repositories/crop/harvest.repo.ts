import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropHarvestRecords } from "../../db/schema";

export const cropHarvestRepo = {
  listHarvestRecords: (farmOwnerId: string, planId?: string) => {
    const conditions = [eq(cropHarvestRecords.farmOwnerId, farmOwnerId)];
    if (planId) conditions.push(eq(cropHarvestRecords.plantingPlanId, planId));
    return db
      .select()
      .from(cropHarvestRecords)
      .where(and(...conditions))
      .orderBy(desc(cropHarvestRecords.harvestDate));
  },

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(cropHarvestRecords)
      .where(
        and(
          eq(cropHarvestRecords.farmOwnerId, farmOwnerId),
          eq(cropHarvestRecords.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  createHarvestRecord: (data: any) =>
    db.insert(cropHarvestRecords).values(data),

  updateHarvestRecord: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cropHarvestRecords)
      .set(data)
      .where(
        and(
          eq(cropHarvestRecords.farmOwnerId, farmOwnerId),
          eq(cropHarvestRecords.id, id),
        ),
      ),

  deleteHarvestRecord: (farmOwnerId: string, id: string) =>
    db
      .delete(cropHarvestRecords)
      .where(
        and(
          eq(cropHarvestRecords.farmOwnerId, farmOwnerId),
          eq(cropHarvestRecords.id, id),
        ),
      ),
};
