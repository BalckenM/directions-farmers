import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollPayRuns } from "../../db/schema";


export const payrollPayRunsRepo = {
  listPayRuns: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(payrollPayRuns)
        .where(eq(payrollPayRuns.farmOwnerId, farmOwnerId))
        .orderBy(desc(payrollPayRuns.periodStart))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(payrollPayRuns)
        .where(eq(payrollPayRuns.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },


  findPayRunById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(payrollPayRuns)
      .where(
        and(
          eq(payrollPayRuns.farmOwnerId, farmOwnerId),
          eq(payrollPayRuns.id, id),
        ),
      )
      .then((r) => r[0] ?? null),


  createPayRun: (data: typeof payrollPayRuns.$inferInsert) =>
    db.insert(payrollPayRuns).values(data),


  updatePayRun: (
    farmOwnerId: string,
    id: string,
    data: Partial<typeof payrollPayRuns.$inferInsert>,
  ) =>
    db
      .update(payrollPayRuns)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(payrollPayRuns.farmOwnerId, farmOwnerId),
          eq(payrollPayRuns.id, id),
        ),
      ),

};
