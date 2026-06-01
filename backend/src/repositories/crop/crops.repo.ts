import { count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { crops } from "../../db/schema";

export const cropsRepo = {
  listCrops: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(crops)
        .where(eq(crops.farmOwnerId, farmOwnerId))
        .orderBy(desc(crops.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(crops)
        .where(eq(crops.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },
};
