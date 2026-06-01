import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollShifts } from "../../db/schema";

export const payrollShiftsRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(payrollShifts)
        .where(eq(payrollShifts.farmOwnerId, farmOwnerId))
        .orderBy(desc(payrollShifts.shiftDate))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(payrollShifts)
        .where(eq(payrollShifts.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(payrollShifts)
      .where(
        and(
          eq(payrollShifts.farmOwnerId, farmOwnerId),
          eq(payrollShifts.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  create: (data: any) => db.insert(payrollShifts).values(data),

  update: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(payrollShifts)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(payrollShifts.farmOwnerId, farmOwnerId),
          eq(payrollShifts.id, id),
        ),
      ),

  delete: (farmOwnerId: string, id: string) =>
    db
      .delete(payrollShifts)
      .where(
        and(
          eq(payrollShifts.farmOwnerId, farmOwnerId),
          eq(payrollShifts.id, id),
        ),
      ),
};
