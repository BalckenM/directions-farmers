import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../config/database";
import {
  productionEggRecords,
  productionMilkRecords,
  productionWoolRecords,
} from "../db/schema";

export const productionRepo = {
  // ── Milk ───────────────────────────────────────────────────────────────────

  listMilk: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(productionMilkRecords)
        .where(eq(productionMilkRecords.farmOwnerId, farmOwnerId))
        .orderBy(desc(productionMilkRecords.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(productionMilkRecords)
        .where(eq(productionMilkRecords.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  insertMilk: (data: Record<string, unknown>) =>
    db.insert(productionMilkRecords).values(data as any),

  findMilkById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(productionMilkRecords)
      .where(
        and(
          eq(productionMilkRecords.farmOwnerId, farmOwnerId),
          eq(productionMilkRecords.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  // ── Eggs ───────────────────────────────────────────────────────────────────

  listEggs: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(productionEggRecords)
        .where(eq(productionEggRecords.farmOwnerId, farmOwnerId))
        .orderBy(desc(productionEggRecords.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(productionEggRecords)
        .where(eq(productionEggRecords.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  insertEggs: (data: Record<string, unknown>) =>
    db.insert(productionEggRecords).values(data as any),

  findEggsById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(productionEggRecords)
      .where(
        and(
          eq(productionEggRecords.farmOwnerId, farmOwnerId),
          eq(productionEggRecords.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  // ── Wool ───────────────────────────────────────────────────────────────────

  listWool: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(productionWoolRecords)
        .where(eq(productionWoolRecords.farmOwnerId, farmOwnerId))
        .orderBy(desc(productionWoolRecords.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(productionWoolRecords)
        .where(eq(productionWoolRecords.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  insertWool: (data: Record<string, unknown>) =>
    db.insert(productionWoolRecords).values(data as any),

  findWoolById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(productionWoolRecords)
      .where(
        and(
          eq(productionWoolRecords.farmOwnerId, farmOwnerId),
          eq(productionWoolRecords.id, id),
        ),
      )
      .then((r) => r[0] ?? null),
};
