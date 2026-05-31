import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { poultryHarvestRecords } from "../../db/schema";

export const poultryHarvestRepo = {
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
