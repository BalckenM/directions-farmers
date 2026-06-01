import { count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropAdvisoryContent } from "../../db/schema";

export const cropAdvisoryRepo = {
  listAdvisoryContent: async (
    farmOwnerId: string,
    offset: number,
    limit: number,
  ) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(cropAdvisoryContent)
        .where(eq(cropAdvisoryContent.farmOwnerId, farmOwnerId))
        .orderBy(desc(cropAdvisoryContent.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(cropAdvisoryContent)
        .where(eq(cropAdvisoryContent.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },
};
