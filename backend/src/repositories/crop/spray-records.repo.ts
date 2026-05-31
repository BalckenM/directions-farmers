import { desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropSprayRecords } from "../../db/schema";

export const cropSprayRecordsRepo = {
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
