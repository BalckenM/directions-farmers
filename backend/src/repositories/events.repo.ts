import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../config/database";
import {
  farmBreedingEvents,
  farmHealthEvents,
  farmWeightRecords,
} from "../db/schema";

export const eventsRepo = {
  // ── Health ─────────────────────────────────────────────────────────────────

  listHealth: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(farmHealthEvents)
        .where(eq(farmHealthEvents.farmOwnerId, farmOwnerId))
        .orderBy(desc(farmHealthEvents.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(farmHealthEvents)
        .where(eq(farmHealthEvents.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  insertHealth: (data: Record<string, unknown>) =>
    db.insert(farmHealthEvents).values(data as any),

  findHealthById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(farmHealthEvents)
      .where(
        and(eq(farmHealthEvents.farmOwnerId, farmOwnerId), eq(farmHealthEvents.id, id)),
      )
      .then((r) => r[0] ?? null),

  // ── Weight ─────────────────────────────────────────────────────────────────

  listWeights: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(farmWeightRecords)
        .where(eq(farmWeightRecords.farmOwnerId, farmOwnerId))
        .orderBy(desc(farmWeightRecords.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(farmWeightRecords)
        .where(eq(farmWeightRecords.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  insertWeight: (data: Record<string, unknown>) =>
    db.insert(farmWeightRecords).values(data as any),

  findWeightById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(farmWeightRecords)
      .where(
        and(
          eq(farmWeightRecords.farmOwnerId, farmOwnerId),
          eq(farmWeightRecords.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  // ── Breeding ───────────────────────────────────────────────────────────────

  listBreeding: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(farmBreedingEvents)
        .where(eq(farmBreedingEvents.farmOwnerId, farmOwnerId))
        .orderBy(desc(farmBreedingEvents.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(farmBreedingEvents)
        .where(eq(farmBreedingEvents.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  insertBreeding: (data: Record<string, unknown>) =>
    db.insert(farmBreedingEvents).values(data as any),

  findBreedingById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(farmBreedingEvents)
      .where(
        and(
          eq(farmBreedingEvents.farmOwnerId, farmOwnerId),
          eq(farmBreedingEvents.id, id),
        ),
      )
      .then((r) => r[0] ?? null),
};
