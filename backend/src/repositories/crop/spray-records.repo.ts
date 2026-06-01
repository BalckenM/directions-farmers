import { and, desc, eq } from "drizzle-orm";
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

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(cropSprayRecords)
      .where(
        and(
          eq(cropSprayRecords.farmOwnerId, farmOwnerId),
          eq(cropSprayRecords.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  createSprayRecord: (data: any) =>
    db.insert(cropSprayRecords).values(data),

  updateSprayRecord: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cropSprayRecords)
      .set(data)
      .where(
        and(
          eq(cropSprayRecords.farmOwnerId, farmOwnerId),
          eq(cropSprayRecords.id, id),
        ),
      ),

  deleteSprayRecord: (farmOwnerId: string, id: string) =>
    db
      .delete(cropSprayRecords)
      .where(
        and(
          eq(cropSprayRecords.farmOwnerId, farmOwnerId),
          eq(cropSprayRecords.id, id),
        ),
      ),
};
