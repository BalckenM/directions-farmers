import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../config/database";
import { movementRecords } from "../db/schema";

export const traceabilityRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(movementRecords)
        .where(eq(movementRecords.farmOwnerId, farmOwnerId))
        .orderBy(desc(movementRecords.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(movementRecords)
        .where(eq(movementRecords.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(movementRecords)
      .where(
        and(eq(movementRecords.farmOwnerId, farmOwnerId), eq(movementRecords.id, id)),
      )
      .then((r) => r[0] ?? null),

  create: (data: Record<string, unknown>) =>
    db.insert(movementRecords).values(data as any),
};
