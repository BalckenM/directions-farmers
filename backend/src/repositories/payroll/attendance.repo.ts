import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollAttendanceRecords } from "../../db/schema";

export const payrollAttendanceRepo = {
  list: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(payrollAttendanceRecords)
        .where(eq(payrollAttendanceRecords.farmOwnerId, farmOwnerId))
        .orderBy(desc(payrollAttendanceRecords.attendanceDate))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(payrollAttendanceRecords)
        .where(eq(payrollAttendanceRecords.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },

  findById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(payrollAttendanceRecords)
      .where(
        and(
          eq(payrollAttendanceRecords.farmOwnerId, farmOwnerId),
          eq(payrollAttendanceRecords.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  create: (data: any) => db.insert(payrollAttendanceRecords).values(data),

  update: (farmOwnerId: string, id: string, data: any) =>
    db
      .update(payrollAttendanceRecords)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(payrollAttendanceRecords.farmOwnerId, farmOwnerId),
          eq(payrollAttendanceRecords.id, id),
        ),
      ),
};
