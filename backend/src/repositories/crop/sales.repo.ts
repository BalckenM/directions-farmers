import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropSales } from "../../db/schema";

export const cropSalesRepo = {
  listSales: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(cropSales)
        .where(eq(cropSales.farmOwnerId, farmOwnerId))
        .orderBy(desc(cropSales.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(cropSales)
        .where(eq(cropSales.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(cropSales)
      .where(
        and(eq(cropSales.farmOwnerId, farmOwnerId), eq(cropSales.id, id)),
      )
      .then((r) => r[0] ?? null),

  create: (data: any) => db.insert(cropSales).values(data),

  update: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cropSales)
      .set(data)
      .where(
        and(eq(cropSales.farmOwnerId, farmOwnerId), eq(cropSales.id, id)),
      ),

  delete: (farmOwnerId: string, id: string) =>
    db
      .delete(cropSales)
      .where(
        and(eq(cropSales.farmOwnerId, farmOwnerId), eq(cropSales.id, id)),
      ),
};
