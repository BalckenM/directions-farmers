import { and, count, desc, eq, or } from "drizzle-orm";
import { db } from "../../config/database";
import {
    payrollAuditLog,
    payrollCommunications,
    payrollComplianceAlerts,
    payrollContracts,
    payrollDeductionRules,
    payrollEmployees,
    payrollGarnisheeOrders,
    payrollIncidents,
    payrollLeaveBalances,
    payrollLeaveRequests,
    payrollLeaveTypes,
    payrollPayGroups,
    payrollPayRuns,
    payrollPayslips,
    payrollPayStructures,
    payrollPieceworkLogs,
    payrollTransactions,
} from "../../db/schema";


export const payrollEmployeesRepo = {
  listEmployees: async (farmOwnerId: string, offset: number, limit: number) => {
    const [rows, total] = await Promise.all([
      db
        .select()
        .from(payrollEmployees)
        .where(eq(payrollEmployees.farmOwnerId, farmOwnerId))
        .orderBy(desc(payrollEmployees.createdAt))
        .limit(limit)
        .offset(offset),
      db
        .select({ count: count() })
        .from(payrollEmployees)
        .where(eq(payrollEmployees.farmOwnerId, farmOwnerId))
        .then((r) => r[0]?.count ?? 0),
    ]);
    return { rows, total };
  },


  findEmployeeById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(payrollEmployees)
      .where(
        and(
          eq(payrollEmployees.farmOwnerId, farmOwnerId),
          eq(payrollEmployees.id, id),
        ),
      )
      .then((r) => r[0] ?? null),


  createEmployee: (data: typeof payrollEmployees.$inferInsert) =>
    db.insert(payrollEmployees).values(data),


  updateEmployee: (
    farmOwnerId: string,
    id: string,
    data: Partial<typeof payrollEmployees.$inferInsert>,
  ) =>
    db
      .update(payrollEmployees)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(payrollEmployees.farmOwnerId, farmOwnerId),
          eq(payrollEmployees.id, id),
        ),
      ),


  deleteEmployee: (farmOwnerId: string, id: string) =>
    db
      .delete(payrollEmployees)
      .where(
        and(
          eq(payrollEmployees.farmOwnerId, farmOwnerId),
          eq(payrollEmployees.id, id),
        ),
      ),

};
