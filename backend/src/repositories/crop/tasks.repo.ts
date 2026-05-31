import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropTasks } from "../../db/schema";

export const cropTasksRepo = {
  listTasks: (farmOwnerId: string, offset: number, limit: number) =>
    db
      .select()
      .from(cropTasks)
      .where(eq(cropTasks.farmOwnerId, farmOwnerId))
      .orderBy(desc(cropTasks.createdAt))
      .limit(limit)
      .offset(offset),

  createTask: (data: any) =>
    db.insert(cropTasks).values(data),

  updateTask: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cropTasks)
      .set({ ...data, updatedAt: new Date() })
      .where(and(eq(cropTasks.farmOwnerId, farmOwnerId), eq(cropTasks.id, id))),
};
