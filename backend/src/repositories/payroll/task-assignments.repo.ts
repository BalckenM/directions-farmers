import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollTaskAssignments } from "../../db/schema";

export const payrollTaskAssignmentsRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(payrollTaskAssignments)
        .where(eq(payrollTaskAssignments.farmOwnerId, farmOwnerId))
        .orderBy(desc(payrollTaskAssignments.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(payrollTaskAssignments)
        .where(eq(payrollTaskAssignments.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(payrollTaskAssignments)
      .where(
        and(
          eq(payrollTaskAssignments.farmOwnerId, farmOwnerId),
          eq(payrollTaskAssignments.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  create: (data: any) => db.insert(payrollTaskAssignments).values(data),

  update: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(payrollTaskAssignments)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(payrollTaskAssignments.farmOwnerId, farmOwnerId),
          eq(payrollTaskAssignments.id, id),
        ),
      ),

  delete: (farmOwnerId: string, id: string) =>
    db
      .delete(payrollTaskAssignments)
      .where(
        and(
          eq(payrollTaskAssignments.farmOwnerId, farmOwnerId),
          eq(payrollTaskAssignments.id, id),
        ),
      ),
};
