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


export const payrollContractsFlatRepo = {
  // Flat contract list (all employees)
  listAllContracts: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollContracts)
      .where(eq(payrollContracts.farmOwnerId, farmOwnerId))
      .orderBy(desc(payrollContracts.createdAt)),


  voidContract: (
    farmOwnerId: string,
    id: string,
    data: Partial<typeof payrollContracts.$inferInsert>,
  ) =>
    db
      .update(payrollContracts)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(payrollContracts.farmOwnerId, farmOwnerId),
          eq(payrollContracts.id, id),
        ),
      ),
};
