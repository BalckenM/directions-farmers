import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../config/database";
import { farmPaddocks, farmStaff } from "../db/schema";

export const farmRepo = {
  // ── Staff ─────────────────────────────────────────────────────────────────

  listStaff: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(farmStaff)
        .where(eq(farmStaff.farmOwnerId, farmOwnerId))
        .orderBy(desc(farmStaff.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(farmStaff)
        .where(eq(farmStaff.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findStaffById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(farmStaff)
      .where(and(eq(farmStaff.farmOwnerId, farmOwnerId), eq(farmStaff.id, id)))
      .then((r) => r[0] ?? null),

  updateStaff: (farmOwnerId: string, id: string, data: Record<string, unknown>) =>
    db
      .update(farmStaff)
      .set({ ...(data as any), updatedAt: new Date() })
      .where(and(eq(farmStaff.farmOwnerId, farmOwnerId), eq(farmStaff.id, id))),

  deactivateStaff: (farmOwnerId: string, id: string) =>
    db
      .update(farmStaff)
      .set({ isActive: false, updatedAt: new Date() })
      .where(and(eq(farmStaff.farmOwnerId, farmOwnerId), eq(farmStaff.id, id))),

  // ── Paddocks ───────────────────────────────────────────────────────────────

  listPaddocks: (farmOwnerId: string) =>
    db
      .select()
      .from(farmPaddocks)
      .where(eq(farmPaddocks.farmOwnerId, farmOwnerId))
      .orderBy(farmPaddocks.name),

  findPaddockById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(farmPaddocks)
      .where(and(eq(farmPaddocks.farmOwnerId, farmOwnerId), eq(farmPaddocks.id, id)))
      .then((r) => r[0] ?? null),

  createPaddock: (data: Record<string, unknown>) =>
    db.insert(farmPaddocks).values(data as any),

  updatePaddock: (farmOwnerId: string, id: string, data: Record<string, unknown>) =>
    db
      .update(farmPaddocks)
      .set({ ...(data as any), updatedAt: new Date() })
      .where(and(eq(farmPaddocks.farmOwnerId, farmOwnerId), eq(farmPaddocks.id, id))),

  deletePaddock: (farmOwnerId: string, id: string) =>
    db
      .delete(farmPaddocks)
      .where(and(eq(farmPaddocks.farmOwnerId, farmOwnerId), eq(farmPaddocks.id, id))),
};
