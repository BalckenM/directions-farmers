import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollPieceworkLogs } from "../../db/schema";


export const payrollPieceworkRepo = {
  listPieceworkLogs: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollPieceworkLogs)
      .where(eq(payrollPieceworkLogs.farmOwnerId, farmOwnerId))
      .orderBy(desc(payrollPieceworkLogs.workDate)),


  createPieceworkLog: (data: typeof payrollPieceworkLogs.$inferInsert) =>
    db.insert(payrollPieceworkLogs).values(data),


  deletePieceworkLog: (farmOwnerId: string, id: string) =>
    db
      .delete(payrollPieceworkLogs)
      .where(
        and(
          eq(payrollPieceworkLogs.farmOwnerId, farmOwnerId),
          eq(payrollPieceworkLogs.id, id),
        ),
      ),

};
