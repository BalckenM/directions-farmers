import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollLeaveRequests } from "../../db/schema";


export const payrollLeaveRequestsRepo = {
  listLeaveRequests: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollLeaveRequests)
      .where(eq(payrollLeaveRequests.farmOwnerId, farmOwnerId))
      .orderBy(desc(payrollLeaveRequests.createdAt)),


  createLeaveRequest: (data: typeof payrollLeaveRequests.$inferInsert) =>
    db.insert(payrollLeaveRequests).values(data),


  updateLeaveRequest: (
    farmOwnerId: string,
    id: string,
    data: Partial<typeof payrollLeaveRequests.$inferInsert>,
  ) =>
    db
      .update(payrollLeaveRequests)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(payrollLeaveRequests.farmOwnerId, farmOwnerId),
          eq(payrollLeaveRequests.id, id),
        ),
      ),


  deleteLeaveRequest: (farmOwnerId: string, id: string) =>
    db
      .delete(payrollLeaveRequests)
      .where(
        and(
          eq(payrollLeaveRequests.farmOwnerId, farmOwnerId),
          eq(payrollLeaveRequests.id, id),
        ),
      ),

};
