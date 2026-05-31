import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropFields } from "../../db/schema";

export const cropFieldsRepo = {
  listFields: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(cropFields)
        .where(eq(cropFields.farmOwnerId, farmOwnerId))
        .orderBy(desc(cropFields.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(cropFields)
        .where(eq(cropFields.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findFieldById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(cropFields)
      .where(and(eq(cropFields.farmOwnerId, farmOwnerId), eq(cropFields.id, id)))
      .then((r) => r[0] ?? null),

  createField: (data: any) => db.insert(cropFields).values(data),

  updateField: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cropFields)
      .set({ ...data, updatedAt: new Date() })
      .where(and(eq(cropFields.farmOwnerId, farmOwnerId), eq(cropFields.id, id))),

  deleteField: (farmOwnerId: string, id: string) =>
    db
      .delete(cropFields)
      .where(and(eq(cropFields.farmOwnerId, farmOwnerId), eq(cropFields.id, id))),
};
