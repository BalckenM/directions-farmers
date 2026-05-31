import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropHarvestRecords } from "../../db/schema";

export const cropHarvestRepo = {
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
};
