import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../config/database";
import { financialTransactions } from "../db/schema";

export const financialRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(financialTransactions)
        .where(eq(financialTransactions.farmOwnerId, farmOwnerId))
        .orderBy(desc(financialTransactions.transactionDate))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(financialTransactions)
        .where(eq(financialTransactions.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(financialTransactions)
      .where(
        and(
          eq(financialTransactions.farmOwnerId, farmOwnerId),
          eq(financialTransactions.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  create: (data: any) =>
    db.insert(financialTransactions).values(data),

  update: (
    farmOwnerId: string,
    id: string,
    data: any,
  ) =>
    db
      .update(financialTransactions)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(financialTransactions.farmOwnerId, farmOwnerId),
          eq(financialTransactions.id, id),
        ),
      ),

  delete: (farmOwnerId: string, id: string) =>
    db
      .delete(financialTransactions)
      .where(
        and(
          eq(financialTransactions.farmOwnerId, farmOwnerId),
          eq(financialTransactions.id, id),
        ),
      ),
};
