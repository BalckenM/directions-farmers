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


export const payrollContractsRepo = {
  listContracts: (farmOwnerId: string, employeeId: string) =>
    db
      .select()
      .from(payrollContracts)
      .where(
        and(
          eq(payrollContracts.farmOwnerId, farmOwnerId),
          eq(payrollContracts.employeeId, employeeId),
        ),
      ),


  createContract: (data: typeof payrollContracts.$inferInsert) =>
    db.insert(payrollContracts).values(data),

};
