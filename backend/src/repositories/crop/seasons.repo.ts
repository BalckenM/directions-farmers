import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropSeasons } from "../../db/schema";

export const cropSeasonsRepo = {
  listSeasons: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(cropSeasons)
        .where(eq(cropSeasons.farmOwnerId, farmOwnerId))
        .orderBy(desc(cropSeasons.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(cropSeasons)
        .where(eq(cropSeasons.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findSeasonById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(cropSeasons)
      .where(
        and(eq(cropSeasons.farmOwnerId, farmOwnerId), eq(cropSeasons.id, id)),
      )
      .then((r) => r[0] ?? null),

  createSeason: (data: any) => db.insert(cropSeasons).values(data),

  updateSeason: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cropSeasons)
      .set(data)
      .where(
        and(eq(cropSeasons.farmOwnerId, farmOwnerId), eq(cropSeasons.id, id)),
      ),

  deleteSeason: (farmOwnerId: string, id: string) =>
    db
      .delete(cropSeasons)
      .where(
        and(eq(cropSeasons.farmOwnerId, farmOwnerId), eq(cropSeasons.id, id)),
      ),
};
