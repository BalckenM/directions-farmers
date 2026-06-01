import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { cropCalendarEvents } from "../../db/schema";

export const cropCalendarEventsRepo = {
  listCalendarEvents: async (
    farmOwnerId: string,
    offset: number,
    limit: number,
  ) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(cropCalendarEvents)
        .where(eq(cropCalendarEvents.farmOwnerId, farmOwnerId))
        .orderBy(desc(cropCalendarEvents.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(cropCalendarEvents)
        .where(eq(cropCalendarEvents.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(cropCalendarEvents)
      .where(
        and(
          eq(cropCalendarEvents.farmOwnerId, farmOwnerId),
          eq(cropCalendarEvents.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  create: (data: any) => db.insert(cropCalendarEvents).values(data),

  update: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(cropCalendarEvents)
      .set(data)
      .where(
        and(
          eq(cropCalendarEvents.farmOwnerId, farmOwnerId),
          eq(cropCalendarEvents.id, id),
        ),
      ),

  delete: (farmOwnerId: string, id: string) =>
    db
      .delete(cropCalendarEvents)
      .where(
        and(
          eq(cropCalendarEvents.farmOwnerId, farmOwnerId),
          eq(cropCalendarEvents.id, id),
        ),
      ),
};
