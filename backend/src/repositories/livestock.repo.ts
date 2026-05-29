import { and, count, eq } from "drizzle-orm";
import { db } from "../config/database";
import { cattleAnimals, goatAnimals, livestockGroups } from "../db/schema";

export const livestockRepo = {
  getGoats: (farmOwnerId: string) =>
    db
      .select()
      .from(goatAnimals)
      .where(eq(goatAnimals.farmOwnerId, farmOwnerId)),

  getCattle: (farmOwnerId: string) =>
    db
      .select()
      .from(cattleAnimals)
      .where(eq(cattleAnimals.farmOwnerId, farmOwnerId)),

  listGroups: (farmOwnerId: string) =>
    db
      .select()
      .from(livestockGroups)
      .where(eq(livestockGroups.farmOwnerId, farmOwnerId)),

  findGroupById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(livestockGroups)
      .where(
        and(eq(livestockGroups.farmOwnerId, farmOwnerId), eq(livestockGroups.id, id)),
      )
      .then((r) => r[0] ?? null),

  createGroup: (data: Record<string, unknown>) =>
    db.insert(livestockGroups).values(data as any),

  updateGroup: (farmOwnerId: string, id: string, data: Record<string, unknown>) =>
    db
      .update(livestockGroups)
      .set({ ...(data as any), updatedAt: new Date() })
      .where(
        and(eq(livestockGroups.farmOwnerId, farmOwnerId), eq(livestockGroups.id, id)),
      ),

  deleteGroup: (farmOwnerId: string, id: string) =>
    db
      .delete(livestockGroups)
      .where(
        and(eq(livestockGroups.farmOwnerId, farmOwnerId), eq(livestockGroups.id, id)),
      ),

  countGoats: (farmOwnerId: string) =>
    db
      .select({ count: count() })
      .from(goatAnimals)
      .where(eq(goatAnimals.farmOwnerId, farmOwnerId))
      .then((r) => Number(r[0]?.count ?? 0)),

  countCattle: (farmOwnerId: string) =>
    db
      .select({ count: count() })
      .from(cattleAnimals)
      .where(eq(cattleAnimals.farmOwnerId, farmOwnerId))
      .then((r) => Number(r[0]?.count ?? 0)),
};
