import { count, desc } from "drizzle-orm";
import { db } from "../../config/database";
import { cropCategories } from "../../db/schema";

export const cropCategoriesRepo = {
  listCategories: async (offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(cropCategories)
        .orderBy(desc(cropCategories.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(cropCategories)
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },
};
