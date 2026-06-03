import { eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollLeaveBalances, payrollLeaveTypes } from "../../db/schema";

export const payrollLeaveBalancesService = {
  listLeaveBalances: async (farmOwnerId: string) => {
    const rows = await db
      .select({
        id: payrollLeaveBalances.id,
        employeeId: payrollLeaveBalances.employeeId,
        leaveTypeId: payrollLeaveBalances.leaveTypeId,
        leaveTypeCode: payrollLeaveTypes.code,
        leaveTypeName: payrollLeaveTypes.name,
        totalEntitled: payrollLeaveBalances.totalEntitled,
        taken: payrollLeaveBalances.taken,
        pending: payrollLeaveBalances.pending,
        asOfDate: payrollLeaveBalances.asOfDate,
      })
      .from(payrollLeaveBalances)
      .leftJoin(
        payrollLeaveTypes,
        eq(payrollLeaveBalances.leaveTypeId, payrollLeaveTypes.id),
      )
      .where(eq(payrollLeaveBalances.farmOwnerId, farmOwnerId));
    const toIso = (v: unknown) =>
      v instanceof Date ? v.toISOString() : v ? String(v) : null;
    return rows.map((r) => ({
      id: r.id,
      employeeId: r.employeeId,
      leaveTypeId: r.leaveTypeId,
      leaveTypeCode: r.leaveTypeCode ?? "",
      leaveTypeName: r.leaveTypeName ?? "",
      totalEntitled: parseFloat(String(r.totalEntitled ?? 0)),
      taken: parseFloat(String(r.taken ?? 0)),
      pending: parseFloat(String(r.pending ?? 0)),
      asOfDate: toIso(r.asOfDate),
    }));
  },
};
