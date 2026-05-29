import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../config/database";
import { feedLogs } from "../db/schema";

export const recordRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(feedLogs)
        .where(eq(feedLogs.farmOwnerId, farmOwnerId))
        .orderBy(desc(feedLogs.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(feedLogs)
        .where(eq(feedLogs.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(feedLogs)
      .where(and(eq(feedLogs.farmOwnerId, farmOwnerId), eq(feedLogs.id, id)))
      .then((r) => r[0] ?? null),

  create: (data: Record<string, unknown>) =>
    db.insert(feedLogs).values(data as any),
};
