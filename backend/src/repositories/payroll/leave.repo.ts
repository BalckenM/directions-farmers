import { and, eq, or } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollLeaveBalances, payrollLeaveTypes } from "../../db/schema";


export const payrollLeaveRepo = {
  listLeaveTypes: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollLeaveTypes)
      .where(
        or(
          eq(payrollLeaveTypes.farmOwnerId, farmOwnerId),
          eq(payrollLeaveTypes.farmOwnerId, "system"),
        ),
      ),


  createLeaveType: (data: typeof payrollLeaveTypes.$inferInsert) =>
    db.insert(payrollLeaveTypes).values(data),


  findLeaveBalance: (
    farmOwnerId: string,
    employeeId: string,
    leaveTypeId: string,
  ) =>
    db
      .select()
      .from(payrollLeaveBalances)
      .where(
        and(
          eq(payrollLeaveBalances.farmOwnerId, farmOwnerId),
          eq(payrollLeaveBalances.employeeId, employeeId),
          eq(payrollLeaveBalances.leaveTypeId, leaveTypeId),
        ),
      )
      .then((r) => r[0] ?? null),

};
