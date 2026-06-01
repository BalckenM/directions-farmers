import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropPestObservations } from "../../db/schema";

export const cropPestObservationsRepo = {
  listPestObservations: async (
    farmOwnerId: string,
    offset: number,
    limit: number,
  ) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(cropPestObservations)
        .where(eq(cropPestObservations.farmOwnerId, farmOwnerId))
        .orderBy(desc(cropPestObservations.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(cropPestObservations)
        .where(eq(cropPestObservations.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(cropPestObservations)
      .where(
        and(
          eq(cropPestObservations.farmOwnerId, farmOwnerId),
          eq(cropPestObservations.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  create: (data: any) => db.insert(cropPestObservations).values(data),

  update: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cropPestObservations)
      .set(data)
      .where(
        and(
          eq(cropPestObservations.farmOwnerId, farmOwnerId),
          eq(cropPestObservations.id, id),
        ),
      ),

  delete: (farmOwnerId: string, id: string) =>
    db
      .delete(cropPestObservations)
      .where(
        and(
          eq(cropPestObservations.farmOwnerId, farmOwnerId),
          eq(cropPestObservations.id, id),
        ),
      ),
};
