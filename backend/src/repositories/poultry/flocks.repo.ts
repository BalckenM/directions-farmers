import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { poultryFlocks } from "../../db/schema";

export const poultryFlocksRepo = {
  listFlocks: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(poultryFlocks)
        .where(eq(poultryFlocks.farmOwnerId, farmOwnerId))
        .orderBy(desc(poultryFlocks.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(poultryFlocks)
        .where(eq(poultryFlocks.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findFlockById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(poultryFlocks)
      .where(
        and(
          eq(poultryFlocks.farmOwnerId, farmOwnerId),
          eq(poultryFlocks.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  createFlock: (data: any) =>
    db.insert(poultryFlocks).values(data),

  updateFlock: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(poultryFlocks)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(poultryFlocks.farmOwnerId, farmOwnerId),
          eq(poultryFlocks.id, id),
        ),
      ),

  deleteFlock: (farmOwnerId: string, id: string) =>
    db
      .delete(poultryFlocks)
      .where(
        and(
          eq(poultryFlocks.farmOwnerId, farmOwnerId),
          eq(poultryFlocks.id, id),
        ),
      ),
};
