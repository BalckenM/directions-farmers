import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropExpenses } from "../../db/schema";

export const cropExpensesRepo = {
  listExpenses: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(cropExpenses)
        .where(eq(cropExpenses.farmOwnerId, farmOwnerId))
        .orderBy(desc(cropExpenses.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(cropExpenses)
        .where(eq(cropExpenses.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(cropExpenses)
      .where(
        and(
          eq(cropExpenses.farmOwnerId, farmOwnerId),
          eq(cropExpenses.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  create: (data: any) => db.insert(cropExpenses).values(data),

  update: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cropExpenses)
      .set(data)
      .where(
        and(
          eq(cropExpenses.farmOwnerId, farmOwnerId),
          eq(cropExpenses.id, id),
        ),
      ),

  delete: (farmOwnerId: string, id: string) =>
    db
      .delete(cropExpenses)
      .where(
        and(
          eq(cropExpenses.farmOwnerId, farmOwnerId),
          eq(cropExpenses.id, id),
        ),
      ),
};
