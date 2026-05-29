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


export const payrollDeductionsRepo = {
  listDeductionRules: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollDeductionRules)
      .where(eq(payrollDeductionRules.farmOwnerId, farmOwnerId)),


  createDeductionRule: (data: typeof payrollDeductionRules.$inferInsert) =>
    db.insert(payrollDeductionRules).values(data),


  updateDeductionRule: (
    farmOwnerId: string,
    id: string,
    data: Partial<typeof payrollDeductionRules.$inferInsert>,
  ) =>
    db
      .update(payrollDeductionRules)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(payrollDeductionRules.farmOwnerId, farmOwnerId),
          eq(payrollDeductionRules.id, id),
        ),
      ),


  deactivateDeductionRule: (farmOwnerId: string, id: string) =>
    db
      .update(payrollDeductionRules)
      .set({ isActive: false, updatedAt: new Date() })
      .where(
        and(
          eq(payrollDeductionRules.farmOwnerId, farmOwnerId),
          eq(payrollDeductionRules.id, id),
        ),
      ),

};
