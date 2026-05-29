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


export const payrollTransactionsRepo = {
  listTransactions: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollTransactions)
      .where(eq(payrollTransactions.farmOwnerId, farmOwnerId))
      .orderBy(desc(payrollTransactions.transactionDate)),

  // Flat contract list (all employees)
};
