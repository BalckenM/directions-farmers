import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { poultryDailyRecords } from "../../db/schema";

export const poultryDailyRecordsRepo = {
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
};
